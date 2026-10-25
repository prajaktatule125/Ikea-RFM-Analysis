-- CREATE DATABASE EcommerceCustomerAnalytics

SELECT COUNT(*) AS Rows2009_2010 FROM Year2009_2010;
SELECT COUNT(*) AS Rows2010_2011 FROM Year2010_2011;

SELECT top(5) * from Year2009_2010

--Combine data from Year 2009-2010 and Year 2010-2011.
SELECT
	Invoice,
	StockCode,
	Description,
	Quantity,
	COALESCE(
		TRY_CONVERT(DATETIME2, InvoiceDate, 120),
		TRY_CONVERT(DATETIME2, InvoiceDate, 105)
		) AS InvoiceDate,
		TRY_CONVERT(decimal(10,2),Price) AS Price,
	Customer_ID,
	Country,
	'2009-2010' AS SourceSheet
INTO dbo.RetailCombined
FROM Year2009_2010

UNION ALL

SELECT
	Invoice,
	StockCode,
	Description,
	Quantity,
	COALESCE(
		TRY_CONVERT(DATETIME2, InvoiceDate, 120),
		TRY_CONVERT(DATETIME2, InvoiceDate, 105)
		) AS InvoiceDate,
		TRY_CONVERT(decimal(10,2),Price) AS Price,
	Customer_ID,
	Country,
	'2010-2011' AS SourceSheet
FROM Year2010_2011

Select top(5) * from RetailCombined

--Check if conversion failed or not
SELECT COUNT(*) AS TotalRows FROM RetailCombined;
SELECT COUNT(*) AS FailedDates FROM RetailCombined WHERE InvoiceDate IS NULL;
SELECT COUNT(*) AS FailedPrice FROM RetailCombined WHERE Price IS NULL;

--Check Missing Customer_ID
SELECT COUNT(*) AS MissingCustomer_IDs FROM RetailCombined WHERE Customer_ID IS NULL;

--Check Negative OR Zero Quantity
SELECT COUNT(*) AS Qunatity FROM RetailCombined WHERE Quantity < 0;

--Check Exact Duplicated Rows
SELECT 
    Invoice,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    Price,
    Customer_ID,
    Country, 
    COUNT(*) AS ExactDupeCount
FROM 
    RetailCombined
GROUP BY 
    Invoice,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    Price,
    Customer_ID,
    Country
HAVING 
    COUNT(*) > 1;

--Deduplicate and produce final cleanded table 
WITH Deduped AS(
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY Invoice, StockCode,Description,Quantity,InvoiceDate,Price,Customer_ID, Country 
		ORDER BY (SELECT NULL)
	) AS RowNum
	FROM RetailCombined
	)
SELECT Invoice, StockCode,Description,Quantity,InvoiceDate,Price,Customer_ID, Country,SourceSheet
INTO dbo.RetailCleaned
FROM Deduped
Where RowNum = 1

--Check How many rows were Duplicate
SELECT 
(SELECT COUNT(*) FROM RetailCombined)-
(SELECT COUNT(*) from RetailCleaned)

SELECT * FROM RetailCleaned
