/* ============================================================
   AMAZON INDIA SALES ANALYTICS PROJECT
   Dataset: Amazon_Sales_2025_INR
   Database: amazon_analytics
   Period: January 2025 - December 2025
   ============================================================ */


/* ============================================================
   1. DATABASE
   ============================================================ */

CREATE DATABASE IF NOT EXISTS amazon_analytics;

USE amazon_analytics;

SELECT * FROM amazon_sales_2025_inr;

/* ============================================================
   2. BASIC DATA AUDIT
   ============================================================ */

-- Total number of rows
SELECT COUNT(*) AS total_rows
FROM amazon_sales_2025_inr;


-- Date range
SELECT
    MIN(Date) AS earliest_date,
    MAX(Date) AS latest_date
FROM amazon_sales_2025_inr;


-- Distinct orders
SELECT COUNT(DISTINCT Order_ID) AS distinct_orders
FROM amazon_sales_2025_inr;


-- Check for NULL values across important fields
SELECT
    SUM(Order_ID IS NULL) AS null_order_id,
    SUM(Date IS NULL) AS null_date,
    SUM(Customer_ID IS NULL) AS null_customer_id,
    SUM(Product_Category IS NULL) AS null_product_category,
    SUM(Product_Name IS NULL) AS null_product_name,
    SUM(Quantity IS NULL) AS null_quantity,
    SUM(Unit_Price_INR IS NULL) AS null_unit_price,
    SUM(Total_Sales_INR IS NULL) AS null_total_sales,
    SUM(Net_Sales_INR IS NULL) AS null_net_sales,
    SUM(Payment_Method IS NULL) AS null_payment_method,
    SUM(Delivery_Status IS NULL) AS null_delivery_status,
    SUM(Extra_Charges IS NULL) AS null_extra_charges,
    SUM('Return Amount_INR' IS NULL) AS null_return_amount,
    SUM(Review_Rating IS NULL) AS null_review_rating,
    SUM(State IS NULL) AS null_state,
    SUM(Country IS NULL) AS null_country
FROM amazon_sales_2025_inr;


-- Available payment methods
SELECT DISTINCT Payment_Method
FROM amazon_sales_2025_inr;


-- Available delivery statuses
SELECT DISTINCT Delivery_Status
FROM amazon_sales_2025_inr;


-- Available product categories
SELECT DISTINCT Product_Category
FROM amazon_sales_2025_inr;


-- Available countries
SELECT DISTINCT Country
FROM amazon_sales_2025_inr;


/* ============================================================
   3. DATE CONVERSION
   Original Date column is stored as DD-MM-YYYY text.
   ============================================================ */

ALTER TABLE amazon_sales_2025_inr
ADD COLUMN Order_Date DATE;


UPDATE amazon_sales_2025_inr
SET Order_Date = STR_TO_DATE(Date, '%d-%m-%Y');


/* ============================================================
   4. EXECUTIVE KPI ANALYSIS
   ============================================================ */

SELECT
    COUNT(DISTINCT Order_ID) AS total_orders,
    COUNT(DISTINCT Customer_ID) AS total_customers,
    SUM(Quantity) AS total_units,
    ROUND(SUM(Total_Sales_INR), 2) AS gross_sales,
    ROUND(SUM(Net_Sales_INR), 2) AS net_sales,
    ROUND(
        SUM(Net_Sales_INR) / COUNT(DISTINCT Order_ID),
        2
    ) AS average_order_value,
    ROUND(
        SUM(
            CASE
                WHEN Delivery_Status = 'Returned' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(DISTINCT Order_ID),
        2
    ) AS return_rate
FROM amazon_sales_2025_inr;


/* ============================================================
   5. MONTHLY PERFORMANCE
   ============================================================ */

SELECT
    YEAR(Order_Date) AS year,
    MONTH(Order_Date) AS month,
    MONTHNAME(Order_Date) AS month_name,
    COUNT(DISTINCT Order_ID) AS orders,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Total_Sales_INR), 2) AS gross_sales,
    ROUND(SUM(Net_Sales_INR), 2) AS net_sales,
    ROUND(
        SUM(Net_Sales_INR) / COUNT(DISTINCT Order_ID),
        2
    ) AS aov,
    ROUND(
        SUM(
            CASE
                WHEN Delivery_Status = 'Returned' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(DISTINCT Order_ID),
        2
    ) AS return_rate
FROM amazon_sales_2025_inr
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date),
    MONTHNAME(Order_Date)
