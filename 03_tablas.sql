/* =========================================================
   TABLAS  —  15 tablas en total
   ========================================================= */

-- Cargos laborales de los mecanicos (Junior, Senior, Especialista, Jefe)
CREATE TABLE cargo(
    id_cargo     NUMBER       PRIMARY KEY,
    nombre_cargo VARCHAR2(50) NOT NULL,
    descripcion  VARCHAR2(200)
);

-- Clientes del taller (una persona puede tener varios vehiculos)
CREATE TABLE cliente(
    id_cliente NUMBER        PRIMARY KEY,
    nombres    VARCHAR2(100) NOT NULL,
    apellidos  VARCHAR2(100) NOT NULL,
    telefono   VARCHAR2(20),
    direccion  VARCHAR2(200)
);

-- Mecanicos del taller: especialidad + cargo jerarquico
CREATE TABLE mecanico(
    id_mecanico  NUMBER        PRIMARY KEY,
    nombres      VARCHAR2(100) NOT NULL,
    especialidad VARCHAR2(100),
    id_cargo     NUMBER        NOT NULL,
    CONSTRAINT fk_mecanico_cargo
        FOREIGN KEY(id_cargo) REFERENCES cargo(id_cargo)
);

-- Catalogo de servicios con su precio de lista
CREATE TABLE servicio(
    id_servicio NUMBER        PRIMARY KEY,
    nombre      VARCHAR2(100) NOT NULL,
    precio      NUMBER(10,2)  NOT NULL,
    CONSTRAINT chk_servicio_precio CHECK (precio > 0)
);

-- Inventario de repuestos con control de stock minimo
CREATE TABLE repuesto(
    id_repuesto  NUMBER        PRIMARY KEY,
    nombre       VARCHAR2(100) NOT NULL,
    precio       NUMBER(10,2)  NOT NULL,
    stock        NUMBER        NOT NULL,
    stock_minimo NUMBER        NOT NULL,
    CONSTRAINT chk_repuesto_precio   CHECK (precio       >  0),
    CONSTRAINT chk_repuesto_stock    CHECK (stock        >= 0),
    CONSTRAINT chk_repuesto_stockmin CHECK (stock_minimo >= 0)
);

-- Vehiculos registrados, cada uno pertenece a un cliente
CREATE TABLE vehiculo(
    id_vehiculo NUMBER        PRIMARY KEY,
    placa       VARCHAR2(20)  NOT NULL UNIQUE,   -- NOT NULL: placa nunca puede ser nula (UNIQUE solo no basta en Oracle)
    marca       VARCHAR2(50)  NOT NULL,
    modelo      VARCHAR2(50)  NOT NULL,
    id_cliente  NUMBER        NOT NULL,
    CONSTRAINT fk_vehiculo_cliente
        FOREIGN KEY(id_cliente) REFERENCES cliente(id_cliente)
);

-- Proveedores externos que suministran los repuestos
CREATE TABLE proveedor(
    id_proveedor NUMBER        PRIMARY KEY,
    nombre       VARCHAR2(100) NOT NULL,
    telefono     VARCHAR2(20),
    ruc          VARCHAR2(20)
);

-- Ordenes de compra emitidas a proveedores para reponer inventario
CREATE TABLE compra(
    id_compra    NUMBER       PRIMARY KEY,
    id_proveedor NUMBER       NOT NULL,
    fecha_compra DATE         NOT NULL,
    total        NUMBER(10,2) NOT NULL,
    CONSTRAINT chk_compra_total CHECK (total > 0),
    CONSTRAINT fk_compra_proveedor
        FOREIGN KEY(id_proveedor) REFERENCES proveedor(id_proveedor)
);

-- Lineas de cada orden de compra: que repuesto, cuantos y a que precio
CREATE TABLE detalle_compra(
    id_detalle_compra NUMBER       PRIMARY KEY,
    id_compra         NUMBER       NOT NULL,
    id_repuesto       NUMBER       NOT NULL,
    cantidad          NUMBER       NOT NULL,
    precio_unitario   NUMBER(10,2) NOT NULL,
    CONSTRAINT chk_dc_cantidad CHECK (cantidad        > 0),
    CONSTRAINT chk_dc_precio   CHECK (precio_unitario > 0),
    CONSTRAINT fk_dc_compra
        FOREIGN KEY(id_compra) REFERENCES compra(id_compra),
    CONSTRAINT fk_dc_repuesto
        FOREIGN KEY(id_repuesto) REFERENCES repuesto(id_repuesto)
);

/* =========================================================
   orden_servicio: registro principal del trabajo en el taller.
   - fecha_ingreso : cuando entro el vehiculo.
   - fecha_cierre  : cuando se termino y se cobro el trabajo
                     (NULL mientras la orden esta ABIERTA).
   - estado        : solo 'ABIERTA' o 'CERRADA' (validado por CHECK).
   ========================================================= */
