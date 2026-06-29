/* =========================================================
   INDICES
   Oracle no crea indices automaticos para claves foraneas,
   por lo que se definen manualmente para optimizar las
   consultas de JOIN mas frecuentes del sistema.
   ========================================================= */

-- ── Tablas originales ────────────────────────────────────

-- Busqueda de clientes por apellido (sp_registrar_vehiculo, reportes)
CREATE INDEX idx_cliente_apellidos
    ON cliente(apellidos);

-- Busqueda de vehiculos por cliente (historial, clientes frecuentes)
CREATE INDEX idx_vehiculo_cliente
    ON vehiculo(id_cliente);

-- Filtrado de ordenes por estado (vistas, sp_abrir_orden, sp_cierre_del_dia)
CREATE INDEX idx_orden_estado
    ON orden_servicio(estado);

-- Busqueda del historial de un vehiculo (sp_historial_vehiculo)
CREATE INDEX idx_orden_vehiculo
    ON orden_servicio(id_vehiculo);

-- Busqueda de ordenes asignadas a un mecanico (sp_abrir_orden, sp_reporte_mecanicos)
CREATE INDEX idx_orden_mecanico
    ON orden_servicio(id_mecanico);

-- Calculo del total de una orden (sp_calcular_orden lo consulta frecuentemente)
CREATE INDEX idx_detalle_servicio
    ON detalle_servicio(id_orden, id_servicio);

-- Calculo del total de repuestos por orden (sp_calcular_orden)
CREATE INDEX idx_detalle_repuesto
    ON detalle_repuesto(id_orden);

-- Busqueda de repuestos por nombre (consultas de inventario)
CREATE INDEX idx_repuesto_nombre
    ON repuesto(nombre);

-- ── Tablas nuevas ────────────────────────────────────────

-- Mecanicos por cargo (reportes de dotacion)
CREATE INDEX idx_mecanico_cargo
    ON mecanico(id_cargo);

-- Compras por proveedor (historial de abastecimiento)
CREATE INDEX idx_compra_proveedor
    ON compra(id_proveedor);

-- Lineas de compra por orden de compra (calculo de totales)
CREATE INDEX idx_detalle_compra_compra
    ON detalle_compra(id_compra);

-- Lineas de compra por repuesto (rotacion de inventario)
CREATE INDEX idx_detalle_compra_repuesto
    ON detalle_compra(id_repuesto);

-- Facturas por orden (join factura-orden frecuente)
CREATE INDEX idx_factura_orden
    ON factura(id_orden);

-- Pagos por factura (calculo de saldo pendiente)
CREATE INDEX idx_pago_factura
    ON pago(id_factura);

-- Citas por cliente (agenda del cliente)
CREATE INDEX idx_cita_cliente
    ON cita(id_cliente);

-- Citas por fecha (agenda diaria)
CREATE INDEX idx_cita_fecha
    ON cita(fecha_cita);
