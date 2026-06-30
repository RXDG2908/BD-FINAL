/* =========================================================
   DATOS DE PRUEBA
   Orden de insercion:
     1.  cargos         (sin dependencias)
     2.  clientes       (sin dependencias)
     3.  mecanicos      (depende de cargo)
     4.  servicios      (sin dependencias)
     5.  repuestos      (stock = valor INICIAL, antes de aplicar
                         compras ni ordenes; los UPDATEs al final
                         de este script dejan el stock consistente)
     6.  vehiculos      (depende de cliente)
     7.  proveedores    (sin dependencias)
     8.  compras        (depende de proveedor)
     9.  det_compra     (depende de compra y repuesto)
    10.  ordenes        (depende de vehiculo y mecanico)
    11.  det_servicio   (depende de orden y servicio)
    12.  det_repuesto   (depende de orden y repuesto)
    13.  facturas       (depende de orden)
    14.  pagos          (depende de factura)
    15.  citas          (depende de cliente y vehiculo)
    --  UPDATEs finales: ajustan stock aplicando compras y ordenes
   ========================================================= */

/* =========================================================
   CARGOS
   ========================================================= */

INSERT INTO cargo VALUES(seq_cargo.NEXTVAL,'Mecanico Junior','Mantenimiento basico y asistencia');
INSERT INTO cargo VALUES(seq_cargo.NEXTVAL,'Mecanico Senior','Reparaciones de media complejidad');
INSERT INTO cargo VALUES(seq_cargo.NEXTVAL,'Especialista',   'Diagnostico y reparacion avanzada');
INSERT INTO cargo VALUES(seq_cargo.NEXTVAL,'Jefe de Taller', 'Supervision y coordinacion del equipo');

/* =========================================================
   CLIENTES
   ========================================================= */

INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Jose',    'Perez',    '999111001','Lima');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Carlos',  'Rojas',    '999111002','Callao');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Luis',    'Diaz',     '999111003','Lima');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Pedro',   'Lopez',    '999111004','Surco');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Miguel',  'Vargas',   '999111005','San Miguel');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Jorge',   'Ramirez',  '999111006','Comas');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Andres',  'Castro',   '999111007','Ate');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Ricardo', 'Vega',     '999111008','La Molina');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Mario',   'Silva',    '999111009','SJL');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Daniel',  'Flores',   '999111010','Barranco');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Fernando','Gutierrez','999111011','Miraflores');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Kevin',   'Mendoza',  '999111012','Chorrillos');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Renato',  'Salas',    '999111013','Lince');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Bruno',   'Herrera',  '999111014','Brea');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Diego',   'Navarro',  '999111015','Callao');

/* =========================================================
   MECANICOS  (incluye id_cargo)
   Columnas: id_mecanico, nombres, especialidad, id_cargo
   ========================================================= */

INSERT INTO mecanico VALUES(seq_mecanico.NEXTVAL,'Miguel Torres','Motor',        3);
INSERT INTO mecanico VALUES(seq_mecanico.NEXTVAL,'Juan Ramos',   'Electricidad', 3);
INSERT INTO mecanico VALUES(seq_mecanico.NEXTVAL,'Carlos Pena',  'Frenos',       2);
INSERT INTO mecanico VALUES(seq_mecanico.NEXTVAL,'Luis Gomez',   'Suspension',   2);
INSERT INTO mecanico VALUES(seq_mecanico.NEXTVAL,'Pedro Ruiz',   'Pintura',      1);
INSERT INTO mecanico VALUES(seq_mecanico.NEXTVAL,'Andres Silva', 'Transmision',  4);

/* =========================================================
   SERVICIOS
   ========================================================= */

INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Cambio de aceite',          120);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Alineamiento',               80);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Balanceo',                   70);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Cambio de frenos',          250);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Lavado completo',            50);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Cambio de bateria',         300);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Revision electrica',        180);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Escaneo computarizado',     150);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Cambio de llantas',         400);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Pintura parcial',           500);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Pintura completa',         2500);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Cambio de amortiguadores',  600);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Afinamiento',               220);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Cambio de filtro aire',      90);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Diagnostico general',       130);

