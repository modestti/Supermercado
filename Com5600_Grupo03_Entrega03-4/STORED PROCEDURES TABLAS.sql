-------------------------------------------------------------------
--ENUNCIADO: Entrega 3
--FECHA DE ENTREGA: 28 de Noviembre 2024
--NUMERO DE COMISION:5600 
--NOMBRE DE LA MATERIA: BASE DE DATOS APLICADA
--NUMERO DEL GRUPO: 03
--INTEGRANTES: 
--			MODESTTI, TOMÁS AGUSTÍN (45073572)
--			NIEVAS, VALENTIN LISANDRO (45464487)
--			QUIÑONEZ, LUCIANO FEDERICO (45007142)
--			RODRIGUEZ, MAURICIO EZEQUIEL (42774942)
-------------------------------------------------------------------
USE Com5600G03
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
GO
------------------------------------------  CERRAR LA SUCURSAL ----------------------------------------------
CREATE OR ALTER PROCEDURE Info.cerrarSucursal (@idSucursal int)
AS
BEGIN 
	--Elinamos la sucursal 
	UPDATE Info.Sucursal
		SET horario=NULL, direccion=NULL,ciudad=NULL
		WHERE idSucursal= @idSucursal

END;
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

------------------------------------------- NUEVA CLASIFICACION ----------------------------------------------
CREATE OR ALTER PROCEDURE Prod.insertarClasificacion( @lineaProducto varchar(100), @producto varchar(50))
AS
BEGIN 
	IF NOT EXISTS (SELECT 1 FROM Prod.Clasificacion WHERE producto=@producto)
		INSERT INTO Prod.Clasificacion (lineaProducto,producto)VALUES (@lineaProducto,@producto)
END;
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


-------------------------------------------- NUEVO PRODUCTO ------------------------------------------------
CREATE OR ALTER PROCEDURE Prod.ingresarCatalogo (@categoria varchar(100), @nombre varchar(100), @precio decimal(10,2))
AS
BEGIN
    -- Verificamos si el producto ya existe en la tabla Catalogo por nombre
    IF NOT EXISTS (SELECT 1 FROM Prod.Catalogo WHERE nombreProducto = @nombre)
    BEGIN
        -- Insertamos el producto en la tabla Catalogo
        INSERT INTO Prod.Catalogo (nombreProducto, precioUnidad, fecha)
        VALUES (@nombre, @precio, GETDATE());
        PRINT 'Producto insertado correctamente en el catálogo.';
		
		INSERT INTO Prod.Clasificacion (lineaProducto)
        VALUES (@categoria);  
    END
    ELSE
    BEGIN
        PRINT 'El producto ya existe en el catálogo.';
    END
END
GO


-------------------------------------------- ELIMINAR PRODUCTO ------------------------------------------------
CREATE OR ALTER PROCEDURE Prod.eliminarCatalogo (@idCatalogo int)
AS 
BEGIN
	--Elinamos el producto
	UPDATE Prod.Catalogo
	SET fecha=NULL
	WHERE idProducto=@idCatalogo
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

--------------------------------------- INGRESAR UNA VENTA -----------------------------------------
CREATE OR ALTER PROCEDURE Ven.registrarVenta (@Id_Sucursal INT, @Id_Empleado INT, @IdFactura INT, @IdMedioPago INT, @Fecha DATE, @Hora TIME,
												@IdProducto INT, @Cantidad INT,@Precio_unitario DECIMAL(10,2)) 
AS
BEGIN
    DECLARE @IdVenta INT;
    DECLARE @MontoTotal DECIMAL(10,2) = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @MontoTotal = SUM(@Cantidad * @Precio_unitario)

        INSERT INTO Ven.Venta (Id_Sucursal, Id_Empleado, IdFactura, IdMedioPago, Fecha, Hora, monto_total)
        VALUES (@Id_Sucursal, @Id_Empleado, @IdFactura, @IdMedioPago, @Fecha, @Hora, @MontoTotal);

        SET @IdVenta = SCOPE_IDENTITY();  -- Obtiene el ID de la venta recién insertada

        INSERT INTO Ven.Detalle_Venta (IdProducto,IdVenta,Cantidad, Precio_unitario, Subtotal, Numero_factura)
        VALUES(@IdProducto,@IdVenta,@Cantidad, @Precio_unitario,@Cantidad * @Precio_unitario, (SELECT Numero_Factura FROM Ven.Factura WHERE IdFactura = @IdFactura))

        UPDATE Ven.Factura
        SET MontoTotal = MontoTotal + @MontoTotal,
            Estado = 'Completa'
        WHERE IdFactura = @IdFactura;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al insertar la venta: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

--------------------------------------- ELIMINAR VENTA -----------------------------------------
CREATE OR ALTER PROCEDURE Ven.cancelarVenta (@IdVenta INT)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @IdFactura INT;
        SELECT @IdFactura = (select IdFactura FROM Ven.Venta WHERE IdVenta = @IdVenta)

		IF @IdFactura IS NOT NULL
		BEGIN 
			UPDATE Ven.Factura
			SET Estado = 'Anulada'
			WHERE IdFactura = @IdFactura;
		END 
		ELSE
        BEGIN
            PRINT 'No hay una venta asociada con ese IDVenta.';
        END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al realizar el borrado lógico de la venta: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

--------------------------------------- NOTA DE CREDITO -----------------------------------------
CREATE OR ALTER PROCEDURE Ven.nuevaNotaCredito (@IdVenta INT)
AS 
BEGIN 
	BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @IdFactura INT;
        SELECT @IdFactura = (select IdFactura FROM Ven.Venta WHERE IdVenta = @IdVenta)

		IF @IdFactura IS NOT NULL
		BEGIN 

			UPDATE Ven.Factura
			SET Estado = 'Anulada'
			WHERE IdFactura = @IdFactura;

			INSERT INTO Ven.Nota_De_Credito(IdFactura,Valor,Fecha_emision)
			SELECT @IdFactura, monto_total, GETDATE() FROM Ven.Venta 
			WHERE IdVenta=@IdVenta
			  PRINT 'La nota de crédito fue generada con éxito.';
        END
        ELSE
        BEGIN
            PRINT 'No existe una venta asociada con el IdVenta proporcionado.';
        END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al realizar el borrado lógico de la venta: ' + ERROR_MESSAGE();
    END CATCH
END;

