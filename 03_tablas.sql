/* =========================================================
   TABLAS  —  15 tablas en total
   ========================================================= */

-- Cargos laborales de los mecanicos (Junior, Senior, Especialista, Jefe)
CREATE TABLE cargo(
    id_cargo     NUMBER PRIMARY KEY,
    nombre_cargo VARCHAR2(50),
    descripcion  VARCHAR2(200)
);

-- Clientes del taller (una persona puede tener varios vehiculos)
CREATE TABLE cliente(
    id_cliente NUMBER PRIMARY KEY,
    nombres    VARCHAR2(100),
    apellidos  VARCHAR2(100),
    telefono   VARCHAR2(20),
    direccion  VARCHAR2(200)
);

-- Mecanicos del taller: especialidad + cargo jerarquico
CREATE TABLE mecanico(
    id_mecanico  NUMBER PRIMARY KEY,
    nombres      VARCHAR2(100),
    especialidad VARCHAR2(100),
    id_cargo     NUMBER,
    CONSTRAINT fk_mecanico_cargo
        FOREIGN KEY(id_cargo) REFERENCES cargo(id_cargo)
);

-- Catalogo de servicios con su precio de lista
CREATE TABLE servicio(
    id_servicio NUMBER PRIMARY KEY,
    nombre      VARCHAR2(100),
    precio      NUMBER(10,2)
);

-- Inventario de repuestos con control de stock minimo
CREATE TABLE repuesto(
    id_repuesto  NUMBER PRIMARY KEY,
    nombre       VARCHAR2(100),
    precio       NUMBER(10,2),
    stock        NUMBER,
    stock_minimo NUMBER
);

-- Vehiculos registrados, cada uno pertenece a un cliente
CREATE TABLE vehiculo(
    id_vehiculo NUMBER PRIMARY KEY,
    placa       VARCHAR2(20) UNIQUE,
    marca       VARCHAR2(50),
    modelo      VARCHAR2(50),
    id_cliente  NUMBER,
    CONSTRAINT fk_vehiculo_cliente
        FOREIGN KEY(id_cliente) REFERENCES cliente(id_cliente)
);

-- Proveedores externos que suministran los repuestos
CREATE TABLE proveedor(
    id_proveedor NUMBER PRIMARY KEY,
    nombre       VARCHAR2(100),
    telefono     VARCHAR2(20),
    ruc          VARCHAR2(20)
);

-- Ordenes de compra emitidas a proveedores para reponer inventario
CREATE TABLE compra(
    id_compra    NUMBER PRIMARY KEY,
    id_proveedor NUMBER,
    fecha_compra DATE,
    total        NUMBER(10,2),
    CONSTRAINT fk_compra_proveedor
        FOREIGN KEY(id_proveedor) REFERENCES proveedor(id_proveedor)
);

-- Lineas de cada orden de compra: que repuesto, cuantos y a que precio
CREATE TABLE detalle_compra(
    id_detalle_compra NUMBER PRIMARY KEY,
    id_compra         NUMBER,
    id_repuesto       NUMBER,
    cantidad          NUMBER,
    precio_unitario   NUMBER(10,2),
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
   - estado        : 'ABIERTA' o 'CERRADA'.
   ========================================================= */
CREATE TABLE orden_servicio(
    id_orden      NUMBER PRIMARY KEY,
    id_vehiculo   NUMBER,
    id_mecanico   NUMBER,
    fecha_ingreso DATE,
    fecha_cierre  DATE,
    estado        VARCHAR2(20),

    CONSTRAINT fk_orden_vehiculo
        FOREIGN KEY(id_vehiculo) REFERENCES vehiculo(id_vehiculo),

    CONSTRAINT fk_orden_mecanico
        FOREIGN KEY(id_mecanico) REFERENCES mecanico(id_mecanico)
);

-- Servicios de mano de obra aplicados a una orden
CREATE TABLE detalle_servicio(
    id_detalle_servicio NUMBER PRIMARY KEY,
    id_orden            NUMBER,
    id_servicio         NUMBER,
    subtotal            NUMBER(10,2),

    CONSTRAINT fk_ds_orden
        FOREIGN KEY(id_orden) REFERENCES orden_servicio(id_orden),

    CONSTRAINT fk_ds_servicio
        FOREIGN KEY(id_servicio) REFERENCES servicio(id_servicio)
);

-- Repuestos utilizados en una orden con la cantidad y el subtotal historico
CREATE TABLE detalle_repuesto(
    id_detalle_repuesto NUMBER PRIMARY KEY,
    id_orden            NUMBER,
    id_repuesto         NUMBER,
    cantidad            NUMBER,
    subtotal            NUMBER(10,2),

    CONSTRAINT fk_dr_orden
        FOREIGN KEY(id_orden) REFERENCES orden_servicio(id_orden),

    CONSTRAINT fk_dr_repuesto
        FOREIGN KEY(id_repuesto) REFERENCES repuesto(id_repuesto)
);

-- Factura fiscal emitida al cerrar una orden (incluye IGV 18%)
CREATE TABLE factura(
    id_factura     NUMBER PRIMARY KEY,
    id_orden       NUMBER,
    numero_factura VARCHAR2(20),
    fecha_emision  DATE,
    subtotal       NUMBER(10,2),
    igv            NUMBER(10,2),
    total          NUMBER(10,2),
    CONSTRAINT fk_factura_orden
        FOREIGN KEY(id_orden) REFERENCES orden_servicio(id_orden)
);

-- Pagos registrados contra una factura (permite abonos y multiples metodos)
CREATE TABLE pago(
    id_pago     NUMBER PRIMARY KEY,
    id_factura  NUMBER,
    fecha_pago  DATE,
    monto       NUMBER(10,2),
    metodo_pago VARCHAR2(20),
    CONSTRAINT fk_pago_factura
        FOREIGN KEY(id_factura) REFERENCES factura(id_factura)
);

-- Citas programadas por el cliente antes de traer su vehiculo
CREATE TABLE cita(
    id_cita     NUMBER PRIMARY KEY,
    id_cliente  NUMBER,
    id_vehiculo NUMBER,
    fecha_cita  DATE,
    motivo      VARCHAR2(200),
    estado      VARCHAR2(20),
    CONSTRAINT fk_cita_cliente
        FOREIGN KEY(id_cliente) REFERENCES cliente(id_cliente),
    CONSTRAINT fk_cita_vehiculo
        FOREIGN KEY(id_vehiculo) REFERENCES vehiculo(id_vehiculo)
);

COMMIT;
