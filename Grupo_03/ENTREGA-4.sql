USE Com5600G03
GO

---COMANDO PARA LA IMPORTACION -> PERMITE EJECUTAR UNA CONSULTA DISTRIBUIDA ----
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
EXEC sp_configure;
GO

-------------------------------------------------------------------------------------------------------------
---------------------------------------------- CATALOGOS ----------------------------------------------------
-------------------------------------------------------------------------------------------------------------

----------------------------------------- PRODUCTOS ELECTRONICOS --------------------------------------------

CREATE OR ALTER PROCEDURE Prod.importarProductosElectronicos (@RutaArchivo NVARCHAR(MAX),@NombreHoja NVARCHAR(50))
AS 
BEGIN  
			DECLARE @Consulta nvarchar(MAX)
			--CREAMOS LA TABLA TEMPORAL DONDE VAMOS A DESCARGAR LA INFORMACION DEL ARCHIVO
			CREATE TABLE #ElectronicoTemporal
			(
				Product varchar(100),
				Precio_Unitario_en_dolares decimal(10,2)
			)

			--GENERAMOS LA CONSULTA Y EJECUTAMOS 
			SET @Consulta = N'
				INSERT INTO #ElectronicoTemporal(Product,Precio_Unitario_en_dolares)
					SELECT Product, [Precio Unitario en dolares]
						FROM OPENROWSET(
								''Microsoft.ACE.OLEDB.12.0'',
								''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES;'',
								''SELECT * FROM ['+@nombreHoja+']'');'
			EXEC sp_executesql @Consulta;

			--MUESTRO LA TABLA TEMPORAL PARA COMPROBAR QUE LA INFORMACION SE BAJO CORRECTAMENTE
			SELECT * FROM #ElectronicoTemporal;

			--PASAMOS LA INFORMACION DE LA TABLA TEMPORAL A LA TABLA PRODUCTOS ELECTRONICOS
			INSERT INTO Prod.Electronico(nombre,precioDolares)
				SELECT Product,Precio_Unitario_en_dolares FROM #ElectronicoTemporal

			--ELIMINAMOS LA TABLA TEMPORAL
			PRINT 'Los datos se insertaron exitosamente' 
			DROP TABLE #ElectronicoTemporal
END

EXECUTE Prod.importarProductosElectronicos  @RutaArchivo = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Productos\Electronic accessories.xlsx', @nombreHoja ='Sheet1$' 
SELECT * FROM Prod.Electronico ---VERIFICO QUE SE HAYA IMPORTADO A LA TABLA
GO

------------------------------------------ PRODUCTOS IMPORTADOS ---------------------------------------------
DROP PROCEDURE IF EXISTS Prod.importarProductosImportados
GO
CREATE OR ALTER PROCEDURE Prod.importarProductosImportados (@RutaArchivo nvarchar(MAX), @NombreHoja nvarchar(50))
AS 
BEGIN
		DECLARE @Consulta NVARCHAR(MAX) 
					 CREATE TABLE #ImportadosTemporal
					 (
						IdProducto int,
						NombreProducto varchar(100),
						Proveedor varchar(100),
						Categoría varchar(50),
						CantidadPorUnidad varchar(255),
						PrecioUnidad decimal(10,2)
					) 

				SET @Consulta = N'
					INSERT INTO #ImportadosTemporal(IdProducto,NombreProducto,Proveedor,Categoría,CantidadPorUnidad,PrecioUnidad)
					SELECT IdProducto,NombreProducto,Proveedor,Categoría,CantidadPorUnidad,PrecioUnidad
					FROM OPENROWSET(
						''Microsoft.ACE.OLEDB.12.0'',
						''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES;'',
						''SELECT * FROM ['+@nombreHoja+']'');'

				EXEC sp_executesql @Consulta 

				SELECT * FROM #ImportadosTemporal

				INSERT INTO Prod.Importado(nombre,proveedor,categoria,cantidadXUnidad,precioUnidad)
					SELECT NombreProducto,Proveedor,Categoría,CantidadPorUnidad,PrecioUnidad FROM #ImportadosTemporal
				PRINT 'Los datos se insertaron exitosamente' 
				DROP TABLE #ImportadosTemporal
END 
GO
EXECUTE Prod.importarProductosImportados @RutaArchivo='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Productos\Productos_importados.xlsx', @NombreHoja='Listado de Productos$' 
SELECT * FROM Prod.Importado
GO

