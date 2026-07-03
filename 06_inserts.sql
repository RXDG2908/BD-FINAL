/* =========================================================
   DATOS DE PRUEBA  -  Sistema AUTOFIX
   (archivo generado con verificacion aritmetica completa:
    subtotales, IGV, totales de compra y stock cuadran entre si)

   Orden de insercion (respeta las dependencias FK):
     1.  cargos          (sin dependencias)
     2.  clientes        (sin dependencias)
     3.  mecanicos       (depende de cargo)
     4.  servicios       (sin dependencias)
     5.  repuestos       (stock = valor INICIAL; los UPDATE
                          finales aplican compras y consumos)
     6.  vehiculos       (depende de cliente)
     7.  proveedores     (sin dependencias)
     8.  compras         (depende de proveedor)
     9.  detalle_compra  (depende de compra y repuesto)
    10.  ordenes         (depende de vehiculo y mecanico)
    11.  detalle_servicio(depende de orden y servicio)
    12.  detalle_repuesto(depende de orden y repuesto)
    13.  facturas        (depende de orden; solo CERRADAS)
    14.  pagos           (depende de factura)
    15.  citas           (depende de cliente y vehiculo)

   Escenarios cubiertos para los procedimientos y vistas:
    - 30 ordenes: 22 CERRADAS (todas con factura) y 8 ABIERTAS
    - Mecanico 1 con 3 ordenes ABIERTAS -> sp_abrir_orden con el
      mecanico 1 devuelve el error del limite (caso de prueba)
    - 3 repuestos bajo stock minimo -> sp_listar_reposicion /
      v_repuestos_stock_bajo devuelven filas
    - Facturas: pago unico, pago en 2 cuotas (orden 4), pago
      parcial (ordenes 11 y 29) y sin pago (orden 10)
      -> v_facturas_por_cobrar devuelve 3 facturas
    - Ordenes 9 y 28 cierran el mismo dia -> sp_cierre_del_dia
      agrupa mas de una orden en la misma fecha
    - Varios clientes con 2+ ordenes -> v_clientes_frecuentes /
      sp_clientes_frecuentes devuelven filas
    - Citas PENDIENTE/CONFIRMADA futuras -> v_citas_pendientes
   ========================================================= */

/* =========================================================
   CARGOS
   ========================================================= */

INSERT INTO cargo VALUES(seq_cargo.NEXTVAL,'Mecanico Junior','Mantenimiento basico y asistencia');
INSERT INTO cargo VALUES(seq_cargo.NEXTVAL,'Mecanico Senior','Reparaciones de media complejidad');
INSERT INTO cargo VALUES(seq_cargo.NEXTVAL,'Especialista','Diagnostico y reparacion avanzada');
INSERT INTO cargo VALUES(seq_cargo.NEXTVAL,'Jefe de Taller','Supervision y coordinacion del equipo');

/* =========================================================
   CLIENTES
   ========================================================= */

INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Jose','Perez','999111001','Lima');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Carlos','Rojas','999111002','Callao');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Luis','Diaz','999111003','Lima');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Pedro','Lopez','999111004','Surco');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Miguel','Vargas','999111005','San Miguel');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Jorge','Ramirez','999111006','Comas');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Andres','Castro','999111007','Ate');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Ricardo','Vega','999111008','La Molina');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Mario','Silva','999111009','SJL');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Daniel','Flores','999111010','Barranco');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Fernando','Gutierrez','999111011','Miraflores');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Kevin','Mendoza','999111012','Chorrillos');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Renato','Salas','999111013','Lince');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Bruno','Herrera','999111014','Brena');
INSERT INTO cliente VALUES(seq_cliente.NEXTVAL,'Diego','Navarro','999111015','Callao');

/* =========================================================
   MECANICOS  (id_mecanico, nombres, especialidad, id_cargo)
   ========================================================= */

INSERT INTO mecanico VALUES(seq_mecanico.NEXTVAL,'Miguel Torres','Motor',3);
INSERT INTO mecanico VALUES(seq_mecanico.NEXTVAL,'Juan Ramos','Electricidad',3);
INSERT INTO mecanico VALUES(seq_mecanico.NEXTVAL,'Carlos Pena','Frenos',2);
INSERT INTO mecanico VALUES(seq_mecanico.NEXTVAL,'Luis Gomez','Suspension',2);
INSERT INTO mecanico VALUES(seq_mecanico.NEXTVAL,'Pedro Ruiz','Pintura',1);
INSERT INTO mecanico VALUES(seq_mecanico.NEXTVAL,'Andres Silva','Transmision',4);

/* =========================================================
   SERVICIOS  (catalogo con precio de lista)
   ========================================================= */

INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Cambio de aceite',120);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Alineamiento',80);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Balanceo',70);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Cambio de frenos',250);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Lavado completo',50);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Cambio de bateria',300);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Revision electrica',180);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Escaneo computarizado',150);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Cambio de llantas',400);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Pintura parcial',500);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Pintura completa',2500);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Cambio de amortiguadores',600);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Afinamiento',220);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Cambio de filtro aire',90);
INSERT INTO servicio VALUES(seq_servicio.NEXTVAL,'Diagnostico general',130);

