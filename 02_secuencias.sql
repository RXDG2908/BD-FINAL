/* =========================================================
   SECUENCIAS  —  15 tablas / 15 secuencias
   ========================================================= */

-- Tablas sin dependencias (se crean primero)
CREATE SEQUENCE seq_cargo            START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_cliente          START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_mecanico         START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_servicio         START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_repuesto         START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_vehiculo         START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_proveedor        START WITH 1 INCREMENT BY 1;

-- Tablas de compras
CREATE SEQUENCE seq_compra           START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_detalle_compra   START WITH 1 INCREMENT BY 1;

-- Tablas de operacion del taller
CREATE SEQUENCE seq_orden            START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_detalle_servicio START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_detalle_repuesto START WITH 1 INCREMENT BY 1;

-- Tablas de facturacion y agenda
CREATE SEQUENCE seq_factura          START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_pago             START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_cita             START WITH 1 INCREMENT BY 1;
