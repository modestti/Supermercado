USE Com5600G03
GO

--INSERTAR SUPERMERCADO--
CREATE PROCEDURE InsertarSupermercado
    @CUIT CHAR(15),
    @nombre_supermercado VARCHAR(255)
AS
BEGIN
    BEGIN TRY
        -- Inserta un nuevo registro en la tabla Info.Supermercado
        INSERT INTO Info.Supermercado (CUIT, nombre_supermercado)
        VALUES (@CUIT, @nombre_supermercado);

        PRINT 'Inserción exitosa';
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        PRINT 'Error al insertar en la tabla Info.Supermercado';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
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

------------------------------------------- NUEVA CLASIFICACION ----------------------------------------------
CREATE OR ALTER PROCEDURE Prod.insertarClasificacion( @lineaProducto varchar(100), @producto varchar(50))
AS
BEGIN 
	IF NOT EXISTS (SELECT 1 FROM Prod.Clasificacion WHERE producto=@producto)
		INSERT INTO Prod.Clasificacion (lineaProducto,producto)VALUES (@lineaProducto,@producto)
END;


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

END;
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
END;
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
END;
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
END;		
GO
EXECUTE Info.despedirEmpleado @dni=45073572
GO
DBCC CHECKIDENT('Info.Empleado' , RESEED, 0)-- RESETEAMOS EL IdEmpleado
GO

-------------------------------------------- NUEVO PRODUCTO ------------------------------------------------
CREATE OR ALTER PROCEDURE Prod.ingresarCatalogo (@categoria varchar(100), @nombre varchar(100), @precio decimal(10,2))
AS
BEGIN	
		--Insertamos el producto nuevo
		IF NOT EXISTS (SELECT 1 FROM Prod.Catalogo WHERE nombreProducto=@nombre AND fecha=GETDATE()) 
			INSERT INTO Prod.Catalogo(categoria,nombreProducto,precioUnidad,fecha)VALUES(@categoria,@nombre,@precio,GETDATE())
END;
GO

-------------------------------------------- ELIMINAR PRODUCTO ------------------------------------------------
CREATE OR ALTER PROCEDURE Prod.eliminarCatalogo (@idCatalogo int)
AS 
BEGIN
	--Elinamos el producto
	DELETE FROM Prod.Catalogo WHERE idProducto=@idCatalogo
END;
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
END;
GO

--------------------------------------- INGRESAR PRODUCTO IMPORTADO -----------------------------------------
CREATE OR ALTER PROCEDURE Prod.ingresarImportado (@nombre varchar(100), @proveedor varchar(100),
											@categoria varchar(50),@cantidadXUnidad varchar(100), @precioUnidad decimal(10,2))
AS
BEGIN
	INSERT INTO Prod.Importado(nombre,proveedor,categoria,cantidadXUnidad,precioUnidad)
	VALUES (@nombre,@proveedor,@categoria,@cantidadXUnidad,@precioUnidad)
END;
GO

--------------------------------------- ELIMINAR PRODUCTO IMPORTADO -----------------------------------------
CREATE OR ALTER PROCEDURE Prod.eliminarImportado (@idImportado int)
AS
BEGIN 
		DELETE FROM Prod.Importado
		WHERE idImportado=@idImportado
END;
GO

---------------------------------- ACTUALIZAR PRECIO PRODUCTO IMPORTADO -------------------------------------
CREATE OR ALTER PROCEDURE Prod.nuePrecioImportado (@idImportado int, @precioUnidad decimal(10,2))
AS
BEGIN
	UPDATE Prod.Importado 
	 SET precioUnidad=@precioUnidad
	 WHERE idImportado=@idImportado
END;
GO

--------------------------------------- INGRESAR UNA VENTA -----------------------------------------
CREATE OR ALTER PROCEDURE Ven.registrarVenta (
    @idFactura CHAR(11),
    @tipoFactura CHAR(1),
    @ciudad VARCHAR(100),
    @tipoCliente VARCHAR(50),
    @genero VARCHAR(20),
    @lineaProducto VARCHAR(100),
    @precioUnitario DECIMAL(10,2),
    @cantidad INT,
    @medioPago VARCHAR(40),
    @idEmpleado INT,
    @identificadorPago VARCHAR(100),
    @categoria VARCHAR(100),   
    @referenciaPrecio DECIMAL(10,2), 
    @referenciaUnidad VARCHAR(10),   
    @idProductoCat INT                
)
AS
BEGIN
    DECLARE @idSucursal INT;
    DECLARE @idImportado INT;
    DECLARE @idElectronico INT;
    DECLARE @idCatalogo INT;

    -- Obtener idSucursal basado en el empleado
    SELECT @idSucursal = idSucursal
    FROM Info.Empleado
    WHERE idEmpleado = @idEmpleado;

    -- Obtener idImportado basado en el nombre del producto
    SELECT @idImportado = idImportado
    FROM Prod.Importado
    WHERE nombre = @lineaProducto;

    -- Obtener idElectronico basado en el nombre del producto
    SELECT @idElectronico = idElectronico
    FROM Prod.Electronico
    WHERE nombre = @lineaProducto;

    -- Verificar si el producto ya existe en Prod.Catalogo
    SELECT @idCatalogo = idCatalogo
    FROM Prod.Catalogo
    WHERE nombre = @lineaProducto;

    -- Si el producto no existe en Prod.Catalogo, insertarlo
    IF @idCatalogo IS NULL
    BEGIN
        INSERT INTO Prod.Catalogo (categoria, nombre, precio, referenciaPrecio, referenciaUnidad, fecha_hora, idProductoCat)
        VALUES (@categoria, @lineaProducto, @precioUnitario, @referenciaPrecio, @referenciaUnidad, GETDATE(), @idProductoCat);

        -- Obtener el idCatalogo recién insertado
        SET @idCatalogo = SCOPE_IDENTITY();
    END

    -- Insertar la venta en Ven.Registrada
    INSERT INTO Ven.Registrada (
        idFactura, tipoFactura, ciudad, tipoCliente, genero, lineaProducto,
        precioUnitario, cantidad, total, fecha, hora, medioPago, idEmpleado,
        identificadorPago, idSucursal, idImportado, idElectronico, idCatalogo
    )
    VALUES (
        @idFactura, @tipoFactura, @ciudad, @tipoCliente, @genero, @lineaProducto,
        @precioUnitario, @cantidad, @precioUnitario * @cantidad, GETDATE(),
        CONVERT(TIME, GETDATE()), @medioPago, @idEmpleado, @identificadorPago,
        @idSucursal, @idImportado, @idElectronico, @idCatalogo
    );

    PRINT 'La venta ha sido registrada exitosamente.';
END;
GO

--------------------------------------- ELIMINAR VENTA -----------------------------------------
CREATE OR ALTER PROCEDURE Ven.cancelarVenta (@idVenta INT, @NroFactura CHAR(30))
AS 
BEGIN
    -- Actualizar fecha y hora a NULL cuando coinciden idVenta y Numero_Factura
    UPDATE Ven.Venta
    SET Fecha = NULL, Hora = NULL
    FROM Ven.Venta
    JOIN Ven.Factura ON Ven.Venta.IdFactura = Ven.Factura.IdFactura
    WHERE Ven.Venta.IdVenta = @idVenta AND Ven.Factura.Numero_Factura = @NroFactura;

    PRINT 'La venta ha sido cancelada exitosamente.';
END;
