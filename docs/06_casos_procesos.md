# Casos de Procesos

[← Volver al índice](../README.md)

`08_casos_procesos.sql` es la **demostración ejecutable** de los 16 procedimientos almacenados: cada caso indica el procedimiento, los datos con los que se prueba y el resultado esperado, imprimiendo todo por `DBMS_OUTPUT` para mostrar en clase que funcionan.

## Cómo ejecutarlo

```sql
SET SERVEROUTPUT ON
@08_casos_procesos.sql
```

Se puede ejecutar completo de una vez, o copiar cada caso por separado para explicarlo paso a paso.

## Tabla de casos

| # | Procedimiento | Datos de prueba | Resultado esperado |
|---|---|---|---|
| 1 | `sp_registrar_cliente` | Ana Quispe, 999222001, Jesús María | `CLIENTE REGISTRADO` + id nuevo |
| 2 | `sp_registrar_vehiculo` | Placa XYZ901, Toyota RAV4, cliente del caso 1 | `VEHICULO REGISTRADO` + id nuevo |
| 2b | " (error) | Cliente 999 (no existe) | `CLIENTE NO EXISTE` |
| 2c | " (error) | Placa ABC101 (ya registrada) | `PLACA DUPLICADA` |
| 3 | `sp_abrir_orden` | Vehículo nuevo + mecánico 4 (libre) + servicio 1 | `ORDEN ABIERTA` + id nuevo |
| 3b | " (error) | Mecánico 1 (ya tiene 3 órdenes abiertas: 7, 21, 22) | `MECANICO NO PUEDE TENER MAS DE 3 ORDENES ABIERTAS` |
| 4 | `sp_agregar_servicio` | Servicio 5 (Lavado, 50) a la orden nueva | `SERVICIO AGREGADO` |
| 4b | " (error) | Orden 1 (está CERRADA) | `ORDEN NO ESTA ABIERTA` |
| 5 | `sp_agregar_repuestos` | Repuesto 2 (Bujía, 15) x4 a la orden nueva | `REPUESTO AGREGADO`, stock baja en 4 |
| 5b | " (error) | Repuesto 17 (Alternador, stock 0) | `STOCK INSUFICIENTE` |
| 6 | `sp_calcular_orden` | La orden nueva (120 + 50 + 60) | Total = **230** |
| 6b | " (error) | Orden 9999 (no existe) | Devuelve **-1** |
| 7 | `sp_cerrar_orden` | La orden nueva | `ORDEN CERRADA`, total 230, fecha de hoy |
| 7b | " (error) | Cerrarla otra vez | `LA ORDEN YA ESTA CERRADA` |
| 8 | `sp_cierre_del_dia` | Fecha de hoy | Total ≥ 230 (incluye la orden del caso 7) |
| 8b | " | `TRUNC(SYSDATE)-10` (cerraron las órdenes 9 y 28) | Total = **1960** (1210 + 750) |
| 9 | `sp_validar_stock` | Repuesto 9 (Aceite sintético) x5 | `DISPONIBLE` |
| 9b | " | Repuesto 17 (Alternador, stock 0) x1 | `NO DISPONIBLE` |
| 9c | " (error) | Repuesto 999 | `REPUESTO NO EXISTE` |
| 10 | `sp_historial_vehiculo` | Vehículo 1 (Corolla ABC101) | 2 órdenes listadas (1 y 27) |
| 10b | " (error) | Vehículo 999 | Devuelve **-1** |
| 11 | `sp_listar_reposicion` | — (lee inventario) | 3 repuestos: Radiador, Alternador, Motor arranque |
| 12 | `sp_reporte_servicios_top` | Top 5 | Ranking por veces solicitado e ingresos |
| 13 | `sp_reporte_mecanicos` | — | 6 mecánicos con órdenes cerradas e ingresos |
| 14 | `sp_actualizar_precios` (error) | -150% | Devuelve **-1** (precios negativos) |
| 14b | " (error) | +300% | Devuelve **-2** (valor absurdo) |
| 14c | " | +5% | **15** filas actualizadas (luego se revierte) |
| 15 | `sp_clientes_frecuentes` | Mínimo 2 órdenes | Varios clientes; José Pérez encabeza con 4 |
| 16 | `sp_consumo_repuestos` | — | Suma de unidades consumidas en todas las órdenes |

## Por qué los datos garantizan cada caso

Los escenarios están **preparados a propósito** en `06_inserts.sql` (ver [Datos de prueba](05_datos_prueba.md)):

- El **mecánico 1** quedó con exactamente 3 órdenes abiertas → el límite de `sp_abrir_orden` siempre se dispara con él, y los mecánicos 4 y 5 (0 abiertas) siempre funcionan.
- El **Alternador (repuesto 17)** quedó con stock 0 → `STOCK INSUFICIENTE` y `NO DISPONIBLE` garantizados.
- Las **órdenes 9 y 28** cierran el mismo día → `sp_cierre_del_dia` demuestra que agrupa varias órdenes por `fecha_cierre`.
- El **vehículo 1** tiene 2 órdenes históricas → historial con datos.
- 3 repuestos bajo mínimo, clientes con 2-4 órdenes y facturas con saldo alimentan los reportes y las vistas.

## Notas para la exposición

- El script se puede volver a ejecutar: cada corrida crea un cliente/vehículo/orden nuevos y el caso 14 revierte los precios al terminar.
- Las 5 consultas del final (`SELECT * FROM v_...`) sirven para mostrar las vistas antes o después de la demo.
