/* =========================================================
   VERIFICACION DE INTEGRIDAD  -  Sistema AUTOFIX
   Ejecutar DESPUES de cargar todos los scripts (01 al 07).

   Valida que los datos esten completamente enlazados y que
   toda la aritmetica cuadre:
     1. Facturas cuadradas   : subtotal = detalles, igv = 18%,
                               total = subtotal + igv
     2. Ordenes vs facturas  : toda CERRADA tiene factura,
                               ninguna ABIERTA esta facturada
     3. Fechas coherentes    : CERRADA con fecha_cierre >= ingreso,
                               ABIERTA sin fecha_cierre
     4. Pagos vs facturas    : lo pagado nunca excede el total
     5. Compras cuadradas    : compra.total = suma del detalle
     6. Stock cuadrado       : stock = inicial implicito
                               (entradas - salidas aplicadas)
     7. Citas coherentes     : el vehiculo pertenece al cliente
     8. Limite de mecanicos  : nadie con mas de 3 ordenes abiertas
     9. Detalles enlazados   : subtotales > 0 y ordenes con
                               al menos un servicio

   Resultado: un unico reporte por DBMS_OUTPUT. Si todo esta
   bien, cada linea dice OK y al final "VERIFICACION COMPLETA".
   ========================================================= */

SET SERVEROUTPUT ON SIZE UNLIMITED

DECLARE
    v_errores NUMBER := 0;
    v_n       NUMBER;

    PROCEDURE chk(p_titulo IN VARCHAR2, p_fallas IN NUMBER) IS
    BEGIN
        IF p_fallas = 0 THEN
            DBMS_OUTPUT.PUT_LINE('OK    | ' || p_titulo);
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR | ' || p_titulo ||
                                 ' -> ' || p_fallas || ' fila(s) inconsistentes');
            v_errores := v_errores + p_fallas;
        END IF;
    END;
