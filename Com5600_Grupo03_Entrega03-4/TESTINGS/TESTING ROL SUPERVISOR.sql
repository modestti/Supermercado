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