/* =========================================================
   REPUESTOS
   Columnas: id, nombre, precio_unitario, stock_INICIAL, stock_minimo

   IMPORTANTE: el stock aqui es el valor ANTES de registrar
   compras y ordenes. Al final de este script se ejecutan dos
   UPDATE que aplican las entradas (detalle_compra) y las
   salidas (detalle_repuesto), dejando el stock en su valor
   real actual.

   Stock final esperado despues de los UPDATEs:
   (valores marcados con * quedan por debajo del stock minimo)
    1 Filtro aceite       : 10 +10(compra) -2(uso) = 18
    2 Bujia               : 30 +20(compra) -4(uso) = 46
    3 Pastillas freno     :  7  +8(compra) -1(uso) = 14
    4 Disco freno         :  8  +0(compra) -2(uso) =  6
    5 Amortiguador        :  5  +5(compra) -1(uso) =  9
    6 Bateria             :  3  +4(compra) -1(uso) =  6
    7 Filtro aire         : 10 +15(compra) -2(uso) = 23
    8 Filtro gasolina     : 18  +0(compra) -1(uso) = 17
    9 Aceite sintetico    : 40  +0(compra) -3(uso) = 37
   10 Radiador            :  2  +0(compra) -1(uso) =  1  * min=2
   11 Faro delantero      : 12  +0(compra) -2(uso) = 10
   12 Parachoque          :  6  +0(compra) -1(uso) =  5
   13 Espejo lateral      : 14  +0(compra) -2(uso) = 12
   14 Llanta aro 16       :  9  +0(compra) -1(uso) =  8
   15 Llanta aro 17       :  7  +0(compra) -1(uso) =  6
   16 Correa distribucion : 11  +0(compra) -1(uso) = 10
   17 Alternador          :  1  +0(compra) -1(uso) =  0  * min=1
   18 Motor arranque      :  1  +0(compra) -1(uso) =  0  * min=1
   19 Sensor oxigeno      : 13  +0(compra) -2(uso) = 11
   20 Termostato          : 16  +0(compra) -3(uso) = 13
   21-25 sin movimiento: stock final = stock inicial
   ========================================================= */

INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Filtro aceite',       35,  10, 5);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Bujia',               15,  30,10);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Pastillas freno',    120,   7, 5);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Disco freno',        200,   8, 3);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Amortiguador',       350,   5, 2);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Bateria',            450,   3, 2);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Filtro aire',         40,  10, 5);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Filtro gasolina',     60,  18, 4);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Aceite sintetico',    90,  40,10);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Radiador',           700,   2, 2);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Faro delantero',     250,  12, 3);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Parachoque',         500,   6, 2);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Espejo lateral',     120,  14, 4);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Llanta aro 16',      420,   9, 3);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Llanta aro 17',      520,   7, 2);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Correa distribucion', 280, 11, 3);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Alternador',         650,   1, 1);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Motor arranque',     750,   1, 1);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Sensor oxigeno',     180,  13, 4);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Termostato',          95,  16, 5);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Compresora aire',    900,   2, 1);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Embrague',           850,   5, 2);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Timon hidraulico',  1200,   2, 1);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Manguera radiador',   70,  20, 5);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Liquido frenos',      45,  30, 8);

/* =========================================================
   VEHICULOS
   ========================================================= */

INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC101','Toyota',     'Corolla', 1);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC102','Kia',        'Rio',     1);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC103','Hyundai',    'Accent',  2);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC104','Nissan',     'Sentra',  2);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC105','Mazda',      '3',       3);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC106','Chevrolet',  'Spark',   4);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC107','Suzuki',     'Swift',   5);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC108','Toyota',     'Yaris',   6);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC109','Volkswagen', 'Gol',     7);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC110','Ford',       'Fiesta',  8);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC111','Toyota',     'Hilux',   9);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC112','Honda',      'Civic',   10);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC113','Kia',        'Cerato',  11);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC114','Mazda',      'CX5',     12);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC115','BMW',        'X3',      13);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC116','Audi',       'A4',      14);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC117','Mercedes',   'C200',    15);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC118','Renault',    'Logan',   3);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC119','Peugeot',    '208',     5);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC120','Jeep',       'Compass', 7);

/* =========================================================
   PROVEEDORES
   ========================================================= */

INSERT INTO proveedor VALUES(seq_proveedor.NEXTVAL,'Repuestos Lima',  '987654321','20123456789');
INSERT INTO proveedor VALUES(seq_proveedor.NEXTVAL,'AutoPartes Peru', '987654322','20234567890');
INSERT INTO proveedor VALUES(seq_proveedor.NEXTVAL,'MotorParts SAC',  '987654323','20345678901');

/* =========================================================
   COMPRAS  (ordenes de compra a proveedores)
   Columnas: id_compra, id_proveedor, fecha_compra, total
   total = suma de (cantidad * precio_unitario) del detalle
   ========================================================= */

