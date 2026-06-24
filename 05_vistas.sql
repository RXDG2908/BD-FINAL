/* =========================================================
   VISTAS
   ========================================================= */

-- Órdenes actualmente en trabajo con datos del vehículo y mecánico asignado
CREATE OR REPLACE VIEW v_ordenes_abiertas AS
SELECT
    o.id_orden,
    o.fecha_ingreso,
    v.placa,
    v.marca || ' ' || v.modelo AS vehiculo,
    m.nombres                  AS mecanico,
    o.estado
FROM orden_servicio o
JOIN vehiculo v ON o.id_vehiculo = v.id_vehiculo
JOIN mecanico m ON o.id_mecanico = m.id_mecanico
WHERE o.estado = 'ABIERTA';

-- Repuestos que han caído por debajo del nivel mínimo y necesitan reposición
CREATE OR REPLACE VIEW v_repuestos_stock_bajo AS
SELECT
    id_repuesto,
    nombre,
    stock            AS stock_actual,
    stock_minimo,
    (stock_minimo - stock) AS unidades_a_reponer
FROM repuesto
WHERE stock < stock_minimo;

-- Clientes con 2 o más órdenes de servicio (criterio de cliente frecuente)
CREATE OR REPLACE VIEW v_clientes_frecuentes AS
SELECT
    c.id_cliente,
    c.nombres,
    c.apellidos,
    c.telefono,
    COUNT(o.id_orden) AS total_ordenes
FROM cliente c
JOIN vehiculo v       ON c.id_cliente  = v.id_cliente
JOIN orden_servicio o ON v.id_vehiculo = o.id_vehiculo
GROUP BY c.id_cliente, c.nombres, c.apellidos, c.telefono
HAVING COUNT(o.id_orden) >= 2
ORDER BY total_ordenes DESC;
