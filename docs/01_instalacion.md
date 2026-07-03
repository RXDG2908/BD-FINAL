# Instalación y puesta en marcha

[← Volver al índice](../README.md)

## Requisitos

- **Oracle Database** (XE 21c o superior recomendado)
- **Oracle SQL Developer** o la extensión de VS Code
- Opcional: **VS Code** con las extensiones que instala `SETUP.bat`

## Configuración rápida (Windows)

Ejecutar `SETUP.bat` en la raíz del proyecto. El script:

1. Verifica que VS Code esté instalado.
2. Instala las extensiones: Oracle SQL Developer, PL/SQL Language, SQLTools y Markdown Mermaid.
3. Abre el proyecto en VS Code.

## Datos de conexión

| Parámetro | Valor |
|---|---|
| Username | `autofix` |
| Password | `autofix123` |
| Hostname | `localhost` |
| Port | `1521` |
| Service | `xe` |

## Orden de ejecución de los scripts

Ejecutar **en este orden exacto** (cada script depende del anterior):

```sql
-- 1. Limpiar esquema anterior (reset completo)
@01_eliminar_tablas.sql

-- 2. Crear estructura
@02_secuencias.sql
@03_tablas.sql
@04_indices.sql
@05_vistas.sql

-- 3. Cargar datos de prueba
@06_inserts.sql

-- 4. Compilar procedimientos almacenados
@07_procedimientos.sql

-- 5. (Recomendado) Verificar que todo quedó consistente
@08_verificacion.sql
```

Si `08_verificacion.sql` termina con `VERIFICACION COMPLETA: todos los datos cuadran.`, la base quedó correctamente instalada.

## Flujo de trabajo con Git

1. `git pull` **siempre antes de empezar** a editar.
2. Commits con mensajes claros de qué se cambió.
3. `git push` al terminar cada sesión de trabajo.
4. Nunca hacer force push: el repositorio es compartido.
