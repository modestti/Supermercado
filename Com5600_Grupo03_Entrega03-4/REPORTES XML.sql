-------------------------------------------------------------------
--ENUNCIADO: REPORTES 
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
-------------------------------------------------------------------
--Mensual: ingresando un mes y año determinado mostrar el total 
--facturado por días de la semana, incluyendo sábado y domingo.
-------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ven.facturacionMensual(@Mes INT, @Anio INT)
AS
BEGIN
	IF (@Mes<1 OR @Mes>12)
	BEGIN
		RAISERROR ('Mes invalido', 16, 1, @Mes)
		RETURN 
	END

	IF (@Anio<1900 OR @Anio>YEAR(GETDATE()))
	BEGIN
		RAISERROR ('Año invalido', 16, 1, @Anio)
		RETURN 
	END

	SELECT DATENAME(WEEKDAY, Fecha) AS DiaSemana,
	SUM(monto_total) AS TotalFacturado FROM Ven.Venta
	WHERE MONTH(Fecha)=@Mes AND YEAR(Fecha)=@Anio 
	GROUP BY DATENAME(WEEKDAY,Fecha)
    FOR XML PATH('Dia'), ROOT('ReporteMensual')
END
GO

-------------------------------------------------------------------
--Trimestral:mostrar el total facturado por turnos de trabajo por mes.
-------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ven.facturacionTrimestral( @Anio INT, @Trimestre INT)
AS
BEGIN
	--Trimestre puede ser 1,2,3 o 4. 
	IF (@Trimestre<1 OR @Trimestre>4)
	BEGIN 
		RAISERROR('Trimestre invalido, ingrese un numero del 1 al 4',16,1,@Trimestre)
		RETURN
	END
	IF (@Anio<1900 OR @Anio>YEAR(GETDATE()))
	BEGIN
		RAISERROR ('Año invalido', 16, 1, @Anio)
		RETURN 
	END

	DECLARE @MesInicio INT = (@Trimestre - 1) * 3 + 1;
	DECLARE @MesFin INT = @Trimestre * 3;

	SELECT MONTH(Fecha) AS Mes,
        CASE 
            WHEN CAST(Hora AS TIME) BETWEEN '06:00:00' AND '14:00:00' THEN 'Mañana'
            ELSE 'Tarde'
        END AS Turno, SUM(monto_total) AS TotalFacturado
    FROM Ven.Venta
    WHERE YEAR(Fecha) = @Anio AND MONTH(Fecha) BETWEEN @MesInicio AND @MesFin
    GROUP BY 
        MONTH(Fecha),
        CASE 
            WHEN CAST(Hora AS TIME) BETWEEN '06:00:00' AND '14:00:00' THEN 'Mañana'
            ELSE 'Tarde'
        END
    ORDER BY MONTH(Fecha), Turno
    FOR XML PATH('Recaudacion'), ELEMENTS, ROOT('ReporteTrimestral')
END
GO

-------------------------------------------------------------------
--Por rango de fechas: ingresando un rango de fechas a demanda, 
--debe poder mostrar la cantidad de productos vendidos en ese rango,
--ordenado de mayor a menor.
-------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ven.cantidadProdVendidos (@FechaIni VARCHAR(20), @FechaFin VARCHAR(20))
AS
BEGIN 
	IF(CAST(@FechaIni AS date)>CAST(@FechaFin as date))
	BEGIN 
		RAISERROR('Se ingresaron mal las fechas',16,1, @FechaIni)
		RETURN
	END

	SELECT c.nombreProducto, SUM(dv.cantidad) as CantidadVendida FROM Ven.Detalle_Venta dv
	INNER JOIN Ven.Venta v ON v.IdVenta=dv.IdVenta
	INNER JOIN Prod.Catalogo c ON c.idProducto=dv.IdProducto
	WHERE v.Fecha BETWEEN CAST(@FechaIni AS date) AND CAST(@FechaFin as date)
	GROUP BY c.nombreProducto
	ORDER BY CantidadVendida DESC
	FOR XML PATH('Producto'), ELEMENTS, ROOT('ReportePorRango')
END
GO 

-------------------------------------------------------------------
--Por rango de fechas: ingresando un rango de fechas a demanda, 
--debe poder mostrar la cantidad de productos vendidos en ese rango 
--por sucursal, ordenado de mayor a menor
-------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ven.cantidadProdVendidosXSucursal (@FechaIni VARCHAR(20), @FechaFin VARCHAR(20))
AS
BEGIN 
	IF(CAST(@FechaIni AS date)>CAST(@FechaFin as date))
	BEGIN 
		RAISERROR('Se ingresaron mal las fechas',16,1, @FechaIni)
		RETURN
	END

	SELECT s.reemplazadaX as Nombre, SUM(dv.cantidad) as CantidadVendida FROM Ven.Detalle_Venta dv
	INNER JOIN Ven.Venta v ON v.IdVenta=dv.IdVenta
	INNER JOIN Info.Sucursal s ON s.idSucursal=v.Id_Sucursal
	WHERE v.Fecha BETWEEN CAST(@FechaIni AS date) AND CAST(@FechaFin as date)
	GROUP BY s.reemplazadaX
	ORDER BY CantidadVendida DESC
	FOR XML PATH('Sucursal'), ELEMENTS, ROOT('ReportePorSucursal')
