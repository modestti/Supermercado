USE Com5600G03
GO 
-------------------------------------------------------------------------------------------------------------
--------------------------------------------------EMPLEADO---------------------------------------------------
-------------------------------------------------------------------------------------------------------------
CREATE TABLE Info.Empleado
(
	idEmpleado int identity(257020,1) primary key, 
	nombre nvarchar (100),
	apellido nvarchar(100),
	dni int,
	direccion varchar(255),
	emailPesonal nvarchar(100),
	emailEmpresa nvarchar(100),
	cargo varchar(60) check (cargo IN ('Cajero','Supervisor','Gerente de sucursal')), --Son los tres puestos ue nuestro empleados pueden ocupar
	sucursal varchar(60) check (sucursal IN ('San Justo','Ramos Mejia','Lomas del Mirador')), --Verificamos que no sean de una sucursal que este fuera del area que nosotros manejamos
	turno varchar(30),
	idSucursal int,

	CONSTRAINT FK_idSucursal FOREIGN KEY (idSucursal) references Info.Sucursal(idSucursal)
);
GO

---------------------------------------------- NUEVO EMPLEADO -----------------------------------------------
CREATE OR ALTER PROCEDURE Info.nuevoEmpleado (@nombre varchar(50), @apellido varchar(50), @dni int,
					      @direccion varchar(100),@emailPersonal varchar(100),
					      @emailEmpresa varchar(100), @cargo varchar(30), @sucursal varchar(20),
					      @turno varchar(25))
AS
BEGIN
	DECLARE @idSucursal int
	-- Buscamos el idSucursal
	SELECT @idSucursal = idSucursal 
    	FROM Info.Sucursal 
    	WHERE reemplazadaX = @sucursal;
	-- Verificamos si se encontró la sucursal
    	IF @idSucursal IS NULL
    	BEGIN
        	PRINT 'Sucursal no encontrada. Inserción cancelada.';
        	RETURN;
    	END
	-- Insertamos el nuevo empleado
	INSERT INTO Info.Empleado(nombre, apellido, dni, direccion, emailPesonal, emailEmpresa, cargo, sucursal, turno, idSucursal)
    	VALUES (@nombre, @apellido, @dni, @direccion, @emailPersonal, @emailEmpresa, @cargo, @sucursal, @turno, @idSucursal);

END
GO
EXECUTE Info.nuevoEmpleado @nombre= 'Tomas', @apellido='Modestti', @dni= 45073572, @direccion='Peribebuy 4242', @emailEmpresa='tomas@empresa.com', 
			   @emailPersonal= 'tomas.m@gmail.com', @cargo= 'Supervisor', @sucursal= 'Lomas del Mirador', @turno='M'
GO


--------------------------------- ACTUALIZACION DEL CARGO DE UN EMPLEADO ------------------------------------
CREATE OR ALTER PROCEDURE Info.nuevoCargoEmpleado (@dni int, @nueCargo varchar(20))
AS
BEGIN
	DECLARE @IdEmpleado INT
	--Busco el idEmpleado por el DNI 
	SELECT @IdEmpleado = IdEmpleado
    	FROM Info.Empleado
    	WHERE dni = @dni;
	-- Verificamos si se encontró el empleado
	IF @IdEmpleado is NULL
	BEGIN 
	 	PRINT 'Empleado no encontrada.';
        	RETURN;
	END
	-- Si se encontro actualizamos su cargo 
	UPDATE Info.Empleado
 	   SET cargo=@nueCargo
 	   WHERE idEmpleado=@IdEmpleado
END
GO
EXECUTE Info.nuevoCargoEmpleado @dni=45073572, @nueCargo= 'Gerente de sucursal'
GO

--------------------------------- ACTUALIZACION DEL TURNO DE UN EMPLEADO ------------------------------------
CREATE OR ALTER PROCEDURE Info.cambioTurnoEmpleado (@dni int, @turno varchar(20))
AS
BEGIN
	DECLARE @IdEmpleado INT
	--Busco el idEmpleado por el DNI 
	SELECT @IdEmpleado = IdEmpleado
    	FROM Info.Empleado
    	WHERE dni = @dni;
	--Verificamos si se encontró el empleado
	IF @IdEmpleado is NULL
	BEGIN 
	 	PRINT 'Empleado no encontrada.';
		RETURN;
        RETURN;
	END
	--Actualizamos el turno en el que encontraremos a ese empleado trabajando
	UPDATE Info.Empleado
	   SET turno=@turno
	   WHERE idEmpleado=@IdEmpleado
END
GO
EXECUTE Info.cambioTurnoEmpleado @dni=45073572, @turno= 'T'
GO

-------------------------------------------- EMPLEADO DESPEDIDO ---------------------------------------------
CREATE OR ALTER PROCEDURE Info.despedirEmpleado (@dni int)
AS
BEGIN
	DECLARE @IdEmpleado INT
	--Busco el idEmpleado por el DNI 
	SELECT @IdEmpleado = IdEmpleado
    	FROM Info.Empleado
    	WHERE dni = @dni;
	-- Verifico si se encontro el IdEmpleado 
	IF @IdEmpleado is NULL
	BEGIN 
	 	PRINT 'Empleado no encontrada.';
        	RETURN;
	END
	-- Borramos el empleado
	DELETE Info.Empleado WHERE idEmpleado=@IdEmpleado
END		
GO
EXECUTE Info.despedirEmpleado @dni=45073572
GO
DBCC CHECKIDENT('Info.Empleado' , RESEED, 0)-- RESETEAMOS EL IdEmpleado
GO

------------------------------------------------- IMPORTAR EMPLEADOS --------------------------------------------
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
				''Microsoft.ACE.OLEDB.12.0'',		--Proveedor OLEB
				''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES;'',	--Especifica que es un archivo Excel, la ruta del archivo, que hay encabezado
				''SELECT * FROM ['+@nombreHoja+']'');'		 --la hoja en la que se encuentran los datos
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
		--En caso de fallar la hora de la importacion mostraria el mensaje con el error correspondiente 
 	BEGIN CATCH 
  			PRINT 'No se pudieron importar los empleados ' + @RutaArchivo 
  			PRINT ERROR_MESSAGE() 
 	END CATCH 
END 
GO
EXECUTE Info.importarEmpleados @RutaArchivo='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS01\TRABAJO PRACTICO\TP_integrador_Archivos\Informacion_complementaria.xlsx', @nombreHoja = 'Empleados$'
SELECT * FROM Info.Empleado
GO
