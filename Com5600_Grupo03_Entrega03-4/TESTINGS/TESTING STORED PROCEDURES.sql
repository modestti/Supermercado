------------------------------------------------------------------------------------------------------
--ENUNCIADO: Entrega 03 
--FECHA DE ENTREGA: 28 de Noviembre 2024
--NUMERO DE COMISION:5600 
--NOMBRE DE LA MATERIA: BASE DE DATOS APLICADA
--NUMERO DEL GRUPO: 03
--INTEGRANTES: 
--			MODESTTI, TOMÁS AGUSTÍN (45073572)
--			NIEVAS, VALENTIN LISANDRO (45464487)
--			QUIÑONEZ, LUCIANO FEDERICO (45007142)
--			RODRIGUEZ, MAURICIO EZEQUIEL (42774942)
------------------------------------------------------------------------------------------------------
--Testing de los Store
USE Com5600G03
GO

--Info.nuevaSucursal-----------------------------------------------------------------------------------
--Caso exitoso
EXEC Info.nuevaSucursal @ciudad = 'Madrid', @reemplazadaX = 'Laferrere', @direccion = 'Calle Mayor 123', @horario = '08:00-20:00', @telefono = '5555-5556';
SELECT * FROM Info.Sucursal; -- Verificar inserción
--Caso Fallido
EXEC Info.nuevaSucursal @ciudad = 'Madrid', @reemplazadaX = 'Laferrere', @direccion = 'Calle Mayor 123', @horario = '08:00-20:00', @telefono = '5555-5556';
SELECT * FROM Info.Sucursal; -- No debería insertar una nueva fila por duplicado



--Info.cerrarSucursal-----------------------------------------------------------------------------------
--Caso Exitoso
EXEC Info.cerrarSucursal @idSucursal = 1;
SELECT * FROM Info.Sucursal; -- La sucursal debería tener `NULL` en los campos actualizados
--Caso Fallido
EXEC Info.cerrarSucursal @idSucursal = 999; -- ID no existe
SELECT * FROM Info.Sucursal; -- Ningún cambio debería ocurrir



--Info.nuevoHorarioSucursal-----------------------------------------------------------------------------------
--Caso Exitoso
EXEC Info.nuevoHorarioSucursal @idSucursal = 2, @horario = '09:00-17:00';
SELECT * FROM Info.Sucursal; -- Verificar actualización
--Caso Fallido
EXEC Info.nuevoHorarioSucursal @idSucursal = 999, @horario = '09:00-17:00';
SELECT * FROM Info.Sucursal; -- Ningún cambio debería ocurrir



--Info.nuevoTelefonoSucursal-----------------------------------------------------------------------------------
--Caso Exitoso
EXEC Info.nuevoTelefonoSucursal @idSucursal = 1, @telefono = '5555-5559';
SELECT * FROM Info.Sucursal; -- Verificar actualización
--Caso Fallido
EXEC Info.nuevoTelefonoSucursal @idSucursal = 999, @telefono = '5555-5559';
SELECT * FROM Info.Sucursal; -- Ningún cambio debería ocurrir



--Info.nuevoEmpleado-----------------------------------------------------------------------------------
--Caso Exitoso
EXEC Info.nuevoEmpleado @nombre = 'Roberto', @apellido = 'Medina', @dni = 12546987, @direccion = 'Santa Maria', @emailPersonal = 'robert.medina@gmail.com', @emailEmpresa = 'rmedina@empresa.com', @cargo = 'Supervisor', @sucursal = 'Laferrere', @turno = 'M';
SELECT * FROM Info.Empleado; -- Verificar inserción
--Caso Fallido (Sucursal no encontrada)
EXEC Info.nuevoEmpleado @nombre = 'Roberto', @apellido = 'Medina', @dni = 12345678, @direccion = 'Santa Maria', @emailPersonal = 'robert.medina@gmail.com', @emailEmpresa = 'rmedina@empresa.com', @cargo = 'Supervisor', @sucursal = 'Catan', @turno = 'M';



--Info.nuevoCargoEmpleado-----------------------------------------------------------------------------------
--Caso Exitoso
SELECT * FROM Info.Empleado
WHERE dni = 12345678;