/* =========================================================
   REPUESTOS  (id, nombre, precio, stock_INICIAL, stock_minimo)

   IMPORTANTE: el stock aqui es el valor ANTES de registrar
   compras y ordenes. Los dos UPDATE del final del script
   aplican entradas (detalle_compra) y salidas (detalle_repuesto)
   dejando el stock en su valor real.

   Stock final esperado (inicial + compras - consumos):
   (* = queda por debajo del stock minimo, escenario de reposicion)
    1 Filtro aceite       :  10 +10 - 5 =  15  (min 5)
    2 Bujia               :  30 +50 - 6 =  74  (min 10)
    3 Pastillas freno     :   7 + 8 - 4 =  11  (min 5)
    4 Disco freno         :   8 + 5 - 4 =   9  (min 3)
    5 Amortiguador        :   5 + 5 - 4 =   6  (min 2)
    6 Bateria             :   3 + 4 - 3 =   4  (min 2)
    7 Filtro aire         :  10 +15 - 2 =  23  (min 5)
    8 Filtro gasolina     :  18 + 0 - 1 =  17  (min 4)
    9 Aceite sintetico    :  40 +20 - 6 =  54  (min 10)
   10 Radiador            :   2 + 0 - 1 =   1  (min 2)  *
   11 Faro delantero      :  12 + 0 - 3 =   9  (min 3)
   12 Parachoque          :   6 + 0 - 1 =   5  (min 2)
   13 Espejo lateral      :  14 + 0 - 2 =  12  (min 4)
   14 Llanta aro 16       :   9 + 4 - 3 =  10  (min 3)
   15 Llanta aro 17       :   7 + 0 - 3 =   4  (min 2)
   16 Correa distribucion :  11 + 0 - 1 =  10  (min 3)
   17 Alternador          :   1 + 0 - 1 =   0  (min 1)  *
   18 Motor arranque      :   1 + 0 - 1 =   0  (min 1)  *
   19 Sensor oxigeno      :  13 + 6 - 2 =  17  (min 4)
   20 Termostato          :  16 +10 - 4 =  22  (min 5)
   21 Compresora aire     :   2 + 0 - 0 =   2  (min 1)
   22 Embrague            :   5 + 0 - 0 =   5  (min 2)
   23 Timon hidraulico    :   2 + 0 - 0 =   2  (min 1)
   24 Manguera radiador   :  20 +10 - 1 =  29  (min 5)
   25 Liquido frenos      :  30 +10 - 3 =  37  (min 8)
   ========================================================= */

INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Filtro aceite',   35,  10,  5);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Bujia',   15,  30, 10);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Pastillas freno',  120,   7,  5);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Disco freno',  200,   8,  3);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Amortiguador',  350,   5,  2);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Bateria',  450,   3,  2);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Filtro aire',   40,  10,  5);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Filtro gasolina',   60,  18,  4);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Aceite sintetico',   90,  40, 10);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Radiador',  700,   2,  2);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Faro delantero',  250,  12,  3);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Parachoque',  500,   6,  2);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Espejo lateral',  120,  14,  4);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Llanta aro 16',  420,   9,  3);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Llanta aro 17',  520,   7,  2);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Correa distribucion',  280,  11,  3);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Alternador',  650,   1,  1);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Motor arranque',  750,   1,  1);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Sensor oxigeno',  180,  13,  4);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Termostato',   95,  16,  5);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Compresora aire',  900,   2,  1);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Embrague',  850,   5,  2);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Timon hidraulico', 1200,   2,  1);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Manguera radiador',   70,  20,  5);
INSERT INTO repuesto VALUES(seq_repuesto.NEXTVAL,'Liquido frenos',   45,  30,  8);

/* =========================================================
   VEHICULOS  (placa UNIQUE, cada uno pertenece a un cliente)
   ========================================================= */

INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC101','Toyota','Corolla', 1);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC102','Kia','Rio', 1);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC103','Hyundai','Accent', 2);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC104','Nissan','Sentra', 2);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC105','Mazda','3', 3);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC106','Chevrolet','Spark', 4);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC107','Suzuki','Swift', 5);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC108','Toyota','Yaris', 6);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC109','Volkswagen','Gol', 7);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC110','Ford','Fiesta', 8);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC111','Toyota','Hilux', 9);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC112','Honda','Civic',10);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC113','Kia','Cerato',11);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC114','Mazda','CX5',12);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC115','BMW','X3',13);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC116','Audi','A4',14);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC117','Mercedes','C200',15);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC118','Renault','Logan', 3);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC119','Peugeot','208', 5);
INSERT INTO vehiculo VALUES(seq_vehiculo.NEXTVAL,'ABC120','Jeep','Compass', 7);

/* =========================================================
   PROVEEDORES
   ========================================================= */