---------------------------------------------- CATALOGO GENERAL ---------------------------------------------
DROP PROCEDURE IF EXISTS Prod.importarCatalogo;
GO
CREATE OR ALTER PROCEDURE Prod.importarCatalogo (@RutaArchivo nvarchar(MAX))
AS 
BEGIN 
            CREATE TABLE #CatalogoTemporal 
            (
				id int,
                category nvarchar(255),
                [name] nvarchar(255),
                price nvarchar(100),
                reference_price nvarchar(100), 
                reference_unit nvarchar(50),
                [date] datetime
            );

            DECLARE @Consulta NVARCHAR(MAX) 
            SET @Consulta = N' 
                BULK INSERT #CatalogoTemporal 
                FROM ''' + @RutaArchivo + ''' 
                WITH (
					FORMAT = ''CSV'',
                    FIELDTERMINATOR = '','', 
					ROWTERMINATOR = ''0x0a'', 
					FIRSTROW = 2,               
					CODEPAGE = ''65001'' 
                );';

            EXEC sp_executesql @Consulta 

			SELECT * FROM #CatalogoTemporal;

			DECLARE @idProdCat int 

            -- Inserta en la tabla final haciendo conversión de fecha
			INSERT Prod.Catalogo(categoria, nombre, precio, referenciaPrecio, referenciaUnidad, fecha_hora,idProductoCat)
			SELECT ct.category,[name], TRY_CAST(ct.price AS decimal(10,2)), TRY_CAST(ct.reference_price AS decimal(10,2)), ct.reference_unit,ct.[date],c.IdProducto FROM #CatalogoTemporal ct 
			INNER JOIN  Prod.Clasificacion c on c.producto=ct.category

            PRINT 'Los datos se insertaron exitosamente';
            DROP TABLE #CatalogoTemporal;
END 
GO
EXECUTE Prod.importarCatalogo 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Productos\catalogo.csv';
select * from Prod.Catalogo ---VERIFICO QUE SE HAYA IMPORTADO A LA TABLA
select * from Prod.Clasificacion
GO



-------------------------------------------------------------------------------------------------------------
----------------------------------------- INFORMACION COMPLEMENTARIA ----------------------------------------
-------------------------------------------------------------------------------------------------------------

----------------------------------------------- CLASIFICACION -----------------------------------------------
DROP PROCEDURE IF EXISTS Prod.importarClasificacionProductos
GO
CREATE OR ALTER PROCEDURE Prod.importarClasificacionProductos (@RutaArchivo NVARCHAR(MAX), @NombreHoja NVARCHAR(50))
AS 
BEGIN
 BEGIN TRY
			DECLARE @Consulta nvarchar(MAX)

			CREATE TABLE #ClasificacionTemporal
			(
				lineaProducto varchar(20),
				producto varchar(50)
			) 

			SET @Consulta = N'
				INSERT INTO #ClasificacionTemporal(lineaProducto,producto)
				SELECT *
				FROM OPENROWSET(
				''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES;'',
				''SELECT * FROM ['+@nombreHoja+']'');'
			EXEC sp_executesql @Consulta 

			SELECT * FROM #ClasificacionTemporal
			
			INSERT INTO Prod.Clasificacion(lineaProducto,producto)
			SELECT lineaProducto,producto FROM #ClasificacionTemporal

			PRINT 'Los datos se insertaron exitosamente' 
			DROP TABLE #ClasificacionTemporal
		
 END TRY 
 BEGIN CATCH 
  PRINT 'No se pudieron importar la clasificacion de productos' + @RutaArchivo 
  PRINT ERROR_MESSAGE() 
 END CATCH 
END 
GO
EXECUTE Prod.importarClasificacionProductos @RutaArchivo='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Informacion_complementaria.xlsx', @nombreHoja = 'Clasificacion productos$'
GO
SELECT * FROM Prod.Clasificacion
GO

-------------------------------------------------- SUCURSAL -------------------------------------------------
CREATE OR ALTER PROCEDURE Info.importarSucursal (@RutaArchivo NVARCHAR(MAX), @NombreHoja NVARCHAR(50))
AS 
BEGIN
 BEGIN TRY
			DECLARE @Consulta nvarchar(MAX)

			CREATE TABLE #SucursalTemporal
			(
				ciudad varchar (15),
				reemplazadaX  varchar(20) not null check (reemplazadaX  IN ('San Justo','Ramos Mejia','Lomas del Mirador')),
				direccion varchar(150),
				horario varchar(50),
				telefono varchar(9) check (telefono like '5555-555[0-9]')
			) 

			SET @Consulta = N'
				INSERT INTO #SucursalTemporal(ciudad,reemplazadaX,direccion,horario,telefono)
				SELECT *
				FROM OPENROWSET(
				''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES;'',
				''SELECT * FROM ['+@nombreHoja+']'');'
			EXEC sp_executesql @Consulta 

			SELECT * FROM #SucursalTemporal
			

			INSERT INTO Info.Sucursal(ciudad,reemplazadaX,direccion,horario,telefono)
			SELECT * FROM #SucursalTemporal

			PRINT 'Los datos se insertaron exitosamente' 
			DROP TABLE #SucursalTemporal
		
 END TRY 
 BEGIN CATCH 
  PRINT 'No se pudo importar la informacion de las sucursales ' + @RutaArchivo 
  PRINT ERROR_MESSAGE() 
 END CATCH 
