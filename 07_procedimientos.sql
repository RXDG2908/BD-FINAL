/* =========================================================
   PROCEDIMIENTOS ALMACENADOS
   Sistema de Gestión de Taller Mecánico AUTOFIX

   Convenciones:
   - p_mensaje OUT: 'OK ...' en éxito, texto de error en fallo.
   - p_total   OUT: valor calculado; -1 indica error o no encontrado.
   - p_cursor  OUT: SYS_REFCURSOR con el resultado tabulado.
   ========================================================= */

/* =========================================================
   PROCEDIMIENTO 1: REGISTRAR CLIENTE
   Inserta un nuevo cliente y retorna el ID asignado.
   No valida duplicados de nombres; el identificador único
   es el ID generado por la secuencia.
   ========================================================= */
CREATE OR REPLACE PROCEDURE sp_registrar_cliente(
    p_nombres   IN  VARCHAR2,
    p_apellidos IN  VARCHAR2,
    p_telefono  IN  VARCHAR2,
    p_direccion IN  VARCHAR2,
    p_id        OUT NUMBER,
    p_mensaje   OUT VARCHAR2
)
AS
BEGIN
    p_id := seq_cliente.NEXTVAL;

    INSERT INTO cliente
    VALUES(p_id, p_nombres, p_apellidos, p_telefono, p_direccion);

    p_mensaje := 'CLIENTE REGISTRADO';
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_mensaje := SQLERRM;
END;
/

/* =========================================================
   PROCEDIMIENTO 2: REGISTRAR VEHICULO
   Verifica que el cliente exista antes de insertar el
   vehículo. La placa tiene restricción UNIQUE, por lo que
   se captura DUP_VAL_ON_INDEX si ya está registrada.
   ========================================================= */
CREATE OR REPLACE PROCEDURE sp_registrar_vehiculo(
    p_placa    IN  VARCHAR2,
    p_marca    IN  VARCHAR2,
    p_modelo   IN  VARCHAR2,
    p_cliente  IN  NUMBER,
    p_id       OUT NUMBER,
    p_mensaje  OUT VARCHAR2
)
AS
    v_count NUMBER;
BEGIN
    -- Verificar que el cliente exista antes de registrar el vehículo
    SELECT COUNT(*) INTO v_count FROM cliente WHERE id_cliente = p_cliente;
    IF v_count = 0 THEN
        p_mensaje := 'CLIENTE NO EXISTE';
        RETURN;
    END IF;

    p_id := seq_vehiculo.NEXTVAL;

    INSERT INTO vehiculo
    VALUES(p_id, p_placa, p_marca, p_modelo, p_cliente);

    p_mensaje := 'VEHICULO REGISTRADO';
    COMMIT;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        p_mensaje := 'PLACA DUPLICADA';
    WHEN OTHERS THEN
        ROLLBACK;
        p_mensaje := SQLERRM;
END;
/

/* =========================================================
   PROCEDIMIENTO 3: ABRIR ORDEN DE SERVICIO
   Crea una orden de servicio e incluye el primer servicio.
   Límite: un mecánico no puede tener más de 3 órdenes
   ABIERTAS simultáneamente.
   ========================================================= */
CREATE OR REPLACE PROCEDURE sp_abrir_orden(
    p_vehiculo IN  NUMBER,
    p_mecanico IN  NUMBER,
    p_servicio IN  NUMBER,
    p_id_orden OUT NUMBER,
    p_mensaje  OUT VARCHAR2
)
AS
    v_precio   NUMBER;
    v_count    NUMBER;
    v_ordenes  NUMBER;  -- Cantidad de órdenes abiertas actuales del mecánico