INSERT INTO proveedor VALUES(seq_proveedor.NEXTVAL,'Repuestos Lima','987654321','20123456789');
INSERT INTO proveedor VALUES(seq_proveedor.NEXTVAL,'AutoPartes Peru','987654322','20234567890');
INSERT INTO proveedor VALUES(seq_proveedor.NEXTVAL,'MotorParts SAC','987654323','20345678901');
INSERT INTO proveedor VALUES(seq_proveedor.NEXTVAL,'Importaciones Torque','987654324','20456789012');
INSERT INTO proveedor VALUES(seq_proveedor.NEXTVAL,'Distribuidora El Piston','987654325','20567890123');

/* =========================================================
   COMPRAS  (total = suma exacta de su detalle_compra)
   ========================================================= */

-- Compra 1: Repuestos Lima | Filtro aceite x10 + Bujia x20 = 650.00
INSERT INTO compra VALUES(seq_compra.NEXTVAL, 1, SYSDATE-30, 650.00);
-- Compra 2: AutoPartes Peru | Pastillas freno x8 + Amortiguador x5 = 2710.00
INSERT INTO compra VALUES(seq_compra.NEXTVAL, 2, SYSDATE-20, 2710.00);
-- Compra 3: Repuestos Lima | Bateria x4 + Filtro aire x15 = 2400.00
INSERT INTO compra VALUES(seq_compra.NEXTVAL, 1, SYSDATE-10, 2400.00);
-- Compra 4: MotorParts SAC | Disco freno x5 + Llanta aro 16 x4 + Sensor oxigeno x6 = 3760.00
INSERT INTO compra VALUES(seq_compra.NEXTVAL, 3, SYSDATE-7, 3760.00);
-- Compra 5: Importaciones Torque | Aceite sintetico x20 + Liquido frenos x10 + Manguera radiador x10 = 2950.00
INSERT INTO compra VALUES(seq_compra.NEXTVAL, 4, SYSDATE-4, 2950.00);
-- Compra 6: Distribuidora El Piston | Bujia x30 + Termostato x10 = 1400.00
INSERT INTO compra VALUES(seq_compra.NEXTVAL, 5, SYSDATE-2, 1400.00);

/* =========================================================
   DETALLE COMPRA  (id, id_compra, id_repuesto, cantidad, precio_unitario)
   ========================================================= */

INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 1,  1, 10,   35.00);  -- Filtro aceite x10 = 350.00
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 1,  2, 20,   15.00);  -- Bujia x20 = 300.00
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 2,  3,  8,  120.00);  -- Pastillas freno x8 = 960.00
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 2,  5,  5,  350.00);  -- Amortiguador x5 = 1750.00
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 3,  6,  4,  450.00);  -- Bateria x4 = 1800.00
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 3,  7, 15,   40.00);  -- Filtro aire x15 = 600.00
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 4,  4,  5,  200.00);  -- Disco freno x5 = 1000.00
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 4, 14,  4,  420.00);  -- Llanta aro 16 x4 = 1680.00
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 4, 19,  6,  180.00);  -- Sensor oxigeno x6 = 1080.00
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 5,  9, 20,   90.00);  -- Aceite sintetico x20 = 1800.00
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 5, 25, 10,   45.00);  -- Liquido frenos x10 = 450.00
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 5, 24, 10,   70.00);  -- Manguera radiador x10 = 700.00
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 6,  2, 30,   15.00);  -- Bujia x30 = 450.00
INSERT INTO detalle_compra VALUES(seq_detalle_compra.NEXTVAL, 6, 20, 10,   95.00);  -- Termostato x10 = 950.00

/* =========================================================
   ORDENES DE SERVICIO
   22 CERRADAS (con fecha_cierre y factura) / 8 ABIERTAS
   Ordenes abiertas por mecanico: m1=3, m2=2, m3=1, m6=2
   -> el mecanico 1 esta en el limite de 3 ordenes abiertas
   ========================================================= */

-- Orden  1 | vehiculo  1 (ABC101) | mecanico 1 (Miguel Torres) | CERRADA  | total 190.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 1, 1, SYSDATE-20, SYSDATE-18,'CERRADA');

-- Orden  2 | vehiculo  2 (ABC102) | mecanico 2 (Juan Ramos) | CERRADA  | total 210.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 2, 2, SYSDATE-19, SYSDATE-17,'CERRADA');

-- Orden  3 | vehiculo  3 (ABC103) | mecanico 3 (Carlos Pena) | CERRADA  | total 770.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 3, 3, SYSDATE-18, SYSDATE-16,'CERRADA');

-- Orden  4 | vehiculo  4 (ABC104) | mecanico 4 (Luis Gomez) | CERRADA  | total 870.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 4, 4, SYSDATE-17, SYSDATE-15,'CERRADA');

-- Orden  5 | vehiculo  5 (ABC105) | mecanico 5 (Pedro Ruiz) | CERRADA  | total 550.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 5, 5, SYSDATE-16, SYSDATE-14,'CERRADA');