-- Compra 1: Repuestos Lima  | Filtro aceite 10u + Bujia 20u = 650.00
INSERT INTO compra VALUES(seq_compra.NEXTVAL, 1, SYSDATE-30,   650.00);
-- Compra 2: AutoPartes Peru | Pastillas freno 8u + Amortiguador 5u = 2710.00
INSERT INTO compra VALUES(seq_compra.NEXTVAL, 2, SYSDATE-20,  2710.00);
-- Compra 3: Repuestos Lima  | Bateria 4u + Filtro aire 15u = 2400.00
INSERT INTO compra VALUES(seq_compra.NEXTVAL, 1, SYSDATE-10,  2400.00);

/* =========================================================
   DETALLE COMPRA
   Columnas: id_detalle, id_compra, id_repuesto, cantidad, precio_unitario
   ========================================================= */

-- Compra 1 | Filtro aceite (35) x 10 = 350  | Bujia (15) x 20 = 300
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 1,  1, 10,  35.00);
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 1,  2, 20,  15.00);

-- Compra 2 | Pastillas freno (120) x 8 = 960  | Amortiguador (350) x 5 = 1750
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 2,  3,  8, 120.00);
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 2,  5,  5, 350.00);

-- Compra 3 | Bateria (450) x 4 = 1800  | Filtro aire (40) x 15 = 600
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 3,  6,  4, 450.00);
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 3,  7, 15,  40.00);

/* =========================================================
   ORDENES DE SERVICIO
   Columnas: id_orden, id_vehiculo, id_mecanico,
             fecha_ingreso, fecha_cierre, estado
   ========================================================= */

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 1, 1, SYSDATE-20, SYSDATE-18,'CERRADA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 2, 2, SYSDATE-19, SYSDATE-17,'CERRADA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 3, 3, SYSDATE-18, SYSDATE-16,'CERRADA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 4, 4, SYSDATE-17, SYSDATE-15,'CERRADA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 5, 5, SYSDATE-16, SYSDATE-14,'CERRADA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 6, 6, SYSDATE-15, SYSDATE-13,'CERRADA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 7, 1, SYSDATE-14, NULL,       'ABIERTA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 8, 2, SYSDATE-13, NULL,       'ABIERTA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 9, 3, SYSDATE-12, SYSDATE-10,'CERRADA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,10, 4, SYSDATE-11, SYSDATE-9, 'CERRADA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,11, 5, SYSDATE-10, SYSDATE-8, 'CERRADA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,12, 6, SYSDATE-9,  NULL,       'ABIERTA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,13, 1, SYSDATE-8,  SYSDATE-6, 'CERRADA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,14, 2, SYSDATE-7,  SYSDATE-5, 'CERRADA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,15, 3, SYSDATE-6,  NULL,       'ABIERTA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,16, 4, SYSDATE-5,  SYSDATE-3, 'CERRADA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,17, 5, SYSDATE-4,  SYSDATE-2, 'CERRADA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,18, 6, SYSDATE-3,  NULL,       'ABIERTA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,19, 1, SYSDATE-2,  SYSDATE-1, 'CERRADA');

INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,20, 2, SYSDATE-1,  NULL,       'ABIERTA');

/* =========================================================
   DETALLE SERVICIO
   Columnas: id_detalle, id_orden, id_servicio, subtotal
   El subtotal = precio de catalogo al momento de la orden.
   ========================================================= */

INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 1, 1,  120);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 2, 2,   80);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 3, 3,   70);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 4, 4,  250);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 5, 5,   50);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 6, 6,  300);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 7, 7,  180);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 8, 8,  150);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 9, 9,  400);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,10,10,  500);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,11,11, 2500);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,12,12,  600);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,13,13,  220);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,14,14,   90);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,15,15,  130);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,16, 1,  120);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,17, 2,   80);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,18, 3,   70);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,19, 4,  250);
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,20, 5,   50);

/* =========================================================
   DETALLE REPUESTO
   Columnas: id_detalle, id_orden, id_repuesto, cantidad, subtotal
   Subtotal = precio_unitario * cantidad
   ========================================================= */

