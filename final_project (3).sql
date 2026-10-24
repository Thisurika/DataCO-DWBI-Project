CREATE DATABASE DataCoDW;
GO

SELECT TOP (1000) *
FROM [DataCoDW].[dbo].[Stg_DataCoSupplyChain];

USE DataCoDW;
GO

SELECT COUNT(*) AS TotalRows
FROM dbo.Stg_DataCoSupplyChain;

--Check the columns
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Stg_DataCoSupplyChain'
ORDER BY ORDINAL_POSITION;

--Check NULL values
SELECT
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN [Order_Zipcode] IS NULL THEN 1 ELSE 0 END) AS NullOrderZipcode,
    SUM(CASE WHEN [Product_Description] IS NULL THEN 1 ELSE 0 END) AS NullProductDescription
FROM dbo.Stg_DataCoSupplyChain;

--Check duplicate Order Item IDs
SELECT
    [Order_Item_Id],
    COUNT(*) AS NumberOfRows
FROM dbo.Stg_DataCoSupplyChain
GROUP BY [Order_Item_Id]
HAVING COUNT(*) > 1;

--Check duplicate Order IDs
SELECT
    [Order_Id],
    COUNT(*) AS NumberOfRows
FROM dbo.Stg_DataCoSupplyChain
GROUP BY [Order_Id]
HAVING COUNT(*) > 1;

--Check the dates
SELECT
    MIN([order_date_DateOrders]) AS EarliestOrderDate,
    MAX([order_date_DateOrders]) AS LatestOrderDate,
    MIN([shipping_date_DateOrders]) AS EarliestShippingDate,
    MAX([shipping_date_DateOrders]) AS LatestShippingDate
FROM dbo.Stg_DataCoSupplyChain;

--Check important categories
SELECT
    [Shipping_Mode],
    COUNT(*) AS NumberOfRows
FROM dbo.Stg_DataCoSupplyChain
GROUP BY [Shipping_Mode]
ORDER BY NumberOfRows DESC;

SELECT
    [Delivery_Status],
    COUNT(*) AS NumberOfRows
FROM dbo.Stg_DataCoSupplyChain
GROUP BY [Delivery_Status]
ORDER BY NumberOfRows DESC;

SELECT
    [Customer_Segment],
    COUNT(*) AS NumberOfRows
FROM dbo.Stg_DataCoSupplyChain
GROUP BY [Customer_Segment]
ORDER BY NumberOfRows DESC;

--code checks - total rows, unique order items, unique orders
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT Order_Item_Id) AS DistinctOrderItems,
    COUNT(DISTINCT Order_Id) AS DistinctOrders
FROM dbo.Stg_DataCoSupplyChain;

--minimum and maximum Order Item ID
SELECT
    MIN(Order_Item_Id) AS MinimumOrderItemId,
    MAX(Order_Item_Id) AS MaximumOrderItemId,
    COUNT(DISTINCT Order_Item_Id) AS DistinctOrderItemIds,
    COUNT(*) AS TotalRows
FROM dbo.Stg_DataCoSupplyChain;

--Check whether Customer_Id and Order_Customer_Id agree
SELECT
    COUNT(*) AS TotalRows,
    SUM(
        CASE
            WHEN Customer_Id = Order_Customer_Id THEN 1
            ELSE 0
        END
    ) AS MatchingRows,
    SUM(
        CASE
            WHEN Customer_Id <> Order_Customer_Id THEN 1
            ELSE 0
        END
    ) AS NonMatchingRows
FROM dbo.Stg_DataCoSupplyChain;