END
GO

-------------------------------------------------------------------
--Mostrar los 5 productos más vendidos en un mes, por semana
-------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ven.productosMasVendidos (@Mes INT, @Anio INT)
AS 
BEGIN 
	IF (@Mes<1 OR @Mes>12)
	BEGIN
		RAISERROR ('Mes invalido', 16, 1, @Mes)
		RETURN 
	END

	IF (@Anio<1900 OR @Anio>YEAR(GETDATE()))
	BEGIN
		RAISERROR ('Año invalido', 16, 1, @Anio)
		RETURN 
	END

	;WITH ProductoSemana AS
	(
		SELECT DATEPART(WEEK,v.Fecha) as Semana, c.nombreProducto as NombreProducto, 
		SUM(dv.Cantidad) as TotalCantidad,ROW_NUMBER() OVER (PARTITION BY DATEPART(WEEK, v.Fecha) ORDER BY SUM(dv.Cantidad) DESC) AS Ranking
		FROM Ven.Detalle_Venta dv
		INNER JOIN Ven.Venta v ON v.IdVenta=dv.IdVenta 
		INNER JOIN Prod.Catalogo c ON c.idProducto=dv.IdProducto
		WHERE YEAR(v.Fecha)= @Anio AND MONTH(v.Fecha)=@Mes
		GROUP BY DATEPART(WEEK,v.Fecha), c.nombreProducto
	)
	
	SELECT Semana,NombreProducto,TotalCantidad
	FROM ProductoSemana
	WHERE Ranking<=5
	ORDER BY Semana,TotalCantidad DESC
	FOR XML PATH('Semana'), ELEMENTS, ROOT('ReporteMensual');
END
GO 

-------------------------------------------------------------------
--Mostrar los 5 productos menos vendidos en el mes
-------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ven.productosMenosVendidos (@Anio INT , @Mes INT)
AS 
BEGIN 
   IF (@Mes<1 OR @Mes>12)
	BEGIN
		RAISERROR ('Mes invalido', 16, 1, @Mes)
		RETURN 
	END

	IF (@Anio<1900 OR @Anio>YEAR(GETDATE()))
	BEGIN
		RAISERROR ('Año invalido', 16, 1, @Anio)
		RETURN 
	END

	SELECT TOP 5 c.nombreProducto,dv.IdProducto, SUM(dv.Cantidad) AS TotalVendido
    	FROM Ven.Detalle_Venta dv
    	INNER JOIN Prod.Catalogo c ON c.idProducto = dv.IdProducto
    	INNER JOIN Ven.Venta v ON v.IdVenta = dv.IdVenta
    	WHERE YEAR(v.Fecha) = @Anio AND MONTH(v.Fecha) = @Mes
    	GROUP BY c.nombreProducto, dv.IdProducto
    ORDER BY TotalVendido ASC
	FOR XML PATH('Producto'), ELEMENTS, ROOT('MenosVendidosMes')
END 
GO

-------------------------------------------------------------------
--Mostrar total acumulado de ventas (o sea tambien mostrar el 
--detalle) para una fecha y sucursal particulares
-------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Ven.totalXFechaYSucursal (@Fecha VARCHAR(20), @Sucursal VARCHAR(30))
AS
BEGIN
	IF( @Sucursal NOT IN ('Ramos Mejia','San Justo','Lomas del Mirador'))
	BEGIN
		RAISERROR('Ingrese correctamente la sucursal', 16,1,@Sucursal)
		RETURN 
	END

	IF (ISDATE(@Fecha)=0)
	BEGIN 
		RAISERROR('Fecha invalida, ingrese una fecha "YYYY-MM-DD"', 16,1,@Fecha)
	END
	
	SELECT v.IdVenta, v.Fecha,s.reemplazadaX AS Sucursal,dv.IdProducto,c.nombreProducto AS Producto,
    	dv.Cantidad,dv.Precio_Unitario,dv.Subtotal,SUM(v.monto_total) OVER (PARTITION BY v.Id_Sucursal, v.Fecha) AS TotalAcumulado
    	FROM Ven.Detalle_Venta dv
	INNER JOIN Ven.Venta v ON v.IdVenta=dv.IdVenta
	INNER JOIN Info.Sucursal s ON s.idSucursal=v.Id_Sucursal
	INNER JOIN Prod.Catalogo c ON  dv.IdProducto=c.idProducto
	WHERE s.reemplazadaX=@Sucursal AND v.Fecha=CAST(@Fecha as date)
	ORDER BY v.IdVenta, dv.IdProducto
	FOR XML PATH('DetalleProducto'), ELEMENTS, ROOT('ReporteTotalFechaSucursal')
END
