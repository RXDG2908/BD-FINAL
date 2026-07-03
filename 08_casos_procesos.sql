/* =========================================================
   CASOS DE PROCESOS  -  Sistema AUTOFIX
   Demostracion ejecutable de los 16 procedimientos almacenados.

   Ejecutar DESPUES de cargar los scripts 01 al 07:
       SET SERVEROUTPUT ON
       @08_casos_procesos.sql

   Cada caso indica el procedimiento, los datos usados y el
   resultado esperado. Se prueban casos de EXITO y casos de
   ERROR CONTROLADO (validaciones del procedimiento).

   Los datos de 06_inserts.sql estan preparados para esto:
   - Mecanico 1 tiene 3 ordenes ABIERTAS  -> limite alcanzado
   - Mecanicos 4 y 5 estan disponibles    -> abrir orden OK
   - Repuesto 17 (Alternador) stock 0     -> stock insuficiente
   - Ordenes 9 y 28 cerradas el mismo dia -> cierre del dia
   - Vehiculo 1 con 2 ordenes historicas  -> historial
   ========================================================= */

SET SERVEROUTPUT ON SIZE UNLIMITED

DECLARE
    -- variables de salida reutilizadas
    v_id       NUMBER;
    v_id2      NUMBER;
    v_orden    NUMBER;
    v_total    NUMBER;
    v_stock    NUMBER;
    v_msg      VARCHAR2(400);
    v_estado   VARCHAR2(100);
    v_cur      SYS_REFCURSOR;

    -- variables para recorrer cursores
    c_id       NUMBER;
    c_nom      VARCHAR2(200);
    c_ape      VARCHAR2(200);
    c_tel      VARCHAR2(50);
    c_esp      VARCHAR2(200);
    c_n1       NUMBER;
    c_n2       NUMBER;
    c_n3       NUMBER;
    c_f1       DATE;
    c_f2       DATE;
    c_est      VARCHAR2(50);

    PROCEDURE titulo(p_txt VARCHAR2) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE('==================================================');
        DBMS_OUTPUT.PUT_LINE(p_txt);
        DBMS_OUTPUT.PUT_LINE('==================================================');
    END;