-- Orden  1 | Filtro aceite   ( 35) x 2 =   70
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 1,  1, 2,   70);
-- Orden  2 | Bujia           ( 15) x 4 =   60
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 2,  2, 4,   60);
-- Orden  3 | Pastillas freno (120) x 1 =  120
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 3,  3, 1,  120);
-- Orden  4 | Disco freno     (200) x 2 =  400
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 4,  4, 2,  400);
-- Orden  5 | Amortiguador    (350) x 1 =  350
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 5,  5, 1,  350);
-- Orden  6 | Bateria         (450) x 1 =  450
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 6,  6, 1,  450);
-- Orden  7 | Filtro aire     ( 40) x 2 =   80
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 7,  7, 2,   80);
-- Orden  8 | Filtro gasolina ( 60) x 1 =   60
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 8,  8, 1,   60);
-- Orden  9 | Aceite sint.    ( 90) x 3 =  270
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 9,  9, 3,  270);
-- Orden 10 | Radiador        (700) x 1 =  700
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,10, 10, 1,  700);
-- Orden 11 | Faro delantero  (250) x 2 =  500
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,11, 11, 2,  500);
-- Orden 12 | Parachoque      (500) x 1 =  500
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,12, 12, 1,  500);
-- Orden 13 | Espejo lateral  (120) x 2 =  240
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,13, 13, 2,  240);
-- Orden 14 | Llanta aro 16   (420) x 1 =  420
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,14, 14, 1,  420);
-- Orden 15 | Llanta aro 17   (520) x 1 =  520
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,15, 15, 1,  520);
-- Orden 16 | Correa dist.    (280) x 1 =  280
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,16, 16, 1,  280);
-- Orden 17 | Alternador      (650) x 1 =  650  (deja stock en 0, bajo el minimo)
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,17, 17, 1,  650);
-- Orden 18 | Motor arranque  (750) x 1 =  750  (deja stock en 0, bajo el minimo)
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,18, 18, 1,  750);
-- Orden 19 | Sensor oxigeno  (180) x 2 =  360
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,19, 19, 2,  360);
-- Orden 20 | Termostato      ( 95) x 3 =  285
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,20, 20, 3,  285);

/* =========================================================
   FACTURAS  (solo para ordenes CERRADAS)
   Columnas: id_factura, id_orden, numero_factura,
             fecha_emision, subtotal, igv (18%), total
   ========================================================= */

-- Orden 1:  120 + 70  = 190  | igv = 190*0.18 = 34.20  | total = 224.20
INSERT INTO factura VALUES(seq_factura.NEXTVAL, 1,'F001-00001',SYSDATE-18,  190.00,  34.20,  224.20);
-- Orden 2:   80 + 60  = 140  | igv = 25.20  | total = 165.20
INSERT INTO factura VALUES(seq_factura.NEXTVAL, 2,'F001-00002',SYSDATE-17,  140.00,  25.20,  165.20);
-- Orden 3:   70 + 120 = 190  | igv = 34.20  | total = 224.20
INSERT INTO factura VALUES(seq_factura.NEXTVAL, 3,'F001-00003',SYSDATE-16,  190.00,  34.20,  224.20);
-- Orden 4:  250 + 400 = 650  | igv = 117.00 | total = 767.00
INSERT INTO factura VALUES(seq_factura.NEXTVAL, 4,'F001-00004',SYSDATE-15,  650.00, 117.00,  767.00);
-- Orden 5:   50 + 350 = 400  | igv = 72.00  | total = 472.00
INSERT INTO factura VALUES(seq_factura.NEXTVAL, 5,'F001-00005',SYSDATE-14,  400.00,  72.00,  472.00);
-- Orden 6:  300 + 450 = 750  | igv = 135.00 | total = 885.00
INSERT INTO factura VALUES(seq_factura.NEXTVAL, 6,'F001-00006',SYSDATE-13,  750.00, 135.00,  885.00);
-- Orden 9:  400 + 270 = 670  | igv = 120.60 | total = 790.60
INSERT INTO factura VALUES(seq_factura.NEXTVAL, 9,'F001-00007',SYSDATE-10,  670.00, 120.60,  790.60);
-- Orden 10: 500 + 700 = 1200 | igv = 216.00 | total = 1416.00
INSERT INTO factura VALUES(seq_factura.NEXTVAL,10,'F001-00008',SYSDATE-9,  1200.00, 216.00, 1416.00);
-- Orden 11: 2500 + 500 = 3000| igv = 540.00 | total = 3540.00
INSERT INTO factura VALUES(seq_factura.NEXTVAL,11,'F001-00009',SYSDATE-8,  3000.00, 540.00, 3540.00);
-- Orden 13: 220 + 240 = 460  | igv = 82.80  | total = 542.80
INSERT INTO factura VALUES(seq_factura.NEXTVAL,13,'F001-00010',SYSDATE-6,   460.00,  82.80,  542.80);

/* =========================================================
   PAGOS
   Columnas: id_pago, id_factura, fecha_pago, monto, metodo_pago

   Escenarios demostrados:
   - Facturas 1,2,3,5,6,7,8 : pago unico = total factura (saldadas)
   - Factura 4              : dos cuotas que suman el total (saldada en dos pagos)
   - Factura 9              : pago parcial (saldo pendiente de 1540.00)
   - Factura 10             : sin ningun pago (saldo pendiente de 542.80)

   v_facturas_por_cobrar devuelve las facturas 9 y 10.
   ========================================================= */

