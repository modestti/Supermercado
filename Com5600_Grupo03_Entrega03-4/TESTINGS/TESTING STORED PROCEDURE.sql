USE Com5600G03

----------------------------------------- ABRIR NUEVA SUCURSAL ----------------------------------------------
EXECUTE Info.nuevaSucursal @Ciudad= 'Madrid',@reemplazadaX= 'Lomas del mirador', @direccion= 'Peribebuy 6000',@horario='24hs',@telefono='5555-5555'
GO
SELECT * FROM INFO.Sucursal
------------------------------------------  CERRAR LA SUCURSAL ----------------------------------------------
EXECUTE Info.cerrarSucursal @idSucursal=1,@ciudad='Madrid'
GO
SELECT * FROM INFO.Sucursal
------------------------------------------ ACTUALIZAR EL HORARIO DE LA SUCURSAL -----------------------------
EXECUTE Info.nuevoHorarioSucursal @idSucursal=2, @horario= 'Lu a Vi 9-18hs'
GO
SELECT * FROM INFO.Sucursal
GO
------------------------------------------ ACTUALIZAR EL TELEFONO DE LA SUCURSAL ----------------------------
EXECUTE Info.nuevoTelefonoSucursal @idSucursal=1, @telefono= '5555-5558'
GO
SELECT * FROM INFO.Sucursal
GO

---------------------------------------------- NUEVO EMPLEADO -----------------------------------------------
EXECUTE Info.nuevoEmpleado @nombre= 'Tomas', @apellido='Modestti', @dni= 45073572, @direccion='Peribebuy 4242', @emailEmpresa='tomas@empresa.com', 
							@emailPersonal= 'tomas.m@gmail.com', @cargo= 'Supervisor', @sucursal= 'Lomas del Mirador', @turno='M'
GO
SELECT * FROM info.Empleado
--------------------------------- ACTUALIZACION DEL CARGO DE UN EMPLEADO ------------------------------------
EXECUTE Info.nuevoCargoEmpleado @dni=45073572, @nueCargo= 'Gerente de sucursal'
GO
SELECT * FROM info.Empleado
--------------------------------- ACTUALIZACION DEL TURNO DE UN EMPLEADO ------------------------------------
EXECUTE Info.cambioTurnoEmpleado @dni=45073572, @turno= 'T'
GO
SELECT * FROM info.Empleado

DBCC CHECKIDENT('Info.Empleado' , RESEED, 0)-- RESETEAMOS EL IdEmpleado
GO

------------------------------------------- ACTUALIZAR PRECIO -----------------------------------------------
-- Caso 1: Actualizar el precio de un producto existente
EXEC Prod.nuePrecioCatalogo @idCatalogo = 1, @nuePrecio = 120.00;
SELECT * FROM Prod.Catalogo
-------------------------------------------- ELIMINAR PRODUCTO ------------------------------------------------
-- Caso 1: Eliminar un producto existente
EXEC Prod.eliminarCatalogo @idCatalogo = 1;
SELECT * FROM Prod.Catalogo
-- Test 2: Arroja error por prod inexistente
EXEC Prod.eliminarCatalogo @idCatalogo = 912;
SELECT * FROM Prod.Catalogo

--------------------------------------------- ELIMINAR VENTA --------------------------------------------------
EXEC Ven.cancelarVenta @IdVenta = 1;

--------------------------------------------- NOTA DE CREDITO -------------------------------------------------
EXECUTE Ven.nuevaNotaCredito @IdVenta=1000
SELECT * FROM Ven.Venta
SELECT * FROM Ven.Factura
SELECT * FROM Ven.Nota_De_Credito