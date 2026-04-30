# 🍽️ Swiggy Data Analysis & Data Warehouse Project

## 📌 Project Overview

This project focuses on **data cleaning, transformation, and analytical reporting** using a Swiggy dataset. It demonstrates how raw transactional data can be converted into a structured **data warehouse (Star Schema)** and used for **business insights and KPI analysis**.

---

## 🧰 Tech Stack

* SQL (T-SQL)
* Relational Database (SQL Server / compatible systems)

---

## 📂 Dataset

The dataset (`swiggy_data`) contains food order details such as:

* State, City, Location
* Restaurant Name
* Dish Name & Category
* Order Date
* Price (INR)
* Rating & Rating Count

---

## 🧹 Data Cleaning & Validation

### ✔ Null Value Check

* Identified missing values in all key columns like state, city, price, rating, etc.

### ✔ Empty String Handling

* Checked for blank values in categorical fields.

### ✔ Duplicate Removal

* Used `ROW_NUMBER()` with CTE to detect and delete duplicate records.

---

## 🏗️ Data Warehouse Design

### ⭐ Star Schema Model

#### Dimension Tables:

* `dim_date` → Date-related attributes (year, month, quarter, etc.)
* `dim_location` → State, city, and location
* `dim_restaurant` → Restaurant details
* `dim_dish` → Dish names
* `dim_category` → Food categories

#### Fact Table:

* `fact_swiggy_orders` → Central table storing:

  * Price
  * Rating
  * Rating Count
  * Foreign keys to all dimension tables

---

## 🔄 ETL Process

1. Extracted data from `swiggy_data`
2. Transformed:

   * Removed duplicates
   * Structured into dimensions
3. Loaded:

   * Inserted into dimension tables
   * Mapped and inserted into fact table using joins

---

## 📊 Key Performance Indicators (KPIs)

* 📦 **Total Orders**
* 💰 **Total Revenue**
* 💵 **Average Dish Price**
* ⭐ **Average Rating**

---

## 📈 Business Insights

### 📅 Monthly Order Trends

* Analyzed order volume across months

### 💰 Monthly Revenue Trends

* Revenue grouped by year and month

---

## 🔍 Sample Analysis Queries

* Total Orders:

```sql
SELECT COUNT(order_id) AS total_orders FROM fact_swiggy_orders;
```

* Revenue:

```sql
SELECT SUM(price_inr) AS revenue FROM fact_swiggy_orders;
```

* Average Rating:

```sql
SELECT AVG(rating) AS avg_rating FROM fact_swiggy_orders;
```

---

## 🚀 Key Learnings

* Data cleaning techniques in SQL
* Handling duplicates using window functions
* Designing a **star schema**
* Building ETL pipelines using SQL
* Performing business-level analytics

---

## 📌 How to Use

1. Run the script in SQL Server / compatible DB
2. Ensure `swiggy_data` table exists with proper data
3. Execute queries step-by-step:

   * Data Cleaning
   * Table Creation
   * Data Insertion
   * Analysis Queries

---

## 📬 Future Improvements

* Add indexes for performance optimization
* Build dashboards (Power BI / Tableau)
* Automate ETL pipeline
* Add advanced analytics (Top restaurants, best dishes, etc.)

---

## 👩‍💻 Author

**Shakeela Shaik**

---

