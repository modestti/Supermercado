USE Com5600G03
GO 

---PRUEBA DEL ROL EMPLEADO---
SELECT * FROM Info.Sucursal
GO
SELECT * FROM Ven.Nota_De_Credito
--TENDRIA QUE FALLAR DADO QUE UN EMPLEADO NO PUEDE GENERAR UNA NOTA DE CREDITO
EXECUTE Ven.nuevaNotaCredito @IdVenta=2