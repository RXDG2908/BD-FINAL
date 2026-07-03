# Procedimientos almacenados

[← Volver al índice](../README.md)

Definidos en `07_procedimientos.sql`. Convenciones:

- `p_mensaje OUT`: `'OK ...'` en éxito, texto del error en fallo.
- `p_total OUT`: valor calculado; `-1` indica error o no encontrado.
- `p_cursor OUT`: `SYS_REFCURSOR` con el resultado tabulado.

## Catálogo (16)

| Procedimiento | Descripción |
|---|---|
| `sp_registrar_cliente` | Inserta un nuevo cliente |
| `sp_registrar_vehiculo` | Registra un vehículo validando que el cliente exista |
| `sp_abrir_orden` | Crea una orden con su primer servicio (límite: 3 órdenes abiertas por mecánico) |
| `sp_agregar_servicio` | Agrega un servicio adicional a una orden abierta |
| `sp_agregar_repuestos` | Agrega un repuesto, valida stock y descuenta inventario (`SELECT FOR UPDATE`) |
| `sp_calcular_orden` | Calcula el total de una orden (servicios + repuestos) |
| `sp_cerrar_orden` | Cierra la orden, registra `fecha_cierre` y calcula el total |
| `sp_cierre_del_dia` | Suma el total facturado en una fecha por `fecha_cierre` |
| `sp_validar_stock` | Verifica disponibilidad de un repuesto |
| `sp_historial_vehiculo` | Historial de órdenes de un vehículo (`SYS_REFCURSOR`) |
| `sp_listar_reposicion` | Repuestos a reponer ordenados por urgencia (`SYS_REFCURSOR`) |
| `sp_reporte_servicios_top` | Ranking de los N servicios más solicitados (`SYS_REFCURSOR`) |
| `sp_reporte_mecanicos` | Desempeño de mecánicos: órdenes e ingresos (`SYS_REFCURSOR`) |
| `sp_actualizar_precios` | Aplica un % de ajuste a todos los precios del catálogo |
| `sp_clientes_frecuentes` | Clientes con N o más órdenes (`SYS_REFCURSOR`) |
| `sp_consumo_repuestos` | Total de unidades de repuestos consumidas |

## Ejemplos de ejecución

Cada procedimiento tiene su escenario garantizado en los datos de prueba:

```sql
-- Caso de éxito: abrir orden con un mecánico disponible (m4 o m5)
DECLARE
    v_id  NUMBER; v_msg VARCHAR2(200);
BEGIN
    sp_abrir_orden(p_vehiculo => 14, p_mecanico => 4, p_servicio => 1,
                   p_id_orden => v_id, p_mensaje => v_msg);
    DBMS_OUTPUT.PUT_LINE(v_msg || ' id=' || v_id);
END;
/

-- Caso de error controlado: el mecánico 1 ya tiene 3 órdenes abiertas
DECLARE
    v_id  NUMBER; v_msg VARCHAR2(200);
BEGIN
    sp_abrir_orden(p_vehiculo => 14, p_mecanico => 1, p_servicio => 1,
                   p_id_orden => v_id, p_mensaje => v_msg);
    DBMS_OUTPUT.PUT_LINE(v_msg);  -- MECANICO NO PUEDE TENER MAS DE 3 ORDENES ABIERTAS
END;
/

-- Repuestos a reponer (devuelve Radiador, Alternador, Motor arranque)
DECLARE
    v_cur SYS_REFCURSOR; v_total NUMBER;
    v_id NUMBER; v_nom VARCHAR2(100); v_stock NUMBER; v_min NUMBER; v_rep NUMBER;
BEGIN
    sp_listar_reposicion(v_cur, v_total);
    DBMS_OUTPUT.PUT_LINE('Items a reponer: ' || v_total);
    LOOP
        FETCH v_cur INTO v_id, v_nom, v_stock, v_min, v_rep;
        EXIT WHEN v_cur%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_nom || ' faltan ' || v_rep);
    END LOOP;
    CLOSE v_cur;
END;
/

-- Cierre del día en que se cerraron las órdenes 9 y 28 (mismo día)
DECLARE
    v_total NUMBER;
BEGIN
    sp_cierre_del_dia(TRUNC(SYSDATE) - 10, v_total);
    DBMS_OUTPUT.PUT_LINE('Total del dia: ' || v_total);
END;
/
```
