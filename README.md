# BD-FINAL — Sistema de Gestión de Taller Mecánico AUTOFIX

Base de datos relacional desarrollada en **Oracle SQL + PL/SQL** para la gestión de clientes, vehículos, servicios, repuestos, compras, facturación y agenda de un taller mecánico.

## 📚 Índice de documentación

| Documento | Contenido |
|---|---|
| [1. Instalación](docs/01_instalacion.md) | Requisitos, SETUP.bat, conexión y orden de ejecución de scripts |
| [2. Esquema](docs/02_esquema.md) | Las 15 tablas, relaciones, reglas de integridad, secuencias e índices |
| [3. Vistas](docs/03_vistas.md) | Las 5 vistas de consulta y su escenario de datos |
| [4. Procedimientos](docs/04_procedimientos.md) | Los 16 procedimientos almacenados con ejemplos de ejecución |
| [5. Datos de prueba](docs/05_datos_prueba.md) | Volumen del dataset y escenarios preparados por procedimiento |
| [6. Casos de Procesos](docs/06_casos_procesos.md) | Demostración ejecutable de los 16 procedimientos con datos y resultados esperados |
| [Diagrama ER](ER_AUTOFIX.md) | Diagrama entidad-relación (Mermaid, `Ctrl+Shift+V` en VS Code) |

## 📂 Scripts SQL

| Archivo | Contenido |
|---|---|
| `01_eliminar_tablas.sql` | Drop de tablas y secuencias (reset completo) |
| `02_secuencias.sql` | 15 secuencias para IDs autoincrementales |
| `03_tablas.sql` | Definición de las 15 tablas del esquema |
| `04_indices.sql` | 16 índices para optimizar consultas |
| `05_vistas.sql` | 5 vistas de consulta rápida |
| `06_inserts.sql` | Datos de prueba enlazados y cuadrados (30 órdenes, 22 facturas…) |
| `07_procedimientos.sql` | 16 procedimientos almacenados |
| `08_casos_procesos.sql` | Casos de prueba de los 16 procedimientos (demo para exposición) |

## 🚀 Inicio rápido

```sql
@01_eliminar_tablas.sql
@02_secuencias.sql
@03_tablas.sql
@04_indices.sql
@05_vistas.sql
@06_inserts.sql
@07_procedimientos.sql
@08_casos_procesos.sql -- demo: prueba los 16 procedimientos con datos reales
```

Detalles de conexión y configuración en [docs/01_instalacion.md](docs/01_instalacion.md).

## 🛠 Tecnología

- **Motor:** Oracle Database / SQL Developer
- **Lenguaje:** SQL + PL/SQL
- **Cursores:** `FOR`, `SYS_REFCURSOR`, `SELECT FOR UPDATE`