ORDER BY
    year,
    month;


/* ============================================================
   6. CATEGORY PERFORMANCE
   ============================================================ */

SELECT
    Product_Category,
    COUNT(DISTINCT Order_ID) AS orders,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Total_Sales_INR), 2) AS gross_sales,
    ROUND(SUM(Net_Sales_INR), 2) AS net_sales,
    ROUND(AVG(Review_Rating), 2) AS avg_rating,
    SUM(
        CASE
            WHEN Delivery_Status = 'Returned' THEN 1
            ELSE 0
        END
    ) AS returned_orders,
    ROUND(
        SUM(
            CASE
                WHEN Delivery_Status = 'Returned' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(DISTINCT Order_ID),
        2
    ) AS return_rate
FROM amazon_sales_2025_inr
GROUP BY Product_Category
ORDER BY net_sales DESC;


/* ============================================================
   7. PRODUCT PERFORMANCE
   ============================================================ */

SELECT
    Product_Category,
    Product_Name,
    COUNT(DISTINCT Order_ID) AS orders,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Total_Sales_INR), 2) AS gross_sales,
    ROUND(SUM(Net_Sales_INR), 2) AS net_sales,
    ROUND(AVG(Review_Rating), 2) AS avg_rating,
    SUM(
        CASE
            WHEN Delivery_Status = 'Returned' THEN 1
            ELSE 0
        END
    ) AS returned_orders,
    ROUND(
        SUM(
            CASE
                WHEN Delivery_Status = 'Returned' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(DISTINCT Order_ID),
        2
    ) AS return_rate
FROM amazon_sales_2025_inr
GROUP BY
    Product_Category,
    Product_Name
ORDER BY net_sales DESC;


/* ============================================================
   8. TOP PRODUCTS
   ============================================================ */

SELECT
    Product_Name,
    Product_Category,
    COUNT(DISTINCT Order_ID) AS orders,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Net_Sales_INR), 2) AS net_revenue
FROM amazon_sales_2025_inr
GROUP BY
    Product_Name,
    Product_Category
ORDER BY net_revenue DESC
LIMIT 20;


/* ============================================================
   9. CUSTOMER ORDER FREQUENCY
   ============================================================ */

SELECT
    order_count,
    COUNT(*) AS customers
FROM (
    SELECT
        Customer_ID,
        COUNT(*) AS order_count
    FROM amazon_sales_2025_inr
    GROUP BY Customer_ID
) t
GROUP BY order_count
ORDER BY order_count;


/* ============================================================
   10. CUSTOMER PERFORMANCE / AOV
   ============================================================ */

SELECT
    Customer_ID,
    COUNT(*) AS orders,
    SUM(Quantity) AS units_purchased,
    ROUND(SUM(Net_Sales_INR), 2) AS net_revenue,
    ROUND(
        SUM(Net_Sales_INR) / COUNT(*),
        2
    ) AS aov,
    CASE
        WHEN COUNT(*) = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type
FROM amazon_sales_2025_inr
GROUP BY Customer_ID;


/* ============================================================
   11. ONE-TIME VS REPEAT CUSTOMERS
   ============================================================ */

SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS customers,
    SUM(order_count) AS orders,
    ROUND(SUM(net_revenue), 2) AS net_revenue,
    ROUND(
        SUM(net_revenue) / SUM(order_count),
        2
    ) AS aov
FROM (
    SELECT
        Customer_ID,
        COUNT(DISTINCT Order_ID) AS order_count,
        SUM(Net_Sales_INR) AS net_revenue
    FROM amazon_sales_2025_inr
    GROUP BY Customer_ID
) t
GROUP BY customer_type;


/* ============================================================
   12. STATE PERFORMANCE
   ============================================================ */