CREATE TABLE orden_servicio(
    id_orden      NUMBER       PRIMARY KEY,
    id_vehiculo   NUMBER       NOT NULL,
    id_mecanico   NUMBER       NOT NULL,
    fecha_ingreso DATE         NOT NULL,
    fecha_cierre  DATE,
    estado        VARCHAR2(20) NOT NULL,
    CONSTRAINT chk_orden_estado CHECK (estado IN ('ABIERTA','CERRADA')),
    CONSTRAINT fk_orden_vehiculo
        FOREIGN KEY(id_vehiculo) REFERENCES vehiculo(id_vehiculo),
    CONSTRAINT fk_orden_mecanico
        FOREIGN KEY(id_mecanico) REFERENCES mecanico(id_mecanico)
);

-- Servicios de mano de obra aplicados a una orden
CREATE TABLE detalle_servicio(
    id_detalle_servicio NUMBER       PRIMARY KEY,
    id_orden            NUMBER       NOT NULL,
    id_servicio         NUMBER       NOT NULL,
    subtotal            NUMBER(10,2) NOT NULL,
    CONSTRAINT chk_ds_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_ds_orden
        FOREIGN KEY(id_orden) REFERENCES orden_servicio(id_orden),
    CONSTRAINT fk_ds_servicio
        FOREIGN KEY(id_servicio) REFERENCES servicio(id_servicio)
);

-- Repuestos utilizados en una orden con la cantidad y el subtotal historico
CREATE TABLE detalle_repuesto(
    id_detalle_repuesto NUMBER       PRIMARY KEY,
    id_orden            NUMBER       NOT NULL,
    id_repuesto         NUMBER       NOT NULL,
    cantidad            NUMBER       NOT NULL,
    subtotal            NUMBER(10,2) NOT NULL,
    CONSTRAINT chk_dr_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_dr_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_dr_orden
        FOREIGN KEY(id_orden) REFERENCES orden_servicio(id_orden),
    CONSTRAINT fk_dr_repuesto
        FOREIGN KEY(id_repuesto) REFERENCES repuesto(id_repuesto)
);

/* =========================================================
   factura: documento fiscal emitido al CERRAR una orden.
   - uq_factura_orden  : una orden genera exactamente UNA factura.
   - uq_factura_numero : el numero de factura es unico en el sistema.
   - igv               : impuesto del 18% sobre el subtotal.
   ========================================================= */
CREATE TABLE factura(
    id_factura     NUMBER       PRIMARY KEY,
    id_orden       NUMBER       NOT NULL,
    numero_factura VARCHAR2(20) NOT NULL,
    fecha_emision  DATE         NOT NULL,
    subtotal       NUMBER(10,2) NOT NULL,
    igv            NUMBER(10,2) NOT NULL,
    total          NUMBER(10,2) NOT NULL,
    CONSTRAINT chk_factura_total  CHECK (total    >  0),
    CONSTRAINT chk_factura_igv    CHECK (igv      >= 0),
    CONSTRAINT uq_factura_orden   UNIQUE (id_orden),        -- una orden -> una sola factura
    CONSTRAINT uq_factura_numero  UNIQUE (numero_factura),  -- numero fiscal unico
    CONSTRAINT fk_factura_orden
        FOREIGN KEY(id_orden) REFERENCES orden_servicio(id_orden)
);

-- Pagos registrados contra una factura (permite cuotas y multiples metodos)
CREATE TABLE pago(
    id_pago     NUMBER       PRIMARY KEY,
    id_factura  NUMBER       NOT NULL,
    fecha_pago  DATE         NOT NULL,
    monto       NUMBER(10,2) NOT NULL,
    metodo_pago VARCHAR2(20) NOT NULL,
    CONSTRAINT chk_pago_monto  CHECK (monto > 0),
    CONSTRAINT chk_pago_metodo CHECK (metodo_pago IN ('EFECTIVO','TARJETA','TRANSFERENCIA')),
    CONSTRAINT fk_pago_factura
        FOREIGN KEY(id_factura) REFERENCES factura(id_factura)
);

-- Citas programadas por el cliente antes de traer su vehiculo
CREATE TABLE cita(
    id_cita     NUMBER       PRIMARY KEY,
    id_cliente  NUMBER       NOT NULL,
    id_vehiculo NUMBER       NOT NULL,
    fecha_cita  DATE         NOT NULL,
    motivo      VARCHAR2(200),
    estado      VARCHAR2(20) NOT NULL,
    CONSTRAINT chk_cita_estado CHECK (estado IN ('PENDIENTE','CONFIRMADA','CANCELADA')),
    CONSTRAINT fk_cita_cliente
        FOREIGN KEY(id_cliente) REFERENCES cliente(id_cliente),
    CONSTRAINT fk_cita_vehiculo
        FOREIGN KEY(id_vehiculo) REFERENCES vehiculo(id_vehiculo)
);

COMMIT;
