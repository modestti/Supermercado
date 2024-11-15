USE Com5600G03
GO
-------------------------------------------------------------------------------------------------------------
----------------------------------------- VENTAS REGISTRADAS ------------------------------------------------
-------------------------------------------------------------------------------------------------------------

-- Creamos tabla Factura en el esquema Ven
CREATE TABLE Ven.Factura (
    IdFactura INT IDENTITY(1,1) PRIMARY KEY,
    Tipo_Factura VARCHAR(50),
    Numero_Factura VARCHAR(50),
    IVA DECIMAL(3,2),
    Fecha_De_Emision DATE,
    Subtotal DECIMAL(10,2),
    MontoTotal DECIMAL(10,2),
	Estado VARCHAR(50)
);
GO
-- Creamos la tabla Venta en el esquema Ven con IdFactura como clave foránea
CREATE TABLE Ven.Venta (
    IdVenta INT IDENTITY(1,1) PRIMARY KEY,
    Id_Sucursal INT,
    Id_Empleado INT,
    IdFactura INT,
	IdMedioPago INT,
    Fecha DATE,
    Hora TIME,
    monto_total DECIMAL(10,2),
    FOREIGN KEY (Id_Sucursal) REFERENCES Info.Sucursal(IdSucursal),
    FOREIGN KEY (Id_Empleado) REFERENCES Info.Empleado(IdEmpleado),
    FOREIGN KEY (IdFactura) REFERENCES Ven.Factura(IdFactura),  -- Clave foránea a Ven.Factura
	FOREIGN KEY (IdMedioPago) REFERENCES Info.MedioPago(idPago)
);
GO

-- Creamos la tabla Detalle_Venta en el esquema Ven
CREATE TABLE Ven.Detalle_Venta (
    Id_Detalle_Venta INT IDENTITY(1,1) PRIMARY KEY,
    IdProducto INT ,
    IdVenta INT,
    Cantidad INT,
    Precio_unitario DECIMAL(10,2),
    Subtotal DECIMAL(10,2),
    Numero_factura CHAR(30),
    FOREIGN KEY (IdVenta) REFERENCES Ven.Venta(IdVenta),
    FOREIGN KEY (IdProducto) REFERENCES Prod.Catalogo(IdProducto) -- Clave foránea a Prod.Catalogo
);
GO

--Creamos la tabla de Nota de Credito
CREATE TABLE Ven.Nota_De_Credito
( 
	IdNotaCredito INT IDENTITY(1,1) PRIMARY KEY,
	IdFactura int,
	Valor decimal(10,2),
	Fecha_emision datetime,
	FOREIGN KEY (IdFactura) REFERENCES Ven.Factura(IdFactura)
);
GO

