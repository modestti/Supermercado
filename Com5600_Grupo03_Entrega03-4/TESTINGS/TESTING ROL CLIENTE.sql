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
-------------------------------------------------------------------}
USE Com5600G03
GO

---PRUEBA DEL ROL CLIENTE---
SELECT * FROM Prod.Catalogo
GO
--TENDRIA QUE FALLAR DADO QUE EL CLIENTE SOLO PUEDE VISUALIZAR EL CATALOGO
EXECUTE Prod.ingresarCatalogo @categoria='Prueba', @nombre='Prueba', @precio=19
GO
SELECT * FROM Ven.Venta
GO
SELECT * FROM Info.Empleado