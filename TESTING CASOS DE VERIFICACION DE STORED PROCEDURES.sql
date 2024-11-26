--Testing de los Store



--Info.nuevaSucursal-----------------------------------------------------------------------------------
--Caso exitoso
EXEC Info.nuevaSucursal @ciudad = 'Madrid', @reemplazadaX = 'Centro', @direccion = 'Calle Mayor 123', @horario = '08:00-20:00', @telefono = '600123456';
SELECT * FROM Info.Sucursal; -- Verificar inserción

--Caso Fallido
EXEC Info.nuevaSucursal @ciudad = 'Madrid', @reemplazadaX = 'Centro', @direccion = 'Calle Mayor 123', @horario = '08:00-20:00', @telefono = '600123456';
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
EXEC Info.nuevoHorarioSucursal @idSucursal = 1, @horario = '09:00-17:00';
SELECT * FROM Info.Sucursal; -- Verificar actualización

--Caso Fallido
EXEC Info.nuevoHorarioSucursal @idSucursal = 999, @horario = '09:00-17:00';
SELECT * FROM Info.Sucursal; -- Ningún cambio debería ocurrir



--Info.nuevoTelefonoSucursal-----------------------------------------------------------------------------------
--Caso Exitoso
EXEC Info.nuevoTelefonoSucursal @idSucursal = 1, @telefono = '600789123';
SELECT * FROM Info.Sucursal; -- Verificar actualización

--Caso Fallido
EXEC Info.nuevoTelefonoSucursal @idSucursal = 999, @telefono = '600789123';
SELECT * FROM Info.Sucursal; -- Ningún cambio debería ocurrir



--Prod.insertarClasificacion-----------------------------------------------------------------------------------
--Caso Exitoso
EXEC Prod.insertarClasificacion @lineaProducto = 'Electrónica', @producto = 'Televisor';
SELECT * FROM Prod.Clasificacion; -- Verificar inserción

--Caso Fallido
EXEC Prod.insertarClasificacion @lineaProducto = 'Electrónica', @producto = 'Televisor';
SELECT * FROM Prod.Clasificacion; -- No debería duplicarse




--Info.nuevoEmpleado-----------------------------------------------------------------------------------
--Caso Exitoso
EXEC Info.nuevoEmpleado @nombre = 'Juan', @apellido = 'Pérez', @dni = 12345678, @direccion = 'Calle Falsa 123', @emailPersonal = 'juan.perez@gmail.com', @emailEmpresa = 'jperez@empresa.com', @cargo = 'Gerente', @sucursal = 'Centro', @turno = 'M';
SELECT * FROM Info.Empleado; -- Verificar inserción

--Caso Fallido (Sucursal no encontrada)
EXEC Info.nuevoEmpleado @nombre = 'Juan', @apellido = 'Pérez', @dni = 12345678, @direccion = 'Calle Falsa 123', @emailPersonal = 'juan.perez@gmail.com', @emailEmpresa = 'jperez@empresa.com', @cargo = 'Gerente', @sucursal = 'Inexistente', @turno = 'M';



--Info.nuevoCargoEmpleado-----------------------------------------------------------------------------------
--Caso Exitoso
SELECT * FROM Info.Empleado
WHERE dni = 36383025;
EXEC Info.nuevoCargoEmpleado @dni = 36383025, @nueCargo = 'Director';
SELECT * FROM Info.Empleado; -- Verificar actualización
WHERE dni = 36383025;

--Caso Fallido
EXEC Info.nuevoCargoEmpleado @dni = 99999999, @nueCargo = 'Director';



--Info.cambioTurnoEmpleado-----------------------------------------------------------------------------------
--Caso Exitoso
SELECT * FROM Info.Empleado
WHERE dni = 36383025;
EXEC Info.cambioTurnoEmpleado @dni = 36383025, @turno = 'T';
SELECT * FROM Info.Empleado -- Verificar cambio
WHERE dni = 36383025;
--Caso Fallido
EXEC Info.cambioTurnoEmpleado @dni = 99999999, @turno = 'T';



--Info.despedirEmpleado-----------------------------------------------------------------------------------
--Caso Exitoso
EXEC Info.despedirEmpleado @dni = 36383025;
SELECT * FROM Info.Empleado; -- Verificar eliminación

--Caso Fallido
EXEC Info.despedirEmpleado @dni = 99999999;



--Prod.ingresarCatalogo-----------------------------------------------------------------------------------
--Caso Exitoso
EXEC Prod.ingresarCatalogo @categoria = 'Hogar', @nombre = 'Microondas', @precio = 300.00;
SELECT * FROM Prod.Catalogo; -- Verificar inserción

--Caso Fallido
EXEC Prod.ingresarCatalogo @categoria = 'Hogar', @nombre = 'Microondas', @precio = 300.00;



--Prod.eliminarCatalogo-----------------------------------------------------------------------------------
--Caso Exitoso
EXEC Prod.eliminarCatalogo @idCatalogo = 1;
SELECT * FROM Prod.Catalogo; -- Verificar que `fecha` sea `NULL`

--Caso Fallido
EXEC Prod.eliminarCatalogo @idCatalogo = 999;



--Prod.nuePrecioCatalogo-----------------------------------------------------------------------------------
--Caso Exitoso
EXEC Prod.nuePrecioCatalogo @idCatalogo = 1, @nuePrecio = 350.00;
SELECT * FROM Prod.Catalogo; -- Verificar precio actualizado

--Caso Fallido
EXEC Prod.nuePrecioCatalogo @idCatalogo = 999, @nuePrecio = 350.00;



--Ven.registrarVenta-----------------------------------------------------------------------------------
--Caso Exitoso
EXEC Ven.registrarVenta @Id_Sucursal = 1, @Id_Empleado = 1, @IdFactura = 1, @IdMedioPago = 1, @Fecha = '2024-11-26', @Hora = '12:00:00', @IdProducto = 1, @Cantidad = 2, @Precio_unitario = 100.00;
SELECT * FROM Ven.Venta; -- Verificar inserción

--Caso Fallido
EXEC Ven.registrarVenta @Id_Sucursal = 999, @Id_Empleado = 1, @IdFactura = 1, @IdMedioPago = 1, @Fecha = '2024-11-26', @Hora = '12:00:00', @IdProducto = 1, @Cantidad = 2, @Precio_unitario = 100.00;

