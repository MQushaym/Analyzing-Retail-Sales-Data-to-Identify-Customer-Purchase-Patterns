
# Analyzing Retail Sales Data in R

![Language](https://img.shields.io/badge/Language-R-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

This project is a comprehensive analysis of a raw retail sales dataset. The primary goal is to apply data cleaning, analysis, and visualization techniques in R to uncover customer purchase patterns, identify top-selling products, and discover seasonal trends.

This was submitted as a requirement for the **ISY 356: Big Data** course at King Saud University.

## Table of Contents

- [Project Overview](#project-overview)
- [Dataset Description](#dataset-description)
- [Methodology & Workflow](#methodology--workflow)
  - [1. Data Cleaning & Preprocessing](#1-data-cleaning--preprocessing)
  - [2. Feature Engineering](#2-feature-engineering)
  - [3. Analysis & Visualization](#3-analysis--visualization)
- [Key Findings](#key-findings)
- [How to Run This Project](#how-to-run-this-project)
- [Author](#author)
- [License](#license)

---

## Project Overview

The project follows a complete data analysis workflow:
1.  **Load** a raw, messy CSV file.
2.  **Diagnose** and **clean** the data using a professional, multi-stage process.
3.  **Analyze** the cleaned data to find insights.
4.  **Visualize** the findings using `ggplot2`.

## Dataset Description

The project uses a raw `retail_sales.csv` file containing 500 records of sales transactions. The data was incomplete and required significant cleaning before analysis.

**Initial Schema:**
* `CustomerID`: Unique customer ID (string).
* `ProductID`: Unique product ID (string).
* `Category`: Product category (string).
* `Quantity`: Number of items purchased (numeric).
* `Price`: Price per item (numeric).
* `PurchaseDate`: Date of the sale (date).
* `Region`: Customer location (string).

## Methodology & Workflow

This project's focus was a robust and "defensive" data cleaning process.

### 1. Data Cleaning & Preprocessing

The raw data contained several critical quality issues: `NA` values, blank strings (`""`), inconsistent casing, and potential duplicate records.

* **Handling `NA` Values (The Smart Fix):**
    * Instead of deleting all 47 rows with `NA`s, we investigated. We found only 3 rows were missing *both* `Price` and `Quantity` (which were deleted).
    * For the 22 rows missing only `Price`, we implemented a **two-stage imputation**:
        1.  **Stage 1 (Smart):** We filled `NA`s using the product-specific median (based on `ProductID`).
        2.  **Stage 2 (Safe):** For the 10 products with no price data at all, we used the **global median price** to fill the remaining `NA`s.
    * The 22 rows missing `Quantity` were imputed with the global median.

* **Handling Blank Strings (`""`):**
    * Blank strings (`""`) in `Category` and `Region` were not deleted. They were converted to an `"unknown"` category. This preserves the data while acknowledging the quality issue.

* **Standardization & Duplicates:**
    * All text data was converted to lowercase and whitespace was trimmed.
    * Duplicate rows were removed using `!duplicated()`.
    * `Quantity` was converted to an `integer`.

### 2. Feature Engineering

Two new columns were created to enable analysis:
1.  `TotalSale`: The most critical feature, engineered by multiplying `Quantity * Price`.
2.  `Month`: Extracted from `PurchaseDate` using `lubridate` for trend analysis.

### 3. Analysis & Visualization

Data was aggregated using `data.table` to find total sales by product, category, region, and month. All findings were then visualized using `ggplot2`.

---

## Key Findings

The analysis of the cleaned data (497 unique transactions) revealed:

1.  **Top Category:** `Groceries` is the highest-grossing category.
2.  **Top Product:** Product `P607` is the #1 revenue generator.
3.  **Top Region:** The `East` region leads in total sales.
4.  **Sales Trend:** Sales peak in January (Month 1) and July (Month 7), with a significant dip in February (Month 2).


---

## How to Run This Project

### 1. Prerequisites
* R (version 4.0 or higher)
* RStudio

### 2. Clone the Repository
```bash
git clone [https://github.com/YOUR_USERNAME/YOUR_REPOSITORY_NAME.git](https://github.com/YOUR_USERNAME/YOUR_REPOSITORY_NAME.git)
cd YOUR_REPOSITORY_NAME
````

### 3\. Install Dependencies

This project requires the following R packages. You can install them by running this command in your R console:

```r
install.packages(c("dplyr", "tidyr", "data.table", "ggplot2", "lubridate"))
```

### 4\. Run the Script

1.  Open `BigData_Project_Script.R` in RStudio.
2.  **IMPORTANT:** Update the file path for `retail_sales.csv` on line 18 to its location on your computer.
3.  Run the script from top to bottom (or `Source` the file). The final plots will be generated in the 'Plots' pane.

-----

## Author

  * **Mashal bin Falah Al Qushaym**
  * Student ID: 443170206
  * King Saud University

## License

This project is licensed under the MIT License.

```
```
