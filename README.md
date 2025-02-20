# ABC-XYZ Analysis for Product Segmentation

---

## Overview

This project applies ABC-XYZ Analysis to segment products based on sales performance and demand variability. The analysis helps businesses identify high-value products, optimize inventory, and improve supply chain management.

## Dataset

The analysis is performed using the `FactResellerSales` and `DimProduct` tables, which contain transactional data related to reseller purchases.

**Source:** `AdventureWorksDW2022` which you can download [here](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms)

## Tools Used

- **SQL Server Management Studio (SSMS)** for querying and data processing.

## Data Cleaning and Preparation

- Removing duplicate transactions.
- Handling missing values in `SalesAmount` and `OrderDate`.
- Aggregating sales data per product for meaningful segmentation.

## ABC Analysis
ABC Analysis segments products based on their contribution to total revenue:

- **A**: Top 40% revenue contributors.
- **B**: Next 40% revenue contributors.
- **C**: Bottom 20% revenue contributors.

```sql
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

XYZ Analysis categorizes products based on sales consistency:

- **X**: Coefficient of Variation ≤ 10%.
- **Y**: 10% < Coefficient of Variation ≤ 25%.
- **Z**: Coefficient of Variation > 25%.

### SQL Implementation:
```sql
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

## Application
- Ensure availability of **high-volume, stable** (**AX**) products while adjusting stock for **highly fluctuating** (**BZ**, **CZ**) items.
- Promote and bundle **underperforming** products (**CZ**) with **high-revenue** items (**AX**, **AY**).
- Target price-sensitive customers with **stable** (**BX**, **CX**) products and implement dynamic pricing for **highly fluctuating** (**BZ**, **CZ**) items.

## Recommendations
- Focus on high-revenue (A) and low-variability (X) products.
- Adjust stock for (Z) category products.
- Ensure consistent availability of (AX, BX) products while dynamically managing (CZ) items.

## Limitations
- Analysis is based on historical data and may not predict future trends.
- External factors such as seasonality and market fluctuations are not considered.
- Regular updates are needed to maintain accuracy.

If you find this project useful, feel free to ⭐. Your support will be my super motivation ❤️.

---

## References:

- [ABC XYZ Analysis in Inventory Management](https://abcsupplychain.com/abc-xyz-analysis/)
- [ABC XYZ Analysis for Inventory Management: Example in Excel (Full Tutorial)](https://www.youtube.com/watch?v=-GoYI746kEY)

  ---

📌 **Author:** Nguyễn Hoàng Gia Phúc  

📧 **Contact:** nguyenhoanggiaphucwork@gmail.com

🔗 **LinkedIn:** [Nguyen Hoang Gia Phuc](https://www.linkedin.com/in/nguyenhoanggiaphuc)
