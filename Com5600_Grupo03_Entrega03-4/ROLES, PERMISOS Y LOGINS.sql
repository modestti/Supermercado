-------------------------------------------------------------------
--ENUNCIADO: Entrega 05
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
-----------------LOGINS--------------------
CREATE LOGIN LSupervisor WITH PASSWORD = 'ddbbSupervisor';
CREATE LOGIN LEmpleado WITH PASSWORD = 'ddbbEmpleado';
CREATE LOGIN LCliente WITH PASSWORD = 'ddbbCliente';

----------------USUARIOS-------------------
CREATE USER USupervisor FOR LOGIN LSupervisor;
CREATE USER UEmpleado FOR LOGIN  LEmpleado;
CREATE USER UCliente FOR LOGIN LCliente;

------------------ROLES---------------------
CREATE ROLE Supervisor;
CREATE ROLE Empleado;
CREATE ROLE Cliente;

-----------------PERMISOS-------------------
-----------------Supervisor-----------------
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::Info TO Supervisor WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::Prod TO Supervisor  WITH GRANT OPTION; 
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::Ven TO Supervisor  WITH GRANT OPTION; 

-----------------Empleado-------------------
GRANT SELECT ON SCHEMA::Info TO Empleado;
GRANT SELECT,UPDATE,DELETE,EXECUTE ON SCHEMA::Prod TO Empleado;
GRANT SELECT,INSERT, UPDATE,EXECUTE ON SCHEMA::Ven TO Empleado;
DENY EXECUTE ON Ven.nuevaNotaCredito TO Empleado;

------------------Cliente-------------------
GRANT SELECT ON Prod.Catalogo TO Cliente;
DENY SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::Info TO Cliente;
DENY SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::Ven TO Cliente;
DENY INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::Prod TO Cliente;

-----------ASIGNO A USUARIOS SU ROL---------
ALTER ROLE Supervisor ADD MEMBER USupervisor;
ALTER ROLE Empleado ADD MEMBER UEmpleado;
ALTER ROLE Cliente ADD MEMBER UCliente;

