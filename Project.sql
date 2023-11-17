
--- EXPLORING
-- PRODUCT TABLE

select B.ProductID,
A.ProductSubcategoryID,
C.Name as ProductName ,
B.Name as ProductSubcategoryName ,
B.ProductNumber,
B.StandardCost,
(B.StandardCost*SSOD.OrderQty) AS TOTALCOST,
SSOD.UnitPrice,
(SSOD.LineTotal-B.StandardCost*SSOD.OrderQty) AS TotalProfit
from Production.ProductSubcategory as A
inner JOIN Production.Product as B
on A.ProductSubcategoryID = B.ProductSubcategoryID
inner join Production.ProductCategory C
on A.ProductCategoryID = C.ProductCategoryID
inner JOIN Sales.SalesOrderDetail SSOD
ON B.ProductID = SSOD.ProductID
order by ProductID ASC;

-- KEY MEASURES TABLE
select SSOD.SalesOrderID,
PP.ProductID,
SSOD.LineTotal as Revenue,
(PP.StandardCost*SSOD.OrderQty) AS TOTALCOST,
(SSOD.LineTotal-PP.StandardCost*SSOD.OrderQty) AS TotalProfit
from Sales.SalesOrderDetail SSOD
left join [Production].[Product] as PP
on SSOD.ProductID = PP.ProductID

Select * from Production.ProductCostHistory
select BusinessEntityID,
BirthDate,
MaritalStatus,
YearlyIncome,
Gender,
TotalChildren,
Education,
Occupation,
case when HomeOwnerFlag  = 1 then 'Homeowner' else 'Tenant'end as HomeOwnerFlag,
NumberCarsOwned
from Sales.vPersonDemographics d
where Education is not null

SELECT 
distinct CustomerID,
A.OnlineOrderFlag
,A.[OrderDate],
A.SalesOrderID
,B.*
FROM [Sales].[SalesOrderHeader] AS A
LEFT JOIN [AdventureWorksDW2017].[dbo].[DimCustomer] AS B
ON A.CustomerID = B.[CustomerKey]
Where A.OnlineOrderFlag = 1


--- SCRAP TABLE
select d.ScrapReasonID,
d.Name as ScrapReasonName,
e.WorkOrderID,
e.ProductID,
e.StockedQty,
e.ScrappedQty
from Production.ScrapReason d
left join Production.WorkOrder e
on d.ScrapReasonID = e.ScrapReasonID
order by ScrapReasonID asc

-- Data for Forecasting
select 
Q.CustomerID,
Q.SalesOrderID,
Q.OrderDate,
P.ProductID,
P.OrderQty,
Q.TerritoryID,
D.Name as TerritoryName,
B.Name as ProductName,
C.Name as ProductSubcategoryName,
((OrderQty * UnitPrice) * (1.0 - UnitPriceDiscount)) Revenue ,
case when Q.[OnlineOrderFlag] = 1 then 'Online' else 'Reseller' end as [SalesChannel]
from Sales.SalesOrderHeader as Q
inner join Sales.SalesTerritory D
on Q.TerritoryID = D.TerritoryID
left join Sales.SalesOrderDetail P
on Q.SalesOrderID = P.SalesOrderID
inner join Production.Product as B
on B.ProductID = P.ProductID
left JOIN Production.ProductSubcategory as C
on B.ProductSubcategoryID = C.ProductSubcategoryID
order by OrderDate ASC; 

---- Market Basket Analysis
SELECT TOP 10 
	SalesOrderID,
	ProductID
FROM Sales.SalesOrderDetail
SELECT TOP 10
	SalesOrderID,
	COUNT(ProductID) AS NumberofProducts
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING COUNT(ProductID) >= 2;
-- step 2  LIST OUT THE SALESORDERNUMBER AND PRODUCTKEY OF ORDERS HAVING AT LEAST TWO PRODUCT KEYS
SELECT
	OrderList.SalesOrderID,
	FIS.ProductID
FROM
	(SELECT
		SalesOrderID,
		COUNT(ProductID) AS NumberofProducts
	FROM Sales.SalesOrderDetail
	GROUP BY SalesOrderID
	HAVING COUNT(ProductID) >= 2) AS OrderList
JOIN Sales.SalesOrderDetail AS FIS ON Orderlist.SalesOrderID = FIS.SalesOrderID;

--3. COMMON TABLE EXPRESSION (CTE)
 WITH Info AS
 (SELECT
	OrderList.SalesOrderID,
	FIS.ProductID
 FROM
	  (SELECT
		SalesOrderID,
		COUNT(ProductID) AS NumberofProducts
	FROM Sales.SalesOrderDetail
		GROUP BY SalesOrderID
		HAVING COUNT(ProductID) >= 2) AS OrderList
	JOIN Sales.SalesOrderDetail AS FIS 
		ON Orderlist.SalesOrderID = FIS.SalesOrderID);

