USE Com5600G03
GO


--CREACION DE ESQUEMAS
CREATE SCHEMA Ven
GO

CREATE SCHEMA Prod
GO

CREATE SCHEMA Info
GO

-------------------------------------------------------------------------------------------------------------
--------------------------------------------------SUCURSAL---------------------------------------------------
-------------------------------------------------------------------------------------------------------------
CREATE TABLE Info.Sucursal
(
	idSucursal int identity(1,1) primary key,
	ciudad varchar (15),
	reemplazadaX  varchar(20) not null check (reemplazadaX  IN ('San Justo','Ramos Mejia','Lomas del Mirador')),
	direccion varchar(150),
	horario varchar(50),
	telefono varchar(9) check (telefono like '5555-555[0-9]')
);
GO
----------------------------------------- ABRIR NUEVA SUCURSAL ----------------------------------------------
CREATE OR ALTER PROCEDURE Info.nuevaSucursal( @ciudad varchar(100) ,@reemplazadaX varchar(100),
											@direccion varchar(150), @horario varchar(100), @telefono varchar(10) )
AS 
BEGIN

		INSERT INTO Info.Sucursal (ciudad,reemplazadaX,direccion,horario,telefono)
		VALUES ( @ciudad,@reemplazadaX,@direccion,@horario,@telefono)

END
EXECUTE Info.nuevaSucursal @Ciudad= 'Tokio',@reemplazadaX= 'Lomas del mirador', @direccion= 'Peribebuy 5090',@horario='24hs',@telefono='5555-5555'
GO

------------------------------------------  CERRAR LA SUCURSAL ----------------------------------------------
CREATE OR ALTER PROCEDURE Info.cerrarSucursal (@idSucursal int, @ciudad varchar(100))
AS
BEGIN 
	
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
	
	UPDATE Info.Sucursal
		SET telefono=@telefono
		WHERE idSucursal= @idSucursal
END;
GO
EXECUTE Info.nuevoTelefonoSucursal @idSucursal=1, @telefono= '5555-5558'

GO
DBCC CHECKIDENT('Info.Sucursal' , RESEED, 0)--Luego de probar los procedure, deberiamos eliminar 
											--las filas de prueba y debemos reiniciar el idSucursal
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
	cargo varchar(60) check (cargo IN ('Cajero','Supervisor','Gerente de sucursal')),
	sucursal varchar(60) check (sucursal IN ('San Justo','Ramos Mejia','Lomas del Mirador')),
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

    -- Verificar si se encontró la sucursal
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
	--Busco el idSucursal por el DNI 
	SELECT @IdEmpleado = IdEmpleado
    FROM Info.Empleado
    WHERE dni = @dni;

	IF @IdEmpleado is NULL
	BEGIN 
	 PRINT 'Empleado no encontrada.';
        RETURN;
	END

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
	--Busco el idSucursal por el DNI 
	SELECT @IdEmpleado = IdEmpleado
    FROM Info.Empleado
    WHERE dni = @dni;

	IF @IdEmpleado is NULL
	BEGIN 
	 PRINT 'Empleado no encontrada.';
        RETURN;
	END

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
	-- Busco el idSucursal por el DNI 
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


-------------------------------------------------------------------------------------------------------------
------------------------------------------ MEDIOS DE PAGOS --------------------------------------------------
-------------------------------------------------------------------------------------------------------------
CREATE TABLE Info.MedioPago
(
	identificadorPago int identity (1,1) primary key,
	tipoPago varchar (50) check (tipoPago IN ('EWallet','Cash','CreditCard')),
	nroTarjetaCuenta varchar (50),
);
GO

-------------------------------------------------------------------------------------------------------------
------------------------------------------- CLASIFICACION ---------------------------------------------------
-------------------------------------------------------------------------------------------------------------
CREATE TABLE Prod.Clasificacion
(
	idProducto int identity(1,1) primary key, 
	lineaProducto varchar(20) not null,
	producto varchar(50) not null
);
GO

-------------------------------------------------------------------------------------------------------------
--------------------------------------------- CATALOGO ------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
CREATE TABLE Prod.Catalogo 
(
	idCatalogo int identity(1,1) primary key,
	categoria varchar(100) not null,
	nombre varchar(100),
	precio decimal(10,2),
	referenciaPrecio decimal(10,2),
	referenciaUnidad varchar(10),
	fecha_hora datetime,
	idProductoCat int,

	CONSTRAINT FK_idCatalogo FOREIGN KEY(idProductoCat) REFERENCES Prod.Clasificacion(idProducto)
);
GO


-------------------------------------------- NUEVO PRODUCTO ------------------------------------------------
CREATE OR ALTER PROCEDURE Prod.ingresarCatalogo (@categoria varchar(100), @nombre varchar(100), @precio decimal(10,2),
											@referenciaPrecio decimal(10,2), @referenciaUnidad char(2))
AS
BEGIN
		DECLARE @IdProducto INT

		SELECT  @IdProducto=idProducto
		FROM Prod.Clasificacion
		WHERE producto= @categoria
		
		INSERT INTO Prod.Catalogo(categoria,nombre,precio,referenciaPrecio,referenciaUnidad,fecha_hora,idProducto)
		VALUES(@categoria,@nombre,@precio,@referenciaPrecio,@referenciaUnidad,GETDATE(),@IdProducto)
	
END
GO

-------------------------------------------- ELIMINAR PRODUCTO ------------------------------------------------
CREATE OR ALTER PROCEDURE Prod.eliminarCatalogo (@idCatalogo int)
AS 
BEGIN
	DELETE FROM Prod.Catalogo
	WHERE idCatalogo=@idCatalogo
