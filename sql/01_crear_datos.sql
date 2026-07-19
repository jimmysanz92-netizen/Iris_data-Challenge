DROP TABLE IF EXISTS cuotas;
DROP TABLE IF EXISTS pagos;
DROP TABLE IF EXISTS creditos;
DROP TABLE IF EXISTS clientes;
GO

CREATE TABLE clientes (
    id_cliente  INT          PRIMARY KEY,
    documento   VARCHAR(20),
    nombre      VARCHAR(60),
    segmento    VARCHAR(20),
    ciudad      VARCHAR(40),
    fecha_alta  DATE
);
GO

CREATE TABLE creditos (
    id_credito          INT           PRIMARY KEY,
    id_cliente          INT,
    tipo_producto       VARCHAR(30),
    monto_desembolsado  DECIMAL(9,2),
    tasa_ea             DECIMAL(5,4) NOT NULL,
    plazo_meses         INT,
    fecha_desembolso    DATE,
    estado              VARCHAR(15)
);
GO

CREATE TABLE pagos (
    id_pago     INT          PRIMARY KEY,
    id_credito  INT,
    fecha_pago  DATE,
    monto_pago  DECIMAL(18,2),
    canal       VARCHAR(15)
);
GO

CREATE TABLE cuotas (
    id_cuota           INT          PRIMARY KEY,
    id_credito         INT,
    num_cuota          INT,
    fecha_vencimiento  DATE,
    valor_cuota        DECIMAL(18,2),
    fecha_pago_real    DATE
);
GO

INSERT INTO clientes (id_cliente, documento, nombre, segmento, ciudad, fecha_alta) VALUES
(1, 'CC12345', 'Ana Rios',    'Premium',     'Bogota',       '2021-03-10'),
(2, 'CC23456', 'Luis Mora',   'Personal',    'Medellin',     '2022-06-01'),
(3, 'CC34567', 'Carla Pena',  'PYME',        'Cali',         '2020-11-20'),
(4, 'CC45678', 'Jorge Diaz',  'Empresarial', 'Barranquilla', '2019-01-15'),
(5, 'CC56789', 'Sofia Luna',  'Personal',    'Bogota',       '2023-02-28'),
(6, 'CC67890', 'Marta Gil',   'Premium',     'Medellin',     '2021-09-05'),
(7, 'CC78901', 'Pedro Saenz', 'PYME',        'Bucaramanga',  '2022-12-12'),
(8, 'CC89012', 'Nora Vega',   'Personal',    'Cali',         '2024-01-08');
GO

INSERT INTO creditos (id_credito, id_cliente, tipo_producto, monto_desembolsado, tasa_ea, plazo_meses, fecha_desembolso, estado) VALUES
(101, 1,  'Libranza',        10000000, 0.18, 24,  '2024-01-15', 'Vigente'),
(102, 1,  'Libre Inversion',  5000000, 0.28, 12,  '2024-02-10', 'Vigente'),
(103, 2,  'Vehiculo',        30000000, 0.16, 48,  '2024-01-20', 'Vigente'),
(104, 3,  'Libre Inversion',  8000000, NULL, 12,  '2024-03-05', 'Vigente'),
(105, 4,  'Vivienda',       120000000, 0.12, 120, '2024-02-01', 'Vigente'),
(106, 5,  'Libranza',         6000000, 0.19, 24,  '2024-04-12', 'Vigente'),
(107, 6,  'Vehiculo',        25000000, 0.17, 48,  '2024-01-30', 'Cancelado'),
(108, 7,  'Libre Inversion',  9000000, 0.30, 18,  '2024-05-08', 'Vigente'),
(109, 2,  'Libranza',         4000000, 0.20, 12,  '2024-06-15', 'Vigente'),
(110, 8,  'Libre Inversion',  3000000, 0.29, 12,  '2024-07-01', 'Vigente'),
(111, 99, 'Libre Inversion',  7000000, 0.27, 12,  '2024-03-22', 'Vigente'),
(112, 3,  'Vehiculo',        20000000, 0.15, 36,  '2024-02-18', 'Castigado');
GO

INSERT INTO pagos (id_pago, id_credito, fecha_pago, monto_pago, canal) VALUES
(1001, 101, '2024-02-15',  550000, 'App'),
(1002, 101, '2024-03-15',  550000, 'App'),
(1003, 101, '2024-04-15',  550000, 'Web'),
(1004, 102, '2024-03-10',  480000, 'Oficina'),
(1005, 103, '2024-02-20',  900000, 'App'),
(1006, 103, '2024-03-20',  900000, 'App'),
(1007, 104, '2024-04-05',  720000, 'Cajero'),
(1008, 105, '2024-03-01', 1500000, 'Oficina'),
(1009, 105, '2024-04-01', 1500000, 'Oficina'),
(1010, 106, '2024-05-12',  300000, 'App'),
(1011, 107, '2024-02-28',  620000, 'Web'),
(1012, 108, '2024-06-08',  600000, 'App'),
(1013, 109, '2024-07-15',  380000, 'App'),
(1014, 111, '2024-04-22',  650000, 'Web'),
(1015, 105, '2024-03-01', 1500000, 'Oficina');
GO

INSERT INTO cuotas (id_cuota, id_credito, num_cuota, fecha_vencimiento, valor_cuota, fecha_pago_real) VALUES
(201, 101, 1, '2024-02-15',  550000, '2024-02-15'),
(202, 101, 2, '2024-03-15',  550000, '2024-03-15'),
(203, 101, 3, '2024-04-15',  550000, '2024-04-16'),
(204, 101, 4, '2024-05-15',  550000, NULL),
(205, 101, 5, '2024-06-15',  550000, NULL),
(206, 101, 6, '2024-07-15',  550000, NULL),
(207, 103, 1, '2024-02-20',  900000, '2024-02-20'),
(208, 103, 2, '2024-03-20',  900000, '2024-03-20'),
(209, 103, 3, '2024-04-20',  900000, NULL),
(210, 106, 1, '2024-05-12',  300000, '2024-05-12'),
(211, 106, 2, '2024-06-12',  300000, NULL),
(212, 106, 3, '2024-07-12',  300000, NULL),
(213, 105, 1, '2024-03-01', 1500000, '2024-03-01'),
(214, 105, 2, '2024-04-01', 1500000, '2024-04-01'),
(215, 105, 3, '2024-05-01', 1500000, '2024-05-02'),
(216, 112, 1, '2024-03-18',  700000, NULL),
(217, 112, 2, '2024-04-18',  700000, NULL),
(218, 112, 3, '2024-05-18',  700000, NULL);
GO
