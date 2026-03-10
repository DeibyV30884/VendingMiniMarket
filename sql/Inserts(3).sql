-- Secuencias para IDs automáticos de todas las tablas
CREATE SEQUENCE SEQ_ROL START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_USUARIO START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_CATEGORIA START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_PROVEEDOR START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_PRODUCTO START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_MAQUINA START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_PRODUCTO_MAQUINA START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_PEDIDO START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_DETALLE_PEDIDO START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_MOVIMIENTO START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_VENTA START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

DESC ROL;

--Consola:
/*
ID_ROL      NOT NULL NUMBER        
NOMBRE      NOT NULL VARCHAR2(50)  
DESCRIPCION          VARCHAR2(200)
*/

-- Roles
INSERT INTO ROL VALUES (SEQ_ROL.NEXTVAL, 'Administrador', 'Acceso total al sistema');
INSERT INTO ROL VALUES (SEQ_ROL.NEXTVAL, 'Colaborador', 'Acceso limitado');
COMMIT;

SELECT * FROM ROL;

--Consola:
/*
1	Administrador	Acceso total al sistema
2	Colaborador	Acceso limitado
*/

DESC USUARIO;

--Consola:
/*
Name           Null?    Type          
-------------- -------- ------------- 
ID_USUARIO     NOT NULL NUMBER        
NOMBRE         NOT NULL VARCHAR2(100) 
EMAIL          NOT NULL VARCHAR2(100) 
CONTRASENA     NOT NULL VARCHAR2(100) 
ID_ROL         NOT NULL NUMBER        
FECHA_REGISTRO          DATE   
*/


-- Usuario admin
INSERT INTO USUARIO VALUES (SEQ_USUARIO.NEXTVAL, 'Deiby Vargas', 'admin@vending.com', 'admin123', 1, SYSDATE);

-- Usuario colaborador
INSERT INTO USUARIO VALUES (SEQ_USUARIO.NEXTVAL, 'Maria Lopez', 'colaborador@vending.com', 'colab123', 2, SYSDATE);
COMMIT;

SELECT * FROM USUARIO;

--Consola:
/*
1	Deiby Vargas	admin@vending.com	admin123	1	09/03/26
2	Maria Lopez	colaborador@vending.com	colab123	2	09/03/26 
*/

DESC CATEGORIA;

--Consola:
/*
Name         Null?    Type          
------------ -------- ------------- 
ID_CATEGORIA NOT NULL NUMBER        
NOMBRE       NOT NULL VARCHAR2(50)  
DESCRIPCION           VARCHAR2(200) 
*/

-- Categorias
INSERT INTO CATEGORIA VALUES (SEQ_CATEGORIA.NEXTVAL, 'Bebidas', 'Bebidas frias y calientes');
INSERT INTO CATEGORIA VALUES (SEQ_CATEGORIA.NEXTVAL, 'Snacks', 'Snacks salados y dulces');
INSERT INTO CATEGORIA VALUES (SEQ_CATEGORIA.NEXTVAL, 'Dulces', 'Dulces y chocolates');
COMMIT;

SELECT * FROM CATEGORIA;

--Consola:
/*
1	Bebidas	Bebidas frias y calientes
2	Snacks	Snacks salados y dulces
3	Dulces	Dulces y chocolates
*/

DESC PROVEEDOR;

--Consola:
/*
Name         Null?    Type          
------------ -------- ------------- 
ID_PROVEEDOR NOT NULL NUMBER        
NOMBRE       NOT NULL VARCHAR2(100) 
CONTACTO              VARCHAR2(100) 
TELEFONO              VARCHAR2(20)  
EMAIL                 VARCHAR2(100) 
DIRECCION             VARCHAR2(200) 
*/

-- Proveedores
INSERT INTO PROVEEDOR VALUES (SEQ_PROVEEDOR.NEXTVAL, 'Distribuidora CR', 'Juan Perez', '8888-1111', 'contacto@distribuidoracr.com', 'San Jose, Costa Rica');
INSERT INTO PROVEEDOR VALUES (SEQ_PROVEEDOR.NEXTVAL, 'Snacks y Mas', 'Maria Lopez', '8888-2222', 'ventas@snacksymas.com', 'Heredia, Costa Rica');
INSERT INTO PROVEEDOR VALUES (SEQ_PROVEEDOR.NEXTVAL, 'Bebidas del Norte', 'Carlos Mora', '8888-3333', 'info@bebidasnorte.com', 'Alajuela, Costa Rica');
COMMIT;