-- Orden  6 | vehiculo  6 (ABC106) | mecanico 6 (Andres Silva) | CERRADA  | total 750.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 6, 6, SYSDATE-15, SYSDATE-13,'CERRADA');

-- Orden  7 | vehiculo  7 (ABC107) | mecanico 1 (Miguel Torres) | ABIERTA  | trabajo en curso: 260.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 7, 1, SYSDATE-14, NULL,       'ABIERTA');

-- Orden  8 | vehiculo  8 (ABC108) | mecanico 2 (Juan Ramos) | ABIERTA  | trabajo en curso: 210.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 8, 2, SYSDATE-13, NULL,       'ABIERTA');

-- Orden  9 | vehiculo  9 (ABC109) | mecanico 3 (Carlos Pena) | CERRADA  | total 1210.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 9, 3, SYSDATE-12, SYSDATE-10,'CERRADA');

-- Orden 10 | vehiculo 10 (ABC110) | mecanico 4 (Luis Gomez) | CERRADA  | total 900.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,10, 4, SYSDATE-11, SYSDATE-9 ,'CERRADA');

-- Orden 11 | vehiculo 11 (ABC111) | mecanico 5 (Pedro Ruiz) | CERRADA  | total 3500.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,11, 5, SYSDATE-10, SYSDATE-8 ,'CERRADA');

-- Orden 12 | vehiculo 12 (ABC112) | mecanico 6 (Andres Silva) | ABIERTA  | trabajo en curso: 1300.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,12, 6, SYSDATE-9 , NULL,       'ABIERTA');

-- Orden 13 | vehiculo 13 (ABC113) | mecanico 1 (Miguel Torres) | CERRADA  | total 580.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,13, 1, SYSDATE-8 , SYSDATE-6 ,'CERRADA');

-- Orden 14 | vehiculo 14 (ABC114) | mecanico 2 (Juan Ramos) | CERRADA  | total 1240.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,14, 2, SYSDATE-7 , SYSDATE-5 ,'CERRADA');

-- Orden 15 | vehiculo 15 (ABC115) | mecanico 3 (Carlos Pena) | ABIERTA  | trabajo en curso: 650.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,15, 3, SYSDATE-6 , NULL,       'ABIERTA');

-- Orden 16 | vehiculo 16 (ABC116) | mecanico 4 (Luis Gomez) | CERRADA  | total 595.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,16, 4, SYSDATE-5 , SYSDATE-3 ,'CERRADA');

-- Orden 17 | vehiculo 17 (ABC117) | mecanico 5 (Pedro Ruiz) | CERRADA  | total 830.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,17, 5, SYSDATE-4 , SYSDATE-2 ,'CERRADA');

-- Orden 18 | vehiculo 18 (ABC118) | mecanico 6 (Andres Silva) | ABIERTA  | trabajo en curso: 880.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,18, 6, SYSDATE-3 , NULL,       'ABIERTA');

-- Orden 19 | vehiculo 19 (ABC119) | mecanico 1 (Miguel Torres) | CERRADA  | total 730.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,19, 1, SYSDATE-2 , SYSDATE-1 ,'CERRADA');

-- Orden 20 | vehiculo 20 (ABC120) | mecanico 2 (Juan Ramos) | ABIERTA  | trabajo en curso: 335.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,20, 2, SYSDATE-1 , NULL,       'ABIERTA');

-- Orden 21 | vehiculo  4 (ABC104) | mecanico 1 (Miguel Torres) | ABIERTA  | trabajo en curso: 130.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 4, 1, SYSDATE-2 , NULL,       'ABIERTA');

-- Orden 22 | vehiculo  6 (ABC106) | mecanico 1 (Miguel Torres) | ABIERTA  | trabajo en curso: 150.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 6, 1, SYSDATE-1 , NULL,       'ABIERTA');

-- Orden 23 | vehiculo  2 (ABC102) | mecanico 4 (Luis Gomez) | CERRADA  | total 335.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 2, 4, SYSDATE-25, SYSDATE-24,'CERRADA');

-- Orden 24 | vehiculo  5 (ABC105) | mecanico 5 (Pedro Ruiz) | CERRADA  | total 1200.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 5, 5, SYSDATE-24, SYSDATE-22,'CERRADA');

-- Orden 25 | vehiculo  9 (ABC109) | mecanico 3 (Carlos Pena) | CERRADA  | total 150.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 9, 3, SYSDATE-22, SYSDATE-21,'CERRADA');

-- Orden 26 | vehiculo 12 (ABC112) | mecanico 4 (Luis Gomez) | CERRADA  | total 535.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,12, 4, SYSDATE-21, SYSDATE-20,'CERRADA');

-- Orden 27 | vehiculo  1 (ABC101) | mecanico 5 (Pedro Ruiz) | CERRADA  | total 370.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 1, 5, SYSDATE-12, SYSDATE-11,'CERRADA');

