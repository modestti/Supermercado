-------------------------------------------------------------------
--ENUNCIADO: EXECUTES REPORTES 
--FECHA DE ENTREGA: 28 de Noviembre 2024
--NUMERO DE COMISION:5600 
--NOMBRE DE LA MATERIA: BASE DE DATOS APLICADA
--NUMERO DEL GRUPO: 03
--INTEGRANTES: 
--			MODESTTI, TOMÁS AGUSTÍN (45073572)
--			NIEVAS, VALENTIN LISANDRO (45464487)
--			QUIÑONEZ, LUCIANO FEDERICO (45007142)
--			RODRIGUEZ, MAURICIO EZEQUIEL (42774942)
--------------------------------------------------------------------
USE Com5600G03
GO
-------------------------------------------------------------------
--Mensual: ingresando un mes y año determinado mostrar el total 
--facturado por días de la semana, incluyendo sábado y domingo.
-------------------------------------------------------------------
EXECUTE Ven.facturacionMensual @Mes=1,@Anio=2019 --Funciona
EXECUTE Ven.facturacionMensual @Mes=15,@Anio=2019 --Falla porque el mes no esta correcto
EXECUTE Ven.facturacionMensual @Mes=1,@Anio=2025 --Falla porque el año no esta correcto

-------------------------------------------------------------------
--Trimestral:mostrar el total facturado por turnos de trabajo por mes.
-------------------------------------------------------------------
EXECUTE Ven.facturacionTrimestral @Anio=2019, @Trimestre=1 --Funciona
EXECUTE Ven.facturacionTrimestral @Anio=1890, @Trimestre=1 --Se ingreso un año incorrecto
EXECUTE Ven.facturacionTrimestral @Anio=2019, @Trimestre=5 --Se ingreso un trimestre erroneo 

-------------------------------------------------------------------
--Por rango de fechas: ingresando un rango de fechas a demanda, 
--debe poder mostrar la cantidad de productos vendidos en ese rango,
--ordenado de mayor a menor.
-------------------------------------------------------------------
EXECUTE Ven.cantidadProdVendidos @FechaIni= '01-05-2019', @FechaFin= '01-27-2019' --Funciona
EXECUTE Ven.cantidadProdVendidos @FechaIni= '01-27-2019', @FechaFin='01-05-2019' --Se ingresaron mal las fechas (Fecha Inicio tiene que ser menor a la Fecha Final)

-------------------------------------------------------------------
--Por rango de fechas: ingresando un rango de fechas a demanda, 
--debe poder mostrar la cantidad de productos vendidos en ese rango 
--por sucursal, ordenado de mayor a menor
-------------------------------------------------------------------
EXECUTE Ven.cantidadProdVendidosXSucursal @FechaIni= '01-05-2019', @FechaFin= '01-06-2019'

-------------------------------------------------------------------
--Mostrar los 5 productos más vendidos en un mes, por semana
-------------------------------------------------------------------
EXECUTE Ven.productosMasVendidos @Mes=1,@Anio=2019 --Funciona 
EXECUTE Ven.productosMasVendidos @Mes=15,@Anio=2025 --Falla debido a que el mes y el anio es incorrecto

-------------------------------------------------------------------
--Mostrar los 5 productos menos vendidos en el mes
-------------------------------------------------------------------
EXECUTE Ven.productosMenosVendidos @Mes=3,@Anio=2019 --Funciona

-------------------------------------------------------------------
--Mostrar total acumulado de ventas (o sea tambien mostrar el 
--detalle) para una fecha y sucursal particulares
-------------------------------------------------------------------
EXECUTE Ven.totalXFechaYSucursal @Fecha='2019-01-03', @Sucursal='San Justo' --Funciona
EXECUTE Ven.totalXFechaYSucursal @Fecha='2019-03-13', @Sucursal='San Juan'	--Se ingresa mal la sucursal 


