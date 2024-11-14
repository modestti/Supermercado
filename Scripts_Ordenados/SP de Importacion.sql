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
			--Creamos la tabla temporal donde vamos a descargar nuestro archivo
			CREATE TABLE #ElectronicoTemporal
			(
				Product varchar(100),
				Precio_Unitario_en_dolares decimal(10,2)
			)

			--Generamos la consulta de importacion 
			SET @Consulta = N'
				INSERT INTO #ElectronicoTemporal(Product,Precio_Unitario_en_dolares)
					SELECT Product, [Precio Unitario en dolares]
						FROM OPENROWSET(
								''Microsoft.ACE.OLEDB.12.0'',
								''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES;'', --Especifica que es un archivo Excel, la ruta del archivo, que hay encabezado y la hoja en la que se encuentran los datos
								''SELECT * FROM ['+@nombreHoja+']'');'
			--Ejecutamos la consulta
			EXEC sp_executesql @Consulta;

			--Muestro la tabla temporal para verificar que la informacion se descargo exitosamente 
			SELECT * FROM #ElectronicoTemporal;

			--Pasamos la informacion a nuestra tabla
			INSERT INTO Prod.Electronico(nombre,precioDolares)
				SELECT Product,Precio_Unitario_en_dolares FROM #ElectronicoTemporal
			WHERE NOT EXISTS (SELECT 1 FROM Prod.Electronico WHERE nombre=Product)

			--Eliminamos la tabla temporal 
			PRINT 'Los datos se insertaron exitosamente' 
			DROP TABLE #ElectronicoTemporal
END

------------------------------------------ PRODUCTOS IMPORTADOS ---------------------------------------------
CREATE OR ALTER PROCEDURE Prod.importarProductosImportados (@RutaArchivo nvarchar(MAX), @NombreHoja nvarchar(50))
AS 
BEGIN
			-- Declaramos la variable consulta y la tabla temporal 
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
			-- Generamos la consulta con SQL Dinamico para importar el archivo a la tabla temporal
			SET @Consulta = N'
				INSERT INTO #ImportadosTemporal(IdProducto,NombreProducto,Proveedor,Categoría,CantidadPorUnidad,PrecioUnidad)
				SELECT IdProducto,NombreProducto,Proveedor,Categoría,CantidadPorUnidad,PrecioUnidad
				FROM OPENROWSET(
					''Microsoft.ACE.OLEDB.12.0'', --Proveedor OLEB
					''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES;'', --Especifica que es un archivo Excel, la ruta del archivo, que hay encabezado y la hoja en la que se encuentran los datos
					''SELECT * FROM ['+@nombreHoja+']'');'  
			-- Ejecutamos la consulta
			EXEC sp_executesql @Consulta 

			-- Verificamos si los datos se importaron finalmente a la tala temporal
			SELECT * FROM #ImportadosTemporal
			-- Insertamos a nuestra tabla, las filas que se encuentran en la tabla temporal
			INSERT INTO Prod.Importado(nombre,proveedor,categoria,cantidadXUnidad,precioUnidad)
			SELECT NombreProducto,Proveedor,Categoría,CantidadPorUnidad,PrecioUnidad FROM #ImportadosTemporal
			-- Eliminamos la tabla temporal 
			PRINT 'Los datos se insertaron exitosamente' 
			DROP TABLE #ImportadosTemporal
END 
GO

