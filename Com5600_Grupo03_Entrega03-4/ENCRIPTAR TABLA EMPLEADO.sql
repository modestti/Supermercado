USE Com5600G03
GO

---ENCRIPTACION DE LA INFO DE LOS EMPLEADOS---
SELECT * FROM Info.Empleado
GO
---VOY A ENCRIPTAR DNI, DIRECCION, EMAIL PERSONAL Y CARGO CUANDO LA TABLA SE ENCUENTRA CARGADA

---CREAMOS COLUMNAS ADICIONALES PARA ALMACENAR LOS DATOS ENCRIPTADOS 
ALTER TABLE Info.Empleado ADD dni_temp VARBINARY(MAX);
ALTER TABLE Info.Empleado ADD direccion_temp VARBINARY(MAX);
ALTER TABLE Info.Empleado ADD emailPesonal_temp VARBINARY(MAX);
GO

--SEGUNDO ENCRIPTAMOS LOS DATOS
UPDATE Info.Empleado
SET 
	dni_temp= ENCRYPTBYPASSPHRASE('claveSegura1234',CAST(dni as VARCHAR(15))),
	direccion_temp = ENCRYPTBYPASSPHRASE('claveSegura1234', direccion),
	emailPesonal_temp = ENCRYPTBYPASSPHRASE('claveSegura1234', emailPesonal)

---UNA VEZ QUE LO DATOS ESTAN ENCRIPTADOS, ELIMINAMOS LAS COLUMNAS QUE NO SIRVE
ALTER TABLE Info.Empleado DROP COLUMN dni;
ALTER TABLE Info.Empleado DROP COLUMN direccion;
ALTER TABLE Info.Empleado DROP COLUMN emailPesonal;	
GO

-- POR ULTIMO RENOMBRAMOS LAS COLUMNAS TEMPORALES AL NOMBRE ORIGINAL
EXEC sp_rename 'Info.Empleado.dni_temp', 'dni', 'COLUMN';
EXEC sp_rename 'Info.Empleado.direccion_temp', 'direccion', 'COLUMN';
EXEC sp_rename 'Info.Empleado.emailPesonal_temp', 'emailPesonal', 'COLUMN';
GO

--PARA VISUALIZAR LOS DATOS CREAMOS UN PROCEDURE
CREATE OR ALTER PROCEDURE Info.desencriptarDatoEmpleado (@ClaveEncriptacion VARCHAR(100))
AS
BEGIN 
	SELECT 
    idEmpleado,
    nombre,
    apellido,
	CONVERT(VARCHAR(50), DecryptByPassPhrase(@ClaveEncriptacion, dni)) AS dni, 
	CONVERT(VARCHAR(100), DecryptByPassPhrase(@ClaveEncriptacion, direccion)) AS direccion, 
	CONVERT(VARCHAR(100), DecryptByPassPhrase(@ClaveEncriptacion, emailPesonal)) AS emailPesonal, 
	emailEmpresa,
    cargo,
    sucursal,
    turno,
    idSucursal
	FROM Info.Empleado;
END

EXECUTE Info.desencriptarDatoEmpleado @ClaveEncriptacion='claveSegura1234'

--PARA AÑADIR DATOS DE UN NUEVO EMPLEADO
DROP PROCEDURE Info.nuevoEmpleado
GO
CREATE OR ALTER PROCEDURE Info.nuevoEmpleadoEncrip (@nombre VARCHAR(100), @apellido VARCHAR(100), @dni INT, @direccion VARCHAR(100), 
									@emailPersonal VARCHAR(100), @emailEmpresa VARCHAR(100), @cargo VARCHAR(30), @sucursal VARCHAR(50), @turno VARCHAR(30))
AS 
BEGIN
	IF NOT EXISTS( SELECT 1 FROM Info.Empleado WHERE CONVERT(VARCHAR(50), DecryptByPassPhrase('claveSegura1234', dni))=CAST(@dni AS VARCHAR(15)))
	BEGIN	
			DECLARE @idSucursal INT=(SELECT idSucursal FROM Info.Sucursal WHERE reemplazadaX=@sucursal)

			INSERT INTO Info.Empleado(nombre,apellido,dni,direccion,emailPesonal,emailEmpresa,cargo,sucursal,turno,idSucursal)
			VALUES (@nombre,@apellido, ENCRYPTBYPASSPHRASE('claveSegura1234',CAST(@dni as VARCHAR(15))),ENCRYPTBYPASSPHRASE('claveSegura1234', @direccion),
			ENCRYPTBYPASSPHRASE('claveSegura1234', @emailPersonal),@emailEmpresa,@cargo,@sucursal,@turno,@idSucursal)
			print 'Se ingreso el nuevo empleado correctamente'
	END
	ELSE
	BEGIN 
			print 'El DNI del empleado nuevo coincide con otro empleado'
	END
END
---INSERTAMOS EMPLEADOS PARA VER QUE SUCEDE
EXECUTE Info.nuevoEmpleadoEncrip @nombre='Juan', @apellido='Mendez' , @dni=45073572, @direccion='Ocampo 12, San Justo', @emailPersonal='juanCarlos1MAmigos@gmail.com', @emailEmpresa= 'juanM@empresa.com',
							@cargo='Cajero', @sucursal='San Justo', @turno='TM'
GO
EXECUTE Info.nuevoEmpleadoEncrip @nombre='Tomas', @apellido='Perez' , @dni=36383025, @direccion='San Justo', @emailPersonal='tomas@gmail.com', @emailEmpresa= 'tomasEmpresa@prrr.com',
							@cargo='Cajero', @sucursal='San Justo', @turno='TM'
GO

---PARA ELIMINAR DATOS DE UN EMPLEADO
DROP PROCEDURE Info.despedirEmpleado
GO
CREATE OR ALTER PROCEDURE Info.despedirEmpleadoEncrip (@IdEmpleado INT)
AS 
BEGIN 
	UPDATE Info.Empleado
	SET dni=NULL, cargo=NULL, sucursal=NULL,turno=NULL,idSucursal=NULL,emailEmpresa=NULL
	WHERE idEmpleado=@IdEmpleado
END
--EJECUTAMOS PARA VER QUE SUCEDE
EXECUTE Info.despedirEmpleadoEncrip @IdEmpleado=257035


