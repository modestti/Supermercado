USE Com5600G03
GO

-------------------------------------------------------------------------------------------------------------
---------------------------------------------- PRODUCTOS ----------------------------------------------------
-------------------------------------------------------------------------------------------------------------
CREATE TABLE Prod.Catalogo 
(
	idProducto int identity(1,1) primary key,
	nombreProducto varchar(150),
	categoria varchar(50),
	precioUnidad decimal(10,2), 
	fecha datetime
)
GO
-------------------------------------------- NUEVO PRODUCTO ------------------------------------------------
CREATE OR ALTER PROCEDURE Prod.ingresarCatalogo (@categoria varchar(100), @nombre varchar(100), @precio decimal(10,2))
AS
BEGIN	
	--Insertamos el producto nuevo
	IF NOT EXISTS (SELECT 1 FROM Prod.Catalogo WHERE nombreProducto=@nombre AND fecha=GETDATE()) 
	INSERT INTO Prod.Catalogo(categoria,nombreProducto,precioUnidad,fecha)VALUES(@categoria,@nombre,@precio,GETDATE())
END
GO

-------------------------------------------- ELIMINAR PRODUCTO ------------------------------------------------
CREATE OR ALTER PROCEDURE Prod.eliminarCatalogo (@idCatalogo int)
AS 
BEGIN
	--Elinamos el producto
	DELETE FROM Prod.Catalogo WHERE idProducto=@idCatalogo
END
GO

------------------------------------------- ACTUALIZAR PRECIO -----------------------------------------------
CREATE OR ALTER PROCEDURE Prod.nuePrecioCatalogo (@idCatalogo int, @nuePrecio decimal(10,2))
AS
BEGIN
	--Buscamos el producto
	IF EXISTS (SELECT 1 FROM Prod.Catalogo WHERE idProducto=@idCatalogo)
	BEGIN
		--Si lo encontramos, actualizamos el precio. Por lo tanto, la fecha y hora tambien para saber cuando fue la ultima vez que se modifico
		UPDATE Prod.Catalogo
		SET precioUnidad=@nuePrecio, fecha=GETDATE()
		WHERE idProducto=@idCatalogo
	END
END
GO

-------------------------------------------------------------------------------------------------------------
------------------------------------------ IMPORTACION DE ARCHIVOS ------------------------------------------
-------------------------------------------------------------------------------------------------------------
---COMANDO PARA LA IMPORTACION -> PERMITE EJECUTAR UNA CONSULTA DISTRIBUIDA ----
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
EXEC sp_configure;
GO
---------------------------------------------- CATALOGO  ---------------------------------------------------
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
	    		FIELDTERMINATOR = '','',		-- Especifica el delimitador de campo como ,           
			ROWTERMINATOR = ''0x0a'',		-- Especifica el delimitador de fila
			FIRSTROW = 2,				-- Ignora encabezados y comienza desde la segunda fila           
			CODEPAGE = ''65001''			-- Codigo de pagina UTF-8 (Caractere unicos)
                );';

	-- Ejecutamos la consulta 
    	EXEC sp_executesql @Consulta 

	-- Verificamos que la consulta haya importado la informacion a la tabla temporal 
	SELECT * FROM #CatalogoTemporal;

	-- Inserta en la tabla final de catalogo y casteamos los valores de varchar
	DECLARE @idProdCat int 
	INSERT Prod.Catalogo(categoria,nombreProducto,precioUnidad, fecha)
	SELECT c.lineaProducto,[name], TRY_CAST(ct.price AS decimal(10,2)),ct.[date] FROM #CatalogoTemporal ct 
	INNER JOIN  Prod.Clasificacion c on c.producto=ct.category
	WHERE NOT EXISTS( SELECT 1 FROM Prod.Catalogo WHERE nombreProducto=[name] AND fecha=ct.[date])

    	PRINT 'Los datos se insertaron exitosamente';
    	DROP TABLE #CatalogoTemporal;
END 
GO
EXECUTE Prod.importarCatalogo 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Productos\catalogo.csv';
GO
SELECT * FROM Prod.Catalogo ---VERIFICO QUE SE HAYA IMPORTADO A LA TABLA
GO

----------------------------------------- PRODUCTOS ELECTRONICOS --------------------------------------------

CREATE OR ALTER PROCEDURE Prod.importarProductosElectronicos (@RutaArchivo NVARCHAR(MAX),@NombreHoja NVARCHAR(50))
AS 
BEGIN  
	DECLARE @Consulta nvarchar(MAX)
	DECLARE @Categoria varchar(50) ='Electronica'
		
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
					''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES;'', 	--Especifica que es un archivo Excel, la ruta del archivo, que hay encabezado y la hoja en la que se encuentran los datos
					''SELECT * FROM ['+@NombreHoja+']'');'
	--Ejecutamos la consulta
	EXEC sp_executesql @Consulta;

	--Muestro la tabla temporal para verificar que la informacion se descargo exitosamente 
	SELECT * FROM #ElectronicoTemporal;

	--Pasamos la informacion a nuestra tabla
	INSERT INTO Prod.Catalogo(categoria,nombreProducto,precioUnidad,fecha)
		SELECT @Categoria,Product,Precio_Unitario_en_dolares,GETDATE() FROM #ElectronicoTemporal
	WHERE NOT EXISTS (SELECT 1 FROM Prod.Catalogo WHERE nombreProducto=Product)

	--Eliminamos la tabla temporal 
	PRINT 'Los datos se insertaron exitosamente' 
	DROP TABLE #ElectronicoTemporal
END

EXECUTE Prod.importarProductosElectronicos  @RutaArchivo = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Productos\Electronic accessories.xlsx', @nombreHoja ='Sheet1$' 
SELECT * FROM Prod.Catalogo ---VERIFICO QUE SE HAYA IMPORTADO A LA TABLA
GO

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
			''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES;'', 	--Especifica que es un archivo Excel, la ruta del archivo, que hay encabezado y la hoja en la que se encuentran los datos
			''SELECT * FROM ['+@nombreHoja+']'');'  
	
		-- Ejecutamos la consulta
	EXEC sp_executesql @Consulta 

	-- Verificamos si los datos se importaron finalmente a la tala temporal
	SELECT * FROM #ImportadosTemporal
	
	-- Insertamos a nuestra tabla, las filas que se encuentran en la tabla temporal
	INSERT INTO Prod.Catalogo(nombreProducto,categoria,precioUnidad,fecha)
	SELECT NombreProducto,Categoría,PrecioUnidad,GETDATE() FROM #ImportadosTemporal it
	WHERE NOT EXISTS (SELECT 1 FROM Prod.Catalogo WHERE nombreProducto= it.NombreProducto)
	
	-- Eliminamos la tabla temporal 
	PRINT 'Los datos se insertaron exitosamente' 
	DROP TABLE #ImportadosTemporal
END 
GO
EXECUTE Prod.importarProductosImportados @RutaArchivo='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Productos\Productos_importados.xlsx', @NombreHoja='Listado de Productos$' 
SELECT * FROM Prod.Catalogo 	---VERIFICO QUE SE HAYA IMPORTADO A LA TABLA
GO

