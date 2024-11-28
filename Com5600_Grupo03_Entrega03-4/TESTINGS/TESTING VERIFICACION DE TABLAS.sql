------------------------------------------------------------------------------------------------------------------------------
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
-----------------------------------------------------Testing de tablas--------------------------------------------------------


-----------------------------------------------------tabla Info.Sucursal--------------------------------------------------------
--CASO CORRECTO
INSERT INTO Info.Sucursal (ciudad, reemplazadaX, direccion, horario, telefono)
VALUES ('Buenos Aires', 'San Justo', 'Av. Principal 123', '8:00 - 20:00', '5555-5551');

-- Verificar la inserción
SELECT * FROM Info.Sucursal WHERE direccion = 'Av. Principal 123';


--Caso fallido 1
INSERT INTO Info.Sucursal (ciudad, reemplazadaX, direccion, horario, telefono)
VALUES ('Buenos Aires', 'San Justo', 'Calle Nueva 789', '8:00 - 20:00', '1234-5678');

-- Resultado esperado: Error por violación del CHECK constraint en `telefono`.


-----------------------------------------------------tabla Info.Empleado--------------------------------------------------------
--CASO CORRECTO
INSERT INTO Info.Empleado (nombre, apellido, dni, direccion, emailPesonal, emailEmpresa, cargo, sucursal, turno, idSucursal)
VALUES ('Juan', 'Pérez', 12345678, 'Calle Falsa 123', 'juan.perez@gmail.com', 'jperez@empresa.com', 'Cajero', 'San Justo', 'Mañana', 1);

-- Verificar la inserción
SELECT * FROM Info.Empleado WHERE dni = 12345678;


INSERT INTO Info.Empleado (nombre, apellido, dni, direccion, emailPesonal, emailEmpresa, cargo, sucursal, turno, idSucursal)
VALUES ('María', 'Gómez', 87654321, 'Calle Verdadera 456', 'maria.gomez@gmail.com', 'mgomez@empresa.com', 'Analista', 'San Justo', 'Tarde', 1);

-- Resultado esperado: Error por violación del *CHECK constraint* en el campo `cargo`




