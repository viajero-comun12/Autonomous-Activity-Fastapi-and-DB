USE AdventureWorksLT2019;
GO

/* 
Ejercicio 1: Catalogo de productos.
a) Liste los colores distintos registrados en los productos, sin repeticiones y sin incluir los productos que no tienen color asignado.
b) Muestre los diez productos de mayor margen bruto. Proyecte código, nombre, precio de lista, costo estándar, el margen bruto calculado como la diferencia entre ambos, 
y el margen expresado en porcentaje del precio de lista. Todas las cabeceras deben mostrarse en español mediante alias.

JUSTIFICACIÓN TÉCNICA:
Se utiliza DISTINCT para eliminar la redundancia de colores repetidos y la cláusula WHERE Color IS NOT NULL para filtrar de los valores nulos, 
respetando la lógica trievaluada del lenguaje SQL. Para el item b, se emplea el uso de TOP 10 junto a ORDER BY [Margen Bruto] DESC con el fin de seleccionar estrictamente los registros con mayor rentabilidad, 
aplicando alias descriptivos en español tanto para claridad como para el cálculo en porcentaje del precio de lista.
 */

-- a) Colores distintos
SELECT DISTINCT 
    Color AS [Color]
FROM SalesLT.Product
WHERE Color IS NOT NULL
ORDER BY Color ASC;

-- Filas obtenidas: 9

-- b) Top 10 productos de mayor margen bruto
SELECT TOP 10
    ProductID AS [Código de Producto],
    Name AS [Nombre de Producto],
    ListPrice AS [Precio de Lista],
    StandardCost AS [Costo Estándar],
    (ListPrice - StandardCost) AS [Margen Bruto],
    ROUND(((ListPrice - StandardCost) / ListPrice) * 100, 2) AS [Porcentaje Margen Bruto]
FROM SalesLT.Product
WHERE ListPrice > 0
ORDER BY [Margen Bruto] DESC;

-- Filas obtenidas: 10

GO

/* 
Ejercicio 2: Filtrado del catálogo.
a) Obtenga los productos cuyo precio de lista este entre 100 y 1000, cuyo nombre contenga la palabra Frame y cuyo color sea Black, Red o Silver. Ordene por color ascendente y, dentro de cada color, por precio descendente. Use BETWEEN, LIKE e IN.
b) Determine cuantos productos no tienen color registrado. Explique en el comentario por que la condición no puede escribirse con el operador igual.

JUSTIFICACIÓN TÉCNICA:
Se emplean las palabras clave relacionales BETWEEN para el rango inclusivo de precios, LIKE con comodines '%Frame%' para la búsqueda de cadenas subtextuales, e IN para listar de forma concisa un conjunto discreto de colores válidos. 
Para el item b, la condición no puede usarse con el operador igual (= NULL), porque en SQL el valor NULL representa la ausencia de un dato o un estado 'desconocido'. Por lo que toda comparación con NULL mediante '=' resulta en UNKNOWN 
según la lógica trievaluada, por lo que exige el operador IS NULL.
 */

-- a) Productos filtrados por rango, nombre y color
SELECT 
    ProductID AS [Código],
    Name AS [Nombre],
    Color AS [Color],
    ListPrice AS [Precio de Lista]
FROM SalesLT.Product
WHERE ListPrice BETWEEN 100 AND 1000
  AND Name LIKE '%Frame%'
  AND Color IN ('Black', 'Red', 'Silver')
ORDER BY Color ASC, ListPrice DESC;
-- Filas obtenidas: 35

-- b) Cantidad de productos sin color registrado

SELECT 
    COUNT(*) AS [Productos Sin Color]
FROM SalesLT.Product
WHERE Color IS NULL;
-- Filas obtenidas: 1
GO


/* 
Ejercicio 3: Líneas de venta por categoría.
Usando tres tablas encadenadas con INNER JOIN, muestre las quince líneas de pedido de mayor valor con la categoría del producto, el nombre del producto, la cantidad, el precio unitario y el total de la línea.

JUSTIFICACIÓN TÉCNICA:
Se seleccionan las tablas SalesOrderDetail, Product y ProductCategory mediante INNER JOIN estricto, 
dado que se requiere analizar únicamente los datos con correspondencia garantizada (ventas registradas de productos existentes asignados a una categoría). 
No se emplean OUTER JOINs porque las líneas que padezcan de producto o categoría no forman parte válida de la analítica del negocio.
 */