BEGIN
    -- Validar que el vehículo existe
    SELECT COUNT(*) INTO v_count FROM vehiculo WHERE id_vehiculo = p_vehiculo;
    IF v_count = 0 THEN
        p_mensaje := 'VEHICULO NO EXISTE';
        RETURN;
    END IF;

    -- Validar que el mecánico existe
    SELECT COUNT(*) INTO v_count FROM mecanico WHERE id_mecanico = p_mecanico;
    IF v_count = 0 THEN
        p_mensaje := 'MECANICO NO EXISTE';
        RETURN;
    END IF;

    -- Validar que el servicio existe y obtener su precio actual
    SELECT COUNT(*), NVL(MAX(precio), 0)
    INTO v_count, v_precio
    FROM servicio
    WHERE id_servicio = p_servicio;
    IF v_count = 0 THEN
        p_mensaje := 'SERVICIO NO EXISTE';
        RETURN;
    END IF;

    -- Verificar que el mecánico no supere el límite de 3 órdenes abiertas
    SELECT COUNT(*)
    INTO v_ordenes
    FROM orden_servicio
    WHERE id_mecanico = p_mecanico
      AND estado = 'ABIERTA';

    IF v_ordenes >= 3 THEN
        p_mensaje := 'MECANICO NO PUEDE TENER MAS DE 3 ORDENES ABIERTAS';
        RETURN;
    END IF;

    -- Crear la orden de servicio
    p_id_orden := seq_orden.NEXTVAL;

    INSERT INTO orden_servicio(id_orden, id_vehiculo, id_mecanico, fecha_ingreso, fecha_cierre, estado)
    VALUES(p_id_orden, p_vehiculo, p_mecanico, SYSDATE, NULL, 'ABIERTA');

    -- Registrar el servicio inicial con el precio del catálogo en este momento
    INSERT INTO detalle_servicio
    VALUES(seq_detalle_servicio.NEXTVAL, p_id_orden, p_servicio, v_precio);

    p_mensaje := 'ORDEN ABIERTA';
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_mensaje := SQLERRM;
END;
/

/* =========================================================
   PROCEDIMIENTO 4: AGREGAR SERVICIO A ORDEN
   Permite añadir servicios adicionales a una orden ABIERTA.
   Complemento simétrico de sp_agregar_repuestos.
   ========================================================= */
CREATE OR REPLACE PROCEDURE sp_agregar_servicio(
    p_orden    IN  NUMBER,
    p_servicio IN  NUMBER,
    p_mensaje  OUT VARCHAR2
)
AS
    v_precio  NUMBER;
    v_count   NUMBER;
    v_estado  VARCHAR2(20);
BEGIN
    SAVEPOINT antes_de_agregar_servicio;

    -- Verificar que la orden existe y está abierta
    SELECT COUNT(*), MAX(estado)
    INTO v_count, v_estado
    FROM orden_servicio
    WHERE id_orden = p_orden;

    IF v_count = 0 THEN
        p_mensaje := 'ORDEN NO EXISTE';
        RETURN;
    END IF;

    IF v_estado <> 'ABIERTA' THEN
        p_mensaje := 'ORDEN NO ESTA ABIERTA';
        RETURN;
    END IF;

    -- Obtener el precio actual del servicio
    SELECT precio INTO v_precio
    FROM servicio
    WHERE id_servicio = p_servicio;

    INSERT INTO detalle_servicio
    VALUES(seq_detalle_servicio.NEXTVAL, p_orden, p_servicio, v_precio);

    p_mensaje := 'SERVICIO AGREGADO';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO antes_de_agregar_servicio;
        p_mensaje := 'SERVICIO NO EXISTE';
    WHEN OTHERS THEN
        ROLLBACK TO antes_de_agregar_servicio;
        p_mensaje := SQLERRM;
END;
/

/* =========================================================
   PROCEDIMIENTO 5: AGREGAR REPUESTO A ORDEN
   Verifica stock, descuenta del inventario e inserta el
   detalle con el precio histórico (precio al momento de uso).
   Usa SAVEPOINT para no afectar otras operaciones de la
   sesión si ocurre un error exclusivamente aquí.
   ========================================================= */
CREATE OR REPLACE PROCEDURE sp_agregar_repuestos(
    p_orden    IN  NUMBER,
    p_repuesto IN  NUMBER,
    p_cantidad IN  NUMBER,
    p_mensaje  OUT VARCHAR2
)
AS
    v_stock   NUMBER;
    v_precio  NUMBER;
    v_count   NUMBER;
    v_estado  VARCHAR2(20);
