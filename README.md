# Cubo OLAP de ventas: Adventure Works

Desafío Práctico 2 · Datawarehouse y Minería de Datos (DMD 941) · Universidad Don Bosco
Leandro Alberto Valencia Escobar · VE242685

Cubo OLAP multidimensional sobre **AdventureWorksDW2022**, consultado con MDX y visualizado en Power BI.
Documento de entrega: [`Desafio2_DMD941_VE242685.pdf`](Desafio2_DMD941_VE242685.pdf)

## Contenido
| Ruta | Descripción |
|---|---|
| `Cubo/AW_Cubo_Ventas/` | Proyecto de Analysis Services: data source, DSV, dimensiones (Fecha, Producto, Territorio) y cubo |
| `PowerBI/Dashboard_AW.pbix` | Dashboard de 3 páginas con conexión en vivo al cubo |
| `scripts/01_exploracion.sql` | Exploración de tablas, medidas e integridad |
| `scripts/02_consultas_sql.sql` | Preguntas de negocio en T-SQL (control de resultados) |
| `scripts/03_consultas_mdx.mdx` | Preguntas de negocio en MDX sobre el cubo |
| `scripts/04_desplegar_cubo.ps1` | Despliegue y procesamiento del cubo |

## Requisitos
SQL Server 2025, Analysis Services en modo Multidimensional, Visual Studio con *Analysis Services Projects*, SSMS y Power BI Desktop.

## Ejecución
1. Restaurar `AdventureWorksDW2022.bak` ([descarga](https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks)).
2. Abrir el proyecto del cubo en Visual Studio y compilarlo.
3. Desplegar y procesar: `powershell -ExecutionPolicy Bypass -File scripts/04_desplegar_cubo.ps1`
4. Ejecutar `scripts/03_consultas_mdx.mdx` en SSMS (conexión a Analysis Services).
5. Abrir `PowerBI/Dashboard_AW.pbix`.

Visual Studio no puede desplegar en la edición *Standard Developer* de SQL Server 2025, por eso el paso 3 usa un script.
