USE Com5600G03
GO
------------------------------------------------------------------
------------------ PRUEBAS DE IMPORTACIONES ----------------------
------------------------------------------------------------------
---ARCHIVO DE EMPLEADOS
EXECUTE Info.importarEmpleados @RutaArchivo='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Informacion_complementaria.xlsx', @nombreHoja = 'Empleados$'
SELECT * FROM Info.Empleado
GO
---ARCHIVO CLASIFICACIONES 
EXECUTE Prod.importarClasificacionProductos @RutaArchivo='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Informacion_complementaria.xlsx', @nombreHoja = 'Clasificacion productos$'
SELECT * FROM Prod.Clasificacion
GO
---ARCHIVO CATALOGO
EXECUTE Prod.importarCatalogo 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Productos\catalogo.csv';
SELECT * FROM Prod.Catalogo
GO
---ARCHIVO IMPORTADOS
EXECUTE Prod.importarProductosElectronicos  @RutaArchivo = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Productos\Electronic accessories.xlsx', @nombreHoja ='Sheet1$' 
SELECT * FROM Prod.Catalogo
GO
---ARCHIVO ELECTRONICOS
EXECUTE Prod.importarProductosImportados @RutaArchivo='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Productos\Productos_importados.xlsx', @NombreHoja='Listado de Productos$' 
SELECT * FROM Prod.Catalogo ---VERIFICO QUE SE HAYA IMPORTADO A LA TABLA
GO
---ARCHIVO DE SUCURSAL
EXECUTE Info.importarSucursal @RutaArchivo='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Informacion_complementaria.xlsx', @nombreHoja = 'sucursal$'
SELECT * FROM Info.Sucursal
GO
---ARCHIVO DE VENTAS
EXECUTE  Ven.importarVentas @RutaArchivo ='C:\Users\tomas\Documents\GitHub\Supermercado\Grupo_03\TP_integrador_Archivos\Ventas_registradas.csv'
SELECT * FROM Ven.Venta
SELECT * FROM Ven.Factura
SELECT * FROM Ven.Detalle_Venta
