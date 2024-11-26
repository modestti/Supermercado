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
