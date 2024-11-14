--CREACION DE ESQUEMAS
CREATE SCHEMA Ven
GO

CREATE SCHEMA Prod
GO

CREATE SCHEMA Info
GO

-------------------------------------------------------------------------------------------------------------
--------------------------------------------------SUCURSAL---------------------------------------------------
-------------------------------------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------------------------------------
--------------------------------------------------EMPLEADO---------------------------------------------------
-------------------------------------------------------------------------------------------------------------
CREATE TABLE Info.Empleado
(
	idEmpleado int identity(257020,1) primary key, 
	nombre nvarchar (100),
	apellido nvarchar(100),
	dni int,
	direccion varchar(255),
	emailPesonal nvarchar(100),
	emailEmpresa nvarchar(100),
	cargo varchar(60) check (cargo IN ('Cajero','Supervisor','Gerente de sucursal')), --Son los tres puestos ue nuestro empleados pueden ocupar
	sucursal varchar(60) check (sucursal IN ('San Justo','Ramos Mejia','Lomas del Mirador')), --Verificamos que no sean de una sucursal que este fuera del area que nosotros manejamos
	turno varchar(30),
	idSucursal int,

	CONSTRAINT FK_idSucursal FOREIGN KEY (idSucursal) references Info.Sucursal(idSucursal)
);
GO

-------------------------------------------------------------------------------------------------------------
------------------------------------------- MEDIO DE PAGO ---------------------------------------------------
-------------------------------------------------------------------------------------------------------------
CREATE TABLE Info.MedioPago
(
	idPago int identity primary key,
	metodoPago varchar(50),
	nombre varchar(50)
);
GO
-------------------------------------------------------------------------------------------------------------
------------------------------------------- CLASIFICACION ---------------------------------------------------
-------------------------------------------------------------------------------------------------------------
CREATE TABLE Prod.Clasificacion
(
	idProducto int identity(1,1) primary key, 
	lineaProducto varchar(20) not null,
	producto varchar(50) not null
);
GO

-------------------------------------------------------------------------------------------------------------
--------------------------------------------- CATALOGO ------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
CREATE TABLE Prod.Catalogo 
(
	idCatalogo int identity(1,1) primary key,
	categoria varchar(100) not null,
	nombre varchar(100),
	precio decimal(10,2),
	referenciaPrecio decimal(10,2),
	referenciaUnidad varchar(10),
	fecha_hora datetime,
	idProductoCat int,

	CONSTRAINT FK_idCatalogo FOREIGN KEY(idProductoCat) REFERENCES Prod.Clasificacion(idProducto)
);
GO

-------------------------------------------------------------------------------------------------------------
--------------------------------------- PRODUCTOS ELECTRONICOS ----------------------------------------------
-------------------------------------------------------------------------------------------------------------
CREATE TABLE Prod.Electronico
(
	idElectronico int identity(1,1) primary key,
	nombre varchar(100),
	precioDolares decimal(10,2)
);
GO

CREATE TABLE Prod.Importado
(
	idImportado int identity(1,1) primary key,
	nombre varchar(100),
	proveedor varchar(100),
	categoria varchar(50),
	cantidadXUnidad varchar(100),
	precioUnidad decimal(10,2)

);
GO

-------------------------------------------------------------------------------------------------------------
----------------------------------------- VENTAS REGISTRADAS ------------------------------------------------
-------------------------------------------------------------------------------------------------------------
CREATE TABLE Ven.Registrada
(
	idVenta int identity(1,1) primary key,
	idFactura char(11),
	tipoFactura char check (tipoFactura IN ('A','B','C')),
	ciudad varchar(100),
	tipoCliente varchar(50),
	genero varchar(20),
	lineaProducto varchar(100),
	precioUnitario decimal(10,2),
	cantidad int check(cantidad>0),
	total decimal(10,3),
	fecha date,
	hora time,
	medioPago varchar(40),
	idEmpleado int not null,
	identificadorPago varchar(100),

	---FOREIGN KEYS
	idSucursal int,
	idImportado int,
	idElectronico int,
	idCatalogo int,

	CONSTRAINT FK_idEmpleado FOREIGN KEY (idEmpleado) REFERENCES Info.Empleado(idEmpleado),
	CONSTRAINT FK_idSucursal FOREIGN KEY (idSucursal) REFERENCES Info.Sucursal(idSucursal),
	CONSTRAINT FK_idImportado FOREIGN KEY (idImportado) REFERENCES Prod.Importado(idImportado),
	CONSTRAINT FK_idElectronico FOREIGN KEY (idElectronico) REFERENCES Prod.Electronico(idElectronico),
	CONSTRAINT FK_idCatalogo FOREIGN KEY (idCatalogo) REFERENCES Prod.Catalogo(idCatalogo)
);
GO