END 
GO
EXECUTE Info.importarSucursal @RutaArchivo='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Informacion_complementaria.xlsx', @nombreHoja = 'sucursal$'
GO
SELECT * FROM Info.Sucursal
GO

------------------------------------------------- EMPLEADOS -------------------------------------------------
CREATE OR ALTER PROCEDURE Info.importarEmpleados (@RutaArchivo NVARCHAR(MAX), @NombreHoja NVARCHAR(50))
AS 
BEGIN
 BEGIN TRY
			DECLARE @Consulta nvarchar(MAX)

			CREATE TABLE #EmpleadosTemporal
			(
				idEmpleado int,
				nombre nvarchar (255),
				apellido nvarchar(255),
				dni int,
				direccion varchar(255),
				emailPesonal nvarchar(255),
				emailEmpresa nvarchar(255),
				cargo varchar(60) check (cargo IN ('Cajero','Supervisor','Gerente de sucursal')),
				sucursal varchar(60) check (sucursal IN ('San Justo','Ramos Mejia','Lomas del Mirador')),
				turno varchar(25)
			) 

			SET @Consulta = N'
				INSERT INTO #EmpleadosTemporal(idEmpleado,nombre,apellido,dni,direccion,emailPesonal,emailEmpresa,cargo,sucursal,turno)
				SELECT [Legajo/ID],Nombre,Apellido,DNI,Direccion,[email personal],[email empresa],Cargo,Sucursal,Turno
				FROM OPENROWSET(
				''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES;'',
				''SELECT * FROM ['+@nombreHoja+']'');'
			EXEC sp_executesql @Consulta 

			SELECT * FROM #EmpleadosTemporal


			INSERT INTO Info.Empleado(nombre,apellido,dni,direccion,emailPesonal,emailEmpresa,cargo,sucursal,turno,idSucursal)
			SELECT nombre,apellido,dni,direccion,emailPesonal,emailEmpresa,cargo,sucursal,turno,
			 (SELECT idSucursal FROM Info.Sucursal suc WHERE suc.reemplazadaX = empTemp.sucursal) as idSucursal
			 FROM #EmpleadosTemporal empTemp

			PRINT 'Los datos se insertaron exitosamente' 
			DROP TABLE #EmpleadosTemporal
		
 END TRY 
 BEGIN CATCH 
  PRINT 'No se pudieron importar los empleados ' + @RutaArchivo 
  PRINT ERROR_MESSAGE() 
 END CATCH 
END 
GO
EXECUTE Info.importarEmpleados @RutaArchivo='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Informacion_complementaria.xlsx', @nombreHoja = 'Empleados$'
SELECT * FROM Info.Empleado
GO

-------------------------------------------------------------------------------------------------------------
---------------------------------------------- VENTAS REGISTRADAS -------------------------------------------
-------------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ven.importarVentas (@RutaArchivo varchar(MAX)) 
AS
BEGIN
 BEGIN TRY

		DECLARE @Consulta nvarchar(max)
		

        -- Definición de la tabla temporal #VentasRegistradas
			DROP TABLE IF EXISTS #VentasRegistradas;
            CREATE TABLE #VentasRegistradas
            (
                idFactura VARCHAR(100),
                tipoFactura VARCHAR(100),
                ciudad VARCHAR(100),
                tipoCliente VARCHAR(100),
                genero VARCHAR(100),
                lineaProducto VARCHAR(100),
                precioUnitario DECIMAL(10,2),
                cantidad INT,
                fecha DATE,
                hora TIME,
                medioPago VARCHAR(100),
                idEmpleado INT,
                idIdentificadorPago VARCHAR(100)
            );

		SET @Consulta = 'BULK INSERT #VentasRegistradas
                         FROM ''' + @RutaArchivo + '''
                         WITH (
                             FIELDTERMINATOR = '';'',  -- Especifica el delimitador de campo como ;
                             ROWTERMINATOR = ''\n'',   -- Especifica el delimitador de fila
                             FIRSTROW = 2              -- Ignora encabezados y comienza desde la segunda fila
                         );';
        -- Ejecutar la consulta
        EXEC sp_executesql @Consulta;

        -- Seleccionar los datos importados para verificar
        SELECT * FROM #VentasRegistradas;

		DROP TABLE #VentasRegistradas
 END TRY
 BEGIN CATCH
	PRINT 'Error al importar los datos de ventas: ' + ERROR_MESSAGE();
 END CATCH
END;

EXECUTE Ven.importarVentas 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Ventas_registradas.csv'

