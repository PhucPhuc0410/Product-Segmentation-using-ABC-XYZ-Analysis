USE AdventureWorksDW2022;

-- Total revenue
DECLARE @Total_sales float
SET @Total_sales = (
	SELECT SUM(SalesAmount)
	FROM FactResellerSales
);

-- Number of product
DECLARE @Num_of_product float
SET @Num_of_product = (
	SELECT COUNT(DISTINCT ProductKey)
	FROM FactResellerSales
);

-- ABC Analysis: Tính % of Items and % of Revenue
DROP TABLE IF EXISTS #Product_Sales
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

DROP TABLE IF EXISTS #ABC_Analysis
	SELECT
		DENSE_RANK() OVER (ORDER BY Total_Sales_Amount DESC) AS Rank_of_Product,
		ProductKey,
		EnglishProductName,
		Total_Sales_Amount,
		Percent_Revenue,
		DENSE_RANK() OVER (ORDER BY Total_Sales_Amount DESC) * 100 / @Num_of_product AS Cumulative_Percent_Item,
		SUM(Percent_Revenue) OVER (ORDER BY Total_Sales_Amount DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Cumulative_Percent_Revenue
	INTO #ABC_Analysis
	FROM #Product_Sales;

-- XYZ Analysis: Standard Deviation and Coefficient of Variation
DROP TABLE IF EXISTS #Product_Sales_Per_Month
	SELECT 
		PRO.ProductKey,
		PRO.EnglishProductName,
		YEAR(FACT.OrderDate) AS SalesYear,
		MONTH(FACT.OrderDate) AS SalesMonth,
		SUM(FACT.SalesAmount) AS MonthlySales
	INTO #Product_Sales_Per_Month
	FROM FactResellerSales FACT
	JOIN DimProduct PRO ON FACT.ProductKey = PRO.ProductKey
	GROUP BY PRO.ProductKey, PRO.EnglishProductName, YEAR(FACT.OrderDate), MONTH(FACT.OrderDate)

DROP TABLE IF EXISTS #XYZ_Analysis
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

-- Merging ABC và XYZ
DROP TABLE IF EXISTS #ABC_XYZ_Analysis
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
	ON ABC.ProductKey = XYZ.ProductKey

SELECT * FROM #ABC_XYZ_Analysis