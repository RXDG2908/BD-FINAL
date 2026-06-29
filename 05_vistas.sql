/* =========================================================
   VISTAS
   ========================================================= */

-- Ordenes actualmente en trabajo con datos del vehiculo y mecanico asignado
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

-- Repuestos que han caido por debajo del nivel minimo y necesitan reposicion
CREATE OR REPLACE VIEW v_repuestos_stock_bajo AS
SELECT
    id_repuesto,
    nombre,
    stock            AS stock_actual,
    stock_minimo,
    (stock_minimo - stock) AS unidades_a_reponer
FROM repuesto
WHERE stock < stock_minimo;

-- Clientes con 2 o mas ordenes de servicio (criterio de cliente frecuente)
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

-- Citas proximas pendientes o confirmadas (agenda del taller)
CREATE OR REPLACE VIEW v_citas_pendientes AS
SELECT
    ci.id_cita,
    ci.fecha_cita,
    c.nombres || ' ' || c.apellidos AS cliente,
    c.telefono,
    v.placa,
    v.marca || ' ' || v.modelo      AS vehiculo,
    ci.motivo,
    ci.estado
FROM cita ci
JOIN cliente c  ON ci.id_cliente  = c.id_cliente
JOIN vehiculo v ON ci.id_vehiculo = v.id_vehiculo
WHERE ci.estado IN ('PENDIENTE','CONFIRMADA')
  AND ci.fecha_cita >= TRUNC(SYSDATE)
ORDER BY ci.fecha_cita;

-- Facturas con saldo por cobrar (pagos recibidos menores al total)
CREATE OR REPLACE VIEW v_facturas_por_cobrar AS
SELECT
    f.id_factura,
    f.numero_factura,
    f.fecha_emision,
    f.total                          AS total_factura,
    NVL(SUM(p.monto), 0)            AS total_pagado,
    f.total - NVL(SUM(p.monto), 0)  AS saldo_pendiente
FROM factura f
LEFT JOIN pago p ON f.id_factura = p.id_factura
GROUP BY f.id_factura, f.numero_factura, f.fecha_emision, f.total
HAVING f.total - NVL(SUM(p.monto), 0) > 0
ORDER BY f.fecha_emision;