-- Orden 28 | vehiculo  3 (ABC103) | mecanico 6 (Andres Silva) | CERRADA  | total 750.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL, 3, 6, SYSDATE-11, SYSDATE-10,'CERRADA');

-- Orden 29 | vehiculo 10 (ABC110) | mecanico 2 (Juan Ramos) | CERRADA  | total 1300.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,10, 2, SYSDATE-6 , SYSDATE-5 ,'CERRADA');

-- Orden 30 | vehiculo 11 (ABC111) | mecanico 3 (Carlos Pena) | CERRADA  | total 1440.00
INSERT INTO orden_servicio(id_orden,id_vehiculo,id_mecanico,fecha_ingreso,fecha_cierre,estado)
VALUES(seq_orden.NEXTVAL,11, 3, SYSDATE-5 , SYSDATE-4 ,'CERRADA');

/* =========================================================
   DETALLE SERVICIO  (id, id_orden, id_servicio, subtotal)
   subtotal = precio de catalogo al momento de la orden
   Varias ordenes tienen 2+ servicios (ordenes multi-linea)
   ========================================================= */

INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 1, 1,  120);  -- Cambio de aceite
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 2, 2,   80);  -- Alineamiento
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 2, 3,   70);  -- Balanceo
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 3, 4,  250);  -- Cambio de frenos
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 4, 4,  250);  -- Cambio de frenos
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 4,15,  130);  -- Diagnostico general
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 5, 5,   50);  -- Lavado completo
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 5,10,  500);  -- Pintura parcial
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 6, 6,  300);  -- Cambio de bateria
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 7, 7,  180);  -- Revision electrica
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 8, 8,  150);  -- Escaneo computarizado
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 9, 9,  400);  -- Cambio de llantas
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL, 9, 1,  120);  -- Cambio de aceite
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,10,15,  130);  -- Diagnostico general
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,11,11, 2500);  -- Pintura completa
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,12,12,  600);  -- Cambio de amortiguadores
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,13,13,  220);  -- Afinamiento
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,13,14,   90);  -- Cambio de filtro aire
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,14, 9,  400);  -- Cambio de llantas
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,15,15,  130);  -- Diagnostico general
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,16,13,  220);  -- Afinamiento
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,17, 7,  180);  -- Revision electrica
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,18,15,  130);  -- Diagnostico general
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,19, 4,  250);  -- Cambio de frenos
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,20, 5,   50);  -- Lavado completo
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,21,15,  130);  -- Diagnostico general
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,22, 8,  150);  -- Escaneo computarizado
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,23, 1,  120);  -- Cambio de aceite
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,23,14,   90);  -- Cambio de filtro aire
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,24, 6,  300);  -- Cambio de bateria
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,25, 2,   80);  -- Alineamiento
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,25, 3,   70);  -- Balanceo
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,26, 4,  250);  -- Cambio de frenos
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,27, 1,  120);  -- Cambio de aceite
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,28,10,  500);  -- Pintura parcial
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,29,12,  600);  -- Cambio de amortiguadores
INSERT INTO detalle_servicio VALUES(seq_detalle_servicio.NEXTVAL,30, 9,  400);  -- Cambio de llantas

/* =========================================================
   DETALLE REPUESTO  (id, id_orden, id_repuesto, cantidad, subtotal)
   subtotal = precio_unitario x cantidad (precio historico)
   ========================================================= */

INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 1,  1, 2,   70.00);  -- Filtro aceite (35) x2
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 2,  2, 4,   60.00);  -- Bujia (15) x4
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 3,  3, 1,  120.00);  -- Pastillas freno (120) x1
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 3,  4, 2,  400.00);  -- Disco freno (200) x2
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 4,  4, 2,  400.00);  -- Disco freno (200) x2
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 4, 25, 2,   90.00);  -- Liquido frenos (45) x2
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 6,  6, 1,  450.00);  -- Bateria (450) x1
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 7,  7, 2,   80.00);  -- Filtro aire (40) x2
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 8,  8, 1,   60.00);  -- Filtro gasolina (60) x1
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 9,  9, 3,  270.00);  -- Aceite sintetico (90) x3
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL, 9, 14, 1,  420.00);  -- Llanta aro 16 (420) x1
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,10, 10, 1,  700.00);  -- Radiador (700) x1
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,10, 24, 1,   70.00);  -- Manguera radiador (70) x1
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,11, 11, 2,  500.00);  -- Faro delantero (250) x2
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,11, 12, 1,  500.00);  -- Parachoque (500) x1
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,12,  5, 2,  700.00);  -- Amortiguador (350) x2
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,13, 13, 2,  240.00);  -- Espejo lateral (120) x2
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,13,  2, 2,   30.00);  -- Bujia (15) x2
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,14, 14, 2,  840.00);  -- Llanta aro 16 (420) x2
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,15, 15, 1,  520.00);  -- Llanta aro 17 (520) x1
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,16, 16, 1,  280.00);  -- Correa distribucion (280) x1
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,16, 20, 1,   95.00);  -- Termostato (95) x1
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,17, 17, 1,  650.00);  -- Alternador (650) x1
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,18, 18, 1,  750.00);  -- Motor arranque (750) x1
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,19, 19, 2,  360.00);  -- Sensor oxigeno (180) x2
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,19,  3, 1,  120.00);  -- Pastillas freno (120) x1
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,20, 20, 3,  285.00);  -- Termostato (95) x3
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,23,  1, 1,   35.00);  -- Filtro aceite (35) x1
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,23,  9, 1,   90.00);  -- Aceite sintetico (90) x1
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,24,  6, 2,  900.00);  -- Bateria (450) x2
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,26,  3, 2,  240.00);  -- Pastillas freno (120) x2
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,26, 25, 1,   45.00);  -- Liquido frenos (45) x1
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,27,  1, 2,   70.00);  -- Filtro aceite (35) x2
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,27,  9, 2,  180.00);  -- Aceite sintetico (90) x2
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,28, 11, 1,  250.00);  -- Faro delantero (250) x1
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,29,  5, 2,  700.00);  -- Amortiguador (350) x2
INSERT INTO detalle_repuesto VALUES(seq_detalle_repuesto.NEXTVAL,30, 15, 2, 1040.00);  -- Llanta aro 17 (520) x2