END
GO

------------------------------------------- ACTUALIZAR PRECIO -----------------------------------------------
CREATE OR ALTER PROCEDURE Prod.nuePrecioCatalogo (@idCatalogo int, @nuePrecio decimal(10,2))
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Prod.Catalogo WHERE idCatalogo=@idCatalogo)
	BEGIN
		UPDATE Prod.Catalogo
		SET precio=@nuePrecio, fecha_hora=GETDATE()
		WHERE idCatalogo=@idCatalogo
	END
END
GO

-------------------------------------------------------------------------------------------------------------
--------------------------------------- PRODUCTOS ELECTRONICOS ----------------------------------------------
-------------------------------------------------------------------------------------------------------------
CREATE TABLE Prod.Electronico
(
	idElectronico int identity(1,1) primary key,
	nombre varchar(100),
	precioDolares decimal(10,2)
);
GO

--------------------------------------- NUEVO PRODUCTO ELECTRONICO ------------------------------------------
CREATE OR ALTER PROCEDURE Prod.ingresarElectronico (@nombre varchar(100),@nuePrecio decimal(10,2))
AS
BEGIN
	INSERT INTO Prod.Electronico(nombre,precioDolares)
	VALUES (@nombre,@nuePrecio)
END
GO


--------------------------------------- ELIMINAR PRODUCTO ELECTRONICO ---------------------------------------
CREATE OR ALTER PROCEDURE Prod.eliminarElectronico (@idElectronico int)
AS 
BEGIN 
	DELETE FROM Prod.Electronico
	WHERE idElectronico=@idElectronico
END
GO

--------------------------------------- ACTUALIZAR PRECIO ELECTRONICO ---------------------------------------
CREATE OR ALTER PROCEDURE Prod.nuePrecioElectronico (@idElectronico int, @nuePrecio decimal(10,2))
AS
BEGIN 
	UPDATE Prod.Electronico 
	SET precioDolares=@nuePrecio
	WHERE idElectronico=@idElectronico
END
GO

-------------------------------------------------------------------------------------------------------------
---------------------------------------- PRODUCTOS IMPORTADOS -----------------------------------------------
-------------------------------------------------------------------------------------------------------------
CREATE TABLE Prod.Importado
(
	idImportado int identity(1,1) primary key,
	nombre varchar(100),
	proveedor varchar(100),
	categoria varchar(50),
	cantidadXUnidad varchar(100),
	precioUnidad decimal(10,2)

);
GO

--------------------------------------- INGRESAR PRODUCTO IMPORTADO -----------------------------------------
CREATE OR ALTER PROCEDURE Prod.ingresarImportado (@nombre varchar(100), @proveedor varchar(100),
											@categoria varchar(50),@cantidadXUnidad varchar(100), @precioUnidad decimal(10,2))
AS
BEGIN
	INSERT INTO Prod.Importado(nombre,proveedor,categoria,cantidadXUnidad,precioUnidad)
	VALUES (@nombre,@proveedor,@categoria,@cantidadXUnidad,@precioUnidad)
END
GO

--------------------------------------- ELIMINAR PRODUCTO IMPORTADO -----------------------------------------
CREATE OR ALTER PROCEDURE Prod.eliminarImportado (@idImportado int)
AS
BEGIN 
		DELETE FROM Prod.Importado
		WHERE idImportado=@idImportado
END
GO

---------------------------------- ACTUALIZAR PRECIO PRODUCTO IMPORTADO -------------------------------------
CREATE OR ALTER PROCEDURE Prod.nuePrecioImportado (@idImportado int, @precioUnidad decimal(10,2))
AS
BEGIN
	UPDATE Prod.Importado 
	 SET precioUnidad=@precioUnidad
	 WHERE idImportado=@idImportado
END
GO


-------------------------------------------------------------------------------------------------------------
----------------------------------------- VENTAS REGISTRADAS ------------------------------------------------
-------------------------------------------------------------------------------------------------------------
DROP TABLE Ven.Registrada
CREATE TABLE Ven.Registrada
(
	idFactura char(11) primary key,
	tipoFactura char check (tipoFactura IN ('A','B','C')),
	ciudad varchar(30),
	tipoCliente varchar(8),
	genero varchar(8),
	lineaProducto varchar(50),
	precioUnitario decimal(10,2),
	cantidad int check(cantidad>0),
	total decimal(10,3),
	fecha date,
	hora time,
	medioPago varchar(12) check (medioPago IN ('EWallet','Cash','CreditCard')),
	---FOREIGN KEYS
	idEmpleado int not null,
	identificadorPago int,
	idSucursal int,
	idImportado int,
	idElectronico int,
	idCatalogo int,
	CONSTRAINT FK_idEmpleado FOREIGN KEY (idEmpleado) REFERENCES Info.Empleado(idEmpleado),
	CONSTRAINT FK_identificadorPago FOREIGN KEY  (identificadorPago) REFERENCES  Info.MedioPago(identificadorPago),
	CONSTRAINT FK_idSucursal FOREIGN KEY (idSucursal) REFERENCES Info.Sucursal(idSucursal),
	CONSTRAINT FK_idImportado FOREIGN KEY (idImportado) REFERENCES Prod.Importado(idImportado),
	CONSTRAINT FK_idElectronico FOREIGN KEY (idElectronico) REFERENCES Prod.Electronico(idElectronico),
	CONSTRAINT FK_idCatalogo FOREIGN KEY (idCatalogo) REFERENCES Prod.Catalogo(idCatalogo)
);
GO
