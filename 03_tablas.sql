/* =========================================================
   TABLAS
   ========================================================= */

-- Clientes del taller (una persona puede tener varios vehículos)
CREATE TABLE cliente(
    id_cliente NUMBER PRIMARY KEY,
    nombres    VARCHAR2(100),
    apellidos  VARCHAR2(100),
    telefono   VARCHAR2(20),
    direccion  VARCHAR2(200)
);

-- Vehículos registrados, cada uno pertenece a un cliente
CREATE TABLE vehiculo(
    id_vehiculo NUMBER PRIMARY KEY,
    placa       VARCHAR2(20) UNIQUE,
    marca       VARCHAR2(50),
    modelo      VARCHAR2(50),
    id_cliente  NUMBER,
    CONSTRAINT fk_vehiculo_cliente
        FOREIGN KEY(id_cliente) REFERENCES cliente(id_cliente)
);

-- Mecánicos del taller con su área de especialización
CREATE TABLE mecanico(
    id_mecanico  NUMBER PRIMARY KEY,
    nombres      VARCHAR2(100),
    especialidad VARCHAR2(100)
);

-- Catálogo de servicios con su precio de lista
CREATE TABLE servicio(
    id_servicio NUMBER PRIMARY KEY,
    nombre      VARCHAR2(100),
    precio      NUMBER(10,2)
);

-- Inventario de repuestos con control de stock mínimo
CREATE TABLE repuesto(
    id_repuesto  NUMBER PRIMARY KEY,
    nombre       VARCHAR2(100),
    precio       NUMBER(10,2),
    stock        NUMBER,
    stock_minimo NUMBER
);

/* =========================================================
   orden_servicio: registro principal del trabajo en el taller.
   - fecha_ingreso : cuándo entró el vehículo.
   - fecha_cierre  : cuándo se terminó y se cobró el trabajo
                     (NULL mientras la orden está ABIERTA).
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

-- Repuestos utilizados en una orden con la cantidad y el subtotal histórico
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

COMMIT;