/* =========================================================
   FACTURAS  (una por cada orden CERRADA, ninguna orden
   cerrada queda sin facturar)
   subtotal = servicios + repuestos de la orden
   igv = subtotal x 18% | total = subtotal + igv
   Numeradas F001-xxxxx en orden cronologico de emision.
   ========================================================= */

-- Orden 23: serv 210.00 + rep 125.00 = 335.00 | igv 60.30 | total 395.30
INSERT INTO factura VALUES(seq_factura.NEXTVAL,23,'F001-00001',SYSDATE-24,  335.00,   60.30,   395.30);
-- Orden 24: serv 300.00 + rep 900.00 = 1200.00 | igv 216.00 | total 1416.00
INSERT INTO factura VALUES(seq_factura.NEXTVAL,24,'F001-00002',SYSDATE-22, 1200.00,  216.00,  1416.00);
-- Orden 25: serv 150.00 + rep 0.00 = 150.00 | igv 27.00 | total 177.00
INSERT INTO factura VALUES(seq_factura.NEXTVAL,25,'F001-00003',SYSDATE-21,  150.00,   27.00,   177.00);
-- Orden 26: serv 250.00 + rep 285.00 = 535.00 | igv 96.30 | total 631.30
INSERT INTO factura VALUES(seq_factura.NEXTVAL,26,'F001-00004',SYSDATE-20,  535.00,   96.30,   631.30);
-- Orden  1: serv 120.00 + rep 70.00 = 190.00 | igv 34.20 | total 224.20
INSERT INTO factura VALUES(seq_factura.NEXTVAL, 1,'F001-00005',SYSDATE-18,  190.00,   34.20,   224.20);
-- Orden  2: serv 150.00 + rep 60.00 = 210.00 | igv 37.80 | total 247.80
INSERT INTO factura VALUES(seq_factura.NEXTVAL, 2,'F001-00006',SYSDATE-17,  210.00,   37.80,   247.80);
-- Orden  3: serv 250.00 + rep 520.00 = 770.00 | igv 138.60 | total 908.60
INSERT INTO factura VALUES(seq_factura.NEXTVAL, 3,'F001-00007',SYSDATE-16,  770.00,  138.60,   908.60);
-- Orden  4: serv 380.00 + rep 490.00 = 870.00 | igv 156.60 | total 1026.60
INSERT INTO factura VALUES(seq_factura.NEXTVAL, 4,'F001-00008',SYSDATE-15,  870.00,  156.60,  1026.60);
-- Orden  5: serv 550.00 + rep 0.00 = 550.00 | igv 99.00 | total 649.00
INSERT INTO factura VALUES(seq_factura.NEXTVAL, 5,'F001-00009',SYSDATE-14,  550.00,   99.00,   649.00);
-- Orden  6: serv 300.00 + rep 450.00 = 750.00 | igv 135.00 | total 885.00
INSERT INTO factura VALUES(seq_factura.NEXTVAL, 6,'F001-00010',SYSDATE-13,  750.00,  135.00,   885.00);
-- Orden 27: serv 120.00 + rep 250.00 = 370.00 | igv 66.60 | total 436.60
INSERT INTO factura VALUES(seq_factura.NEXTVAL,27,'F001-00011',SYSDATE-11,  370.00,   66.60,   436.60);
-- Orden  9: serv 520.00 + rep 690.00 = 1210.00 | igv 217.80 | total 1427.80
INSERT INTO factura VALUES(seq_factura.NEXTVAL, 9,'F001-00012',SYSDATE-10, 1210.00,  217.80,  1427.80);
-- Orden 28: serv 500.00 + rep 250.00 = 750.00 | igv 135.00 | total 885.00
INSERT INTO factura VALUES(seq_factura.NEXTVAL,28,'F001-00013',SYSDATE-10,  750.00,  135.00,   885.00);
-- Orden 10: serv 130.00 + rep 770.00 = 900.00 | igv 162.00 | total 1062.00
INSERT INTO factura VALUES(seq_factura.NEXTVAL,10,'F001-00014',SYSDATE-9 ,  900.00,  162.00,  1062.00);
-- Orden 11: serv 2500.00 + rep 1000.00 = 3500.00 | igv 630.00 | total 4130.00
INSERT INTO factura VALUES(seq_factura.NEXTVAL,11,'F001-00015',SYSDATE-8 , 3500.00,  630.00,  4130.00);
-- Orden 13: serv 310.00 + rep 270.00 = 580.00 | igv 104.40 | total 684.40
INSERT INTO factura VALUES(seq_factura.NEXTVAL,13,'F001-00016',SYSDATE-6 ,  580.00,  104.40,   684.40);
-- Orden 14: serv 400.00 + rep 840.00 = 1240.00 | igv 223.20 | total 1463.20
INSERT INTO factura VALUES(seq_factura.NEXTVAL,14,'F001-00017',SYSDATE-5 , 1240.00,  223.20,  1463.20);
-- Orden 29: serv 600.00 + rep 700.00 = 1300.00 | igv 234.00 | total 1534.00
INSERT INTO factura VALUES(seq_factura.NEXTVAL,29,'F001-00018',SYSDATE-5 , 1300.00,  234.00,  1534.00);
-- Orden 30: serv 400.00 + rep 1040.00 = 1440.00 | igv 259.20 | total 1699.20
INSERT INTO factura VALUES(seq_factura.NEXTVAL,30,'F001-00019',SYSDATE-4 , 1440.00,  259.20,  1699.20);
-- Orden 16: serv 220.00 + rep 375.00 = 595.00 | igv 107.10 | total 702.10
INSERT INTO factura VALUES(seq_factura.NEXTVAL,16,'F001-00020',SYSDATE-3 ,  595.00,  107.10,   702.10);
-- Orden 17: serv 180.00 + rep 650.00 = 830.00 | igv 149.40 | total 979.40
INSERT INTO factura VALUES(seq_factura.NEXTVAL,17,'F001-00021',SYSDATE-2 ,  830.00,  149.40,   979.40);
-- Orden 19: serv 250.00 + rep 480.00 = 730.00 | igv 131.40 | total 861.40
INSERT INTO factura VALUES(seq_factura.NEXTVAL,19,'F001-00022',SYSDATE-1 ,  730.00,  131.40,   861.40);

