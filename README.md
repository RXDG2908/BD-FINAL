# BD-FINAL — Sistema de Gestión de Taller Mecánico AUTOFIX
Base de datos relacional desarrollada en **Oracle SQL Developer** para la gestión de clientes, vehículos, servicios, repuestos y órdenes de trabajo de un taller mecánico.

---

## Estructura del proyecto

| Archivo | Contenido |
|---|---|
| `01_eliminar_tablas.sql` | Drop de tablas y secuencias (reset completo) |
| `02_secuencias.sql` | Secuencias para IDs autoincrementales |
| `03_tablas.sql` | Definición de las 8 tablas del esquema |
| `04_indices.sql` | 8 índices para optimizar consultas |
| `05_vistas.sql` | 3 vistas de consulta rápida |
| `06_inserts.sql` | Datos de prueba (15 clientes, 20 vehículos, 6 mecánicos…) |
| `07_procedimientos.sql` | 16 procedimientos almacenados |
| `base de datos AUTOFIX.txt` | Informe del proyecto |

---

## Esquema de tablas

```
cliente ──< vehiculo ──< orden_servicio ──< detalle_servicio >── servicio
                                      └──< detalle_repuesto  >── repuesto
mecanico ──< orden_servicio
```

| Tabla | Descripción |
|---|---|
| `cliente` | Datos del cliente (nombre, teléfono, dirección) |
| `vehiculo` | Vehículos registrados, vinculados a un cliente |
| `mecanico` | Mecánicos del taller con especialidad |
| `servicio` | Catálogo de servicios con precio |
| `repuesto` | Inventario de repuestos con stock mínimo |
| `orden_servicio` | Cabecera de cada orden (fecha ingreso, fecha cierre, estado) |
| `detalle_servicio` | Servicios aplicados a una orden |
| `detalle_repuesto` | Repuestos utilizados en una orden |

---

## Vistas

| Vista | Descripción |
|---|---|
| `v_ordenes_abiertas` | Órdenes activas con vehículo y mecánico asignado |
| `v_repuestos_stock_bajo` | Repuestos por debajo del stock mínimo |
| `v_clientes_frecuentes` | Clientes con 2 o más órdenes de servicio |

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