---------------------------------------------- CATALOGO GENERAL ---------------------------------------------
CREATE OR ALTER PROCEDURE Prod.importarCatalogo (@RutaArchivo nvarchar(MAX))
AS 
BEGIN 
			-- Creamos la tabla temporal
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

			-- Generamos con SQL Dinamico la consulta que nos va a servir para importar el archivo a la tabla temporal
            DECLARE @Consulta NVARCHAR(MAX) 
            SET @Consulta = N' 
                BULK INSERT #CatalogoTemporal 
                FROM ''' + @RutaArchivo + ''' 
                WITH (
					FORMAT = ''CSV'',			-- Usamos formato CSV debido a la extension del archivo
                    FIELDTERMINATOR = '','',	-- Especifica el delimitador de campo como ,           
					ROWTERMINATOR = ''0x0a'',	-- Especifica el delimitador de fila
					FIRSTROW = 2,				-- Ignora encabezados y comienza desde la segunda fila           
					CODEPAGE = ''65001''		-- Codigo de pagina UTF-8 (Caractere unicos)
                );';

			-- Ejecutamos la consulta 
            EXEC sp_executesql @Consulta 

			-- Verificamos que la consulta haya importado la informacion a la tabla temporal 
			SELECT * FROM #CatalogoTemporal;

			-- Inserta en la tabla final de catalogo y casteamos los valores de varchar
			DECLARE @idProdCat int 
			INSERT Prod.Catalogo(categoria, nombre, precio, referenciaPrecio, referenciaUnidad, fecha_hora,idProductoCat)
			SELECT ct.category,[name], TRY_CAST(ct.price AS decimal(10,2)), TRY_CAST(ct.reference_price AS decimal(10,2)), ct.reference_unit,ct.[date],c.IdProducto FROM #CatalogoTemporal ct 
			INNER JOIN  Prod.Clasificacion c on c.producto=ct.category

            PRINT 'Los datos se insertaron exitosamente';
            DROP TABLE #CatalogoTemporal;
END 
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
			--Creamos la tabla temporal 
			CREATE TABLE #ClasificacionTemporal
			(
				lineaProducto varchar(20),
				producto varchar(50)
			) 
			--Generamos la consulta con SQL Dinamico para importar el archivo a la tabla temporal 
			SET @Consulta = N'
				INSERT INTO #ClasificacionTemporal(lineaProducto,producto)
				SELECT *
				FROM OPENROWSET(
				''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES;'', --Especifica que es un archivo Excel, la ruta del archivo, que hay encabezado y la hoja en la que se encuentran los datos
				''SELECT * FROM ['+@nombreHoja+']'');'
			--Ejecutamos la consulta
			EXEC sp_executesql @Consulta 

			SELECT * FROM #ClasificacionTemporal
			--Inserto en la tabla de clasificacion la informacion que se encuentra en la tabla temporal
			INSERT INTO Prod.Clasificacion(lineaProducto,producto)
			SELECT lineaProducto,producto FROM #ClasificacionTemporal

			--Elimino la tabla temporal
			PRINT 'Los datos se insertaron exitosamente' 
			DROP TABLE #ClasificacionTemporal
 END TRY 
 BEGIN CATCH 
  --En caso de fallar la hora de la importacion mostraria el mensaje con el error correspondiente 
  PRINT 'No se pudieron importar la clasificacion de productos' + @RutaArchivo 
  PRINT ERROR_MESSAGE() 
 END CATCH 
END 
GO

-------------------------------------------------- SUCURSAL -------------------------------------------------
CREATE OR ALTER PROCEDURE Info.importarSucursal (@RutaArchivo NVARCHAR(MAX), @NombreHoja NVARCHAR(50))
AS 
BEGIN
 BEGIN TRY
			DECLARE @Consulta nvarchar(MAX)
			-- Creamos la tabla temporal 
			CREATE TABLE #SucursalTemporal
			(
				ciudad varchar (15),
				reemplazadaX  varchar(20) not null check (reemplazadaX  IN ('San Justo','Ramos Mejia','Lomas del Mirador')),
				direccion varchar(150),
				horario varchar(50),
				telefono varchar(9) check (telefono like '5555-555[0-9]')
			) 
			-- Generamos la consulta para importar el archivo
			SET @Consulta = N'
				INSERT INTO #SucursalTemporal(ciudad,reemplazadaX,direccion,horario,telefono)
				SELECT *
				FROM OPENROWSET(
				''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES;'',
				''SELECT * FROM ['+@nombreHoja+']'');'
			--Ejecutamos la consulta para importar el archivo a la tabla temporal 
			EXEC sp_executesql @Consulta 
			SELECT * FROM #SucursalTemporal
			--Insertamos en nuestra tabla la informacion ue contiene la tabla temporal 
			INSERT INTO Info.Sucursal(ciudad,reemplazadaX,direccion,horario,telefono)
			SELECT * FROM #SucursalTemporal st
			WHERE NOT EXISTS (SELECT 1 FROM Info.Sucursal s WHERE s.ciudad=st.ciudad and s.direccion=st.direccion) -- Funciona para que las sucursales que figuran en la tabla no se dupliquen 

			--Elimamos la tabla temporal 
			PRINT 'Los datos se insertaron exitosamente' 
			DROP TABLE #SucursalTemporal
 END TRY 
 BEGIN CATCH 
  PRINT 'No se pudo importar la informacion de las sucursales ' + @RutaArchivo 
  PRINT ERROR_MESSAGE() 
 END CATCH 
