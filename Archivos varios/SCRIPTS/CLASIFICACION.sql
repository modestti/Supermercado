USE Com5600G03
GO
------------------------------------------------------------------------------------------------------------
------------------------------------------- CLASIFICACION --------------------------------------------------
------------------------------------------------------------------------------------------------------------
CREATE TABLE Prod.Clasificacion
(
	idProducto int identity(1,1) primary key, 
	lineaProducto varchar(20) not null,
	producto varchar(50) not null
);
GO

------------------------------------------- NUEVA CLASIFICACION ----------------------------------------------
CREATE OR ALTER PROCEDURE Prod.insertarClasificacion( @lineaProducto varchar(100), @producto varchar(50))
AS
BEGIN 
	IF NOT EXISTS (SELECT 1 FROM Prod.Clasificacion WHERE producto=@producto)
		INSERT INTO Prod.Clasificacion (lineaProducto,producto)VALUES (@lineaProducto,@producto)
END

------------------------------------------ IMPORTAR CLASIFICACION --------------------------------------------
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
			SELECT lineaProducto,producto FROM #ClasificacionTemporal ct
			WHERE NOT EXISTS (SELECT 1 FROM Prod.Clasificacion c WHERE c.lineaProducto=ct.lineaProducto AND c.producto=ct.producto)

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
EXECUTE Prod.importarClasificacionProductos @RutaArchivo='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Informacion_complementaria.xlsx', @nombreHoja = 'Clasificacion productos$'
GO
SELECT * FROM Prod.Clasificacion
GO