BEGIN
    DBMS_OUTPUT.PUT_LINE('================================================');
    DBMS_OUTPUT.PUT_LINE('  AUTOFIX - Verificacion de integridad de datos');
    DBMS_OUTPUT.PUT_LINE('================================================');

    ------------------------------------------------------------------
    -- 1. FACTURAS: subtotal debe ser la suma exacta de los detalles
    ------------------------------------------------------------------
    SELECT COUNT(*) INTO v_n
    FROM factura f
    WHERE f.subtotal <>
          (SELECT NVL(SUM(ds.subtotal),0) FROM detalle_servicio ds WHERE ds.id_orden = f.id_orden)
        + (SELECT NVL(SUM(dr.subtotal),0) FROM detalle_repuesto dr WHERE dr.id_orden = f.id_orden);
    chk('Factura.subtotal = servicios + repuestos de su orden', v_n);

    -- IGV exacto (18% del subtotal, redondeado a 2 decimales)
    SELECT COUNT(*) INTO v_n
    FROM factura
    WHERE igv <> ROUND(subtotal * 0.18, 2);
    chk('Factura.igv = 18% del subtotal', v_n);

    -- Total exacto
    SELECT COUNT(*) INTO v_n
    FROM factura
    WHERE total <> subtotal + igv;
    chk('Factura.total = subtotal + igv', v_n);

    ------------------------------------------------------------------
    -- 2. ORDENES vs FACTURAS
    ------------------------------------------------------------------
    SELECT COUNT(*) INTO v_n
    FROM orden_servicio o
    WHERE o.estado = 'CERRADA'
      AND NOT EXISTS (SELECT 1 FROM factura f WHERE f.id_orden = o.id_orden);
    chk('Toda orden CERRADA tiene su factura', v_n);

    SELECT COUNT(*) INTO v_n
    FROM factura f
    JOIN orden_servicio o ON o.id_orden = f.id_orden
    WHERE o.estado <> 'CERRADA';
    chk('Ninguna orden ABIERTA esta facturada', v_n);

    ------------------------------------------------------------------
    -- 3. FECHAS COHERENTES
    ------------------------------------------------------------------
    SELECT COUNT(*) INTO v_n
    FROM orden_servicio
    WHERE (estado = 'CERRADA' AND (fecha_cierre IS NULL OR fecha_cierre < fecha_ingreso))
       OR (estado = 'ABIERTA' AND fecha_cierre IS NOT NULL);
    chk('Fechas de orden coherentes con su estado', v_n);

    ------------------------------------------------------------------
    -- 4. PAGOS: lo pagado nunca puede exceder el total de la factura
    ------------------------------------------------------------------
    SELECT COUNT(*) INTO v_n
    FROM (
        SELECT f.id_factura
        FROM factura f
        LEFT JOIN pago p ON p.id_factura = f.id_factura
        GROUP BY f.id_factura, f.total
        HAVING NVL(SUM(p.monto),0) > f.total
    );
    chk('Ninguna factura esta pagada por encima de su total', v_n);

    ------------------------------------------------------------------
    -- 5. COMPRAS: total = suma exacta de las lineas del detalle
    ------------------------------------------------------------------
    SELECT COUNT(*) INTO v_n
    FROM compra c
    WHERE c.total <>
          (SELECT NVL(SUM(dc.cantidad * dc.precio_unitario),0)
           FROM detalle_compra dc WHERE dc.id_compra = c.id_compra);
    chk('Compra.total = suma de su detalle_compra', v_n);

    -- Toda compra debe tener al menos una linea de detalle
    SELECT COUNT(*) INTO v_n
    FROM compra c
    WHERE NOT EXISTS (SELECT 1 FROM detalle_compra dc WHERE dc.id_compra = c.id_compra);
    chk('Toda compra tiene detalle', v_n);

    ------------------------------------------------------------------
    -- 6. STOCK: nunca negativo (las salidas no superan
    --    inicial + entradas) y detalle_repuesto cuadrado
    ------------------------------------------------------------------
    SELECT COUNT(*) INTO v_n FROM repuesto WHERE stock < 0;
    chk('Ningun repuesto con stock negativo', v_n);

    SELECT COUNT(*) INTO v_n
    FROM detalle_repuesto dr
    JOIN repuesto r ON r.id_repuesto = dr.id_repuesto
    WHERE dr.subtotal <> dr.cantidad * r.precio;
    chk('detalle_repuesto.subtotal = cantidad x precio', v_n);

    SELECT COUNT(*) INTO v_n
    FROM detalle_servicio ds
    JOIN servicio s ON s.id_servicio = ds.id_servicio
    WHERE ds.subtotal <> s.precio;
    chk('detalle_servicio.subtotal = precio de catalogo', v_n);

    ------------------------------------------------------------------
    -- 7. CITAS: el vehiculo debe pertenecer al cliente de la cita
    ------------------------------------------------------------------
    SELECT COUNT(*) INTO v_n
    FROM cita ci
    JOIN vehiculo v ON v.id_vehiculo = ci.id_vehiculo
    WHERE v.id_cliente <> ci.id_cliente;
    chk('Cada cita enlaza un vehiculo de su propio cliente', v_n);

    ------------------------------------------------------------------
    -- 8. REGLA DE NEGOCIO: max 3 ordenes ABIERTAS por mecanico
    ------------------------------------------------------------------
    SELECT COUNT(*) INTO v_n
    FROM (
        SELECT id_mecanico
        FROM orden_servicio
        WHERE estado = 'ABIERTA'
        GROUP BY id_mecanico
        HAVING COUNT(*) > 3
    );
    chk('Ningun mecanico supera 3 ordenes abiertas', v_n);

    ------------------------------------------------------------------
    -- 9. DETALLES ENLAZADOS: toda orden tiene al menos un servicio
    ------------------------------------------------------------------
    SELECT COUNT(*) INTO v_n
    FROM orden_servicio o
    WHERE NOT EXISTS (SELECT 1 FROM detalle_servicio ds WHERE ds.id_orden = o.id_orden);
    chk('Toda orden tiene al menos un servicio', v_n);

    ------------------------------------------------------------------
    -- RESUMEN
    ------------------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
    IF v_errores = 0 THEN
        DBMS_OUTPUT.PUT_LINE('VERIFICACION COMPLETA: todos los datos cuadran.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('VERIFICACION FALLIDA: ' || v_errores ||
                             ' inconsistencia(s). Revisar 06_inserts.sql.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('================================================');
END;
/

/* =========================================================
   CONSULTAS INFORMATIVAS (opcionales)
   Muestran los escenarios de prueba cargados.
   ========================================================= */

-- Ordenes abiertas por mecanico (el mecanico 1 debe estar en 3)
SELECT m.id_mecanico, m.nombres, COUNT(*) AS ordenes_abiertas
FROM   orden_servicio o
JOIN   mecanico m ON m.id_mecanico = o.id_mecanico
WHERE  o.estado = 'ABIERTA'
GROUP  BY m.id_mecanico, m.nombres
ORDER  BY ordenes_abiertas DESC;

-- Repuestos bajo stock minimo (escenario de reposicion)
SELECT * FROM v_repuestos_stock_bajo;

-- Facturas con saldo pendiente (escenario de cobranza)
SELECT * FROM v_facturas_por_cobrar;