SELECT TOP 15
    pc.Name AS [Categoría],
    p.Name AS [Producto],
    sod.OrderQty AS [Cantidad],
    sod.UnitPrice AS [Precio Unitario],
    sod.LineTotal AS [Total de Línea]
FROM SalesLT.SalesOrderDetail sod
INNER JOIN SalesLT.Product p 
    ON sod.ProductID = p.ProductID
INNER JOIN SalesLT.ProductCategory pc 
    ON p.ProductCategoryID = pc.ProductCategoryID
ORDER BY sod.LineTotal DESC;
-- Filas obtenidas: 15
GO


/* 
Ejercicio 4: Auditoria de catalogo.
Identifique los productos que nunca han sido vendidos. Resuélvalo con LEFT JOIN y filtrado por valor nulo, es decir el patrón anti join. Indique en el comentario por que la columna elegida para el filtro es la adecuada.

JUSTIFICACIÓN TÉCNICA:
Se aplica el patrón Anti-Join mediante un LEFT JOIN desde la tabla de productos (SalesLT.Product) hacia la tabla de detalle de ventas (SalesLT.SalesOrderDetail), 
aplicando WHERE sod.SalesOrderDetailID IS NULL. La columna SalesOrderDetailID es la adecuada para este filtro porque es la clave primaria (Primary Key) de la tabla secundaria, 
garantizando que nunca contenga valores NULL por definición propia salvo cuando la combinación de tablas falla por falta de coincidencia.
*/

SELECT 
    p.ProductID AS [Código de Producto],
    p.Name AS [Nombre de Producto],
    p.ProductNumber AS [Número de Producto],
    p.ListPrice AS [Precio de Lista]
FROM SalesLT.Product p
LEFT JOIN SalesLT.SalesOrderDetail sod 
    ON p.ProductID = sod.ProductID
WHERE sod.SalesOrderDetailID IS NULL;
-- Filas obtenidas: 153
GO


/* 
Ejercicio 5: Jerarquía y escenario de prueba.
a) Con un SELF JOIN sobre la tabla de categorías, muestre cada subcategoría junto al nombre de su categoría padre. Explique en el comentario que representa la columna que enlaza la tabla consigo misma.
b) Con un CROSS JOIN, genere la matriz de cobertura comercial que combina cada categoría raíz con cada país presente en las direcciones. Indique cuantas filas produce y justifique ese numero a partir del producto cartesiano.

JUSTIFICACIÓN TÉCNICA:
En a), se utiliza un INNER/LEFT SELF JOIN sobre SalesLT.ProductCategory para modelar la relación jerárquica padre-hijo; la columna que realiza el enlace es ParentProductCategoryID, la 
cual actúa como clave foránea autorreferencial apuntando hacia la clave primaria ProductCategoryID de la misma tabla. 

En b), el CROSS JOIN genera un producto cartesiano estricto (\(M \times N\)), multiplicando el número de categorías raíz (\(M\)) por el número de países (\(N\)), lo cual sirve para simular escenarios globales de cobertura.
*/

-- a) Self Join jerárquico
SELECT 
    sub.ProductCategoryID AS [ID Subcategoría],
    sub.Name AS [Subcategoría],
    padre.Name AS [Categoría Padre]
FROM SalesLT.ProductCategory sub
INNER JOIN SalesLT.ProductCategory padre 
    ON sub.ParentProductCategoryID = padre.ProductCategoryID;
-- Filas obtenidas: 37

-- b) Matriz de cobertura comercial con CROSS JOIN
SELECT 
    cat.Name AS [Categoría Raíz],
    pais.CountryRegion AS [País]
FROM (
    SELECT Name 
    FROM SalesLT.ProductCategory 
    WHERE ParentProductCategoryID IS NULL
) cat
CROSS JOIN (
    SELECT DISTINCT CountryRegion 
    FROM SalesLT.Address
) pais;
-- Filas obtenidas: 12 (Justificación: 4 categorías raíz * 3 países presentes en las direcciones = 12 filas producidas por el producto cartesiano)
GO


