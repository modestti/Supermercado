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

---PRUEBA DEL SUPERVISOR---
SELECT * FROM Info.Sucursal
GO
SELECT * FROM Ven.Venta
GO
SELECT * FROM Ven.Nota_De_Credito
GO
SELECT * FROM Ven.Factura
GO
EXECUTE Ven.nuevaNotaCredito @IdVenta=1


