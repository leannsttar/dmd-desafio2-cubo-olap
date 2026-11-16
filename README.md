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

## Sobre el despliegue
Lo habitual es desplegar y procesar el cubo con **Deploy** en Visual Studio. Aquí no fue posible: la extensión de Visual Studio no reconoce la edición *Standard Developer* de SQL Server 2025 y falla con *"The current edition 'StandardDeveloper64' of the target SQL Server Analysis Services instance is not supported by the client"*.

`04_desplegar_cubo.ps1` hace lo mismo que Deploy: toma la definición que genera Visual Studio al compilar (`bin/AW_Cubo_Ventas.asdatabase`), la envía al servidor por el proveedor MSOLAP (compatible con esa edición), procesa la base y verifica los totales. El diseño del cubo no cambia; solo cambia la herramienta que lo envía al servidor. En un servidor donde Deploy funcione, el script no es necesario.
