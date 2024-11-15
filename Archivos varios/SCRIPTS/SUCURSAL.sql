USE Com5600G03
GO
-------------------------------------------------------------------------------------------------------------
--------------------------------------------------SUCURSAL---------------------------------------------------
-------------------------------------------------------------------------------------------------------------
CREATE TABLE Info.Sucursal
(
	idSucursal int identity(1,1) primary key,
	ciudad varchar (15),																						--Ciudad	
	reemplazadaX  varchar(20) not null check (reemplazadaX  IN ('San Justo','Ramos Mejia','Lomas del Mirador')), --Chequeamos que se encuentre dentro de la localidad en la que nos manejamos
	direccion varchar(150),																						--La direccion de nuestra sucursal 
	horario varchar(50),																						--Los horarios de atencion al publico
	telefono varchar(9) check (telefono like '5555-555[0-9]')													--Nuestro telefono interno
);
GO
----------------------------------------- ABRIR NUEVA SUCURSAL ----------------------------------------------
CREATE OR ALTER PROCEDURE Info.nuevaSucursal( @ciudad varchar(100) ,@reemplazadaX varchar(100),
											@direccion varchar(150), @horario varchar(100), @telefono varchar(10) )
AS 
BEGIN
		-- Verificamos si ya existe un sucursal en la misma direccion y ciudad
		IF NOT EXISTS (SELECT 1 FROM Info.Sucursal WHERE ciudad=@ciudad AND direccion=@direccion)
		BEGIN 
				--En el caso, que la sucursal nueva no exista en nuestra tabla. Insertamos
				INSERT INTO Info.Sucursal (ciudad,reemplazadaX,direccion,horario,telefono)
				VALUES ( @ciudad,@reemplazadaX,@direccion,@horario,@telefono)
		END

END
EXECUTE Info.nuevaSucursal @Ciudad= 'Madrid',@reemplazadaX= 'Lomas del mirador', @direccion= 'Peribebuy 6000',@horario='24hs',@telefono='5555-5555'
GO
------------------------------------------  CERRAR LA SUCURSAL ----------------------------------------------
CREATE OR ALTER PROCEDURE Info.cerrarSucursal (@idSucursal int, @ciudad varchar(100))
AS
BEGIN 
	--Elinamos la sucursal 
	DELETE FROM Info.Sucursal 
	WHERE idSucursal=@idSucursal and ciudad=@ciudad

END;
GO
EXECUTE Info.cerrarSucursal @idSucursal=1,@ciudad='Tokio'
GO

------------------------------------------ ACTUALIZAR EL HORARIO DE LA SUCURSAL -----------------------------
CREATE OR ALTER PROCEDURE Info.nuevoHorarioSucursal (@idSucursal int, @horario varchar(100))
AS 
BEGIN
	--En caso de modificacion de horario, utilizariamos este proceso para actualizar el horario
	UPDATE Info.Sucursal
		SET horario=@horario
		WHERE idSucursal= @idSucursal
END;
GO
EXECUTE Info.nuevoHorarioSucursal @idSucursal=1, @horario= 'Lu a Vi 9-18hs'
GO

------------------------------------------ ACTUALIZAR EL TELEFONO DE LA SUCURSAL ----------------------------
CREATE OR ALTER PROCEDURE Info.nuevoTelefonoSucursal (@idSucursal int, @telefono varchar(100))
AS 
BEGIN
	--En caso de modificacion del telefono, utilizariamos este proceso para actualizar el telefono de contacto 
	UPDATE Info.Sucursal
		SET telefono=@telefono
		WHERE idSucursal= @idSucursal
END;
GO
EXECUTE Info.nuevoTelefonoSucursal @idSucursal=1, @telefono= '5555-5558'

GO
DBCC CHECKIDENT('Info.Sucursal' , RESEED, 0)--Luego de probar los procedure, deberiamos eliminar las filas de prueba y debemos reiniciar el idSucursal
GO

---COMANDO PARA LA IMPORTACION -> PERMITE EJECUTAR UNA CONSULTA DISTRIBUIDA ----
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
EXEC sp_configure;

--------------------------------------------------IMPORTAR SUCURSALES -------------------------------------------------
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
EXECUTE Info.importarSucursal @RutaArchivo='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Informacion_complementaria.xlsx', @nombreHoja = 'sucursal$'
GO
SELECT * FROM Info.Sucursal
GO