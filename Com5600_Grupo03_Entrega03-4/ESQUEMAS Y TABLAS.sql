-----------------------------------------------------------------------------
--------------------- CREACION DE LA BASE Y ESQUEMAS ------------------------
-----------------------------------------------------------------------------

---EN EL CASO DE QUE NO EXISTA LA BASE DE DATOS LA CREA 
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Com5600G03')
    CREATE DATABASE Com5600G03;

USE Com5600G03
GO
--ESQUEMA CREADO PARA LO RELACIONADO CON VENTAS
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Ven')
		EXECUTE('CREATE SCHEMA Ven')

--ESQUEMA CREADO PARA LO RELACIONADO CON LOS PRODUCTOS
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Prod')
	EXECUTE('CREATE SCHEMA Prod')

--ESQUEMA CREADO CON LO RELACIONADO A LAS SUCURSALES 
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Info')
		EXECUTE('CREATE SCHEMA Info')

GO


-----------------------------------------------------------------------------
------------------------- CREACION DE TABLAS --------------------------------
-----------------------------------------------------------------------------
CREATE TABLE Info.Sucursal
(
	idSucursal int identity(1,1) primary key,
	ciudad varchar (15),																						--Ciudad	
	reemplazadaX  varchar(20) not null check (reemplazadaX  IN ('San Justo','Ramos Mejia','Lomas del Mirador')), --Chequeamos que se encuentre dentro de la localidad en la que nos manejamos
	direccion varchar(150),																						--La direccion de nuestra sucursal 
	horario varchar(50),																						--Los horarios de atencion al publico
	telefono varchar(9) check (telefono like '5555-555[0-9]')													--Nuestro telefono interno
);
GO

CREATE TABLE Info.Empleado
(
	idEmpleado int identity(257020,1) primary key, 
	nombre varchar (100),
	apellido varchar(100),
	dni int,
	direccion varchar(255),
	emailPesonal varchar(100),
	emailEmpresa varchar(100),
	cargo varchar(60) check (cargo IN ('Cajero','Supervisor','Gerente de sucursal')), --Son los tres puestos ue nuestro empleados pueden ocupar
	sucursal varchar(60) check (sucursal IN ('San Justo','Ramos Mejia','Lomas del Mirador')), --Verificamos que no sean de una sucursal que este fuera del area que nosotros manejamos
	turno varchar(30),
	idSucursal int,

	CONSTRAINT FK_idSucursal FOREIGN KEY (idSucursal) references Info.Sucursal(idSucursal)
);
GO

CREATE TABLE Info.MedioPago
(
	idPago int identity primary key,
	metodoPago varchar(50),
	nombre varchar(50)
);
GO

CREATE TABLE Prod.Clasificacion
(
	idProducto int identity(1,1) primary key, 
	lineaProducto varchar(20) not null,
	producto varchar(50) not null
);
GO

CREATE TABLE Prod.Catalogo 
(
	idProducto int identity(1,1) primary key,
	nombreProducto varchar(150),
	categoria varchar(50),
	precioUnidad decimal(10,2), 
	fecha datetime
)
GO

CREATE TABLE Ven.Factura (
    IdFactura INT IDENTITY(1,1) PRIMARY KEY,
    Tipo_Factura VARCHAR(50),
    Numero_Factura VARCHAR(50),
    IVA DECIMAL(3,2),
    Fecha_De_Emision DATE,
    Subtotal DECIMAL(10,2),
    MontoTotal DECIMAL(10,2),
	Estado VARCHAR(50)
);
GO

CREATE TABLE Ven.Venta (
    IdVenta INT IDENTITY(1,1) PRIMARY KEY,
    Id_Sucursal INT,
    Id_Empleado INT,
    IdFactura INT,
	IdMedioPago INT,
    Fecha DATE,
    Hora TIME,
    monto_total DECIMAL(10,2),
    FOREIGN KEY (Id_Sucursal) REFERENCES Info.Sucursal(IdSucursal),
    FOREIGN KEY (Id_Empleado) REFERENCES Info.Empleado(IdEmpleado),
    FOREIGN KEY (IdFactura) REFERENCES Ven.Factura(IdFactura),  -- Clave foránea a Ven.Factura
	FOREIGN KEY (IdMedioPago) REFERENCES Info.MedioPago(idPago)
);
GO

CREATE TABLE Ven.Detalle_Venta (
    Id_Detalle_Venta INT IDENTITY(1,1) PRIMARY KEY,
    IdProducto INT ,
    IdVenta INT,
    Cantidad INT,
    Precio_unitario DECIMAL(10,2),
    Subtotal DECIMAL(10,2),
    Numero_factura CHAR(30),
    FOREIGN KEY (IdVenta) REFERENCES Ven.Venta(IdVenta),
    FOREIGN KEY (IdProducto) REFERENCES Prod.Catalogo(IdProducto) -- Clave foránea a Prod.Catalogo
);
GO

CREATE TABLE Ven.Nota_De_Credito
( 
	IdNotaCredito INT IDENTITY(1,1) PRIMARY KEY,
	IdFactura int,
	Valor decimal(10,2),
	Fecha_emision datetime,
	FOREIGN KEY (IdFactura) REFERENCES Ven.Factura(IdFactura)
);
GO