/* =========================================================
   PAGOS  (id, id_factura, fecha_pago, monto, metodo)

   Escenarios demostrados:
   - Pago unico completo        : la mayoria de facturas
   - Pago en 2 cuotas           : factura de la orden 4
   - Pago parcial con saldo     : facturas de ordenes 11 y 29
   - Sin ningun pago            : factura de la orden 10
   Saldos pendientes resultantes:
     F001-00014: saldo 1062.00
     F001-00015: saldo 2130.00
     F001-00018: saldo 1234.00
   -> v_facturas_por_cobrar devuelve exactamente esas facturas
   ========================================================= */

INSERT INTO pago VALUES(seq_pago.NEXTVAL, 1,SYSDATE-24,  395.30,'EFECTIVO');
INSERT INTO pago VALUES(seq_pago.NEXTVAL, 2,SYSDATE-22, 1416.00,'TARJETA');
INSERT INTO pago VALUES(seq_pago.NEXTVAL, 3,SYSDATE-21,  177.00,'TRANSFERENCIA');
INSERT INTO pago VALUES(seq_pago.NEXTVAL, 4,SYSDATE-20,  631.30,'EFECTIVO');
INSERT INTO pago VALUES(seq_pago.NEXTVAL, 5,SYSDATE-18,  224.20,'TARJETA');
INSERT INTO pago VALUES(seq_pago.NEXTVAL, 6,SYSDATE-17,  247.80,'TRANSFERENCIA');
INSERT INTO pago VALUES(seq_pago.NEXTVAL, 7,SYSDATE-16,  908.60,'EFECTIVO');
INSERT INTO pago VALUES(seq_pago.NEXTVAL, 8,SYSDATE-15,  513.30,'TARJETA');  -- cuota 1 de la orden 4
INSERT INTO pago VALUES(seq_pago.NEXTVAL, 8,SYSDATE-14,  513.30,'EFECTIVO');  -- cuota 2 de la orden 4
INSERT INTO pago VALUES(seq_pago.NEXTVAL, 9,SYSDATE-14,  649.00,'TARJETA');
INSERT INTO pago VALUES(seq_pago.NEXTVAL,10,SYSDATE-13,  885.00,'TRANSFERENCIA');
INSERT INTO pago VALUES(seq_pago.NEXTVAL,11,SYSDATE-11,  436.60,'EFECTIVO');
INSERT INTO pago VALUES(seq_pago.NEXTVAL,12,SYSDATE-10, 1427.80,'TARJETA');
INSERT INTO pago VALUES(seq_pago.NEXTVAL,13,SYSDATE-10,  885.00,'TRANSFERENCIA');
INSERT INTO pago VALUES(seq_pago.NEXTVAL,15,SYSDATE-8 , 2000.00,'TRANSFERENCIA');  -- pago parcial (orden 11)
INSERT INTO pago VALUES(seq_pago.NEXTVAL,16,SYSDATE-6 ,  684.40,'EFECTIVO');
INSERT INTO pago VALUES(seq_pago.NEXTVAL,17,SYSDATE-5 , 1463.20,'TARJETA');
INSERT INTO pago VALUES(seq_pago.NEXTVAL,18,SYSDATE-5 ,  300.00,'TRANSFERENCIA');  -- pago parcial (orden 29)
INSERT INTO pago VALUES(seq_pago.NEXTVAL,19,SYSDATE-4 , 1699.20,'TRANSFERENCIA');
INSERT INTO pago VALUES(seq_pago.NEXTVAL,20,SYSDATE-3 ,  702.10,'EFECTIVO');
INSERT INTO pago VALUES(seq_pago.NEXTVAL,21,SYSDATE-2 ,  979.40,'TARJETA');
INSERT INTO pago VALUES(seq_pago.NEXTVAL,22,SYSDATE-1 ,  861.40,'TRANSFERENCIA');
-- Factura de la orden 10 (F001-00014): sin pagos registrados

