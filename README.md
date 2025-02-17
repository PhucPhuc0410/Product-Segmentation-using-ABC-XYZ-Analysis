# ABC-XYZ Analysis for Product Segmentation

---

## Overview

This project applies ABC-XYZ Analysis to segment products based on sales performance and demand variability. The analysis helps businesses identify high-value products, optimize inventory, and improve supply chain management.

## Dataset

The analysis is performed using the `FactResellerSales` and `DimProduct` tables, which contain transactional data related to reseller purchases.

**Source:** `AdventureWorksDW2022` which you can download [here](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms)

## Tools Used

- **SQL Server Management Studio (SSMS)** for querying and data processing.
- **Power BI** for data visualization and insights.
- **Python** for querying and data processing, and data visualization.

*Even though SQL and Power BI are sufficient for these tasks. However, I incorporated Python to expand the project scope.*

## Data Cleaning and Preparation

- Removing duplicate transactions.
- Handling missing values in `SalesAmount` and `OrderDate`.
- Aggregating sales data per product for meaningful segmentation.

## ABC Analysis: Revenue Contribution
ABC Analysis segments products based on their contribution to total revenue:

1. **Category A**: Top 40% revenue contributors.
2. **Category B**: Next 40% revenue contributors.
3. **Category C**: Bottom 20% revenue contributors.

### SQL Implementation:
```sql
DECLARE @Total_sales FLOAT;
SET @Total_sales = (
    SELECT SUM(SalesAmount) FROM FactResellerSales
);

DECLARE @Num_of_product FLOAT;
SET @Num_of_product = (
    SELECT COUNT(DISTINCT ProductKey) FROM FactResellerSales
);

DROP TABLE IF EXISTS #Product_Sales;
SELECT 
    PRO.ProductKey,
    PRO.EnglishProductName,
    SUM(FACT.SalesAmount) AS Total_Sales_Amount,
    SUM(FACT.SalesAmount) / @Total_sales * 100 AS Percent_Revenue 
INTO #Product_Sales
FROM FactResellerSales FACT
JOIN DimProduct PRO 
ON FACT.ProductKey = PRO.ProductKey
GROUP BY PRO.ProductKey, PRO.EnglishProductName;
```

## XYZ Analysis: Demand Variability
XYZ Analysis categorizes products based on sales consistency:

1. **Category X**: Low variability (Coefficient of Variation ≤ 10%).
2. **Category Y**: Moderate variability (10% < Coefficient of Variation ≤ 25%).
3. **Category Z**: High variability (> 25%).

### SQL Implementation:
```sql
DROP TABLE IF EXISTS #Product_Sales_Per_Month;
SELECT 
    PRO.ProductKey,
    PRO.EnglishProductName,
    YEAR(FACT.OrderDate) AS SalesYear,
    MONTH(FACT.OrderDate) AS SalesMonth,
    SUM(FACT.SalesAmount) AS MonthlySales
INTO #Product_Sales_Per_Month
FROM FactResellerSales FACT
JOIN DimProduct PRO ON FACT.ProductKey = PRO.ProductKey
GROUP BY PRO.ProductKey, PRO.EnglishProductName, YEAR(FACT.OrderDate), MONTH(FACT.OrderDate);

DROP TABLE IF EXISTS #XYZ_Analysis;
SELECT 
    PRO.ProductKey,
    PRO.EnglishProductName,
    AVG(PSPM.MonthlySales) AS Avg_Sales,
    STDEV(PSPM.MonthlySales) AS STDV_Sales,  
    CASE 
        WHEN AVG(PSPM.MonthlySales) = 0 THEN NULL 
        ELSE STDEV(PSPM.MonthlySales) * 100 / NULLIF(AVG(PSPM.MonthlySales), 0) 
    END AS Coefficient_Variation 
INTO #XYZ_Analysis
FROM #Product_Sales_Per_Month PSPM
JOIN DimProduct PRO 
ON PSPM.ProductKey = PRO.ProductKey
GROUP BY PRO.ProductKey, PRO.EnglishProductName;
```

## Merging ABC and XYZ Analysis
```sql
DROP TABLE IF EXISTS #ABC_XYZ_Analysis;
SELECT
    ABC.ProductKey,
    ABC.EnglishProductName,
    ABC.Cumulative_Percent_Item,
    ABC.Cumulative_Percent_Revenue,
    XYZ.STDV_Sales,
    XYZ.Coefficient_Variation,
    CASE
        WHEN ABC.Cumulative_Percent_Revenue <= 40 THEN 'A'
        WHEN ABC.Cumulative_Percent_Revenue <= 80 THEN 'B'
        ELSE 'C'
    END AS ABC_Analysis,
    CASE
        WHEN XYZ.Coefficient_Variation <= 10 THEN 'X'
        WHEN XYZ.Coefficient_Variation <= 25 THEN 'Y'
        ELSE 'Z'
    END AS XYZ_Analysis
INTO #ABC_XYZ_Analysis
FROM #ABC_Analysis ABC
JOIN #XYZ_Analysis XYZ
ON ABC.ProductKey = XYZ.ProductKey;

SELECT * FROM #ABC_XYZ_Analysis;
```

## Application
- **Inventory Optimization**: Ensure availability of high-value, low-variability (AX) products while adjusting stock for high-variability (BZ, CZ) items.
- **Sales Strategy**: Promote and bundle underperforming products (CZ) with high-revenue items (AX, AY).
- **Marketing Focus**: Target price-sensitive customers with stable (BX, CX) products and create dynamic pricing for fluctuating (BZ, CZ) items.

## Recommendations
- **Enhance customer loyalty**: Focus on high-revenue (A) and low-variability (X) products.
- **Optimize inventory for fluctuating demand**: Adjust stock for (Z) category products.
- **Improve supply chain planning**: Ensure consistent availability of (AX, BX) products while dynamically managing (CZ) items.

## Limitations
- Analysis is based on historical data and may not predict future trends.
- External factors such as seasonality and market fluctuations are not considered.
- Regular updates are needed to maintain accuracy.

If you find this project useful, feel free to ⭐. Your support will be my super motivation ❤️.

📌 **Author:** Nguyễn Hoàng Gia Phúc  
📧 **Contact:** nguyenhoanggiaphucwork@gmail.com
🔗 **LinkedIn:** [Nguyen Hoang Gia Phuc](https://www.linkedin.com/in/nguyenhoanggiaphuc)
