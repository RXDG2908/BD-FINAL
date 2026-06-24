/* =========================================================
   INDICES
   Oracle no crea índices automáticos para claves foráneas,
   por lo que se definen manualmente para optimizar las
   consultas de JOIN más frecuentes del sistema.
   ========================================================= */

-- Búsqueda de clientes por apellido (sp_registrar_vehiculo, reportes)
CREATE INDEX idx_cliente_apellidos
    ON cliente(apellidos);

-- Búsqueda de vehículos por cliente (historial, clientes frecuentes)
CREATE INDEX idx_vehiculo_cliente
    ON vehiculo(id_cliente);

-- Filtrado de órdenes por estado (vistas, sp_abrir_orden, sp_cierre_del_dia)
CREATE INDEX idx_orden_estado
    ON orden_servicio(estado);

-- Búsqueda del historial de un vehículo (sp_historial_vehiculo)
CREATE INDEX idx_orden_vehiculo
    ON orden_servicio(id_vehiculo);

-- Búsqueda de órdenes asignadas a un mecánico (sp_abrir_orden, sp_reporte_mecanicos)
CREATE INDEX idx_orden_mecanico
    ON orden_servicio(id_mecanico);

-- Cálculo del total de una orden (sp_calcular_orden lo consulta frecuentemente)
CREATE INDEX idx_detalle_servicio
    ON detalle_servicio(id_orden, id_servicio);

-- Cálculo del total de repuestos por orden (sp_calcular_orden)
CREATE INDEX idx_detalle_repuesto
    ON detalle_repuesto(id_orden);

-- Búsqueda de repuestos por nombre (consultas de inventario)
CREATE INDEX idx_repuesto_nombre
    ON repuesto(nombre);