END 
GO

------------------------------------------------- EMPLEADOS -------------------------------------------------
CREATE OR ALTER PROCEDURE Info.importarEmpleados (@RutaArchivo NVARCHAR(MAX), @NombreHoja NVARCHAR(50))
AS 
BEGIN
 BEGIN TRY
			DECLARE @Consulta nvarchar(MAX)
			--Creamos la tabla temporal 
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
			--Generamos la consulta para importar el archivo 
			SET @Consulta = N'
				INSERT INTO #EmpleadosTemporal(idEmpleado,nombre,apellido,dni,direccion,emailPesonal,emailEmpresa,cargo,sucursal,turno)
				SELECT [Legajo/ID],Nombre,Apellido,DNI,Direccion,[email personal],[email empresa],Cargo,Sucursal,Turno
				FROM OPENROWSET(
				''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES;'',
				''SELECT * FROM ['+@nombreHoja+']'');'
			--Ejecutamos la consulta 
			EXEC sp_executesql @Consulta 

			SELECT * FROM #EmpleadosTemporal
			--Insertamos en nuestra tabla la informacion que contiene la tabla temporal 
			INSERT INTO Info.Empleado(nombre,apellido,dni,direccion,emailPesonal,emailEmpresa,cargo,sucursal,turno,idSucursal)
			SELECT nombre,apellido,dni,direccion,emailPesonal,emailEmpresa,cargo,sucursal,turno,
			 (SELECT idSucursal FROM Info.Sucursal suc WHERE suc.reemplazadaX = empTemp.sucursal) as idSucursal
			 FROM #EmpleadosTemporal empTemp
			 WHERE NOT EXISTS (SELECT 1 FROM Info.Empleado e WHERE empTemp.dni= e.dni) AND empTemp.idEmpleado IS NOT NULL --Evitamos duplicados y basura del archivo 
			--Eliminamos la tabla temporal 
			PRINT 'Los datos se insertaron exitosamente' 
			DROP TABLE #EmpleadosTemporal		
 END TRY 
 BEGIN CATCH 
  PRINT 'No se pudieron importar los empleados ' + @RutaArchivo 
  PRINT ERROR_MESSAGE() 
 END CATCH 
END 
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
                identificadorPago VARCHAR(100)
            );
		--Generamos la consulta del BULK INSERT 
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

		-- Insertamos en la tabla ventas
		INSERT INTO Ven.Registrada(idFactura, tipoFactura,ciudad,tipoCliente,genero,lineaProducto,precioUnitario,cantidad,total,fecha,hora,medioPago,idEmpleado,identificadorPago,idSucursal, idImportado,idElectronico, idCatalogo)
		SELECT v.idFactura, v.tipoFactura,v.ciudad,v.tipoCliente,v.genero,v.lineaProducto,v.precioUnitario,v.cantidad, v.precioUnitario * v.cantidad AS total ,v.fecha,v.hora,v.medioPago,v.idEmpleado,v.identificadorPago, s.idSucursal, i.idImportado, e.idElectronico, c.idCatalogo
			FROM #VentasRegistradas v
		LEFT JOIN Info.Sucursal s ON s.ciudad= v.ciudad
		LEFT JOIN Prod.Importado i ON i.nombre= v.lineaProducto		--Hacemos los JOIN para enlazar las tablas
		LEFT JOIN Prod.Electronico e ON e.nombre= v.lineaProducto
		LEFT JOIN  (SELECT DISTINCT nombre, idCatalogo FROM Prod.Catalogo) c ON c.nombre = v.lineaProducto
		WHERE NOT EXISTS (SELECT 1 FROM Ven.Registrada r WHERE r.idFactura=v.idFactura) --Evitamos facturas duplicadas 

		-- Eliminamos la tabla temporal ya que no la necesitaremos la informacion almacenada alli
		DROP TABLE #VentasRegistradas
 END TRY
 BEGIN CATCH
	PRINT 'Error al importar los datos de ventas: ' + ERROR_MESSAGE();
 END CATCH
END;
GO