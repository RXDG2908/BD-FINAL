# Verificación de integridad

[← Volver al índice](../README.md)

`08_verificacion.sql` audita que **todos los datos estén enlazados y cuadrados**. Ejecutarlo después de cargar los scripts 01-07, y cada vez que se modifiquen datos a mano.

## Qué valida

| # | Chequeo | Detecta |
|---|---|---|
| 1 | `factura.subtotal` = suma de detalles de su orden | Facturas descuadradas |
| 2 | `factura.igv` = 18% del subtotal y `total` = subtotal + igv | Errores de cálculo fiscal |
| 3 | Toda orden CERRADA tiene factura / ninguna ABIERTA facturada | Órdenes sin facturar o facturas prematuras |
| 4 | Fechas coherentes con el estado de la orden | CERRADA sin fecha de cierre, cierre anterior al ingreso |
| 5 | Pagos acumulados ≤ total de la factura | Sobrepagos |
| 6 | `compra.total` = suma de su `detalle_compra` | Compras descuadradas o sin detalle |
| 7 | Stock nunca negativo y subtotales de detalle = precio × cantidad | Inventario roto |
| 8 | El vehículo de cada cita pertenece al cliente de la cita | Citas cruzadas |
| 9 | Ningún mecánico con más de 3 órdenes abiertas | Violación de la regla de negocio |
| 10 | Toda orden tiene al menos un servicio | Órdenes vacías |

## Cómo ejecutarlo

```sql
SET SERVEROUTPUT ON
@08_verificacion.sql
```

## Salida esperada

```
================================================
  AUTOFIX - Verificacion de integridad de datos
================================================
OK    | Factura.subtotal = servicios + repuestos de su orden
OK    | Factura.igv = 18% del subtotal
OK    | Factura.total = subtotal + igv
OK    | Toda orden CERRADA tiene su factura
OK    | Ninguna orden ABIERTA esta facturada
OK    | Fechas de orden coherentes con su estado
OK    | Ninguna factura esta pagada por encima de su total
OK    | Compra.total = suma de su detalle_compra
OK    | Toda compra tiene detalle
OK    | Ningun repuesto con stock negativo
OK    | detalle_repuesto.subtotal = cantidad x precio
OK    | detalle_servicio.subtotal = precio de catalogo
OK    | Cada cita enlaza un vehiculo de su propio cliente
OK    | Ningun mecanico supera 3 ordenes abiertas
OK    | Toda orden tiene al menos un servicio
------------------------------------------------
VERIFICACION COMPLETA: todos los datos cuadran.
================================================
```

Si alguna línea dice `ERROR`, indica cuántas filas están inconsistentes; el script incluye al final consultas informativas para ubicarlas.

> Nota: los chequeos de subtotal vs precio de catálogo (11 y 12) asumen que no se ejecutó `sp_actualizar_precios` después de cargar los datos; si se cambiaron los precios, esos dos avisos son esperados porque los subtotales guardan el precio histórico.