BEGIN
    SAVEPOINT antes_de_agregar_repuesto;

    -- Verificar que la orden existe y está abierta
    SELECT COUNT(*), MAX(estado)
    INTO v_count, v_estado
    FROM orden_servicio
    WHERE id_orden = p_orden;

    IF v_count = 0 THEN
        p_mensaje := 'ORDEN NO EXISTE';
        RETURN;
    END IF;

    IF v_estado <> 'ABIERTA' THEN
        p_mensaje := 'ORDEN NO ESTA ABIERTA';
        RETURN;
    END IF;

    -- Bloquear la fila para evitar que otra sesión modifique el stock en paralelo
    SELECT stock, precio
    INTO v_stock, v_precio
    FROM repuesto
    WHERE id_repuesto = p_repuesto
    FOR UPDATE;

    IF v_stock < p_cantidad THEN
        p_mensaje := 'STOCK INSUFICIENTE';
        RETURN;
    END IF;

    -- Registrar el uso del repuesto con el precio histórico actual
    INSERT INTO detalle_repuesto
    VALUES(seq_detalle_repuesto.NEXTVAL, p_orden, p_repuesto, p_cantidad, v_precio * p_cantidad);

    -- Descontar del inventario
    UPDATE repuesto
    SET stock = stock - p_cantidad
    WHERE id_repuesto = p_repuesto;

    p_mensaje := 'REPUESTO AGREGADO';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO antes_de_agregar_repuesto;
        p_mensaje := 'REPUESTO NO EXISTE';
    WHEN OTHERS THEN
        ROLLBACK TO antes_de_agregar_repuesto;
        p_mensaje := SQLERRM;
END;
/

/* =========================================================
   PROCEDIMIENTO 6: CALCULAR TOTAL DE ORDEN
   Suma los subtotales de servicios y repuestos de la orden.
   Retorna -1 si la orden no existe, 0 si no tiene detalles.
   ========================================================= */
CREATE OR REPLACE PROCEDURE sp_calcular_orden(
    p_orden IN  NUMBER,
    p_total OUT NUMBER
)
AS
    v_servicios NUMBER;
    v_repuestos NUMBER;
    v_count     NUMBER;
BEGIN
    -- Verificar que la orden exista
    SELECT COUNT(*) INTO v_count FROM orden_servicio WHERE id_orden = p_orden;
    IF v_count = 0 THEN
        p_total := -1;  -- Código de error: orden no encontrada
        RETURN;
    END IF;

    SELECT NVL(SUM(subtotal), 0)
    INTO v_servicios
    FROM detalle_servicio
    WHERE id_orden = p_orden;

    SELECT NVL(SUM(subtotal), 0)
    INTO v_repuestos
    FROM detalle_repuesto
    WHERE id_orden = p_orden;

    p_total := v_servicios + v_repuestos;

END;
/

/* =========================================================
   PROCEDIMIENTO 7: CERRAR ORDEN DE SERVICIO
   Valida que la orden exista y esté ABIERTA, calcula el
   total, registra la fecha de cierre y cambia el estado.
   Sin esta validación, se podría "cerrar" una orden ya
   cerrada y el mensaje de éxito sería engañoso.
   ========================================================= */
CREATE OR REPLACE PROCEDURE sp_cerrar_orden(
    p_orden   IN  NUMBER,
    p_total   OUT NUMBER,
    p_mensaje OUT VARCHAR2
)
AS
    v_estado VARCHAR2(20);
    v_count  NUMBER;
BEGIN
    -- Verificar que la orden existe y obtener su estado actual
    SELECT COUNT(*), MAX(estado)
    INTO v_count, v_estado
    FROM orden_servicio
    WHERE id_orden = p_orden;

    IF v_count = 0 THEN
        p_total   := 0;
        p_mensaje := 'ORDEN NO EXISTE';
        RETURN;
    END IF;

    IF v_estado <> 'ABIERTA' THEN
        p_total   := 0;
        p_mensaje := 'LA ORDEN YA ESTA CERRADA';
        RETURN;
    END IF;

    -- Calcular el importe total antes de cerrar
    sp_calcular_orden(p_orden, p_total);

    -- Cerrar la orden y registrar la fecha/hora exacta de cierre
    UPDATE orden_servicio
    SET estado       = 'CERRADA',
        fecha_cierre = SYSDATE
    WHERE id_orden = p_orden;

    p_mensaje := 'ORDEN CERRADA';
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_mensaje := SQLERRM;
END;
/

