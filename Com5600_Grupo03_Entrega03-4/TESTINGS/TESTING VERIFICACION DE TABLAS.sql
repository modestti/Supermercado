-----------------------------------------------------Testing de tablas--------------------------------------------------------



-----------------------------------------------------tabla Info.Empleado--------------------------------------------------------
--CASO CORRECTO
INSERT INTO Info.Empleado (nombre, apellido, dni, direccion, emailPesonal, emailEmpresa, cargo, sucursal, turno, idSucursal)
VALUES ('Juan', 'Pérez', 12345678, 'Calle Falsa 123', 'juan.perez@gmail.com', 'jperez@empresa.com', 'Cajero', 'San Justo', 'Mañana', 1);

-- Verificar la inserción
SELECT * FROM Info.Empleado WHERE dni = 12345678;


INSERT INTO Info.Empleado (nombre, apellido, dni, direccion, emailPesonal, emailEmpresa, cargo, sucursal, turno, idSucursal)
VALUES ('María', 'Gómez', 87654321, 'Calle Verdadera 456', 'maria.gomez@gmail.com', 'mgomez@empresa.com', 'Analista', 'San Justo', 'Tarde', 1);

-- Resultado esperado: Error por violación del *CHECK constraint* en el campo `cargo`


INSERT INTO Info.Empleado (nombre, apellido, dni, direccion, emailPesonal, emailEmpresa, cargo, sucursal, turno, idSucursal)
VALUES ('Carlos', 'Sánchez', 45678912, 'Avenida Siempre Viva 742', 'carlos.sanchez@gmail.com', 'csanchez@empresa.com', 'Gerente de sucursal', 'Morón', 'Noche', 1);

-- Resultado esperado: Error por violación del *CHECK constraint* en el campo `sucursal`





-----------------------------------------------------tabla Info.Sucursal--------------------------------------------------------
--CASO CORRECTO
INSERT INTO Info.Sucursal (ciudad, reemplazadaX, direccion, horario, telefono)
VALUES ('Buenos Aires', 'San Justo', 'Av. Principal 123', '8:00 - 20:00', '5555-5551');

-- Verificar la inserción
SELECT * FROM Info.Sucursal WHERE direccion = 'Av. Principal 123';

--Caso fallido 1
INSERT INTO Info.Sucursal (ciudad, reemplazadaX, direccion, horario, telefono)
VALUES ('Buenos Aires', 'Morón', 'Av. Secundaria 456', '8:00 - 20:00', '5555-5552');

-- Resultado esperado: Error por violación del CHECK constraint en `reemplazadaX`.

--Caso fallido 2
INSERT INTO Info.Sucursal (ciudad, reemplazadaX, direccion, horario, telefono)
VALUES ('Buenos Aires', 'San Justo', 'Calle Nueva 789', '8:00 - 20:00', '1234-5678');

-- Resultado esperado: Error por violación del CHECK constraint en `telefono`.
