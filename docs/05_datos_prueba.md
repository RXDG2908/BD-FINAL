# Datos de prueba

[← Volver al índice](../README.md)

`06_inserts.sql` carga un dataset **completamente enlazado y cuadrado**: cada FK apunta a un registro existente, cada factura suma exactamente sus detalles, y el stock refleja las compras y consumos registrados. Estos datos alimentan la demo de [Casos de Procesos](06_casos_procesos.md) (`08_casos_procesos.sql`).

## Volumen de datos

| Tabla | Filas | Notas |
|---|---|---|
| `cargo` | 4 | Junior, Senior, Especialista, Jefe de Taller |
| `cliente` | 15 | |
| `mecanico` | 6 | Todos los cargos representados |
| `servicio` | 15 | Precios de 50 a 2500 |
| `repuesto` | 25 | 3 quedan bajo stock mínimo |
| `vehiculo` | 20 | 5 clientes tienen 2 vehículos |
| `proveedor` | 5 | |
| `compra` | 6 | Total = suma exacta de su detalle |
| `detalle_compra` | 13 | |
| `orden_servicio` | 30 | 22 CERRADAS + 8 ABIERTAS |
| `detalle_servicio` | 37 | Varias órdenes con 2+ servicios |
| `detalle_repuesto` | 37 | Subtotal = precio × cantidad |
| `factura` | 22 | Una por cada orden cerrada, IGV 18% exacto |
| `pago` | 22 | Únicos, en cuotas, parciales |
| `cita` | 12 | El vehículo siempre pertenece al cliente |

## Escenarios preparados

Cada procedimiento y vista tiene datos que garantizan su ejecución:

1. **Límite de órdenes por mecánico** — El mecánico 1 tiene exactamente **3 órdenes abiertas** (7, 21, 22). Llamar `sp_abrir_orden` con él devuelve el mensaje de límite; con los mecánicos 4 o 5 (0 abiertas) funciona normal.
2. **Stock bajo mínimo** — Radiador (1/2), Alternador (0/1) y Motor de arranque (0/1) quedan bajo el mínimo: `sp_listar_reposicion` y `v_repuestos_stock_bajo` devuelven 3 filas.
3. **Facturación completa** — Las 22 órdenes cerradas tienen factura con `subtotal = servicios + repuestos`, `igv = 18%` y `total = subtotal + igv`, centavo a centavo.
4. **Cobranza** — Tres situaciones de pago pendiente para `v_facturas_por_cobrar`:
   - Orden 10: factura **sin ningún pago** (saldo 1062.00)
   - Orden 11: **pago parcial** de 2000 (saldo 2130.00)
   - Orden 29: **pago parcial** de 300 (saldo 1234.00)
   - Orden 4: pagada en **2 cuotas** que suman el total exacto (saldada)
5. **Cierre del día** — Las órdenes 9 y 28 cierran el mismo día (`SYSDATE-10`): `sp_cierre_del_dia` con esa fecha agrupa más de una orden.
6. **Clientes frecuentes** — Los clientes con 2 vehículos acumulan hasta 4 órdenes: `v_clientes_frecuentes` y `sp_clientes_frecuentes` devuelven varias filas.
7. **Agenda** — 10 citas futuras PENDIENTE/CONFIRMADA para `v_citas_pendientes`, más 2 canceladas.

## Cómo se mantiene la consistencia

- El stock de `repuesto` se inserta con el valor **inicial** y dos `UPDATE` al final del script aplican las entradas (`detalle_compra`) y salidas (`detalle_repuesto`). Así `stock` siempre cuadra con los movimientos registrados.
- Los subtotales de detalle usan el **precio de catálogo vigente**, igual que hacen los procedimientos al insertar.
- Las facturas se numeran `F001-xxxxx` en orden cronológico de emisión.

> **Importante:** si agregas datos a mano, cuida que los montos sigan cuadrando (factura = detalles, stock = movimientos) y vuelve a correr `08_casos_procesos.sql` para confirmar que los procedimientos siguen funcionando.