/* =========================================================
   PROCEDIMIENTO 8: CIERRE DEL DIA
   Suma los totales de las órdenes cerradas EN la fecha
   indicada, filtrando por fecha_cierre (no por fecha_ingreso).
   Una orden puede ingresar un día y cerrarse otro distinto.
   ========================================================= */
CREATE OR REPLACE PROCEDURE sp_cierre_del_dia(
    p_fecha IN  DATE,
    p_total OUT NUMBER
)
AS
    CURSOR c_ordenes IS
        SELECT id_orden
        FROM orden_servicio
        WHERE estado = 'CERRADA'
          AND TRUNC(fecha_cierre) = TRUNC(p_fecha);  -- Día en que se cerró, no en que ingresó

    v_subtotal NUMBER;
BEGIN
    p_total := 0;

    FOR r IN c_ordenes LOOP
        sp_calcular_orden(r.id_orden, v_subtotal);
        p_total := p_total + v_subtotal;
    END LOOP;

END;
/

/* =========================================================
   PROCEDIMIENTO 9: VALIDAR STOCK DE REPUESTO
   Consulta el stock actual y determina si hay cantidad
   suficiente. Devuelve p_stock = 0 si el repuesto no existe.
   ========================================================= */
CREATE OR REPLACE PROCEDURE sp_validar_stock(
    p_repuesto IN  NUMBER,
    p_cantidad IN  NUMBER,
    p_stock    OUT NUMBER,
    p_estado   OUT VARCHAR2
)
AS
BEGIN
    SELECT stock
    INTO p_stock
    FROM repuesto
    WHERE id_repuesto = p_repuesto;

    IF p_stock >= p_cantidad THEN
        p_estado := 'DISPONIBLE';
    ELSE
        p_estado := 'NO DISPONIBLE';
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_stock  := 0;
        p_estado := 'REPUESTO NO EXISTE';
END;
/

/* =========================================================
   PROCEDIMIENTO 10: HISTORIAL DE VEHICULO
   Devuelve todas las órdenes de un vehículo con fechas,
   mecánico asignado y total cobrado por cada orden.
   p_cursor : filas con el historial detallado.
   p_total  : número de órdenes encontradas; -1 si el vehículo no existe.
   ========================================================= */
CREATE OR REPLACE PROCEDURE sp_historial_vehiculo(
    p_vehiculo IN  NUMBER,
    p_cursor   OUT SYS_REFCURSOR,
    p_total    OUT NUMBER
)
AS
    v_count NUMBER;
BEGIN
    -- Verificar que el vehículo existe
    SELECT COUNT(*) INTO v_count FROM vehiculo WHERE id_vehiculo = p_vehiculo;
    IF v_count = 0 THEN
        p_total  := -1;
        p_cursor := NULL;
        RETURN;
    END IF;

    -- Contar las órdenes del vehículo
    SELECT COUNT(*) INTO p_total
    FROM orden_servicio
    WHERE id_vehiculo = p_vehiculo;

    -- Retornar el historial con totales pre-agregados por orden
    OPEN p_cursor FOR
        SELECT
            o.id_orden,
            o.fecha_ingreso,
            o.fecha_cierre,
            o.estado,
            m.nombres                                       AS mecanico,
            NVL(ds_sum.sub_s, 0) + NVL(dr_sum.sub_r, 0)  AS total_orden
        FROM orden_servicio o
        JOIN mecanico m ON o.id_mecanico = m.id_mecanico
        LEFT JOIN (
            SELECT id_orden, SUM(subtotal) AS sub_s
            FROM detalle_servicio
            GROUP BY id_orden
        ) ds_sum ON o.id_orden = ds_sum.id_orden
        LEFT JOIN (
            SELECT id_orden, SUM(subtotal) AS sub_r
            FROM detalle_repuesto
            GROUP BY id_orden
        ) dr_sum ON o.id_orden = dr_sum.id_orden
        WHERE o.id_vehiculo = p_vehiculo
        ORDER BY o.fecha_ingreso DESC;

EXCEPTION
    WHEN OTHERS THEN
        p_total  := -1;
        p_cursor := NULL;
END;
/

/* =========================================================
   PROCEDIMIENTO 11: LISTAR REPUESTOS PARA REPOSICION
   Devuelve los repuestos con stock por debajo del mínimo,
   ordenados por urgencia (mayor déficit primero).
   p_cursor : filas con los repuestos a reponer y cuánto falta.
   p_total  : cantidad de repuestos que necesitan reposición.
   ========================================================= */
