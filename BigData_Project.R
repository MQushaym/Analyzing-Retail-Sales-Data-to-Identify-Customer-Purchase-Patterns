# ===================================================================
# PROJECT: Analyzing Retail Sales Data (ISY 356)
# AUTHOR:  Mashal bin Falah Al Qushaym (443170206)
# DATE:    November 8, 2025
# ===================================================================


# --- 1. LOAD LIBRARIES ---
# -------------------------------------------------------------------
# Install necessary packages if they are not already installed
install.packages(c("dplyr", "tidyr", "data.table", "ggplot2", "lubridate"))

# Load libraries into the session
library(dplyr)
library(tidyr)
library(data.table)
library(ggplot2)
library(lubridate)

print("Libraries loaded successfully.")


# --- 2. DATA COLLECTION & INITIAL ASSESSMENT ---
# -------------------------------------------------------------------
# Set your working directory path here
# setwd("YOUR_WORKING_DIRECTORY_PATH")

# 2.1. Load the Data
# NOTE: Update this path to the location of the file on your computer
sales_data <- fread("YOUR_PATH_HERE/retail_sales.csv")

# 2.2. Initial Diagnostic
# (In RStudio, you would typically run these lines interactively)
print("--- Initial Data Structure ---")
str(sales_data)
print("--- Initial Data Summary ---")
summary(sales_data)


# --- 3. DATA CLEANING METHODOLOGY ---
# -------------------------------------------------------------------
# Create a copy to work on, preserving the original
sales_data_cleaned <- copy(sales_data)

# 3.1. Standardize Categorical Data
# Standardize text to lowercase and trim whitespace
text_cols <- c("Category", "Region")
sales_data_cleaned[, (text_cols) := lapply(.SD, function(x) tolower(trimws(x))), .SDcols = text_cols]

# 3.2. Handle Empty Strings ("")
# Replace blank strings with "unknown" for clear classification
sales_data_cleaned[Category == "", Category := "unknown"]
sales_data_cleaned[Region == "", Region := "unknown"]

# 3.3. Handle Missing Numerical Data (NA)
# Based on our analysis (3 rows missing both, 22 Price-only, 22 Qty-only)

# 3.3.1. Delete unsalvageable rows (missing both Price and Quantity)
sales_data_cleaned <- sales_data_cleaned[!(is.na(Quantity) & is.na(Price))]

# 3.3.2. Two-Stage Imputation for 'Price'
# Stage 1 (Smart Imputation): Use ProductID-specific median
sales_data_cleaned[, MedianPrice := median(Price, na.rm = TRUE), by = ProductID]
sales_data_cleaned[is.na(Price), Price := MedianPrice]
sales_data_cleaned[, MedianPrice := NULL] # Remove temporary column

# Stage 2 (Safe Imputation): Use Global Median for products with no price data
global_median_price <- median(sales_data_cleaned$Price, na.rm = TRUE)
sales_data_cleaned[is.na(Price), Price := global_median_price]

# 3.3.3. Imputation for 'Quantity' (Use Global Median)
median_quantity <- as.integer(median(sales_data_cleaned$Quantity, na.rm = TRUE))
sales_data_cleaned[is.na(Quantity), Quantity := median_quantity]

# 3.4. Remove Duplicate Records
# Create the final, clean dataset
sales_data_final <- sales_data_cleaned[!duplicated(sales_data_cleaned)]

# 3.5. Correct Data Types
# Ensure 'Quantity' is an integer for data integrity
sales_data_final[, Quantity := as.integer(Quantity)]

# 3.6. Final Verification
print("--- Final Cleaned Data Structure ---")
str(sales_data_final)
print("--- Final Cleaned Data Summary (NA's should be 0) ---")
summary(sales_data_final)


# --- 4. DATA ANALYSIS & FINDINGS ---
# -------------------------------------------------------------------

# 4.1. Feature Engineering: Create TotalSale Column
# This is the central metric for all subsequent analysis
sales_data_final[, TotalSale := Quantity * Price]

# 4.2. Compute Total Sales
total_revenue <- sales_data_final[, sum(TotalSale)]
print(paste("Overall Total Revenue:", total_revenue))

# 4.3. Top Product Analysis
product_sales <- sales_data_final[, .(TotalSalesPerProduct = sum(TotalSale)), by = ProductID]
setorder(product_sales, -TotalSalesPerProduct)
print("--- Top 5 Products by Revenue ---")
print(head(product_sales, 5))

# 4.4. Sales by Category
category_sales <- sales_data_final[, .(TotalSalesPerCategory = sum(TotalSale)), by = Category]
setorder(category_sales, -TotalSalesPerCategory)
print("--- Total Sales by Category (Sorted) ---")
print(category_sales)

# 4.5. Regional Sales Analysis
region_sales <- sales_data_final[, .(TotalSalesPerRegion = sum(TotalSale)), by = Region]
setorder(region_sales, -TotalSalesPerRegion)
print("--- Total Sales by Region (Sorted) ---")
print(region_sales)

# 4.6. Monthly Sales Trend
# Engineer 'Month' feature from PurchaseDate
sales_data_final[, Month := month(PurchaseDate)]
monthly_sales <- sales_data_final[, .(TotalSalesPerMonth = sum(TotalSale)), by = Month]
setorder(monthly_sales, Month)
print("--- Total Sales by Month ---")
print(monthly_sales)


# --- 5. DATA VISUALIZATION (using ggplot2) ---
# -------------------------------------------------------------------
# (In RStudio, the plots will appear in the 'Plots' pane)

# 5.1. Visualization 1: Total Sales by Category
category_plot <- ggplot(category_sales,
                        aes(x = reorder(Category, -TotalSalesPerCategory),
                            y = TotalSalesPerCategory)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(
    title = "Total Sales by Category",
    subtitle = "Ordered from highest to lowest",
    x = "Category",
    y = "Total Sales"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(category_plot)


# 5.2. Visualization 2: Monthly Sales Trend
monthly_plot <- ggplot(monthly_sales,
                       aes(x = Month,
                           y = TotalSalesPerMonth)) +
  geom_line(color = "red", linewidth = 1) +
  geom_point(color = "red", size = 3) +
  labs(
    title = "Total Sales Trend Over the Year",
    subtitle = "Total revenue month by month",
    x = "Month",
    y = "Total Sales"
  ) +
  scale_x_continuous(breaks = 1:12) +
  theme_minimal()

print(monthly_plot)


# 5.3. Visualization 3: Total Sales by Region
region_plot <- ggplot(region_sales,
                      aes(x = reorder(Region, -TotalSalesPerRegion),
                          y = TotalSalesPerRegion)) +
  geom_bar(stat = "identity", fill = "darkgreen") +
  labs(
    title = "Total Sales by Region",
    subtitle = "Ordered from highest to lowest",
    x = "Region",
    y = "Total Sales"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(region_plot)


# 5.4. Visualization 4: Top 10 Products by Revenue
top_10_products <- head(product_sales, 10)

product_plot <- ggplot(top_10_products,
                       aes(x = reorder(ProductID, -TotalSalesPerProduct),
                           y = TotalSalesPerProduct)) +
  geom_bar(stat = "identity", fill = "purple") +
  labs(
    title = "Top 10 Products by Revenue",
    subtitle = "Ordered from highest to lowest",
    x = "Product ID",
    y = "Total Sales"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(product_plot)


# --- END OF SCRIPT ---