/* 
Ejercicio 6: Subconsultas escalar y multivalor.
a) Liste los productos cuyo precio de lista supera el precio promedio de todo el catalogo, usando una subconsulta escalar. Explique por que no se escribe el promedio como un numero fijo.
b) Liste los clientes que compraron al menos un producto de la categoría Mountain Bikes, usando una subconsulta multivalor con IN.

JUSTIFICACIÓN TÉCNICA:
En a), se emplea una subconsulta escalar para calcular el precio de lista promedio en tiempo de ejecución. No se escribe un valor fijo o "hardcodeado" porque los precios de la base de datos cambian dinámicamente; si se quema un número estático, la consulta pierde vigencia técnica ante cualquier actualización de inventario. En b), la subconsulta retorna una lista de identificadores (multivalor) consumida por el operador IN dentro del filtro principal para obtener clientes.
 */

-- a) Productos por encima del precio promedio general (Subconsulta escalar)
SELECT 
    ProductID AS [Código],
    Name AS [Nombre],
    ListPrice AS [Precio de Lista]
FROM SalesLT.Product
WHERE ListPrice > (
    SELECT AVG(ListPrice) 
    FROM SalesLT.Product
)
ORDER BY ListPrice DESC;
-- Filas obtenidas: 102

-- b) Clientes que compraron 'Mountain Bikes' (Subconsulta multivalor)
SELECT 
    CustomerID AS [ID Cliente],
    FirstName AS [Nombre],
    LastName AS [Apellido],
    CompanyName AS [Empresa]
FROM SalesLT.Customer
WHERE CustomerID IN (
    SELECT soh.CustomerID
    FROM SalesLT.SalesOrderHeader soh
    INNER JOIN SalesLT.SalesOrderDetail sod 
        ON soh.SalesOrderID = sod.SalesOrderID
    INNER JOIN SalesLT.Product p 
        ON sod.ProductID = p.ProductID
    INNER JOIN SalesLT.ProductCategory pc 
        ON p.ProductCategoryID = pc.ProductCategoryID
    WHERE pc.Name = 'Mountain Bikes'
);
-- Filas obtenidas: 8
GO


/* 
Ejercicio 7: Subconsulta correlacionada y de existencia.
a) Liste los productos cuyo precio supera el promedio de su propia categoría. Explique en el comentario cuantas veces se evalúa el bloque interno y por que no puede resolverse una sola vez.
b) Cuente los clientes que nunca han registrado un pedido, usando NOT EXISTS. Justifique por qué NOT EXISTS es preferible a NOT IN en esta consulta.

JUSTIFICACIÓN TÉCNICA:
En a), la subconsulta se evalúa N veces (una vez por cada fila analizada en la consulta externa) porque depende del ProductCategoryID actual de cada registro de la tabla externa. No se evalúa una sola vez porque el promedio cambia dependiendo de la categoría en cuestión. 

En b), NOT EXISTS evalúa únicamente la existencia de coincidencia mediante un valor booleano y es resistente al comportamiento ambiguo que presenta NOT IN si la subconsulta llegase a devolver un valor NULL.
*/

-- a) Productos cuyo precio supera el promedio de su propia categoría
SELECT 
    p1.ProductID AS [Código],
    p1.Name AS [Nombre],
    p1.ProductCategoryID AS [ID Categoría],
    p1.ListPrice AS [Precio de Lista]
FROM SalesLT.Product p1
WHERE p1.ListPrice > (
    SELECT AVG(p2.ListPrice)
    FROM SalesLT.Product p2
    WHERE p2.ProductCategoryID = p1.ProductCategoryID
)
ORDER BY p1.ProductCategoryID, p1.ListPrice DESC;
-- Filas obtenidas: 116

-- b) Conteo de clientes sin pedidos usando NOT EXISTS
SELECT 
    COUNT(*) AS [Clientes Sin Pedidos]
FROM SalesLT.Customer c
WHERE NOT EXISTS (
    SELECT 1 
    FROM SalesLT.SalesOrderHeader soh
    WHERE soh.CustomerID = c.CustomerID
);
-- Filas obtenidas: 1 (Resultado del conteo: 815)



