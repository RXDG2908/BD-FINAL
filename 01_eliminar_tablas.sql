/* =========================================================
   PROYECTO: SISTEMA DE GESTION DE TALLER MECANICO AUTOFIX
   MOTOR: ORACLE SQL DEVELOPER
   ========================================================= */

/* =========================================================
   ELIMINAR TABLAS
   Se eliminan en orden inverso al de creación para respetar
   las restricciones de clave foránea.
   ========================================================= */

BEGIN EXECUTE IMMEDIATE 'DROP TABLE detalle_repuesto  CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE detalle_servicio  CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE orden_servicio    CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE repuesto          CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE servicio          CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE vehiculo          CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE mecanico          CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE cliente           CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

/* =========================================================
   ELIMINAR SECUENCIAS
   Al eliminarlas junto con las tablas, la siguiente
   ejecución del setup reinicia los IDs desde 1, evitando
   desincronización con los datos de prueba del script 06.
   ========================================================= */

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_cliente';           EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_vehiculo';          EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_mecanico';          EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_servicio';          EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_repuesto';          EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_orden';             EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_detalle_servicio';  EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_detalle_repuesto';  EXCEPTION WHEN OTHERS THEN NULL; END;
/
