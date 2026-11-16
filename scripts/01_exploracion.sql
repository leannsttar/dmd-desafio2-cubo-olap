USE AdventureWorksDW2022;
GO

-- Tablas de hechos y dimensiones con su número de filas
SELECT CASE WHEN t.name LIKE 'Fact%' THEN 'Hecho' ELSE 'Dimension' END AS Tipo,
       t.name AS Tabla, SUM(p.rows) AS Filas
FROM sys.tables t
JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
WHERE t.name LIKE 'Fact%' OR t.name LIKE 'Dim%'
GROUP BY t.name
ORDER BY Tipo DESC, Filas DESC;

-- Periodo cubierto por cada canal de venta
SELECT 'Internet' AS Canal, MIN(OrderDate) AS PrimeraVenta, MAX(OrderDate) AS UltimaVenta,
       COUNT(DISTINCT SalesOrderNumber) AS Ordenes
FROM dbo.FactInternetSales
UNION ALL
SELECT 'Reseller', MIN(OrderDate), MAX(OrderDate), COUNT(DISTINCT SalesOrderNumber)
FROM dbo.FactResellerSales;

-- Perfil de las medidas por canal
SELECT 'Internet' AS Canal, SUM(SalesAmount) AS Ventas, SUM(TotalProductCost) AS Costo,
       SUM(SalesAmount - TotalProductCost) AS Ganancia,
       SUM(CASE WHEN SalesAmount IS NULL OR TotalProductCost IS NULL THEN 1 ELSE 0 END) AS Nulos
FROM dbo.FactInternetSales
UNION ALL
SELECT 'Reseller', SUM(SalesAmount), SUM(TotalProductCost),
       SUM(SalesAmount - TotalProductCost),
       SUM(CASE WHEN SalesAmount IS NULL OR TotalProductCost IS NULL THEN 1 ELSE 0 END)
FROM dbo.FactResellerSales;

-- Integridad referencial: ventas sin correspondencia en las dimensiones
SELECT 'Internet sin producto' AS Chequeo, COUNT(*) AS Filas FROM dbo.FactInternetSales f
  LEFT JOIN dbo.DimProduct d ON d.ProductKey = f.ProductKey WHERE d.ProductKey IS NULL
UNION ALL SELECT 'Internet sin territorio', COUNT(*) FROM dbo.FactInternetSales f
  LEFT JOIN dbo.DimSalesTerritory d ON d.SalesTerritoryKey = f.SalesTerritoryKey WHERE d.SalesTerritoryKey IS NULL
UNION ALL SELECT 'Reseller sin producto', COUNT(*) FROM dbo.FactResellerSales f
  LEFT JOIN dbo.DimProduct d ON d.ProductKey = f.ProductKey WHERE d.ProductKey IS NULL
UNION ALL SELECT 'Reseller sin territorio', COUNT(*) FROM dbo.FactResellerSales f
  LEFT JOIN dbo.DimSalesTerritory d ON d.SalesTerritoryKey = f.SalesTerritoryKey WHERE d.SalesTerritoryKey IS NULL;

-- Productos sin subcategoría y nombres de producto repetidos (varias claves por nombre)
SELECT (SELECT COUNT(*) FROM dbo.DimProduct WHERE ProductSubcategoryKey IS NULL) AS SinSubcategoria,
       (SELECT COUNT(*) FROM (SELECT EnglishProductName FROM dbo.DimProduct
                              GROUP BY EnglishProductName HAVING COUNT(*) > 1) x) AS NombresRepetidos;
