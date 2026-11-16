-- Preguntas de negocio en T-SQL, usadas como control de los resultados del cubo.
-- Ganancia = SalesAmount - TotalProductCost
USE AdventureWorksDW2022;
GO

-- Une ambos canales de venta en una sola vista
CREATE OR ALTER VIEW dbo.vw_VentasCanales
AS
SELECT 'Internet' AS Canal, ProductKey, OrderDateKey, SalesTerritoryKey,
       OrderQuantity, SalesAmount, TotalProductCost
FROM dbo.FactInternetSales
UNION ALL
SELECT 'Reseller', ProductKey, OrderDateKey, SalesTerritoryKey,
       OrderQuantity, SalesAmount, TotalProductCost
FROM dbo.FactResellerSales;
GO

-- a.1 Top 5 subcategorías por ventas en cada año
WITH VentasSub AS (
    SELECT d.CalendarYear                  AS Anio,
           c.EnglishProductCategoryName    AS Categoria,
           s.EnglishProductSubcategoryName AS Subcategoria,
           SUM(v.SalesAmount)              AS Ventas,
           SUM(v.OrderQuantity)            AS Unidades
    FROM dbo.vw_VentasCanales v
    JOIN dbo.DimDate               d ON d.DateKey               = v.OrderDateKey
    JOIN dbo.DimProduct            p ON p.ProductKey            = v.ProductKey
    JOIN dbo.DimProductSubcategory s ON s.ProductSubcategoryKey = p.ProductSubcategoryKey
    JOIN dbo.DimProductCategory    c ON c.ProductCategoryKey    = s.ProductCategoryKey
    GROUP BY d.CalendarYear, c.EnglishProductCategoryName, s.EnglishProductSubcategoryName
)
SELECT Anio, Ranking, Categoria, Subcategoria, Ventas, Unidades
FROM (SELECT *, RANK() OVER (PARTITION BY Anio ORDER BY Ventas DESC) AS Ranking FROM VentasSub) x
WHERE Ranking <= 5
ORDER BY Anio, Ranking;
GO

-- a.2 Ventas por categoría y trimestre con variación respecto al trimestre anterior
WITH VentasTrim AS (
    SELECT c.EnglishProductCategoryName AS Categoria,
           d.CalendarYear               AS Anio,
           d.CalendarQuarter            AS Trimestre,
           SUM(v.SalesAmount)           AS Ventas
    FROM dbo.vw_VentasCanales v
    JOIN dbo.DimDate               d ON d.DateKey               = v.OrderDateKey
    JOIN dbo.DimProduct            p ON p.ProductKey            = v.ProductKey
    JOIN dbo.DimProductSubcategory s ON s.ProductSubcategoryKey = p.ProductSubcategoryKey
    JOIN dbo.DimProductCategory    c ON c.ProductCategoryKey    = s.ProductCategoryKey
    GROUP BY c.EnglishProductCategoryName, d.CalendarYear, d.CalendarQuarter
),
ConAnterior AS (
    SELECT *, LAG(Ventas) OVER (PARTITION BY Categoria ORDER BY Anio, Trimestre) AS VentasTrimAnterior
    FROM VentasTrim
)
SELECT Categoria, Anio, Trimestre, Ventas, VentasTrimAnterior,
       CAST(100.0 * (Ventas - VentasTrimAnterior) / NULLIF(VentasTrimAnterior, 0) AS DECIMAL(10,2)) AS VariacionQoQ_Pct
FROM ConAnterior
ORDER BY Categoria, Anio, Trimestre;
GO

-- b.1 Ganancia por territorio, separada por canal
SELECT t.SalesTerritoryGroup   AS Grupo,
       t.SalesTerritoryCountry AS Pais,
       t.SalesTerritoryRegion  AS Region,
       SUM(CASE WHEN v.Canal = 'Internet' THEN v.SalesAmount END)                      AS VentasInternet,
       SUM(CASE WHEN v.Canal = 'Reseller' THEN v.SalesAmount END)                      AS VentasReseller,
       SUM(CASE WHEN v.Canal = 'Internet' THEN v.SalesAmount - v.TotalProductCost END) AS GananciaInternet,
       SUM(CASE WHEN v.Canal = 'Reseller' THEN v.SalesAmount - v.TotalProductCost END) AS GananciaReseller,
       SUM(v.SalesAmount - v.TotalProductCost)                                         AS GananciaTotal,
       CAST(100.0 * SUM(v.SalesAmount - v.TotalProductCost) / SUM(v.SalesAmount) AS DECIMAL(6,2)) AS MargenPct
FROM dbo.vw_VentasCanales v
JOIN dbo.DimSalesTerritory t ON t.SalesTerritoryKey = v.SalesTerritoryKey
GROUP BY t.SalesTerritoryGroup, t.SalesTerritoryCountry, t.SalesTerritoryRegion
ORDER BY GananciaTotal DESC;
GO

-- c.1 Top 10 productos por ganancia (agrupados por nombre: un producto puede tener varias claves)
SELECT TOP (10)
       p.EnglishProductName                    AS Producto,
       SUM(v.SalesAmount)                      AS Ventas,
       SUM(v.SalesAmount - v.TotalProductCost) AS Ganancia,
       CAST(100.0 * SUM(v.SalesAmount - v.TotalProductCost) / SUM(v.SalesAmount) AS DECIMAL(6,2)) AS MargenPct
FROM dbo.vw_VentasCanales v
JOIN dbo.DimProduct p ON p.ProductKey = v.ProductKey
GROUP BY p.EnglishProductName
ORDER BY Ganancia DESC;
GO

-- c.2 Ganancia del Top 10 por año y trimestre
WITH Top10 AS (
    SELECT TOP (10) p.EnglishProductName AS Producto
    FROM dbo.vw_VentasCanales v
    JOIN dbo.DimProduct p ON p.ProductKey = v.ProductKey
    GROUP BY p.EnglishProductName
    ORDER BY SUM(v.SalesAmount - v.TotalProductCost) DESC
)
SELECT p.EnglishProductName AS Producto,
       d.CalendarYear       AS Anio,
       SUM(CASE WHEN d.CalendarQuarter = 1 THEN v.SalesAmount - v.TotalProductCost ELSE 0 END) AS T1,
       SUM(CASE WHEN d.CalendarQuarter = 2 THEN v.SalesAmount - v.TotalProductCost ELSE 0 END) AS T2,
       SUM(CASE WHEN d.CalendarQuarter = 3 THEN v.SalesAmount - v.TotalProductCost ELSE 0 END) AS T3,
       SUM(CASE WHEN d.CalendarQuarter = 4 THEN v.SalesAmount - v.TotalProductCost ELSE 0 END) AS T4,
       SUM(v.SalesAmount - v.TotalProductCost) AS TotalAnio
FROM dbo.vw_VentasCanales v
JOIN dbo.DimProduct p ON p.ProductKey = v.ProductKey
JOIN dbo.DimDate    d ON d.DateKey    = v.OrderDateKey
WHERE p.EnglishProductName IN (SELECT Producto FROM Top10)
GROUP BY p.EnglishProductName, d.CalendarYear
ORDER BY p.EnglishProductName, d.CalendarYear;
GO
