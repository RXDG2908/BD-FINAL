# Esquema de la base de datos

[← Volver al índice](../README.md)

El diagrama entidad-relación completo está en [ER_AUTOFIX.md](../ER_AUTOFIX.md) (abrir en VS Code y presionar `Ctrl+Shift+V` para ver el diagrama Mermaid).

## Relaciones principales

```
cargo ──< mecanico ──< orden_servicio ──< detalle_servicio >── servicio
                  └──< orden_servicio ──< detalle_repuesto >── repuesto
cliente ──< vehiculo ──< orden_servicio ──< factura ──< pago
                   └──< cita >── cliente
proveedor ──< compra ──< detalle_compra >── repuesto
```

## Tablas (15)

| # | Tabla | Descripción |
|---|---|---|
| 1 | `cargo` | Cargos laborales: Junior, Senior, Especialista, Jefe de Taller |
| 2 | `cliente` | Datos del cliente (nombre, teléfono, dirección) |
| 3 | `mecanico` | Mecánicos con especialidad y cargo asignado |
| 4 | `servicio` | Catálogo de servicios con precio |
| 5 | `repuesto` | Inventario de repuestos con stock mínimo |
| 6 | `vehiculo` | Vehículos registrados, vinculados a un cliente |
| 7 | `proveedor` | Empresas que suministran los repuestos |
| 8 | `compra` | Órdenes de compra emitidas a proveedores |
| 9 | `detalle_compra` | Líneas de cada orden de compra |
| 10 | `orden_servicio` | Cabecera de cada orden (fecha ingreso, fecha cierre, estado) |
| 11 | `detalle_servicio` | Servicios aplicados a una orden |
| 12 | `detalle_repuesto` | Repuestos utilizados en una orden |
| 13 | `factura` | Documento fiscal emitido al cerrar una orden (incluye IGV 18%) |
| 14 | `pago` | Pagos registrados contra una factura (admite abonos) |
| 15 | `cita` | Agenda de turnos solicitados por el cliente |

## Reglas de integridad destacadas

Además de las claves foráneas, el esquema refuerza los vínculos con:

- **`orden_servicio.estado`**: CHECK, solo `ABIERTA` o `CERRADA`. Las órdenes abiertas tienen `fecha_cierre` NULL.
- **`factura`**: `UNIQUE(id_orden)` — una orden genera exactamente **una** factura; `UNIQUE(numero_factura)` — el número fiscal no se repite.
- **`vehiculo.placa`**: `NOT NULL UNIQUE` — ningún vehículo sin placa ni placas repetidas.
- **`pago.metodo_pago`**: CHECK, solo `EFECTIVO`, `TARJETA` o `TRANSFERENCIA`.
- **`cita.estado`**: CHECK, solo `PENDIENTE`, `CONFIRMADA` o `CANCELADA`.
- **Precios y cantidades**: CHECK `> 0` en servicios, repuestos, compras y detalles; stock nunca negativo.

## Secuencias (15)

Cada tabla tiene su secuencia `seq_<tabla>` (`START WITH 1 INCREMENT BY 1`) definida en `02_secuencias.sql`. Los IDs se generan siempre con `seq_x.NEXTVAL`, nunca a mano.

## Índices (16)

Definidos en `04_indices.sql` sobre las columnas FK y de búsqueda frecuente para acelerar los JOIN de vistas y procedimientos.