--Test whether those NVARCHAR columns contain valid numbers
SELECT
    COUNT(*) AS TotalRows,

    SUM(CASE
        WHEN TRY_CONVERT(INT, Days_for_shipping_real) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidDaysReal,

    SUM(CASE
        WHEN TRY_CONVERT(INT, Days_for_shipment_scheduled) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidDaysScheduled,

    SUM(CASE
        WHEN TRY_CONVERT(DECIMAL(18,4), Benefit_per_order) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidBenefit,

    SUM(CASE
        WHEN TRY_CONVERT(INT, Late_delivery_risk) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidLateRisk,

    SUM(CASE
        WHEN TRY_CONVERT(DECIMAL(18,4), Order_Item_Discount) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidDiscount,

    SUM(CASE
        WHEN TRY_CONVERT(DECIMAL(18,4), Order_Item_Discount_Rate) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidDiscountRate,

    SUM(CASE
        WHEN TRY_CONVERT(DECIMAL(18,4), Order_Item_Profit_Ratio) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidProfitRatio,

    SUM(CASE
        WHEN TRY_CONVERT(INT, Order_Item_Quantity) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidQuantity,

    SUM(CASE
        WHEN TRY_CONVERT(DECIMAL(18,4), Order_Profit_Per_Order) IS NULL
        THEN 1 ELSE 0
    END) AS InvalidOrderProfit

FROM dbo.Stg_DataCoSupplyChain;

SELECT DISTINCT
    Days_for_shipping_real
FROM dbo.Stg_DataCoSupplyChain
WHERE TRY_CONVERT(INT, Days_for_shipping_real) IS NULL;

--Check the financial columns
SELECT
    MIN(Sales) AS MinSales,
    MAX(Sales) AS MaxSales,
    AVG(Sales) AS AvgSales,

    MIN(Order_Item_Product_Price) AS MinProductPrice,
    MAX(Order_Item_Product_Price) AS MaxProductPrice,
    AVG(Order_Item_Product_Price) AS AvgProductPrice,

    MIN(Order_Item_Total) AS MinOrderItemTotal,
    MAX(Order_Item_Total) AS MaxOrderItemTotal,
    AVG(Order_Item_Total) AS AvgOrderItemTotal
FROM dbo.Stg_DataCoSupplyChain;

--Check quantity
SELECT
    MIN(TRY_CONVERT(INT, Order_Item_Quantity)) AS MinimumQuantity,
    MAX(TRY_CONVERT(INT, Order_Item_Quantity)) AS MaximumQuantity,
    AVG(TRY_CONVERT(DECIMAL(18,2), Order_Item_Quantity)) AS AverageQuantity
FROM dbo.Stg_DataCoSupplyChain;

--Investigate your NULL values
SELECT
    COUNT(*) AS TotalRows,

    SUM(CASE
        WHEN Order_Zipcode IS NULL
        THEN 1 ELSE 0
    END) AS NullOrderZipcode,

    CAST(
        100.0 * SUM(CASE
            WHEN Order_Zipcode IS NULL
            THEN 1 ELSE 0
        END) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS OrderZipcodeNullPercentage,

    SUM(CASE
        WHEN Product_Description IS NULL
        THEN 1 ELSE 0
    END) AS NullProductDescription,

    CAST(
        100.0 * SUM(CASE
            WHEN Product_Description IS NULL
            THEN 1 ELSE 0
        END) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS ProductDescriptionNullPercentage

FROM dbo.Stg_DataCoSupplyChain;

--Check whether customer IDs are consistent
SELECT
    Customer_Id,
    COUNT(DISTINCT Customer_Fname) AS DifferentFirstNames,
    COUNT(DISTINCT Customer_Lname) AS DifferentLastNames,
    COUNT(DISTINCT Customer_City) AS DifferentCities,
    COUNT(DISTINCT Customer_State) AS DifferentStates
FROM dbo.Stg_DataCoSupplyChain
GROUP BY Customer_Id
HAVING
    COUNT(DISTINCT Customer_Fname) > 1
    OR COUNT(DISTINCT Customer_Lname) > 1
    OR COUNT(DISTINCT Customer_City) > 1
    OR COUNT(DISTINCT Customer_State) > 1;

--Check product consistency
SELECT
    Product_Card_Id,
    COUNT(DISTINCT Product_Name) AS DifferentProductNames,
    COUNT(DISTINCT Product_Category_Id) AS DifferentCategories,
    COUNT(DISTINCT Product_Price) AS DifferentPrices
FROM dbo.Stg_DataCoSupplyChain
GROUP BY Product_Card_Id
HAVING
    COUNT(DISTINCT Product_Name) > 1
    OR COUNT(DISTINCT Product_Category_Id) > 1
    OR COUNT(DISTINCT Product_Price) > 1;

--Check the late-delivery risk values
SELECT
    Late_delivery_risk,
    COUNT(*) AS NumberOfRows
FROM dbo.Stg_DataCoSupplyChain
GROUP BY Late_delivery_risk
ORDER BY Late_delivery_risk;

--Check the relationship between Delivery Status and Late Delivery Risk
SELECT
    Delivery_Status,
    Late_delivery_risk,
    COUNT(*) AS NumberOfRows
FROM dbo.Stg_DataCoSupplyChain
GROUP BY
    Delivery_Status,
    Late_delivery_risk
ORDER BY
    Delivery_Status,
    Late_delivery_risk;

--Check date consistency
SELECT
    COUNT(*) AS InvalidDateRows
FROM dbo.Stg_DataCoSupplyChain
WHERE shipping_date_DateOrders < order_date_DateOrders;

--Calculate actual shipping duration
SELECT
    MIN(DATEDIFF(
        DAY,
        order_date_DateOrders,
        shipping_date_DateOrders
    )) AS MinimumShippingDays,

    MAX(DATEDIFF(
        DAY,
        order_date_DateOrders,
        shipping_date_DateOrders
    )) AS MaximumShippingDays,

    AVG(CAST(DATEDIFF(
        DAY,
        order_date_DateOrders,
        shipping_date_DateOrders
    ) AS DECIMAL(10,2))) AS AverageShippingDays
FROM dbo.Stg_DataCoSupplyChain;

--Compare actual and scheduled shipping duration
SELECT
    MIN(TRY_CONVERT(INT, Days_for_shipping_real)) AS MinActualDays,
    MAX(TRY_CONVERT(INT, Days_for_shipping_real)) AS MaxActualDays,

    MIN(TRY_CONVERT(INT, Days_for_shipment_scheduled)) AS MinScheduledDays,
    MAX(TRY_CONVERT(INT, Days_for_shipment_scheduled)) AS MaxScheduledDays,

    AVG(TRY_CONVERT(DECIMAL(10,2), Days_for_shipping_real)) AS AvgActualDays,
    AVG(TRY_CONVERT(DECIMAL(10,2), Days_for_shipment_scheduled)) AS AvgScheduledDays
FROM dbo.Stg_DataCoSupplyChain;

--Check whether actual shipping exceeds scheduled shipping
SELECT
    COUNT(*) AS TotalRows,
    SUM(
        CASE
            WHEN TRY_CONVERT(INT, Days_for_shipping_real)
               > TRY_CONVERT(INT, Days_for_shipment_scheduled)
            THEN 1
            ELSE 0
        END
    ) AS RowsExceedingSchedule
FROM dbo.Stg_DataCoSupplyChain;

-------------------------------------------------------
--Check one more thing before designing the star schema
SELECT
    COUNT(*) AS TotalRows,

    COUNT(DISTINCT
        CONCAT(
            Order_Item_Id,
            '-',
            Customer_Id
        )
    ) AS OrderItemCustomerCombinations,

    COUNT(DISTINCT
        CONCAT(
            Order_Item_Id,
            '-',
            Product_Card_Id
        )
    ) AS OrderItemProductCombinations

FROM dbo.Stg_DataCoSupplyChain;

--Check whether one order item has one order
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT
        CONCAT(
            Order_Item_Id,
            '-',
            Order_Id
        )
    ) AS OrderItemOrderCombinations
FROM dbo.Stg_DataCoSupplyChain;

--Check whether one order item has one date
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT
        CONCAT(
            Order_Item_Id,
            '-',
            CONVERT(VARCHAR(30), order_date_DateOrders, 121)
        )
    ) AS OrderItemOrderDateCombinations,

    COUNT(DISTINCT
        CONCAT(
            Order_Item_Id,
            '-',
            CONVERT(VARCHAR(30), shipping_date_DateOrders, 121)
        )
    ) AS OrderItemShippingDateCombinations
FROM dbo.Stg_DataCoSupplyChain;

--Check whether a product belongs to one category
SELECT
    Product_Card_Id,
    Product_Name,
    Product_Category_Id,
    Category_Name,
    Department_Id,
    Department_Name
FROM dbo.Stg_DataCoSupplyChain
GROUP BY
    Product_Card_Id,
    Product_Name,
    Product_Category_Id,
    Category_Name,
    Department_Id,
    Department_Name
ORDER BY Product_Card_Id;

--Check the location structure
SELECT
    COUNT(DISTINCT Customer_City) AS CustomerCities,
    COUNT(DISTINCT Customer_State) AS CustomerStates,
    COUNT(DISTINCT Customer_Country) AS CustomerCountries,

    COUNT(DISTINCT Order_City) AS OrderCities,
    COUNT(DISTINCT Order_State) AS OrderStates,
    COUNT(DISTINCT Order_Country) AS OrderCountries,

    COUNT(DISTINCT Order_Region) AS OrderRegions,
    COUNT(DISTINCT Market) AS Markets
FROM dbo.Stg_DataCoSupplyChain;

--Check whether Customer Country is constant
SELECT
    Customer_Id,
    COUNT(DISTINCT Customer_Country) AS CountryCount
FROM dbo.Stg_DataCoSupplyChain
GROUP BY Customer_Id
HAVING COUNT(DISTINCT Customer_Country) > 1;

--Check Order Status
SELECT
    Order_Status,
    COUNT(*) AS NumberOfRows
FROM dbo.Stg_DataCoSupplyChain
GROUP BY Order_Status
ORDER BY NumberOfRows DESC;

--Check order type
SELECT
    Type,
    COUNT(*) AS NumberOfRows
FROM dbo.Stg_DataCoSupplyChain
GROUP BY Type
ORDER BY NumberOfRows DESC;

--Check market and region
SELECT
    Market,
    Order_Region,
    COUNT(*) AS NumberOfRows
FROM dbo.Stg_DataCoSupplyChain
GROUP BY
    Market,
    Order_Region
ORDER BY
    Market,
    Order_Region;

    ----------------------------------------
--Check Product ID consistency
SELECT
    Product_Card_Id,

    COUNT(DISTINCT Product_Name) AS ProductNameCount,
    COUNT(DISTINCT Product_Category_Id) AS CategoryIdCount,
    COUNT(DISTINCT Category_Name) AS CategoryNameCount,
    COUNT(DISTINCT Department_Id) AS DepartmentIdCount,
    COUNT(DISTINCT Department_Name) AS DepartmentNameCount

FROM dbo.Stg_DataCoSupplyChain

GROUP BY Product_Card_Id

HAVING
    COUNT(DISTINCT Product_Name) > 1
    OR COUNT(DISTINCT Product_Category_Id) > 1
    OR COUNT(DISTINCT Category_Name) > 1
    OR COUNT(DISTINCT Department_Id) > 1
    OR COUNT(DISTINCT Department_Name) > 1

ORDER BY Product_Card_Id;

--Check whether the two Product IDs are actually the same
SELECT
    COUNT(*) AS TotalRows,

    SUM(
        CASE
            WHEN Order_Item_Cardprod_Id = Product_Card_Id
            THEN 1
            ELSE 0
        END
    ) AS MatchingRows,

    SUM(
        CASE
            WHEN Order_Item_Cardprod_Id <> Product_Card_Id
            THEN 1
            ELSE 0
        END
    ) AS NonMatchingRows

FROM dbo.Stg_DataCoSupplyChain;

--Check the Category IDs
SELECT
    COUNT(*) AS TotalRows,

    SUM(
        CASE
            WHEN Category_Id = Product_Category_Id
            THEN 1
            ELSE 0
        END
    ) AS MatchingRows,

    SUM(
        CASE
            WHEN Category_Id <> Product_Category_Id
            THEN 1
            ELSE 0
        END
    ) AS NonMatchingRows

FROM dbo.Stg_DataCoSupplyChain;

--Check order-level consistency
SELECT
    Order_Id,

    COUNT(DISTINCT Order_Status) AS StatusCount,
    COUNT(DISTINCT Type) AS TypeCount,
    COUNT(DISTINCT Order_Customer_Id) AS CustomerCount,
    COUNT(DISTINCT order_date_DateOrders) AS OrderDateCount

FROM dbo.Stg_DataCoSupplyChain

GROUP BY Order_Id

HAVING
    COUNT(DISTINCT Order_Status) > 1
    OR COUNT(DISTINCT Type) > 1
    OR COUNT(DISTINCT Order_Customer_Id) > 1
    OR COUNT(DISTINCT order_date_DateOrders) > 1

ORDER BY Order_Id;

----------------------------------------------------
--Create the Data Warehouse schema
USE DataCoDW;
GO

CREATE SCHEMA DW;
GO

SELECT
    SCHEMA_NAME(schema_id) AS SchemaName
FROM sys.schemas
WHERE name = 'DW';

--Create DimCustomer
CREATE TABLE DW.DimCustomer
(
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,

    Customer_Id INT NOT NULL,

    Customer_Fname NVARCHAR(50),
    Customer_Lname NVARCHAR(50),

    Customer_Segment NVARCHAR(50),

    Customer_Street NVARCHAR(100),
    Customer_City NVARCHAR(100),
    Customer_State NVARCHAR(100),
    Customer_Country NVARCHAR(100),
    Customer_Zipcode INT
);
GO

--Create DimProduct
CREATE TABLE DW.DimProduct
(
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,

    Product_Card_Id INT NOT NULL,

    Product_Name NVARCHAR(100),
    Product_Price DECIMAL(18,2),
    Product_Status NVARCHAR(50),

    Category_Id INT,
    Category_Name NVARCHAR(100),

    Department_Id INT,
    Department_Name NVARCHAR(100)
);
GO

--Create DimDate
CREATE TABLE DW.DimDate
(
    DateKey INT PRIMARY KEY,

    FullDate DATE NOT NULL,

    Year INT,
    Quarter INT,

    Month INT,
    MonthName NVARCHAR(20),

    WeekOfYear INT,

    DayOfMonth INT,
    DayName NVARCHAR(20)
);
GO

--Create DimLocation
CREATE TABLE DW.DimLocation
(
    LocationKey INT IDENTITY(1,1) PRIMARY KEY,

    Market NVARCHAR(50),
    Order_Region NVARCHAR(100),
    Order_Country NVARCHAR(100),
    Order_State NVARCHAR(100),
    Order_City NVARCHAR(100),
    Order_Zipcode NVARCHAR(50),

    Latitude DECIMAL(10,6),
    Longitude DECIMAL(10,6)
);
GO

--Create DimShipping
CREATE TABLE DW.DimShipping
(
    ShippingKey INT IDENTITY(1,1) PRIMARY KEY,

    Shipping_Mode NVARCHAR(50),
    Delivery_Status NVARCHAR(50),
    Late_Delivery_Risk INT
);
GO

--Create FactOrderItem
CREATE TABLE DW.FactOrderItem
(
    OrderItemFactKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    Order_Item_Id INT NOT NULL,
    Order_Id INT NOT NULL,

    CustomerKey INT NOT NULL,
    ProductKey INT NOT NULL,

    OrderDateKey INT NOT NULL,
    ShippingDateKey INT NOT NULL,

    LocationKey INT NOT NULL,
    ShippingKey INT NOT NULL,

    Quantity INT,

    Sales DECIMAL(18,2),
    Discount DECIMAL(18,2),
    OrderItemTotal DECIMAL(18,2),
    Profit DECIMAL(18,2),

    ProductPrice DECIMAL(18,2),

    ScheduledShippingDays INT,
    ActualShippingDays INT,
    ShippingDelayDays INT
);
GO

--Add Foreign Keys
--Customer
ALTER TABLE DW.FactOrderItem
ADD CONSTRAINT FK_FactOrderItem_Customer
FOREIGN KEY (CustomerKey)
REFERENCES DW.DimCustomer(CustomerKey);
GO
--Product
ALTER TABLE DW.FactOrderItem
ADD CONSTRAINT FK_FactOrderItem_Product
FOREIGN KEY (ProductKey)
REFERENCES DW.DimProduct(ProductKey);
GO
--Order date
ALTER TABLE DW.FactOrderItem
ADD CONSTRAINT FK_FactOrderItem_OrderDate
FOREIGN KEY (OrderDateKey)
REFERENCES DW.DimDate(DateKey);
GO
--Shipping date
ALTER TABLE DW.FactOrderItem
ADD CONSTRAINT FK_FactOrderItem_ShippingDate
FOREIGN KEY (ShippingDateKey)
REFERENCES DW.DimDate(DateKey);
GO
--Location
ALTER TABLE DW.FactOrderItem
ADD CONSTRAINT FK_FactOrderItem_Location
FOREIGN KEY (LocationKey)
REFERENCES DW.DimLocation(LocationKey);
GO
--Shipping
ALTER TABLE DW.FactOrderItem
ADD CONSTRAINT FK_FactOrderItem_Shipping
FOREIGN KEY (ShippingKey)
REFERENCES DW.DimShipping(ShippingKey);
GO

--------------------------------------------------
--Populate DimCustomer
INSERT INTO DW.DimCustomer
(
    Customer_Id,
    Customer_Fname,
    Customer_Lname,
    Customer_Segment,
    Customer_Street,
    Customer_City,
    Customer_State,
    Customer_Country,
    Customer_Zipcode
)
SELECT DISTINCT
    Customer_Id,
    Customer_Fname,
    Customer_Lname,
    Customer_Segment,
    Customer_Street,
    Customer_City,
    Customer_State,
    Customer_Country,
    Customer_Zipcode
FROM dbo.Stg_DataCoSupplyChain;

--Populate DimProduct
INSERT INTO DW.DimProduct
(
    Product_Card_Id,
    Product_Name,
    Product_Price,
    Product_Status,
    Category_Id,
    Category_Name,
    Department_Id,
    Department_Name
)
SELECT DISTINCT
    Product_Card_Id,
    Product_Name,
    TRY_CONVERT(DECIMAL(18,2), Product_Price),
    Product_Status,
    Category_Id,
    Category_Name,
    Department_Id,
    Department_Name
FROM dbo.Stg_DataCoSupplyChain;

--Populate DimShipping
INSERT INTO DW.DimShipping
(
    Shipping_Mode,
    Delivery_Status,
    Late_Delivery_Risk
)
SELECT DISTINCT
    Shipping_Mode,
    Delivery_Status,
    TRY_CONVERT(INT, Late_delivery_risk)
FROM dbo.Stg_DataCoSupplyChain;

--Populate DimLocation
INSERT INTO DW.DimLocation
(
    Market,
    Order_Region,
    Order_Country,
    Order_State,
    Order_City,
    Order_Zipcode,
    Latitude,
    Longitude
)
SELECT DISTINCT
    Market,
    Order_Region,
    Order_Country,
    Order_State,
    Order_City,
    Order_Zipcode,
    Latitude,
    Longitude
FROM dbo.Stg_DataCoSupplyChain;

--Populate DimDate
SELECT
    MIN(CAST(order_date_DateOrders AS DATE)) AS MinOrderDate,
    MAX(CAST(order_date_DateOrders AS DATE)) AS MaxOrderDate,

    MIN(CAST(shipping_date_DateOrders AS DATE)) AS MinShippingDate,
    MAX(CAST(shipping_date_DateOrders AS DATE)) AS MaxShippingDate

FROM dbo.Stg_DataCoSupplyChain;


--Check your date range
USE DataCoDW;
GO

DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

-- Find the overall date range
SELECT
    @StartDate =
        CASE
            WHEN MIN(CAST(order_date_DateOrders AS DATE))
                 < MIN(CAST(shipping_date_DateOrders AS DATE))
            THEN MIN(CAST(order_date_DateOrders AS DATE))
            ELSE MIN(CAST(shipping_date_DateOrders AS DATE))
        END,

    @EndDate =
        CASE
            WHEN MAX(CAST(order_date_DateOrders AS DATE))
                 > MAX(CAST(shipping_date_DateOrders AS DATE))
            THEN MAX(CAST(order_date_DateOrders AS DATE))
            ELSE MAX(CAST(shipping_date_DateOrders AS DATE))
        END
FROM dbo.Stg_DataCoSupplyChain;


-- Generate and insert every date into DimDate
;WITH DateSeries AS
(
    SELECT @StartDate AS FullDate

    UNION ALL

    SELECT DATEADD(DAY, 1, FullDate)
    FROM DateSeries
    WHERE FullDate < @EndDate
)
INSERT INTO DW.DimDate
(
    DateKey,
    FullDate,
    Year,
    Quarter,
    Month,
    MonthName,
    WeekOfYear,
    DayOfMonth,
    DayName
)
SELECT
    CONVERT(INT, CONVERT(CHAR(8), FullDate, 112)) AS DateKey,

    FullDate,
    YEAR(FullDate) AS Year,
    DATEPART(QUARTER, FullDate) AS Quarter,
    MONTH(FullDate) AS Month,
    DATENAME(MONTH, FullDate) AS MonthName,
    DATEPART(WEEK, FullDate) AS WeekOfYear,
    DAY(FullDate) AS DayOfMonth,
    DATENAME(WEEKDAY, FullDate) AS DayName

FROM DateSeries
OPTION (MAXRECURSION 0);
GO

--Verify DimDate
SELECT COUNT(*) AS NumberOfDates
FROM DW.DimDate;

SELECT TOP 10 *
FROM DW.DimDate
ORDER BY FullDate;

SELECT TOP 10 *
FROM DW.DimDate
ORDER BY FullDate DESC;

--Before loading the Fact table: validate dimensions
--Check dimension row counts
SELECT 'DimCustomer' AS TableName, COUNT(*) AS Row_Count
FROM DW.DimCustomer

UNION ALL

SELECT 'DimProduct', COUNT(*)
FROM DW.DimProduct

UNION ALL

SELECT 'DimDate', COUNT(*)
FROM DW.DimDate

UNION ALL

SELECT 'DimLocation', COUNT(*)
FROM DW.DimLocation

UNION ALL

SELECT 'DimShipping', COUNT(*)
FROM DW.DimShipping;

--Check dimension business-key duplicates
--Customer
SELECT
    Customer_Id,
    COUNT(*) AS NumberOfRows
FROM DW.DimCustomer
GROUP BY Customer_Id
HAVING COUNT(*) > 1;
--Product
SELECT
    Product_Card_Id,
    COUNT(*) AS NumberOfRows
FROM DW.DimProduct
GROUP BY Product_Card_Id
HAVING COUNT(*) > 1;
--Date
SELECT
    DateKey,
    COUNT(*) AS NumberOfRows
FROM DW.DimDate
GROUP BY DateKey
HAVING COUNT(*) > 1;

--Load the Fact table
--First test the Fact joins
SELECT
    COUNT(*) AS TotalRows,
    COUNT(c.CustomerKey) AS CustomerMatches,
    COUNT(p.ProductKey) AS ProductMatches,
    COUNT(od.DateKey) AS OrderDateMatches,
    COUNT(sd.DateKey) AS ShippingDateMatches,
    COUNT(l.LocationKey) AS LocationMatches,
    COUNT(s.ShippingKey) AS ShippingMatches

FROM dbo.Stg_DataCoSupplyChain st

LEFT JOIN DW.DimCustomer c
    ON st.Customer_Id = c.Customer_Id

LEFT JOIN DW.DimProduct p
    ON st.Product_Card_Id = p.Product_Card_Id

LEFT JOIN DW.DimDate od
    ON CAST(st.order_date_DateOrders AS DATE) = od.FullDate

LEFT JOIN DW.DimDate sd
    ON CAST(st.shipping_date_DateOrders AS DATE) = sd.FullDate

LEFT JOIN DW.DimLocation l
    ON ISNULL(st.Market, '') = ISNULL(l.Market, '')
    AND ISNULL(st.Order_Region, '') = ISNULL(l.Order_Region, '')
    AND ISNULL(st.Order_Country, '') = ISNULL(l.Order_Country, '')
    AND ISNULL(st.Order_State, '') = ISNULL(l.Order_State, '')
    AND ISNULL(st.Order_City, '') = ISNULL(l.Order_City, '')
    AND ISNULL(st.Order_Zipcode, '') = ISNULL(l.Order_Zipcode, '')
    AND ISNULL(st.Latitude, 0) = ISNULL(l.Latitude, 0)
    AND ISNULL(st.Longitude, 0) = ISNULL(l.Longitude, 0)

LEFT JOIN DW.DimShipping s
    ON ISNULL(st.Shipping_Mode, '') = ISNULL(s.Shipping_Mode, '')
    AND ISNULL(st.Delivery_Status, '') = ISNULL(s.Delivery_Status, '')
    AND TRY_CONVERT(INT, st.Late_delivery_risk) = s.Late_Delivery_Risk;

--Test Location matching without Latitude/Longitude
SELECT
    COUNT(*) AS TotalRows,
    COUNT(l.LocationKey) AS LocationMatches
FROM dbo.Stg_DataCoSupplyChain st

LEFT JOIN DW.DimLocation l
    ON ISNULL(st.Market, '') = ISNULL(l.Market, '')
    AND ISNULL(st.Order_Region, '') = ISNULL(l.Order_Region, '')
    AND ISNULL(st.Order_Country, '') = ISNULL(l.Order_Country, '')
    AND ISNULL(st.Order_State, '') = ISNULL(l.Order_State, '')
    AND ISNULL(st.Order_City, '') = ISNULL(l.Order_City, '')
    AND ISNULL(st.Order_Zipcode, '') = ISNULL(l.Order_Zipcode, '');

--
SELECT
    Market,
    Order_Region,
    Order_Country,
    Order_State,
    Order_City,
    Order_Zipcode,
    COUNT(*) AS NumberOfRows
FROM DW.DimLocation
GROUP BY
    Market,
    Order_Region,
    Order_Country,
    Order_State,
    Order_City,
    Order_Zipcode
HAVING COUNT(*) > 1
ORDER BY NumberOfRows DESC;

--First check how many unique logical locations exist
SELECT
    COUNT(*) AS TotalDimLocationRows,
    COUNT(DISTINCT
        CONCAT(
            ISNULL(Market, ''), '|',
            ISNULL(Order_Region, ''), '|',
            ISNULL(Order_Country, ''), '|',
            ISNULL(Order_State, ''), '|',
            ISNULL(Order_City, ''), '|',
            ISNULL(Order_Zipcode, '')
        )
    ) AS UniqueLogicalLocations
FROM DW.DimLocation;

--rebuild DimLocation
SELECT COUNT(*) AS FactRows
FROM DW.FactOrderItem


--check again
--Clear the current Location dimension
TRUNCATE TABLE DW.DimLocation;

--Re-populate DimLocation correctly
INSERT INTO DW.DimLocation
(
    Market,
    Order_Region,
    Order_Country,
    Order_State,
    Order_City,
    Order_Zipcode,
    Latitude,
    Longitude
)
SELECT
    Market,
    Order_Region,
    Order_Country,
    Order_State,
    Order_City,
    Order_Zipcode,
    MAX(Latitude) AS Latitude,
    MAX(Longitude) AS Longitude
FROM dbo.Stg_DataCoSupplyChain
GROUP BY
    Market,
    Order_Region,
    Order_Country,
    Order_State,
    Order_City,
    Order_Zipcode;

--Check the new row count
SELECT COUNT(*) AS LocationRows
FROM DW.DimLocation;

SELECT TOP 10 *
FROM DW.DimLocation
ORDER BY LocationKey;

--Verify there are no duplicate logical locations
SELECT
    Market,
    Order_Region,
    Order_Country,
    Order_State,
    Order_City,
    Order_Zipcode,
    COUNT(*) AS NumberOfRows
FROM DW.DimLocation
GROUP BY
    Market,
    Order_Region,
    Order_Country,
    Order_State,
    Order_City,
    Order_Zipcode
HAVING COUNT(*) > 1;

--Re-run the Fact lookup test
SELECT
    COUNT(*) AS TotalRows,
    COUNT(c.CustomerKey) AS CustomerMatches,
    COUNT(p.ProductKey) AS ProductMatches,
    COUNT(od.DateKey) AS OrderDateMatches,
    COUNT(sd.DateKey) AS ShippingDateMatches,
    COUNT(l.LocationKey) AS LocationMatches,
    COUNT(s.ShippingKey) AS ShippingMatches

FROM dbo.Stg_DataCoSupplyChain st

LEFT JOIN DW.DimCustomer c
    ON st.Customer_Id = c.Customer_Id

LEFT JOIN DW.DimProduct p
    ON st.Product_Card_Id = p.Product_Card_Id

LEFT JOIN DW.DimDate od
    ON CAST(st.order_date_DateOrders AS DATE) = od.FullDate

LEFT JOIN DW.DimDate sd
    ON CAST(st.shipping_date_DateOrders AS DATE) = sd.FullDate

LEFT JOIN DW.DimLocation l
    ON ISNULL(st.Market, '') = ISNULL(l.Market, '')
    AND ISNULL(st.Order_Region, '') = ISNULL(l.Order_Region, '')
    AND ISNULL(st.Order_Country, '') = ISNULL(l.Order_Country, '')
    AND ISNULL(st.Order_State, '') = ISNULL(l.Order_State, '')
    AND ISNULL(st.Order_City, '') = ISNULL(l.Order_City, '')
    AND ISNULL(st.Order_Zipcode, '') = ISNULL(l.Order_Zipcode, '')

LEFT JOIN DW.DimShipping s
    ON ISNULL(st.Shipping_Mode, '') = ISNULL(s.Shipping_Mode, '')
    AND ISNULL(st.Delivery_Status, '') = ISNULL(s.Delivery_Status, '')
    AND TRY_CONVERT(INT, st.Late_delivery_risk) = s.Late_Delivery_Risk;

------------------------------------------------------------------------
USE DataCoDW;
GO

SELECT *
INTO DW.DimLocation_Backup
FROM DW.DimLocation;

SELECT COUNT(*) AS BackupRows
FROM DW.DimLocation_Backup;

SELECT TOP 5 *
FROM DW.DimLocation;

TRUNCATE TABLE DW.DimLocation;

DELETE FROM DW.DimLocation;

INSERT INTO DW.DimLocation
(
    Market,
    Order_Region,
    Order_Country,
    Order_State,
    Order_City,
    Order_Zipcode
)
SELECT DISTINCT
    Market,
    Order_Region,
    Order_Country,
    Order_State,
    Order_City,
    Order_Zipcode
FROM dbo.Stg_DataCoSupplyChain

SELECT COUNT(*) AS DimLocationRows
FROM DW.DimLocation;

SELECT COUNT(*) AS UniqueLogicalLocations
FROM
(
    SELECT DISTINCT
        Market,
        Order_Region,
        Order_Country,
        Order_State,
        Order_City,
        Order_Zipcode
    FROM DW.DimLocation
) x;

SELECT
    Market,
    Order_Region,
    Order_Country,
    Order_State,
    Order_City,
    Order_Zipcode,
    COUNT(*) AS DuplicateCount
FROM DW.DimLocation
GROUP BY
    Market,
    Order_Region,
    Order_Country,
    Order_State,
    Order_City,
    Order_Zipcode
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS LocationMatches
FROM  dbo.Stg_DataCoSupplyChain s
INNER JOIN DW.DimLocation d
    ON ISNULL(s.Market, '') = ISNULL(d.Market, '')
   AND ISNULL(s.Order_Region, '') = ISNULL(d.Order_Region, '')
   AND ISNULL(s.Order_Country, '') = ISNULL(d.Order_Country, '')
   AND ISNULL(s.Order_State, '') = ISNULL(d.Order_State, '')
   AND ISNULL(s.Order_City, '') = ISNULL(d.Order_City, '')
   AND ISNULL(s.Order_Zipcode, '') = ISNULL(d.Order_Zipcode, '');

SELECT COUNT(*) AS UnmatchedLocations
FROM dbo.Stg_DataCoSupplyChain s
LEFT JOIN DW.DimLocation d
    ON ISNULL(s.Market, '') = ISNULL(d.Market, '')
   AND ISNULL(s.Order_Region, '') = ISNULL(d.Order_Region, '')
   AND ISNULL(s.Order_Country, '') = ISNULL(d.Order_Country, '')
   AND ISNULL(s.Order_State, '') = ISNULL(d.Order_State, '')
   AND ISNULL(s.Order_City, '') = ISNULL(d.Order_City, '')
   AND ISNULL(s.Order_Zipcode, '') = ISNULL(d.Order_Zipcode, '')
WHERE d.LocationKey IS NULL;

SELECT COUNT(*) AS CustomerMatches
FROM Stg_DataCoSupplyChain s
INNER JOIN DW.DimCustomer d
    ON s.Order_Customer_Id = d.CustomerKey;

SELECT COUNT(*) AS ProductMatches
FROM  Stg_DataCoSupplyChain s
INNER JOIN DW.DimProduct d
    ON s.Order_Item_Cardprod_Id = d.ProductKey;

SELECT COUNT(*) AS ShippingMatches
FROM Stg_DataCoSupplyChain s
INNER JOIN DW.DimShipping d
    ON s.Shipping_Mode = d.ShippingKey;

--Re-run the Fact lookup test
SELECT
    COUNT(*) AS TotalRows,
    COUNT(c.CustomerKey) AS CustomerMatches,
    COUNT(p.ProductKey) AS ProductMatches,
    COUNT(od.DateKey) AS OrderDateMatches,
    COUNT(sd.DateKey) AS ShippingDateMatches,
    COUNT(l.LocationKey) AS LocationMatches,
    COUNT(s.ShippingKey) AS ShippingMatches

FROM dbo.Stg_DataCoSupplyChain st

LEFT JOIN DW.DimCustomer c
    ON st.Customer_Id = c.Customer_Id

LEFT JOIN DW.DimProduct p
    ON st.Product_Card_Id = p.Product_Card_Id

LEFT JOIN DW.DimDate od
    ON CAST(st.order_date_DateOrders AS DATE) = od.FullDate

LEFT JOIN DW.DimDate sd
    ON CAST(st.shipping_date_DateOrders AS DATE) = sd.FullDate

LEFT JOIN DW.DimLocation l
    ON ISNULL(st.Market, '') = ISNULL(l.Market, '')
    AND ISNULL(st.Order_Region, '') = ISNULL(l.Order_Region, '')
    AND ISNULL(st.Order_Country, '') = ISNULL(l.Order_Country, '')
    AND ISNULL(st.Order_State, '') = ISNULL(l.Order_State, '')
    AND ISNULL(st.Order_City, '') = ISNULL(l.Order_City, '')
    AND ISNULL(st.Order_Zipcode, '') = ISNULL(l.Order_Zipcode, '')

LEFT JOIN DW.DimShipping s
    ON ISNULL(st.Shipping_Mode, '') = ISNULL(s.Shipping_Mode, '')
    AND ISNULL(st.Delivery_Status, '') = ISNULL(s.Delivery_Status, '')
    AND TRY_CONVERT(INT, st.Late_delivery_risk) = s.Late_Delivery_Risk;

SELECT COUNT(*) AS ExistingFactRows
FROM DW.FactOrderItem;

SELECT COUNT(*) AS ExistingFactRows
FROM DW.FactOrderItem;

--------------------------------------------------------------------------
--Check the shipping and profit values
SELECT TOP 20
    Order_Item_Id,
    Order_Id,

    -- Original shipping fields
    Days_for_shipping_real,
    Days_for_shipment_scheduled,

    -- Date-based shipping calculation
    DATEDIFF(
        DAY,
        CAST(order_date_DateOrders AS DATE),
        CAST(shipping_date_DateOrders AS DATE)
    ) AS CalculatedActualShippingDays,

    -- Financial fields
    Sales,
    Order_Item_Discount,
    Order_Item_Total,
    Product_Price,
    Benefit_per_order,
    Order_Profit_Per_Order

FROM dbo.Stg_DataCoSupplyChain
ORDER BY Order_Item_Id;

--Verify the shipping-day fields
SELECT
    COUNT(*) AS TotalRows,

    COUNT(
        CASE
            WHEN TRY_CONVERT(INT, Days_for_shipping_real) IS NOT NULL
            THEN 1
        END
    ) AS ValidActualShippingDays,

    COUNT(
        CASE
            WHEN TRY_CONVERT(INT, Days_for_shipment_scheduled) IS NOT NULL
            THEN 1
        END
    ) AS ValidScheduledShippingDays,

    MIN(TRY_CONVERT(INT, Days_for_shipping_real))
        AS MinActualShippingDays,

    MAX(TRY_CONVERT(INT, Days_for_shipping_real))
        AS MaxActualShippingDays,

    MIN(TRY_CONVERT(INT, Days_for_shipment_scheduled))
        AS MinScheduledShippingDays,

    MAX(TRY_CONVERT(INT, Days_for_shipment_scheduled))
        AS MaxScheduledShippingDays

FROM dbo.Stg_DataCoSupplyChain;

--Verify the delay calculation
SELECT
    COUNT(*) AS TotalRows,

    SUM(
        CASE
            WHEN
                TRY_CONVERT(INT, Days_for_shipping_real)
                >
                TRY_CONVERT(INT, Days_for_shipment_scheduled)
            THEN 1
            ELSE 0
        END
    ) AS DelayedRows,

    SUM(
        CASE
            WHEN
                TRY_CONVERT(INT, Days_for_shipping_real)
                =
                TRY_CONVERT(INT, Days_for_shipment_scheduled)
            THEN 1
            ELSE 0
        END
    ) AS OnScheduleRows,

    SUM(
        CASE
            WHEN
                TRY_CONVERT(INT, Days_for_shipping_real)
                <
                TRY_CONVERT(INT, Days_for_shipment_scheduled)
            THEN 1
            ELSE 0
        END
    ) AS EarlyRows

FROM dbo.Stg_DataCoSupplyChain;

--Verify the financial fields
SELECT
    COUNT(*) AS TotalRows,

    MIN(Sales) AS MinSales,
    MAX(Sales) AS MaxSales,
    AVG(Sales) AS AvgSales,

    MIN(Order_Item_Discount) AS MinDiscount,
    MAX(Order_Item_Discount) AS MaxDiscount,

    MIN(Order_Item_Total) AS MinOrderItemTotal,
    MAX(Order_Item_Total) AS MaxOrderItemTotal,

    MIN(Product_Price) AS MinProductPrice,
    MAX(Product_Price) AS MaxProductPrice,

    MIN(TRY_CONVERT(DECIMAL(18,2), Benefit_per_order))
        AS MinBenefit,

    MAX(TRY_CONVERT(DECIMAL(18,2), Benefit_per_order))
        AS MaxBenefit

FROM dbo.Stg_DataCoSupplyChain;

--Final Profit Validation
SELECT
    COUNT(*) AS TotalRows,
    SUM(
        CASE
            WHEN
                TRY_CONVERT(DECIMAL(18,2), Benefit_per_order)
                =
                TRY_CONVERT(DECIMAL(18,2), Order_Profit_Per_Order)
            THEN 1
            ELSE 0
        END
    ) AS MatchingProfitRows,
    SUM(
        CASE
            WHEN
                TRY_CONVERT(DECIMAL(18,2), Benefit_per_order)
                <>
                TRY_CONVERT(DECIMAL(18,2), Order_Profit_Per_Order)
            THEN 1
            ELSE 0
        END
    ) AS DifferentProfitRows
FROM dbo.Stg_DataCoSupplyChain;

-----------------------------------------------------------------------
--Check Fact Table Is Still Empty
SELECT COUNT(*) AS ExistingFactRows
FROM DW.FactOrderItem;

--Load the Fact Table
INSERT INTO DW.FactOrderItem
(
    Order_Item_Id,
    Order_Id,
    CustomerKey,
    ProductKey,
    OrderDateKey,
    ShippingDateKey,
    LocationKey,
    ShippingKey,
    Quantity,
    Sales,
    Discount,
    OrderItemTotal,
    Profit,
    ProductPrice,
    ScheduledShippingDays,
    ActualShippingDays,
    ShippingDelayDays
)
SELECT
    st.Order_Item_Id,
    st.Order_Id,

    c.CustomerKey,
    p.ProductKey,

    od.DateKey AS OrderDateKey,
    sd.DateKey AS ShippingDateKey,

    l.LocationKey,
    s.ShippingKey,

    TRY_CONVERT(INT, st.Order_Item_Quantity) AS Quantity,

    TRY_CONVERT(DECIMAL(18,2), st.Sales) AS Sales,

    TRY_CONVERT(DECIMAL(18,2), st.Order_Item_Discount) AS Discount,

    TRY_CONVERT(DECIMAL(18,2), st.Order_Item_Total) AS OrderItemTotal,

    TRY_CONVERT(DECIMAL(18,2), st.Benefit_per_order) AS Profit,

    TRY_CONVERT(DECIMAL(18,2), st.Product_Price) AS ProductPrice,

    TRY_CONVERT(INT, st.Days_for_shipment_scheduled)
        AS ScheduledShippingDays,

    TRY_CONVERT(INT, st.Days_for_shipping_real)
        AS ActualShippingDays,

    TRY_CONVERT(INT, st.Days_for_shipping_real)
    -
    TRY_CONVERT(INT, st.Days_for_shipment_scheduled)
        AS ShippingDelayDays

FROM dbo.Stg_DataCoSupplyChain st

INNER JOIN DW.DimCustomer c
    ON st.Customer_Id = c.Customer_Id

INNER JOIN DW.DimProduct p
    ON st.Product_Card_Id = p.Product_Card_Id

INNER JOIN DW.DimDate od
    ON CAST(st.order_date_DateOrders AS DATE) = od.FullDate

INNER JOIN DW.DimDate sd
    ON CAST(st.shipping_date_DateOrders AS DATE) = sd.FullDate

INNER JOIN DW.DimLocation l
    ON ISNULL(st.Market, '') = ISNULL(l.Market, '')
    AND ISNULL(st.Order_Region, '') = ISNULL(l.Order_Region, '')
    AND ISNULL(st.Order_Country, '') = ISNULL(l.Order_Country, '')
    AND ISNULL(st.Order_State, '') = ISNULL(l.Order_State, '')
    AND ISNULL(st.Order_City, '') = ISNULL(l.Order_City, '')
    AND ISNULL(st.Order_Zipcode, '') = ISNULL(l.Order_Zipcode, '')

INNER JOIN DW.DimShipping s
    ON ISNULL(st.Shipping_Mode, '') = ISNULL(s.Shipping_Mode, '')
    AND ISNULL(st.Delivery_Status, '') = ISNULL(s.Delivery_Status, '')
    AND TRY_CONVERT(INT, st.Late_delivery_risk) = s.Late_Delivery_Risk;

--Check Fact Row Count
SELECT COUNT(*) AS FactRows
FROM DW.FactOrderItem;

--Check Fact Grain
SELECT
    COUNT(*) AS TotalFactRows,
    COUNT(DISTINCT Order_Item_Id) AS DistinctOrderItems,
    MIN(Order_Item_Id) AS MinOrderItemId,
    MAX(Order_Item_Id) AS MaxOrderItemId
FROM DW.FactOrderItem;

--Check for NULL foreign keys
SELECT
    SUM(CASE WHEN CustomerKey IS NULL THEN 1 ELSE 0 END) AS NullCustomerKeys,
    SUM(CASE WHEN ProductKey IS NULL THEN 1 ELSE 0 END) AS NullProductKeys,
    SUM(CASE WHEN OrderDateKey IS NULL THEN 1 ELSE 0 END) AS NullOrderDateKeys,
    SUM(CASE WHEN ShippingDateKey IS NULL THEN 1 ELSE 0 END) AS NullShippingDateKeys,
    SUM(CASE WHEN LocationKey IS NULL THEN 1 ELSE 0 END) AS NullLocationKeys,
    SUM(CASE WHEN ShippingKey IS NULL THEN 1 ELSE 0 END) AS NullShippingKeys
FROM DW.FactOrderItem;

--Check the Measures
SELECT
    COUNT(*) AS FactRows,

    SUM(Quantity) AS TotalQuantity,
    SUM(Sales) AS TotalSales,
    SUM(Discount) AS TotalDiscount,
    SUM(OrderItemTotal) AS TotalOrderItemValue,
    SUM(Profit) AS TotalProfit,

    AVG(ActualShippingDays) AS AvgActualShippingDays,
    AVG(ScheduledShippingDays) AS AvgScheduledShippingDays,
    AVG(ShippingDelayDays) AS AvgShippingDelayDays

FROM DW.FactOrderItem;

--perform a Fact-vs-Staging reconciliation.
SELECT
    -- Row counts
    (SELECT COUNT(*)
     FROM dbo.Stg_DataCoSupplyChain) AS StagingRows,

    (SELECT COUNT(*)
     FROM DW.FactOrderItem) AS FactRows,

    -- Quantity
    (SELECT SUM(TRY_CONVERT(INT, Order_Item_Quantity))
     FROM dbo.Stg_DataCoSupplyChain) AS StagingQuantity,

    (SELECT SUM(Quantity)
     FROM DW.FactOrderItem) AS FactQuantity,

    -- Sales
    (SELECT SUM(TRY_CONVERT(DECIMAL(18,2), Sales))
     FROM dbo.Stg_DataCoSupplyChain) AS StagingSales,

    (SELECT SUM(Sales)
     FROM DW.FactOrderItem) AS FactSales,

    -- Discount
    (SELECT SUM(TRY_CONVERT(DECIMAL(18,2), Order_Item_Discount))
     FROM dbo.Stg_DataCoSupplyChain) AS StagingDiscount,

    (SELECT SUM(Discount)
     FROM DW.FactOrderItem) AS FactDiscount,

    -- Order Item Total
    (SELECT SUM(TRY_CONVERT(DECIMAL(18,2), Order_Item_Total))
     FROM dbo.Stg_DataCoSupplyChain) AS StagingOrderItemTotal,

    (SELECT SUM(OrderItemTotal)
     FROM DW.FactOrderItem) AS FactOrderItemTotal,

    -- Profit
    (SELECT SUM(TRY_CONVERT(DECIMAL(18,2), Benefit_per_order))
     FROM dbo.Stg_DataCoSupplyChain) AS StagingProfit,

    (SELECT SUM(Profit)
     FROM DW.FactOrderItem) AS FactProfit;

--------------------------------------------------------
--Data Mart
SELECT 'DimCustomer' AS TableName, COUNT(*) AS Row_Count
FROM DW.DimCustomer

UNION ALL

SELECT 'DimProduct', COUNT(*)
FROM DW.DimProduct

UNION ALL

SELECT 'DimDate', COUNT(*)
FROM DW.DimDate

UNION ALL

SELECT 'DimLocation', COUNT(*)
FROM DW.DimLocation

UNION ALL

SELECT 'DimShipping', COUNT(*)
FROM DW.DimShipping

UNION ALL

SELECT 'FactOrderItem', COUNT(*)
FROM DW.FactOrderItem;

--inspect the delivery performance available in your DW
SELECT
    s.Delivery_Status,
    s.Shipping_Mode,
    COUNT(*) AS OrderItemCount,
    SUM(f.Quantity) AS TotalQuantity,
    SUM(f.Sales) AS TotalSales,
    SUM(f.Profit) AS TotalProfit,
    AVG(f.ActualShippingDays) AS AvgActualShippingDays,
    AVG(f.ScheduledShippingDays) AS AvgScheduledShippingDays,
    AVG(f.ShippingDelayDays) AS AvgShippingDelayDays
FROM DW.FactOrderItem f
INNER JOIN DW.DimShipping s
    ON f.ShippingKey = s.ShippingKey
GROUP BY
    s.Delivery_Status,
    s.Shipping_Mode
ORDER BY
    s.Delivery_Status,
    s.Shipping_Mode;

---------------------------------------------------------------------------------
--Check your foreign keys
SELECT
    fk.name AS ForeignKeyName,
    OBJECT_SCHEMA_NAME(fk.parent_object_id) AS FactSchema,
    OBJECT_NAME(fk.parent_object_id) AS FactTable,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS FactColumn,
    OBJECT_SCHEMA_NAME(fk.referenced_object_id) AS DimensionSchema,
    OBJECT_NAME(fk.referenced_object_id) AS DimensionTable,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS DimensionColumn
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id
WHERE fk.parent_object_id = OBJECT_ID('DW.FactOrderItem');