/* =========================================================
   CITAS  (agenda de turnos)
   Regla verificada: el vehiculo pertenece al cliente indicado.
   ========================================================= */

-- cliente  1 (Jose Perez) -> vehiculo  1 (Toyota Corolla ABC101)
INSERT INTO cita VALUES(seq_cita.NEXTVAL, 1, 1,SYSDATE+1,'Cambio de aceite','CONFIRMADA');
-- cliente  2 (Carlos Rojas) -> vehiculo  3 (Hyundai Accent ABC103)
INSERT INTO cita VALUES(seq_cita.NEXTVAL, 2, 3,SYSDATE+2,'Revision de frenos','PENDIENTE');
-- cliente  3 (Luis Diaz) -> vehiculo  5 (Mazda 3 ABC105)
INSERT INTO cita VALUES(seq_cita.NEXTVAL, 3, 5,SYSDATE+3,'Alineamiento','CONFIRMADA');
-- cliente  4 (Pedro Lopez) -> vehiculo  6 (Chevrolet Spark ABC106)
INSERT INTO cita VALUES(seq_cita.NEXTVAL, 4, 6,SYSDATE+1,'Diagnostico general','PENDIENTE');
-- cliente  5 (Miguel Vargas) -> vehiculo  7 (Suzuki Swift ABC107)
INSERT INTO cita VALUES(seq_cita.NEXTVAL, 5, 7,SYSDATE+5,'Cambio de llantas','CONFIRMADA');
-- cliente  6 (Jorge Ramirez) -> vehiculo  8 (Toyota Yaris ABC108)
INSERT INTO cita VALUES(seq_cita.NEXTVAL, 6, 8,SYSDATE-1,'Escaneo general','CANCELADA');
-- cliente  7 (Andres Castro) -> vehiculo  9 (Volkswagen Gol ABC109)
INSERT INTO cita VALUES(seq_cita.NEXTVAL, 7, 9,SYSDATE+2,'Revision electrica','PENDIENTE');
-- cliente  8 (Ricardo Vega) -> vehiculo 10 (Ford Fiesta ABC110)
INSERT INTO cita VALUES(seq_cita.NEXTVAL, 8,10,SYSDATE+4,'Afinamiento','CONFIRMADA');
-- cliente  9 (Mario Silva) -> vehiculo 11 (Toyota Hilux ABC111)
INSERT INTO cita VALUES(seq_cita.NEXTVAL, 9,11,SYSDATE+6,'Cambio de bateria','PENDIENTE');
-- cliente  3 (Luis Diaz) -> vehiculo 18 (Renault Logan ABC118)
INSERT INTO cita VALUES(seq_cita.NEXTVAL, 3,18,SYSDATE+3,'Balanceo','PENDIENTE');
-- cliente  5 (Miguel Vargas) -> vehiculo 19 (Peugeot 208 ABC119)
INSERT INTO cita VALUES(seq_cita.NEXTVAL, 5,19,SYSDATE+7,'Cambio de frenos','CONFIRMADA');
-- cliente  7 (Andres Castro) -> vehiculo 20 (Jeep Compass ABC120)
INSERT INTO cita VALUES(seq_cita.NEXTVAL, 7,20,SYSDATE+2,'Pintura parcial','CANCELADA');

/* =========================================================
   AJUSTE FINAL DE STOCK
   stock_final = stock_inicial + entradas(compras) - salidas(ordenes)
   Deja repuesto.stock cuadrado con detalle_compra y
   detalle_repuesto (verificable con 08_verificacion.sql).
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