SELECT * FROM PROVEEDOR;

--Consola:
/*
1	Distribuidora CR	Juan Perez	8888-1111	contacto@distribuidoracr.com	San Jose, Costa Rica
2	Snacks y Mas	Maria Lopez	8888-2222	ventas@snacksymas.com	Heredia, Costa Rica
3	Bebidas del Norte	Carlos Mora	8888-3333	info@bebidasnorte.com	Alajuela, Costa Rica
*/


DESC PRODUCTO;

--Consola:
/*
Name                Null?    Type          
------------------- -------- ------------- 
ID_PRODUCTO         NOT NULL NUMBER        
NOMBRE              NOT NULL VARCHAR2(100) 
ID_CATEGORIA        NOT NULL NUMBER        
ID_PROVEEDOR        NOT NULL NUMBER        
PRECIO_COSTO        NOT NULL NUMBER(10,2)  
PORCENTAJE_GANANCIA          NUMBER(5,2)   
PRECIO_VENTA                 NUMBER(10,2)  
STOCK_BODEGA                 NUMBER        
FECHA_INGRESO                DATE     
*/

-- Productos
INSERT INTO PRODUCTO VALUES (SEQ_PRODUCTO.NEXTVAL, 'Coca Cola 350ml', 1, 1, 500, 30, 650, 50, SYSDATE);
INSERT INTO PRODUCTO VALUES (SEQ_PRODUCTO.NEXTVAL, 'Agua Pura 500ml', 1, 3, 300, 25, 375, 30, SYSDATE);
INSERT INTO PRODUCTO VALUES (SEQ_PRODUCTO.NEXTVAL, 'Papas Lays', 2, 2, 400, 30, 520, 40, SYSDATE);
INSERT INTO PRODUCTO VALUES (SEQ_PRODUCTO.NEXTVAL, 'Doritos', 2, 2, 450, 30, 585, 35, SYSDATE);
INSERT INTO PRODUCTO VALUES (SEQ_PRODUCTO.NEXTVAL, 'Chocolate Kit Kat', 3, 2, 350, 30, 455, 25, SYSDATE);
COMMIT;

SELECT * FROM PRODUCTO;

--Consola:
/*
1	Coca Cola 350ml	1	1	500	30	650	50	10/03/26
2	Agua Pura 500ml	1	3	300	25	375	30	10/03/26
3	Papas Lays	2	2	400	30	520	40	10/03/26
4	Doritos	2	2	450	30	585	35	10/03/26
5	Chocolate Kit Kat	3	2	350	30	455	25	10/03/26  
*/

DESC MAQUINA;

--Consola:
/*
Name              Null?    Type          
----------------- -------- ------------- 
ID_MAQUINA        NOT NULL NUMBER        
CODIGO_MAQUINA    NOT NULL VARCHAR2(20)  
UBICACION         NOT NULL VARCHAR2(100) 
CAPACIDAD_MAXIMA           NUMBER        
ESTADO                     VARCHAR2(20)  
FECHA_INSTALACION          DATE          
*/

-- Maquinas
INSERT INTO MAQUINA VALUES (SEQ_MAQUINA.NEXTVAL, 'Maquina Central', 'Edificio A - Planta Baja', 'Activa');
INSERT INTO MAQUINA VALUES (SEQ_MAQUINA.NEXTVAL, 'Maquina Norte', 'Edificio B - Segundo Piso', 'Activa');
INSERT INTO MAQUINA VALUES (SEQ_MAQUINA.NEXTVAL, 'Maquina Sur', 'Cafeteria Principal', 'Activa');
COMMIT;



DESC MAQUINA;

--Consola:
/*
Name              Null?    Type          
----------------- -------- ------------- 
ID_MAQUINA        NOT NULL NUMBER        
CODIGO_MAQUINA    NOT NULL VARCHAR2(20)  
UBICACION         NOT NULL VARCHAR2(100) 
CAPACIDAD_MAXIMA           NUMBER        
ESTADO                     VARCHAR2(20)  
FECHA_INSTALACION          DATE               
*/