EXEC Info.nuevoCargoEmpleado @dni = 12345678, @nueCargo = 'Cajero';

SELECT * FROM Info.Empleado -- Verificamos actualización
WHERE dni = 12345678;

--Caso Fallido
EXEC Info.nuevoCargoEmpleado @dni = 99999999, @nueCargo = 'Supervisor';



--Info.cambioTurnoEmpleado-----------------------------------------------------------------------------------
--Caso Exitoso
SELECT * FROM Info.Empleado
WHERE dni = 12345678;

EXEC Info.cambioTurnoEmpleado @dni =12345678, @turno = 'T';

SELECT * FROM Info.Empleado -- Verificamos cambio
WHERE dni = 12345678;

--Caso Fallido
EXEC Info.cambioTurnoEmpleado @dni =45073572, @turno = 'T';


--Info.despedirEmpleado-----------------------------------------------------------------------------------
--Caso Exitoso
EXEC Info.despedirEmpleado @dni = 12345678;
SELECT * FROM Info.Empleado; 
--Caso Fallido
EXEC Info.despedirEmpleado @dni = 99999999;



--Prod.insertarClasificacion-----------------------------------------------------------------------------------
--Caso Exitoso
EXEC Prod.insertarClasificacion @lineaProducto = 'Electrónica', @producto = 'Televisor';
SELECT * FROM Prod.Clasificacion;
--Caso Fallido
EXEC Prod.insertarClasificacion @lineaProducto = 'Electrónica', @producto = 'Televisor';
SELECT * FROM Prod.Clasificacion; -- No debería duplicarse


--Prod.ingresarCatalogo-----------------------------------------------------------------------------------
--Caso Exitoso
EXEC Prod.ingresarCatalogo @categoria = 'Electronico', @nombre = 'Celular', @precio = 300.00;
SELECT * FROM Prod.Catalogo; 
--Caso Fallido
EXEC Prod.ingresarCatalogo @categoria = 'Electronico', @nombre = 'Celular', @precio = 300.00;



--Prod.eliminarCatalogo-----------------------------------------------------------------------------------
--Caso Exitoso
EXEC Prod.eliminarCatalogo @idCatalogo = 1;
SELECT * FROM Prod.Catalogo; -- Verificar que 'fecha' sea 'NULL'
--Caso Fallido
EXEC Prod.eliminarCatalogo @idCatalogo = 999;



--Prod.nuePrecioCatalogo-----------------------------------------------------------------------------------
--Caso Exitoso
EXEC Prod.nuePrecioCatalogo @idCatalogo = 2, @nuePrecio = 350.00;
SELECT * FROM Prod.Catalogo; -- Verificar precio actualizado
--Caso Fallido
EXEC Prod.nuePrecioCatalogo @idCatalogo = 999, @nuePrecio = 350.00;


--Info.ingresarMedioPago
--Caso Exitoso
EXECUTE Info.ingresarMedioPago @Metodo='Null', @Nombre='Cash'
SELECT * FROM Info.MedioPago
--Caso Fallido
EXECUTE Info.ingresarMedioPago @Metodo='Null', @Nombre='Cash'

  
--Ven.registrarVenta-----------------------------------------------------------------------------------
--Caso Exitoso
EXEC Ven.registrarVenta @IdSucursal=3, @IdEmpleado=257022, @NumeroFactura='004-78-4555', @IdMedioPago=1, @IdProducto=1, @Cantidad=10, @PrecioUnitario=30, @TipoFactura='B'
SELECT * FROM Ven.Venta;
SELECT * FROM Ven.Factura
SELECT * FROM Ven.Detalle_Venta-- Verificar inserción
--Caso Fallido
EXEC Ven.registrarVenta @IdSucursal=999, @IdEmpleado=257022, @NumeroFactura='004-89-1012', @IdMedioPago=1, @IdProducto=2, @Cantidad=30, @PrecioUnitario=2.10, @TipoFactura='B'

  
--Ven.cancelarVenta
--Caso Exitoso
EXEC Ven.cancelarVenta @IdVenta=1
SELECT * FROM Ven.Venta
SELECT * FROM Ven.Factura
--Caso Fallido
EXEC Ven.cancelarVenta @IdVenta=9999