-- MBA

SELECT Top 20 p1, p2, COUNT(*) as numorders
FROM (SELECT op1.SalesOrderID, op1.ProductID as p1, op2.ProductID as p2
FROM (SELECT SalesOrderID
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING COUNT(DISTINCT SalesOrderDetailID) BETWEEN 2 and 10
) filter JOIN
(SELECT DISTINCT SalesOrderID, ProductID FROM Sales.SalesOrderDetail) op1
ON filter.SalesOrderID = op1.SalesOrderID JOIN
(SELECT DISTINCT SalesOrderID, ProductID FROM Sales.SalesOrderDetail) op2
ON op1.SalesOrderID = op2.SalesOrderID AND
op1.ProductId < op2.ProductId
) combinations
GROUP BY p1, p2
order by COUNT(*) desc

 Select a.Name as ProductName, b.ProductID 
from Production.ProductSubcategory a
inner join Production.Product b
on a.ProductSubcategoryID = b.ProductSubcategoryID
select * from Sales.SalesOrderHeader SSOD

-- KEY MEASURE TABLE
select top 10
SSOD.SalesOrderID,
PP.Name as productName,
SSOD.UnitPrice,
SSOD.LineTotal as Revenue,
(PP.StandardCost*SSOD.OrderQty) AS TOTALCOST,
(SSOD.LineTotal-PP.StandardCost*SSOD.OrderQty) AS TotalProfit
from Sales.SalesOrderDetail SSOD
left join [Production].[Product] as PP
on SSOD.ProductID = PP.ProductID


--Sales Table

with CTESemicolonPrefix as (
Select 
ProductID,
StandardCost,
StartDate,
isnull(EndDate, GETDATE()) as 'NewEndDate'
from [Production].[ProductCostHistory])

	Select
	sh.SalesOrderID,sh.CustomerID,
	SalesOrderDetailID, sh.SalesOrderNumber,
	OrderDate,
	OrderQty, 
	sd.ProductID,
	(Select StandardCost from CTESemicolonPrefix where sd.ProductID = ProductID and OrderDate between StartDate and NewEndDate) as UnitCost,
	UnitPrice,
	LineTotal as Revenue, 
	case when OnlineOrderFlag = 1 then 'Online Sales' else 'Reseller Sales' end as OnlineOrderflag,
	sh.TerritoryID 
	--case when Name IS NULL then 'Other' else T.Name end as SalesReasonName

from [Sales].[SalesOrderDetail] sd
inner join Sales.SalesOrderHeader sh
on sd.SalesOrderID = sh.SalesOrderID

--- SCRAP TABLE
select d.ScrapReasonID,
d.Name as ScrapReasonName,
e.WorkOrderID,
e.ProductID,
e.StockedQty,
e.ScrappedQty
from Production.ScrapReason d
left join Production.WorkOrder e
on d.ScrapReasonID = e.ScrapReasonID
order by ScrapReasonID asc


--- Customer Demography Online
SELECT 
A.SalesOrderID,B.CustomerKey,
A.OnlineOrderFlag
,A.[OrderDate],
B.BirthDate,
B.MaritalStatus,
B.Gender,B.YearlyIncome,B.TotalChildren,B.NumberChildrenAtHome,B.NumberCarsOwned,
B.EnglishEducation,B.EnglishOccupation,B.HouseOwnerFlag,B.CommuteDistance
FROM [AdventureWorksDW2017].[dbo].[DimCustomer] AS B
left JOIN [Sales].[SalesOrderHeader] AS A
ON B.[CustomerKey] = A.CustomerID
Where A.OnlineOrderFlag = 1 order by A.SalesOrderID asc

--select distinct CustomerID from Sales.SalesOrderHeader

--select distinct CustomerKey from [AdventureWorksDW2017].[dbo].[DimCustomer]

--Purchasing Table
select a.PurchaseOrderID,
a.VendorID, 
a.ShipMethodID,
a.freight,
c.BusinessEntityID,
b.ProductID,
b.OrderQty,
b.RejectedQty,
a.OrderDate,
a.ShipDate,
b.DueDate,
c.AverageLeadTime
from Purchasing.PurchaseOrderHeader a
inner join Purchasing.PurchaseOrderDetail b
on a.PurchaseOrderID = b.PurchaseOrderID
 right join Purchasing.ProductVendor c
on b.ProductID = c.ProductID
order by PurchaseOrderID