/* 
Ejercicio 8: Tabla temporal y reporte final.
Construya una tabla temporal local llamada #ResumenCategoria que consolide, por categoría de producto, el numero de pedidos, las unidades vendidas y el monto total vendido. Consulte esa tabla temporal para mostrar únicamente las categorías cuyo monto vendido supera el promedio de todas las categorías, y libere la estructura al terminar. Verifique previamente la existencia del objeto antes de crearlo, de modo que el archivo pueda ejecutarse mas de una vez sin error.

JUSTIFICACIÓN TÉCNICA:
Se emplea una tabla temporal local (#ResumenCategoria) con verificación previa (OBJECT_ID) para aislar y procesar cálculos agregados complejos de manera modular en lugar de rehacer costosas agrupaciones múltiples en tiempo real. La tabla temporal se destruye explícitamente con DROP TABLE al finalizar para garantizar el manejo limpio de memoria en la sesión actual de SSMS.
*/

-- 1. Verificación e inactivación previa si ya existe la tabla temporal
IF OBJECT_ID('tempdb..#ResumenCategoria') IS NOT NULL
    DROP TABLE #ResumenCategoria;

-- 2. Creación y consolidación de datos en la tabla temporal local
SELECT 
    pc.Name AS Categoria,
    COUNT(DISTINCT sod.SalesOrderID) AS CantidadPedidos,
    SUM(sod.OrderQty) AS UnidadesVendidas,
    SUM(sod.LineTotal) AS MontoTotalVendido
INTO #ResumenCategoria
FROM SalesLT.ProductCategory pc
INNER JOIN SalesLT.Product p 
    ON pc.ProductCategoryID = p.ProductCategoryID
INNER JOIN SalesLT.SalesOrderDetail sod 
    ON p.ProductID = sod.ProductID
GROUP BY pc.Name;

-- 3. Consulta del reporte final (categorías por encima del promedio global)
SELECT 
    Categoria AS [Categoría de Producto],
    CantidadPedidos AS [Número de Pedidos],
    UnidadesVendidas AS [Unidades Vendidas],
    MontoTotalVendido AS [Monto Total Vendido]
FROM #ResumenCategoria
WHERE MontoTotalVendido > (
    SELECT AVG(MontoTotalVendido) 
    FROM #ResumenCategoria
)
ORDER BY MontoTotalVendido DESC;
-- Filas obtenidas: 4

-- 4. Liberación limpia de la estructura temporal
DROP TABLE #ResumenCategoria;
GO



/* 
5. DECLARACIÓN DE USO DE INTELIGENCIA ARTIFICIAL

5.1. Herramientas utilizadas (nombre y versión):

- Gemini (Modelo 1.5 Pro / Flash).

5.2. Ejercicios en los que se utilizó:
- Ejercicios 1 al 8 y estructuración del bloque final.

5.3. Tipo de uso:
- Generación inicial de la estructura de consultas SQL, apoyo en la redacción técnica de 
justificaciones analíticas y revisión de sintaxis T-SQL.

5.4. Ejemplo de una indicación utilizada:

- "Escribe una consulta en Transact-SQL para AdventureWorksLT2019 
que realice un Anti-Join entre Product y SalesOrderDetail 
para identificar productos no vendidos e incluye la justificación técnica 
de por qué elegir la clave primaria en el filtro IS NULL."

5.5. Cómo el grupo verificó la salida de la herramienta:

- Se ejecutó el script de manera secuencial dentro de SQL Server Management Studio (SSMS) sobre la base de datos AdventureWorksLT2019.
- Se constató manualmente la ausencia de errores sintácticos o lógicos.
- Se verificó que el conteo de filas de cada ejercicio coincidiera con los datos reales almacenados en las tablas SalesLT.

5.6. Qué aportó el grupo por cuenta propia:

- Análisis de la estructura del modelo relacional de AdventureWorksLT2019.
- Adaptación de alias descriptivos en español según los requerimientos académicos.
- Verificación manual de la cardinalidad en los operadores JOIN (especialmente en la comprobación del producto cartesiano del Ejercicio 5b).
- Corrección del flujo de validación `OBJECT_ID` para tablas temporales.
*/


