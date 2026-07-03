# Vistas

[← Volver al índice](../README.md)

Definidas en `05_vistas.sql`. Los datos de prueba garantizan que **todas devuelven filas** (ver [Datos de prueba](05_datos_prueba.md)).

| Vista | Descripción | Escenario en datos de prueba |
|---|---|---|
| `v_ordenes_abiertas` | Órdenes activas con vehículo y mecánico asignado | 8 órdenes abiertas |
| `v_repuestos_stock_bajo` | Repuestos por debajo del stock mínimo | Radiador, Alternador y Motor de arranque |
| `v_clientes_frecuentes` | Clientes con 2 o más órdenes de servicio | Varios clientes con 2-4 órdenes |
| `v_citas_pendientes` | Agenda de citas próximas (PENDIENTE o CONFIRMADA) | 10 citas futuras activas |
| `v_facturas_por_cobrar` | Facturas con saldo pendiente de pago | 3 facturas: sin pago, pago parcial x2 |

## Uso

```sql
SELECT * FROM v_ordenes_abiertas;
SELECT * FROM v_repuestos_stock_bajo;
SELECT * FROM v_clientes_frecuentes;
SELECT * FROM v_citas_pendientes;
SELECT * FROM v_facturas_por_cobrar;
```
