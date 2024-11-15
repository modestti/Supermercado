-------------------------------------------------------------------------------------------------------------
---------------------------------------------- CATALOGOS ----------------------------------------------------
-------------------------------------------------------------------------------------------------------------

----------------------------------------- PRODUCTOS ELECTRONICOS --------------------------------------------
EXECUTE Prod.importarProductosElectronicos  @RutaArchivo = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Productos\Electronic accessories.xlsx', @nombreHoja ='Sheet1$' 
SELECT * FROM Prod.Catalogo ---VERIFICO QUE SE HAYA IMPORTADO A LA TABLA
GO

------------------------------------------ PRODUCTOS IMPORTADOS ---------------------------------------------
EXECUTE Prod.importarProductosImportados @RutaArchivo='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Productos\Productos_importados.xlsx', @NombreHoja='Listado de Productos$' 
SELECT * FROM Prod.Catalogo ---VERIFICO QUE SE HAYA IMPORTADO A LA TABLA
GO

---------------------------------------------- CATALOGO GENERAL ---------------------------------------------
EXECUTE Prod.importarCatalogo 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Productos\catalogo.csv';
GO
SELECT * FROM Prod.Catalogo ---VERIFICO QUE SE HAYA IMPORTADO A LA TABLA
GO
-------------------------------------------------------------------------------------------------------------
----------------------------------------- INFORMACION COMPLEMENTARIA ----------------------------------------
-------------------------------------------------------------------------------------------------------------

----------------------------------------------- CLASIFICACION -----------------------------------------------
EXECUTE Prod.importarClasificacionProductos @RutaArchivo='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Informacion_complementaria.xlsx', @nombreHoja = 'Clasificacion productos$'
GO
SELECT * FROM Prod.Clasificacion
GO

-------------------------------------------------- SUCURSAL -------------------------------------------------
EXECUTE Info.importarSucursal @RutaArchivo='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Informacion_complementaria.xlsx', @nombreHoja = 'sucursal$'
GO
SELECT * FROM Info.Sucursal
GO

------------------------------------------------- EMPLEADOS -------------------------------------------------
EXECUTE Info.importarEmpleados @RutaArchivo='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Informacion_complementaria.xlsx', @nombreHoja = 'Empleados$'
SELECT * FROM Info.Empleado
GO

-------------------------------------------------------------------------------------------------------------
---------------------------------------------- VENTAS REGISTRADAS -------------------------------------------
-------------------------------------------------------------------------------------------------------------
EXECUTE Ven.importarVentas 'C:\Users\tomas\Documents\GitHub\Supermercado\Grupo_03\TP_integrador_Archivos\Ventas_registradas.csv'
GO
SELECT * FROM Ven.Factura;
GO

WITH eliminar_facturas_duplicadas AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY IdFactura ORDER BY IdFactura) AS NumeroFila   -- CTE para identificar duplicados en IdFactura
    FROM Ven.Factura
)
DELETE FROM eliminar_facturas_duplicadas WHERE NumeroFila > 1;
