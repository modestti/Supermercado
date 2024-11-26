-----------------------------------------------------Testing de tablas--------------------------------------------------------



-----------------------------------------------------tabla Info.Empleado--------------------------------------------------------
--CASO CORRECTO
INSERT INTO Info.Empleado (nombre, apellido, dni, direccion, emailPesonal, emailEmpresa, cargo, sucursal, turno, idSucursal)
VALUES ('Juan', 'P�rez', 12345678, 'Calle Falsa 123', 'juan.perez@gmail.com', 'jperez@empresa.com', 'Cajero', 'San Justo', 'Ma�ana', 1);

-- Verificar la inserci�n
SELECT * FROM Info.Empleado WHERE dni = 12345678;


INSERT INTO Info.Empleado (nombre, apellido, dni, direccion, emailPesonal, emailEmpresa, cargo, sucursal, turno, idSucursal)
VALUES ('Mar�a', 'G�mez', 87654321, 'Calle Verdadera 456', 'maria.gomez@gmail.com', 'mgomez@empresa.com', 'Analista', 'San Justo', 'Tarde', 1);

-- Resultado esperado: Error por violaci�n del *CHECK constraint* en el campo `cargo`


INSERT INTO Info.Empleado (nombre, apellido, dni, direccion, emailPesonal, emailEmpresa, cargo, sucursal, turno, idSucursal)
VALUES ('Carlos', 'S�nchez', 45678912, 'Avenida Siempre Viva 742', 'carlos.sanchez@gmail.com', 'csanchez@empresa.com', 'Gerente de sucursal', 'Mor�n', 'Noche', 1);

-- Resultado esperado: Error por violaci�n del *CHECK constraint* en el campo `sucursal`





-----------------------------------------------------tabla Info.Sucursal--------------------------------------------------------