-------------------------------------------------------------------------------------------------------------
-------------------------------------- STORES PROCEDURES VENTAS ---------------------------------------------
-------------------------------------------------------------------------------------------------------------
--------------------------------------- INGRESAR UNA VENTA -----------------------------------------
CREATE OR ALTER PROCEDURE Ven.registrarVenta (@Id_Sucursal INT, @Id_Empleado INT, @IdFactura INT, @IdMedioPago INT, @Fecha DATE, @Hora TIME,
												@Productos TABLE (IdProducto INT, Cantidad INT, Precio_unitario DECIMAL(10,2)) 
AS
BEGIN
    DECLARE @IdVenta INT;
    DECLARE @MontoTotal DECIMAL(10,2) = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @MontoTotal = SUM(Cantidad * Precio_unitario)
        FROM @Productos;

        INSERT INTO Ven.Venta (Id_Sucursal, Id_Empleado, IdFactura, IdMedioPago, Fecha, Hora, monto_total)
        VALUES (@Id_Sucursal, @Id_Empleado, @IdFactura, @IdMedioPago, @Fecha, @Hora, @MontoTotal);

        SET @IdVenta = SCOPE_IDENTITY();  -- Obtiene el ID de la venta recién insertada

        INSERT INTO Ven.Detalle_Venta (IdProducto, IdVenta, Cantidad, Precio_unitario, Subtotal, Numero_factura)
        SELECT IdProducto, @IdVenta, Cantidad, Precio_unitario, Cantidad * Precio_unitario, (SELECT Numero_Factura FROM Ven.Factura WHERE IdFactura = @IdFactura)
        FROM @Productos;

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

        UPDATE Ven.Factura
        SET Estado = 'Anulada'
        WHERE IdFactura = @IdFactura;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al realizar el borrado lógico de la venta: ' + ERROR_MESSAGE();
    END CATCH
END;
GO


-------------------------------------------------------------------------------------------------------------
--------------------------------- IMPORTACION DE VENTAS REGISTRADAS -----------------------------------------
-------------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ven.importarVentas (@RutaArchivo varchar(MAX)) 
AS
BEGIN
    BEGIN TRY

        DECLARE @Consulta nvarchar(max);
        DECLARE @IVA decimal(10,2)= 0.21
		DECLARE @ESTADO varchar(50) = 'Pagada'

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

        -- Generamos la consulta del BULK INSERT 
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
		
		-- Insertamos los medios de pago

		INSERT INTO Info.MedioPago(metodoPago,nombre)
		SELECT v.identificadorPago, v.medioPago FROM #VentasRegistradas v
		WHERE NOT EXISTS( SELECT 1 FROM Info.MedioPago WHERE metodoPago=v.identificadorPago)

		--Al insertar todos los que pagaron con cash, debemos eliminarlos dejando unicamente uno
		DELETE FROM Info.MedioPago 
		WHERE nombre = 'Cash' 
		AND idPago NOT IN (SELECT MIN(idPago) FROM Info.MedioPago WHERE nombre = 'Cash');

		-- Insertar en la tabla Factura en el esquema Ven
        INSERT INTO Ven.Factura (Tipo_Factura, Numero_Factura,IVA, Fecha_De_Emision, Subtotal, MontoTotal,Estado)
        SELECT DISTINCT v.tipoFactura, v.idFactura,@IVA, v.fecha, v.precioUnitario * v.cantidad, (v.precioUnitario * v.cantidad)*(1+@IVA),@ESTADO
        FROM #VentasRegistradas v
        WHERE NOT EXISTS (SELECT 1 FROM Ven.Factura f WHERE f.Numero_Factura = v.idFactura);


		-- Insertar en la tabla Venta en el esquema Ven
        INSERT INTO Ven.Venta (Id_Sucursal,Id_Empleado,IdFactura,IdMedioPago, Fecha, Hora, monto_total)
        SELECT DISTINCT s.idSucursal,e.idEmpleado, f.IdFactura, m.idPago, v.fecha, v.hora, v.precioUnitario * v.cantidad
        FROM #VentasRegistradas v
		INNER JOIN Info.Sucursal s ON v.ciudad=s.ciudad
		INNER JOIN Info.Empleado e ON v.idEmpleado=e.idEmpleado
		INNER JOIN Ven.Factura f ON f.Numero_Factura= v.idFactura
		INNER JOIN Info.MedioPago m ON m.metodoPago=v.identificadorPago
        WHERE NOT EXISTS (SELECT 1 FROM Ven.Venta ve WHERE ve.Fecha = v.fecha AND ve.Hora = v.hora AND ve.Id_Empleado = v.idEmpleado 
									AND ve.Id_Sucursal = s.idSucursal AND ve.IdFactura = f.IdFactura AND ve.IdMedioPago = m.idPago)
		
		-- Insertar en la tabla Detalle_Venta en el esquema Ven
        INSERT INTO Ven.Detalle_Venta (IdProducto, IdVenta, Cantidad, Precio_unitario, Subtotal, Numero_factura)
        SELECT c.idProducto, ve.IdVenta, v.cantidad, v.precioUnitario, v.precioUnitario * v.cantidad, v.idFactura
        FROM #VentasRegistradas v
        INNER JOIN Prod.Catalogo c ON c.nombreProducto = v.lineaProducto  -- Relaciona con Prod.Catalogo por nombreProducto
        INNER JOIN Ven.Venta ve ON ve.Fecha = v.fecha AND ve.Hora = v.hora AND ve.Id_Empleado = v.idEmpleado
		WHERE NOT EXISTS (SELECT 1 FROM Ven.Detalle_Venta WHERE Numero_factura= v.idFactura)

        -- Eliminamos la tabla temporal ya que no la necesitaremos la información almacenada allí
        DROP TABLE #VentasRegistradas;

    END TRY
    BEGIN CATCH
        PRINT 'Error al importar los datos de ventas: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

EXECUTE  Ven.importarVentas @RutaArchivo ='C:\Users\tomas\Documents\GitHub\Supermercado\Grupo_03\TP_integrador_Archivos\Ventas_registradas.csv'