-- Maquinas
INSERT INTO MAQUINA VALUES (SEQ_MAQUINA.NEXTVAL, 'MAQ-001', 'Edificio A - Planta Baja', 50, 'Activa', SYSDATE);
INSERT INTO MAQUINA VALUES (SEQ_MAQUINA.NEXTVAL, 'MAQ-002', 'Edificio B - Segundo Piso', 50, 'Activa', SYSDATE);
INSERT INTO MAQUINA VALUES (SEQ_MAQUINA.NEXTVAL, 'MAQ-003', 'Cafeteria Principal', 50, 'Activa', SYSDATE);
COMMIT;

SELECT * FROM MAQUINA;

--Consola:
/*
1	MAQ-001	Edificio A - Planta Baja	50	Activa	10/03/26
2	MAQ-002	Edificio B - Segundo Piso	50	Activa	10/03/26
3	MAQ-003	Cafeteria Principal	50	Activa	10/03/26        
*/

DESC PRODUCTO_MAQUINA;

--Consola:
/*
Name                Null?    Type   
------------------- -------- ------ 
ID_PRODUCTO_MAQUINA NOT NULL NUMBER 
ID_PRODUCTO         NOT NULL NUMBER 
ID_MAQUINA          NOT NULL NUMBER 
STOCK_ACTUAL                 NUMBER 
STOCK_MINIMO        NOT NULL NUMBER 
FECHA_ASIGNACION             DATE         
*/

INSERT INTO PRODUCTO_MAQUINA VALUES (SEQ_PRODUCTO_MAQUINA.NEXTVAL, 1, 1, 20, 5, SYSDATE);
INSERT INTO PRODUCTO_MAQUINA VALUES (SEQ_PRODUCTO_MAQUINA.NEXTVAL, 2, 1, 15, 5, SYSDATE);
INSERT INTO PRODUCTO_MAQUINA VALUES (SEQ_PRODUCTO_MAQUINA.NEXTVAL, 3, 2, 20, 5, SYSDATE);
INSERT INTO PRODUCTO_MAQUINA VALUES (SEQ_PRODUCTO_MAQUINA.NEXTVAL, 4, 2, 15, 5, SYSDATE);
INSERT INTO PRODUCTO_MAQUINA VALUES (SEQ_PRODUCTO_MAQUINA.NEXTVAL, 5, 3, 10, 3, SYSDATE);
COMMIT;

SELECT * FROM PRODUCTO_MAQUINA;

--Consola:
/*
1	1	1	20	5	10/03/26
2	2	1	15	5	10/03/26
3	3	2	20	5	10/03/26
4	4	2	15	5	10/03/26
5	5	3	10	3	10/03/26         
*/

DESC PEDIDO;

--Consola:
/*
Name            Null?    Type         
--------------- -------- ------------ 
ID_PEDIDO       NOT NULL NUMBER       
ID_PROVEEDOR    NOT NULL NUMBER       
ID_USUARIO      NOT NULL NUMBER       
FECHA_PEDIDO             DATE         
FECHA_RECEPCION          DATE         
ESTADO                   VARCHAR2(20) 
TOTAL                    NUMBER(10,2)         
*/

INSERT INTO PEDIDO VALUES (SEQ_PEDIDO.NEXTVAL, 1, 1, SYSDATE, NULL, 'Pendiente', 0);
COMMIT;

SELECT * FROM PEDIDO;

--Consola:
/*
1	1	1	10/03/26		Pendiente	0        
*/

DESC DETALLE_PEDIDO;

--Consola:
/*
Name            Null?    Type         
--------------- -------- ------------ 
ID_DETALLE      NOT NULL NUMBER       
ID_PEDIDO       NOT NULL NUMBER       
ID_PRODUCTO     NOT NULL NUMBER       
CANTIDAD        NOT NULL NUMBER       
PRECIO_UNITARIO NOT NULL NUMBER(10,2) 
SUBTOTAL                 NUMBER(10,2)       
*/

INSERT INTO DETALLE_PEDIDO VALUES (SEQ_DETALLE_PEDIDO.NEXTVAL, 1, 1, 10, 500, 5000);
INSERT INTO DETALLE_PEDIDO VALUES (SEQ_DETALLE_PEDIDO.NEXTVAL, 1, 2, 10, 300, 3000);
COMMIT;

SELECT * FROM DETALLE_PEDIDO;

--Consola:
/*
1	1	1	10	500	5000
2	1	2	10	300	3000      
*/

