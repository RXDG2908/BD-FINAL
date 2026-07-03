# BD-FINAL — Sistema de Gestión de Taller Mecánico AUTOFIX
Base de datos relacional desarrollada en **Oracle SQL Developer** para la gestión de clientes, vehículos, servicios, repuestos, compras, facturación y agenda de un taller mecánico.

---

## Estructura del proyecto

| Archivo | Contenido |
|---|---|
| `01_eliminar_tablas.sql` | Drop de tablas y secuencias (reset completo) |
| `02_secuencias.sql` | 15 secuencias para IDs autoincrementales |
| `03_tablas.sql` | Definición de las 15 tablas del esquema |
| `04_indices.sql` | 16 índices para optimizar consultas |
| `05_vistas.sql` | 5 vistas de consulta rápida |
| `06_inserts.sql` | Datos de prueba (15 clientes, 20 vehículos, 6 mecánicos…) |
| `07_procedimientos.sql` | 16 procedimientos almacenados |

---

## Esquema de tablas (15)

```
cargo ──< mecanico ──< orden_servicio ──< detalle_servicio >── servicio
                  └──< orden_servicio ──< detalle_repuesto >── repuesto
cliente ──< vehiculo ──< orden_servicio ──< factura ──< pago
                   └──< cita >── cliente
proveedor ──< compra ──< detalle_compra >── repuesto
```

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
| 13 | `factura` | Documento fiscal emitido al cerrar una orden (incluye IGV) |
| 14 | `pago` | Pagos registrados contra una factura (admite abonos) |
| 15 | `cita` | Agenda de turnos solicitados por el cliente |

---

## Vistas (5)

| Vista | Descripción |
|---|---|
| `v_ordenes_abiertas` | Órdenes activas con vehículo y mecánico asignado |
| `v_repuestos_stock_bajo` | Repuestos por debajo del stock mínimo |
| `v_clientes_frecuentes` | Clientes con 2 o más órdenes de servicio |
| `v_citas_pendientes` | Agenda de citas próximas (PENDIENTE o CONFIRMADA) |
| `v_facturas_por_cobrar` | Facturas con saldo pendiente de pago |

---

## Procedimientos almacenados (16)

| Procedimiento | Descripción |
|---|---|
| `sp_registrar_cliente` | Inserta un nuevo cliente |
| `sp_registrar_vehiculo` | Registra un vehículo validando que el cliente exista |
| `sp_abrir_orden` | Crea una orden con su primer servicio (límite: 3 órdenes abiertas por mecánico) |
| `sp_agregar_servicio` | Agrega un servicio adicional a una orden abierta |
| `sp_agregar_repuestos` | Agrega un repuesto, valida stock y descuenta inventario |
| `sp_calcular_orden` | Calcula el total de una orden (servicios + repuestos) |
| `sp_cerrar_orden` | Cierra la orden, registra `fecha_cierre` y calcula el total |
| `sp_cierre_del_dia` | Suma el total facturado en una fecha por `fecha_cierre` |
| `sp_validar_stock` | Verifica disponibilidad de un repuesto |
| `sp_historial_vehiculo` | Devuelve el historial de órdenes de un vehículo (SYS_REFCURSOR) |
| `sp_listar_reposicion` | Lista repuestos a reponer ordenados por urgencia (SYS_REFCURSOR) |
| `sp_reporte_servicios_top` | Ranking de los N servicios más solicitados (SYS_REFCURSOR) |
| `sp_reporte_mecanicos` | Desempeño de mecánicos: órdenes e ingresos (SYS_REFCURSOR) |
| `sp_actualizar_precios` | Aplica un % de ajuste a todos los precios del catálogo |
| `sp_clientes_frecuentes` | Clientes con N o más órdenes (SYS_REFCURSOR) |
| `sp_consumo_repuestos` | Total de unidades de repuestos consumidas |

---

## Orden de ejecución

```sql
-- 1. Limpiar esquema anterior
@01_eliminar_tablas.sql

-- 2. Crear estructura
@02_secuencias.sql
@03_tablas.sql
@04_indices.sql
@05_vistas.sql

-- 3. Cargar datos de prueba
@06_inserts.sql

-- 4. Compilar procedimientos
@07_procedimientos.sql
```

---

## Tecnología
- **Motor:** Oracle Database / SQL Developer
- **Lenguaje:** SQL + PL/SQL
- **Cursores:** `FOR`, `SYS_REFCURSOR`, `SELECT FOR UPDATE`

---

## Colaboradores
- Johan-Salazar-Atencio
