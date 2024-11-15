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
	--Busco el idSucursal por el DNI 
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
	--Busco el idSucursal por el DNI 
	SELECT @IdEmpleado = IdEmpleado
    FROM Info.Empleado
    WHERE dni = @dni;
	--Verificamos si se encontró el empleado
	IF @IdEmpleado is NULL
	BEGIN 
	 PRINT 'Empleado no encontrada.';
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
------------------------------------------- MEDIO DE PAGO ---------------------------------------------------
-------------------------------------------------------------------------------------------------------------
CREATE TABLE Info.MedioPago
(
	idPago int identity primary key,
	metodoPago varchar(50),
	nombre varchar(50)
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
		--Buscamos idProducto en la tabla Prod.Clasificacion
		SELECT  @IdProducto=idProducto
		FROM Prod.Clasificacion
		WHERE producto= @categoria
		--Insertamos el producto nuevo
		INSERT INTO Prod.Catalogo(categoria,nombre,precio,referenciaPrecio,referenciaUnidad,fecha_hora,idProducto)
		VALUES(@categoria,@nombre,@precio,@referenciaPrecio,@referenciaUnidad,GETDATE(),@IdProducto)
	
END
GO

-------------------------------------------- ELIMINAR PRODUCTO ------------------------------------------------
CREATE OR ALTER PROCEDURE Prod.eliminarCatalogo (@idCatalogo int)
AS 
BEGIN
	--Elinamos el producto
	DELETE FROM Prod.Catalogo
	WHERE idCatalogo=@idCatalogo
END
GO

------------------------------------------- ACTUALIZAR PRECIO -----------------------------------------------
CREATE OR ALTER PROCEDURE Prod.nuePrecioCatalogo (@idCatalogo int, @nuePrecio decimal(10,2))
AS
BEGIN
	--Buscamos el producto
	IF EXISTS (SELECT 1 FROM Prod.Catalogo WHERE idCatalogo=@idCatalogo)
	BEGIN
		--Si lo encontramos, actualizamos el precio. Por lo tanto, la fecha y hora tambien para saber cuando fue la ultima vez que se modifico
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
	--Insertamos el producto 
	INSERT INTO Prod.Electronico(nombre,precioDolares)
	VALUES (@nombre,@nuePrecio)
END
GO


--------------------------------------- ELIMINAR PRODUCTO ELECTRONICO ---------------------------------------
CREATE OR ALTER PROCEDURE Prod.eliminarElectronico (@idElectronico int)
AS 
BEGIN 
	--Eliminamos el producto
	DELETE FROM Prod.Electronico
	WHERE idElectronico=@idElectronico
END
GO

--------------------------------------- ACTUALIZAR PRECIO ELECTRONICO ---------------------------------------
CREATE OR ALTER PROCEDURE Prod.nuePrecioElectronico (@idElectronico int, @nuePrecio decimal(10,2))
AS
BEGIN 
	--Actualizamos el precio 
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
CREATE TABLE Ven.Registrada
(
	idVenta int identity(1,1) primary key,
	idFactura char(11),
	tipoFactura char check (tipoFactura IN ('A','B','C')),
	ciudad varchar(100),
	tipoCliente varchar(50),
	genero varchar(20),
	lineaProducto varchar(100),
	precioUnitario decimal(10,2),
	cantidad int check(cantidad>0),
	total decimal(10,3),
	fecha date,
	hora time,
	medioPago varchar(40),
	idEmpleado int not null,
	identificadorPago varchar(100),

	---FOREIGN KEYS
	idSucursal int,
	idImportado int,
	idElectronico int,
	idCatalogo int,

	CONSTRAINT FK_idEmpleado FOREIGN KEY (idEmpleado) REFERENCES Info.Empleado(idEmpleado),
	CONSTRAINT FK_idSucursal FOREIGN KEY (idSucursal) REFERENCES Info.Sucursal(idSucursal),
	CONSTRAINT FK_idImportado FOREIGN KEY (idImportado) REFERENCES Prod.Importado(idImportado),
	CONSTRAINT FK_idElectronico FOREIGN KEY (idElectronico) REFERENCES Prod.Electronico(idElectronico),
	CONSTRAINT FK_idCatalogo FOREIGN KEY (idCatalogo) REFERENCES Prod.Catalogo(idCatalogo)
);
GO

--------------------------------------- INGRESAR UNA VENTA -----------------------------------------
CREATE OR ALTER PROCEDURE Ven.registrarVenta (@idFactura char(11), @tipoFactura char, @ciudad varchar(100),@tipoCliente varchar(50),
											@genero varchar(20),@lineaProducto varchar(100),@precioUnitario decimal(10,2),@cantidad int,@medioPago varchar(40),@idEmpleado int,@identificadorPago varchar(100))
AS
BEGIN 
	DECLARE @idSucursal int
	DECLARE @idImportado int
	DECLARE @idElectronico int
	DECLARE @idCatalogo int

	SELECT @idSucursal=idSucursal FROM Info.Empleado
	WHERE idEmpleado = @idEmpleado

	SELECT @idImportado=idImportado FROM Prod.Importado
	WHERE nombre=@lineaProducto

	SELECT @idElectronico=idElectronico FROM Prod.Electronico
	WHERE nombre=@lineaProducto

	SELECT @idCatalogo=@idCatalogo FROM Prod.Catalogo
	WHERE nombre=@lineaProducto

	INSERT INTO Ven.Registrada(idFactura, tipoFactura,ciudad,tipoCliente,genero,lineaProducto,precioUnitario,cantidad,total,fecha,hora,medioPago,idEmpleado,identificadorPago,idSucursal, idImportado,idElectronico, idCatalogo)
	VALUES  (@idFactura,@tipoFactura,@ciudad,@tipoCliente,@genero,@lineaProducto,@precioUnitario,@cantidad,@precioUnitario*@cantidad,GETDATE(),CONVERT(TIME, GETDATE()),@medioPago,@idEmpleado,@identificadorPago,@idSucursal, @idImportado,@idElectronico,@idCatalogo)

END
GO
--------------------------------------- ELIMINAR VENTA -----------------------------------------
CREATE OR ALTER PROCEDURE Ven.cancelarVenta (@idVenta int ,@idFactura char(11))
AS 
BEGIN 
      UPDATE Ven.Registrada
      SET  fecha = NULL, hora = NULL   
      WHERE idFactura = @idFactura AND idVenta=@idVenta;
      PRINT 'La venta ha sido cancelada exitosamente.';
END;