CREATE OR REPLACE PROCEDURE sp_listar_reposicion(
    p_cursor OUT SYS_REFCURSOR,
    p_total  OUT NUMBER
)
AS
BEGIN
    -- Contar cuántos ítems necesitan reposición
    SELECT COUNT(*) INTO p_total
    FROM repuesto
    WHERE stock < stock_minimo;

    -- Retornar el detalle ordenado de mayor a menor urgencia
    OPEN p_cursor FOR
        SELECT
            id_repuesto,
            nombre,
            stock            AS stock_actual,
            stock_minimo,
            (stock_minimo - stock) AS unidades_a_reponer
        FROM repuesto
        WHERE stock < stock_minimo
        ORDER BY (stock_minimo - stock) DESC;

EXCEPTION
    WHEN OTHERS THEN
        p_total  := -1;
        p_cursor := NULL;
END;
/

/* =========================================================
   PROCEDIMIENTO 12: REPORTE SERVICIOS MAS SOLICITADOS (TOP N)
   Devuelve los servicios ordenados de mayor a menor por
   cantidad de veces solicitados e ingresos generados.
   p_limite : cuántos servicios incluir en el top (defecto: 10).
   p_cursor : filas con el ranking.
   p_total  : número de servicios distintos prestados.
   ========================================================= */
CREATE OR REPLACE PROCEDURE sp_reporte_servicios_top(
    p_limite IN  NUMBER DEFAULT 10,
    p_cursor OUT SYS_REFCURSOR,
    p_total  OUT NUMBER
)
AS
BEGIN
    -- Contar cuántos servicios distintos se han prestado
    SELECT COUNT(DISTINCT id_servicio) INTO p_total
    FROM detalle_servicio;

    -- Retornar el ranking; ROWNUM se aplica después del ORDER BY (subquery)
    OPEN p_cursor FOR
        SELECT *
        FROM (
            SELECT
                s.id_servicio,
                s.nombre,
                s.precio            AS precio_actual,
                COUNT(ds.id_orden)  AS veces_solicitado,
                NVL(SUM(ds.subtotal), 0) AS total_generado
            FROM servicio s
            LEFT JOIN detalle_servicio ds ON s.id_servicio = ds.id_servicio
            GROUP BY s.id_servicio, s.nombre, s.precio
            ORDER BY veces_solicitado DESC, total_generado DESC
        )
        WHERE ROWNUM <= p_limite;

EXCEPTION
    WHEN OTHERS THEN
        p_total  := -1;
        p_cursor := NULL;
END;
/

/* =========================================================
   PROCEDIMIENTO 13: REPORTE DE DESEMPEÑO DE MECANICOS
   Devuelve por mecánico: especialidad, órdenes cerradas
   atendidas e ingresos generados. Los totales se calculan
   con subqueries previos para evitar doble conteo al hacer
   JOIN simultáneo con detalle_servicio y detalle_repuesto.
   p_cursor : filas con el desempeño de cada mecánico.
   p_total  : número total de mecánicos en la tabla.
   ========================================================= */
CREATE OR REPLACE PROCEDURE sp_reporte_mecanicos(
    p_cursor OUT SYS_REFCURSOR,
    p_total  OUT NUMBER
)
AS
BEGIN
    SELECT COUNT(*) INTO p_total FROM mecanico;

    OPEN p_cursor FOR
        SELECT
            m.id_mecanico,
            m.nombres,
            m.especialidad,
            NVL(stats.ordenes_atendidas, 0) AS ordenes_atendidas,
            NVL(stats.total_generado,    0) AS total_generado
        FROM mecanico m
        LEFT JOIN (
            SELECT
                o.id_mecanico,
                COUNT(o.id_orden)                          AS ordenes_atendidas,
                SUM(NVL(ds_s.sub_s, 0) + NVL(ds_r.sub_r, 0)) AS total_generado
            FROM orden_servicio o
            LEFT JOIN (
                SELECT id_orden, SUM(subtotal) AS sub_s
                FROM detalle_servicio GROUP BY id_orden
            ) ds_s ON o.id_orden = ds_s.id_orden
            LEFT JOIN (
                SELECT id_orden, SUM(subtotal) AS sub_r
                FROM detalle_repuesto GROUP BY id_orden
            ) ds_r ON o.id_orden = ds_r.id_orden
            WHERE o.estado = 'CERRADA'
            GROUP BY o.id_mecanico
        ) stats ON m.id_mecanico = stats.id_mecanico
        ORDER BY stats.ordenes_atendidas DESC NULLS LAST;