INSERT INTO pago VALUES(seq_pago.NEXTVAL, 1, SYSDATE-18,  224.20,'EFECTIVO');
INSERT INTO pago VALUES(seq_pago.NEXTVAL, 2, SYSDATE-17,  165.20,'TARJETA');
INSERT INTO pago VALUES(seq_pago.NEXTVAL, 3, SYSDATE-16,  224.20,'EFECTIVO');
INSERT INTO pago VALUES(seq_pago.NEXTVAL, 4, SYSDATE-15,  400.00,'TARJETA');       -- primera cuota
INSERT INTO pago VALUES(seq_pago.NEXTVAL, 4, SYSDATE-14,  367.00,'EFECTIVO');      -- segunda cuota (total cubierto: 767.00)
INSERT INTO pago VALUES(seq_pago.NEXTVAL, 5, SYSDATE-14,  472.00,'TRANSFERENCIA');
INSERT INTO pago VALUES(seq_pago.NEXTVAL, 6, SYSDATE-13,  885.00,'TARJETA');
INSERT INTO pago VALUES(seq_pago.NEXTVAL, 7, SYSDATE-10,  790.60,'EFECTIVO');
INSERT INTO pago VALUES(seq_pago.NEXTVAL, 8, SYSDATE-9,  1416.00,'TARJETA');
INSERT INTO pago VALUES(seq_pago.NEXTVAL, 9, SYSDATE-8,  2000.00,'TRANSFERENCIA'); -- pago parcial; saldo = 1540.00
-- Factura 10: sin registro de pago (saldo pendiente = 542.80)

/* =========================================================
   CITAS  (agenda de turnos)
   Columnas: id_cita, id_cliente, id_vehiculo,
             fecha_cita, motivo, estado
   Restriccion: el vehiculo debe pertenecer al cliente indicado.
   ========================================================= */

-- cliente 1 (Jose Perez)    -> vehiculo 1 (Toyota Corolla ABC101) ✓
INSERT INTO cita VALUES(seq_cita.NEXTVAL, 1,  1, SYSDATE+1,'Cambio de aceite',   'CONFIRMADA');
-- cliente 2 (Carlos Rojas)  -> vehiculo 3 (Hyundai Accent ABC103) ✓
INSERT INTO cita VALUES(seq_cita.NEXTVAL, 2,  3, SYSDATE+2,'Revision de frenos', 'PENDIENTE');
-- cliente 3 (Luis Diaz)     -> vehiculo 5 (Mazda 3 ABC105) ✓
INSERT INTO cita VALUES(seq_cita.NEXTVAL, 3,  5, SYSDATE+3,'Alineamiento',       'CONFIRMADA');
-- cliente 4 (Pedro Lopez)   -> vehiculo 6 (Chevrolet Spark ABC106) ✓
INSERT INTO cita VALUES(seq_cita.NEXTVAL, 4,  6, SYSDATE+1,'Diagnostico general','PENDIENTE');
-- cliente 5 (Miguel Vargas) -> vehiculo 7 (Suzuki Swift ABC107) ✓
INSERT INTO cita VALUES(seq_cita.NEXTVAL, 5,  7, SYSDATE+5,'Cambio de llantas',  'CONFIRMADA');
-- cliente 6 (Jorge Ramirez) -> vehiculo 8 (Toyota Yaris ABC108) ✓
INSERT INTO cita VALUES(seq_cita.NEXTVAL, 6,  8, SYSDATE-1,'Escaneo general',    'CANCELADA');

/* =========================================================
   AJUSTE FINAL DE STOCK
   Se aplican las transacciones registradas anteriormente para
   que repuesto.stock refleje el inventario real actual:
     stock_final = stock_inicial + entradas(compras) - salidas(ordenes)
   ========================================================= */

-- Sumar cantidades recibidas de proveedores
UPDATE repuesto r
SET    stock = stock + (
    SELECT NVL(SUM(dc.cantidad), 0)
    FROM   detalle_compra dc
    WHERE  dc.id_repuesto = r.id_repuesto
);

-- Restar cantidades consumidas en ordenes de servicio
UPDATE repuesto r
SET    stock = stock - (
    SELECT NVL(SUM(dr.cantidad), 0)
    FROM   detalle_repuesto dr
    WHERE  dr.id_repuesto = r.id_repuesto
);

COMMIT;