BEGIN
    DBMS_OUTPUT.PUT_LINE('****************************************************');
    DBMS_OUTPUT.PUT_LINE('*  AUTOFIX - CASOS DE PRUEBA DE LOS PROCEDIMIENTOS *');
    DBMS_OUTPUT.PUT_LINE('****************************************************');

    ------------------------------------------------------------------
    titulo('CASO 1: sp_registrar_cliente');
    ------------------------------------------------------------------
    -- Datos: Ana Quispe, 999222001, Jesus Maria
    -- Esperado: CLIENTE REGISTRADO + id nuevo (16 en carga limpia)
    sp_registrar_cliente('Ana','Quispe','999222001','Jesus Maria', v_id, v_msg);
    DBMS_OUTPUT.PUT_LINE('  Exito    -> ' || v_msg || ' (id=' || v_id || ')');

    ------------------------------------------------------------------
    titulo('CASO 2: sp_registrar_vehiculo');
    ------------------------------------------------------------------
    -- Datos: placa XYZ901, Toyota RAV4, del cliente recien creado
    -- Esperado: VEHICULO REGISTRADO + id nuevo
    sp_registrar_vehiculo('XYZ901','Toyota','RAV4', v_id, v_id2, v_msg);
    DBMS_OUTPUT.PUT_LINE('  Exito    -> ' || v_msg || ' (id=' || v_id2 || ')');

    -- Error 1: cliente 999 no existe
    sp_registrar_vehiculo('XYZ902','Kia','Sportage', 999, v_id, v_msg);
    DBMS_OUTPUT.PUT_LINE('  Error ok -> ' || v_msg || ' (cliente 999)');

    -- Error 2: placa ABC101 ya existe (UNIQUE)
    sp_registrar_vehiculo('ABC101','Ford','Focus', 1, v_id, v_msg);
    DBMS_OUTPUT.PUT_LINE('  Error ok -> ' || v_msg || ' (placa repetida ABC101)');

    ------------------------------------------------------------------
    titulo('CASO 3: sp_abrir_orden');
    ------------------------------------------------------------------
    -- Datos: vehiculo nuevo (RAV4), mecanico 4 (0 ordenes abiertas),
    --        servicio 1 (Cambio de aceite, 120)
    -- Esperado: ORDEN ABIERTA + id nuevo
    sp_abrir_orden(v_id2, 4, 1, v_orden, v_msg);
    DBMS_OUTPUT.PUT_LINE('  Exito    -> ' || v_msg || ' (orden=' || v_orden || ')');

    -- Error: mecanico 1 ya tiene 3 ordenes ABIERTAS (7, 21 y 22)
    sp_abrir_orden(v_id2, 1, 1, v_id, v_msg);
    DBMS_OUTPUT.PUT_LINE('  Error ok -> ' || v_msg);

    ------------------------------------------------------------------
    titulo('CASO 4: sp_agregar_servicio');
    ------------------------------------------------------------------
    -- Datos: servicio 5 (Lavado completo, 50) a la orden recien abierta
    -- Esperado: SERVICIO AGREGADO
    sp_agregar_servicio(v_orden, 5, v_msg);
    DBMS_OUTPUT.PUT_LINE('  Exito    -> ' || v_msg || ' (Lavado a orden ' || v_orden || ')');

    -- Error: la orden 1 esta CERRADA
    sp_agregar_servicio(1, 5, v_msg);
    DBMS_OUTPUT.PUT_LINE('  Error ok -> ' || v_msg || ' (orden 1 cerrada)');

    ------------------------------------------------------------------
    titulo('CASO 5: sp_agregar_repuestos');
    ------------------------------------------------------------------
    -- Datos: repuesto 2 (Bujia, 15) x4 a la orden abierta
    -- Esperado: REPUESTO AGREGADO y stock descontado en 4
    sp_agregar_repuestos(v_orden, 2, 4, v_msg);
    DBMS_OUTPUT.PUT_LINE('  Exito    -> ' || v_msg || ' (4 bujias a orden ' || v_orden || ')');

    -- Error: repuesto 17 (Alternador) tiene stock 0
    sp_agregar_repuestos(v_orden, 17, 1, v_msg);
    DBMS_OUTPUT.PUT_LINE('  Error ok -> ' || v_msg || ' (Alternador sin stock)');

    ------------------------------------------------------------------
    titulo('CASO 6: sp_calcular_orden');
    ------------------------------------------------------------------
    -- Datos: la orden abierta (120 + 50 servicios + 60 repuestos)
    -- Esperado: total = 230
    sp_calcular_orden(v_orden, v_total);
    DBMS_OUTPUT.PUT_LINE('  Exito    -> total orden ' || v_orden || ' = ' || v_total || ' (esperado 230)');

    -- Error: orden 9999 no existe -> devuelve -1
    sp_calcular_orden(9999, v_total);
    DBMS_OUTPUT.PUT_LINE('  Error ok -> orden 9999 devuelve ' || v_total || ' (esperado -1)');

    ------------------------------------------------------------------
    titulo('CASO 7: sp_cerrar_orden');
    ------------------------------------------------------------------
    -- Datos: la orden abierta de los casos anteriores
    -- Esperado: ORDEN CERRADA con total 230 y fecha_cierre de hoy
    sp_cerrar_orden(v_orden, v_total, v_msg);
    DBMS_OUTPUT.PUT_LINE('  Exito    -> ' || v_msg || ' (total=' || v_total || ')');

    -- Error: cerrarla de nuevo
    sp_cerrar_orden(v_orden, v_total, v_msg);
    DBMS_OUTPUT.PUT_LINE('  Error ok -> ' || v_msg);

    ------------------------------------------------------------------
    titulo('CASO 8: sp_cierre_del_dia');
    ------------------------------------------------------------------
    -- Datos: hoy (incluye la orden cerrada en el CASO 7)
    -- Esperado: total >= 230
    sp_cierre_del_dia(SYSDATE, v_total);
    DBMS_OUTPUT.PUT_LINE('  Exito    -> total facturado hoy = ' || v_total);

    -- Datos: hace 10 dias cerraron DOS ordenes (9: 1210 y 28: 750)
    -- Esperado: 1960
    sp_cierre_del_dia(TRUNC(SYSDATE) - 10, v_total);
    DBMS_OUTPUT.PUT_LINE('  Exito    -> total de hace 10 dias = ' || v_total || ' (esperado 1960: ordenes 9 y 28)');

    ------------------------------------------------------------------
    titulo('CASO 9: sp_validar_stock');
    ------------------------------------------------------------------
    -- Datos: repuesto 9 (Aceite sintetico, stock alto) x5
    -- Esperado: DISPONIBLE
    sp_validar_stock(9, 5, v_stock, v_estado);
    DBMS_OUTPUT.PUT_LINE('  Exito    -> Aceite sintetico x5: ' || v_estado || ' (stock=' || v_stock || ')');

    -- Datos: repuesto 17 (Alternador, stock 0) x1 -> NO DISPONIBLE
    sp_validar_stock(17, 1, v_stock, v_estado);
    DBMS_OUTPUT.PUT_LINE('  Error ok -> Alternador x1: ' || v_estado || ' (stock=' || v_stock || ')');

    -- Datos: repuesto 999 -> REPUESTO NO EXISTE
    sp_validar_stock(999, 1, v_stock, v_estado);
    DBMS_OUTPUT.PUT_LINE('  Error ok -> repuesto 999: ' || v_estado);

    ------------------------------------------------------------------
    titulo('CASO 10: sp_historial_vehiculo');
    ------------------------------------------------------------------
    -- Datos: vehiculo 1 (Toyota Corolla ABC101, ordenes 1 y 27)
    -- Esperado: 2 ordenes listadas
    sp_historial_vehiculo(1, v_cur, v_total);
    DBMS_OUTPUT.PUT_LINE('  Exito    -> vehiculo 1 tiene ' || v_total || ' ordenes:');
    LOOP
        FETCH v_cur INTO c_id, c_f1, c_f2, c_est, c_nom, c_n1;
        EXIT WHEN v_cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('             orden ' || c_id || ' | ' || c_est ||
                             ' | mecanico ' || c_nom || ' | total ' || c_n1);
    END LOOP;
    CLOSE v_cur;

    -- Error: vehiculo 999 -> p_total = -1
    sp_historial_vehiculo(999, v_cur, v_total);
    DBMS_OUTPUT.PUT_LINE('  Error ok -> vehiculo 999 devuelve ' || v_total || ' (esperado -1)');

    ------------------------------------------------------------------
    titulo('CASO 11: sp_listar_reposicion');
    ------------------------------------------------------------------
    -- Datos: ninguno (lee el inventario)
    -- Esperado: 3 repuestos bajo minimo (Radiador, Alternador, Motor arranque)
    sp_listar_reposicion(v_cur, v_total);
    DBMS_OUTPUT.PUT_LINE('  Exito    -> ' || v_total || ' repuestos por reponer:');
    LOOP
        FETCH v_cur INTO c_id, c_nom, c_n1, c_n2, c_n3;
        EXIT WHEN v_cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('             ' || c_nom || ': stock ' || c_n1 ||
                             ' / minimo ' || c_n2 || ' -> faltan ' || c_n3);
    END LOOP;
    CLOSE v_cur;

    ------------------------------------------------------------------
    titulo('CASO 12: sp_reporte_servicios_top');
    ------------------------------------------------------------------
    -- Datos: top 5
    -- Esperado: ranking por veces solicitado e ingresos
    sp_reporte_servicios_top(5, v_cur, v_total);
    DBMS_OUTPUT.PUT_LINE('  Exito    -> ' || v_total || ' servicios distintos prestados. Top 5:');
    LOOP
        FETCH v_cur INTO c_id, c_nom, c_n1, c_n2, c_n3;
        EXIT WHEN v_cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('             ' || c_nom || ': ' || c_n2 ||
                             ' veces | genero ' || c_n3);
    END LOOP;
    CLOSE v_cur;

    ------------------------------------------------------------------
    titulo('CASO 13: sp_reporte_mecanicos');
    ------------------------------------------------------------------
    -- Datos: ninguno
    -- Esperado: 6 mecanicos con sus ordenes cerradas e ingresos
    sp_reporte_mecanicos(v_cur, v_total);
    DBMS_OUTPUT.PUT_LINE('  Exito    -> ' || v_total || ' mecanicos:');
    LOOP
        FETCH v_cur INTO c_id, c_nom, c_esp, c_n1, c_n2;
        EXIT WHEN v_cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('             ' || c_nom || ' (' || c_esp || '): ' ||
                             c_n1 || ' ordenes | ingresos ' || c_n2);
    END LOOP;
    CLOSE v_cur;

    ------------------------------------------------------------------
    titulo('CASO 14: sp_actualizar_precios');
    ------------------------------------------------------------------
    -- Error 1: -150% dejaria precios negativos -> devuelve -1
    sp_actualizar_precios(-150, v_total);
    DBMS_OUTPUT.PUT_LINE('  Error ok -> -150% devuelve ' || v_total || ' (esperado -1)');

    -- Error 2: +300% es un valor absurdo -> devuelve -2
    sp_actualizar_precios(300, v_total);
    DBMS_OUTPUT.PUT_LINE('  Error ok -> +300% devuelve ' || v_total || ' (esperado -2)');

    -- Exito: +5% a todo el catalogo -> 15 filas actualizadas
    sp_actualizar_precios(5, v_total);
    DBMS_OUTPUT.PUT_LINE('  Exito    -> +5% aplicado a ' || v_total || ' servicios (esperado 15)');

    -- Se revierte para dejar el catalogo como estaba (5/1.05 = 4.7619%)
    UPDATE servicio SET precio = ROUND(precio / 1.05, 2);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('             (precios restaurados al valor original)');

    ------------------------------------------------------------------
    titulo('CASO 15: sp_clientes_frecuentes');
    ------------------------------------------------------------------
    -- Datos: minimo 2 ordenes
    -- Esperado: varios clientes (Jose Perez tiene 4 ordenes)
    sp_clientes_frecuentes(2, v_cur, v_total);
    DBMS_OUTPUT.PUT_LINE('  Exito    -> ' || v_total || ' clientes con 2+ ordenes:');
    LOOP
        FETCH v_cur INTO c_id, c_nom, c_ape, c_tel, c_n1;
        EXIT WHEN v_cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('             ' || c_nom || ' ' || c_ape ||
                             ': ' || c_n1 || ' ordenes');
    END LOOP;
    CLOSE v_cur;

    ------------------------------------------------------------------
    titulo('CASO 16: sp_consumo_repuestos');
    ------------------------------------------------------------------
    -- Datos: ninguno
    -- Esperado: suma de unidades consumidas en todas las ordenes
    sp_consumo_repuestos(v_total);
    DBMS_OUTPUT.PUT_LINE('  Exito    -> unidades de repuesto consumidas: ' || v_total);

    DBMS_OUTPUT.PUT_LINE(' ');
    DBMS_OUTPUT.PUT_LINE('****************************************************');
    DBMS_OUTPUT.PUT_LINE('*  FIN: 16 procedimientos probados con exito       *');
    DBMS_OUTPUT.PUT_LINE('****************************************************');
END;
/

/* =========================================================
   CONSULTAS DE APOYO PARA LA DEMOSTRACION
   Utiles para mostrar el estado antes/despues en las vistas.
   ========================================================= */

-- Ordenes actualmente abiertas (el mecanico 1 concentra 3)
SELECT * FROM v_ordenes_abiertas;

-- Repuestos que necesitan reposicion
SELECT * FROM v_repuestos_stock_bajo;

-- Facturas con saldo pendiente de cobro
SELECT * FROM v_facturas_por_cobrar;

-- Clientes frecuentes del taller
SELECT * FROM v_clientes_frecuentes;

-- Agenda de citas proximas
SELECT * FROM v_citas_pendientes;