EXCEPTION
    WHEN OTHERS THEN
        p_total  := -1;
        p_cursor := NULL;
END;
/

/* =========================================================
   PROCEDIMIENTO 14: ACTUALIZAR PRECIOS DE SERVICIOS
   Aplica un porcentaje de ajuste a todos los servicios del
   catálogo. El porcentaje debe estar entre -99 y 200 para
   evitar precios nulos o negativos y valores absurdos.
   Los subtotales históricos en detalle_servicio no se ven
   afectados; solo cambia el precio para nuevas órdenes.
   p_porcentaje : positivo = aumento, negativo = descuento.
   p_total      : filas actualizadas; -1 o -2 en error de validación.
   ========================================================= */
CREATE OR REPLACE PROCEDURE sp_actualizar_precios(
    p_porcentaje IN  NUMBER,
    p_total      OUT NUMBER
)
AS
BEGIN
    -- Porcentaje de -100 o menor dejaría precios en cero o negativos
    IF p_porcentaje <= -100 THEN
        p_total := -1;
        RETURN;
    END IF;

    -- Porcentaje mayor a 200 es probablemente un error de entrada
    IF p_porcentaje > 200 THEN
        p_total := -2;
        RETURN;
    END IF;

    UPDATE servicio
    SET precio = ROUND(precio * (1 + p_porcentaje / 100), 2);

    -- SQL%ROWCOUNT contiene el número de filas afectadas por el último DML
    p_total := SQL%ROWCOUNT;
    COMMIT;

END;
/

/* =========================================================
   PROCEDIMIENTO 15: CLIENTES FRECUENTES
   Devuelve los clientes que superan un número mínimo de
   órdenes de servicio. Incluye el total de órdenes para
   poder ordenarlos de mayor a menor fidelidad.
   p_min_ordenes : umbral mínimo de visitas (defecto: 2).
   p_cursor      : filas con los clientes frecuentes.
   p_total       : cantidad de clientes que cumplen el criterio.
   ========================================================= */
CREATE OR REPLACE PROCEDURE sp_clientes_frecuentes(
    p_min_ordenes IN  NUMBER DEFAULT 2,
    p_cursor      OUT SYS_REFCURSOR,
    p_total       OUT NUMBER
)
AS
BEGIN
    -- Contar cuántos clientes cumplen el umbral de frecuencia
    SELECT COUNT(*) INTO p_total
    FROM (
        SELECT v.id_cliente
        FROM orden_servicio o
        JOIN vehiculo v ON o.id_vehiculo = v.id_vehiculo
        GROUP BY v.id_cliente
        HAVING COUNT(o.id_orden) >= p_min_ordenes
    );

    -- Retornar el detalle de cada cliente frecuente
    OPEN p_cursor FOR
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
        HAVING COUNT(o.id_orden) >= p_min_ordenes
        ORDER BY total_ordenes DESC;

EXCEPTION
    WHEN OTHERS THEN
        p_total  := -1;
        p_cursor := NULL;
END;
/

/* =========================================================
   PROCEDIMIENTO 16: CONSUMO TOTAL DE REPUESTOS
   Suma las unidades de repuestos consumidas en todas las
   órdenes. Útil para análisis de rotación de inventario.
   p_total : total de unidades consumidas; -1 si hay error.
   ========================================================= */
CREATE OR REPLACE PROCEDURE sp_consumo_repuestos(
    p_total OUT NUMBER
)
AS
BEGIN
    -- Una sola consulta es más eficiente que recorrer con cursor
    SELECT NVL(SUM(cantidad), 0)
    INTO p_total
    FROM detalle_repuesto;

EXCEPTION
    WHEN OTHERS THEN
        p_total := -1;
END;
/

/* =========================================================
   COMMIT FINAL
   ========================================================= */
COMMIT;