SELECT
    State,
    COUNT(DISTINCT Order_ID) AS orders,
    COUNT(DISTINCT Customer_ID) AS customers,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Net_Sales_INR), 2) AS net_revenue,
    ROUND(
        SUM(Net_Sales_INR) / COUNT(DISTINCT Order_ID),
        2
    ) AS aov,
    ROUND(
        SUM(
            CASE
                WHEN Delivery_Status = 'Returned' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(DISTINCT Order_ID),
        2
    ) AS return_rate
FROM amazon_sales_2025_inr
GROUP BY State
ORDER BY net_revenue DESC;


/* ============================================================
   13. TABLEAU VIEW — EXECUTIVE KPIs
   ============================================================ */

CREATE OR REPLACE VIEW vw_executive_kpis AS
SELECT
    COUNT(DISTINCT Order_ID) total_orders,
    COUNT(DISTINCT Customer_ID) total_customers,
    SUM(Quantity) total_units,
    ROUND(SUM(Total_Sales_INR),2) gross_sales,
    ROUND(SUM(Net_Sales_INR),2) net_sales,
    ROUND(
        SUM(Net_Sales_INR) / COUNT(DISTINCT Order_ID),
        2
    ) average_order_value,
    ROUND(
        SUM(
            CASE
                WHEN Delivery_Status='Returned' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(DISTINCT Order_ID),
        2
    ) return_rate
FROM amazon_sales_2025_inr;


/* ============================================================
   14. TABLEAU VIEW — MONTHLY PERFORMANCE
   ============================================================ */

CREATE OR REPLACE VIEW vw_monthly_performance AS
SELECT
    YEAR(Order_Date) AS year,
    MONTH(Order_Date) AS month,
    MONTHNAME(Order_Date) AS month_name,
    COUNT(DISTINCT Order_ID) AS orders,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Total_Sales_INR),2) AS gross_sales,
    ROUND(SUM(Net_Sales_INR),2) AS net_sales,
    ROUND(
        SUM(Net_Sales_INR) / COUNT(DISTINCT Order_ID),
        2
    ) AS aov,
    ROUND(
        SUM(
            CASE
                WHEN Delivery_Status='Returned' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(DISTINCT Order_ID),
        2
    ) AS return_rate
FROM amazon_sales_2025_inr
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date),
    MONTHNAME(Order_Date);


/* ============================================================
   15. TABLEAU VIEW — PRODUCT PERFORMANCE
   ============================================================ */

CREATE OR REPLACE VIEW vw_product_performance AS
SELECT
    Product_Category,
    Product_Name,
    COUNT(DISTINCT Order_ID) AS orders,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Total_Sales_INR),2) AS gross_sales,
    ROUND(SUM(Net_Sales_INR),2) AS net_sales,
    ROUND(AVG(Review_Rating),2) AS avg_rating,
    SUM(
        CASE
            WHEN Delivery_Status='Returned' THEN 1
            ELSE 0
        END
    ) AS returned_orders,
    ROUND(
        SUM(
            CASE
                WHEN Delivery_Status='Returned' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(DISTINCT Order_ID),
        2
    ) AS return_rate
FROM amazon_sales_2025_inr
GROUP BY
    Product_Category,
    Product_Name;


/* ============================================================
   16. TABLEAU VIEW — CUSTOMER PERFORMANCE
   ============================================================ */

CREATE OR REPLACE VIEW vw_customer_performance AS
SELECT
    Customer_ID,
    COUNT(DISTINCT Order_ID) AS order_count,
    SUM(Quantity) AS units_purchased,
    ROUND(SUM(Net_Sales_INR),2) AS net_revenue,
    ROUND(
        SUM(Net_Sales_INR) / COUNT(DISTINCT Order_ID),
        2
    ) AS aov,
    CASE
        WHEN COUNT(DISTINCT Order_ID) = 1
            THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type
FROM amazon_sales_2025_inr
GROUP BY Customer_ID;


/* ============================================================
   17. TABLEAU VIEW — STATE PERFORMANCE
   ============================================================ */

CREATE OR REPLACE VIEW vw_state_performance AS
SELECT
    State,
    COUNT(DISTINCT Order_ID) AS orders,
    COUNT(DISTINCT Customer_ID) AS customers,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Net_Sales_INR),2) AS net_revenue,
    ROUND(
        SUM(Net_Sales_INR) / COUNT(DISTINCT Order_ID),
        2
    ) AS aov,
    ROUND(
        SUM(
            CASE
                WHEN Delivery_Status='Returned' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(DISTINCT Order_ID),
        2
    ) AS return_rate
FROM amazon_sales_2025_inr
GROUP BY State;


/* ============================================================
   END OF AMAZON SALES ANALYTICS PROJECT
   ============================================================ */