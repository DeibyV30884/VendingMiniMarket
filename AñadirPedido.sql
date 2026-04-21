-- Añadir pedido

CREATE OR REPLACE PROCEDURE SP_LISTAR_PRODUCTOS_RECARGABLES(
    p_cursor OUT SYS_REFCURSOR,
    p_id_maquina IN NUMBER
)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT PM.ID_PRODUCTO_MAQUINA,
               P.ID_PRODUCTO,
               P.NOMBRE AS NOMBRE_PRODUCTO,
               P.STOCK_BODEGA,
               PM.STOCK_ACTUAL AS STOCK_ACTUAL_MAQUINA,
               PM.STOCK_MINIMO,
               P.PRECIO_VENTA
        FROM PRODUCTO_MAQUINA PM
        JOIN PRODUCTO P ON PM.ID_PRODUCTO = P.ID_PRODUCTO
        WHERE PM.ID_MAQUINA = p_id_maquina
          AND P.STOCK_BODEGA > 0
        ORDER BY P.NOMBRE;
END SP_LISTAR_PRODUCTOS_RECARGABLES;
/

--Procedure SP_LISTAR_PRODUCTOS_RECARGABLES compilado


--Recargar la maquina

CREATE OR REPLACE PROCEDURE SP_RECARGAR_MAQUINA(
    p_id_producto_maquina IN NUMBER,
    p_cantidad IN NUMBER,
    p_id_usuario IN NUMBER,
    p_mensaje OUT VARCHAR2,
    p_resultado OUT NUMBER
)
AS
    v_stock_bodega NUMBER;
    v_id_producto NUMBER;
    v_id_maquina NUMBER;
    v_nombre_producto VARCHAR2(100);
BEGIN
    p_resultado := 0;
    
    -- Datos de la asignación
    SELECT PM.ID_PRODUCTO, PM.ID_MAQUINA, P.NOMBRE, P.STOCK_BODEGA
    INTO v_id_producto, v_id_maquina, v_nombre_producto, v_stock_bodega
    FROM PRODUCTO_MAQUINA PM
    JOIN PRODUCTO P ON PM.ID_PRODUCTO = P.ID_PRODUCTO
    WHERE PM.ID_PRODUCTO_MAQUINA = p_id_producto_maquina;
    
    -- Validar cantidad
    IF p_cantidad <= 0 THEN
        p_mensaje := 'La cantidad a recargar debe ser mayor a 0';
        p_resultado := 1;
        RETURN;
    END IF;
    
    -- Validar stock en bodega
    IF v_stock_bodega < p_cantidad THEN
        p_mensaje := 'Stock insuficiente en bodega. Disponible: ' || v_stock_bodega || ', Solicitado: ' || p_cantidad;
        p_resultado := 1;
        RETURN;
    END IF;
    
    -- Iniciar transacción
    SAVEPOINT antes_recarga;
    
    -- Actualizar stock en bodega (se hace una resta)
    UPDATE PRODUCTO SET STOCK_BODEGA = STOCK_BODEGA - p_cantidad
    WHERE ID_PRODUCTO = v_id_producto;
    
    -- Actualizar stock en máquina (se hace una suma)
    UPDATE PRODUCTO_MAQUINA SET STOCK_ACTUAL = STOCK_ACTUAL + p_cantidad
    WHERE ID_PRODUCTO_MAQUINA = p_id_producto_maquina;
    
    -- Registrar movimiento de inventario
    INSERT INTO MOVIMIENTO_INVENTARIO (ID_MOVIMIENTO, ID_PRODUCTO, ID_USUARIO, ID_MAQUINA, TIPO_MOVIMIENTO, CANTIDAD, FECHA)
    VALUES (SEQ_MOVIMIENTO.NEXTVAL, v_id_producto, p_id_usuario, v_id_maquina, 'RECARGA A MAQUINA', p_cantidad, SYSDATE);
    
    COMMIT;
    p_mensaje := 'Recarga exitosa. Se movieron ' || p_cantidad || ' unidades de "' || v_nombre_producto || '" a la máquina.';
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO antes_recarga;
        p_mensaje := SQLERRM;
        p_resultado := 1;
END SP_RECARGAR_MAQUINA;
/

--Procedure SP_RECARGAR_MAQUINA compilado

--Provedores 

CREATE OR REPLACE PROCEDURE SP_LISTAR_PROVEEDORES(
    p_cursor OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT ID_PROVEEDOR, NOMBRE, CONTACTO, TELEFONO
        FROM PROVEEDOR
        ORDER BY NOMBRE;
END SP_LISTAR_PROVEEDORES;
/

--Procedure SP_LISTAR_PROVEEDORES compilado

--Productos pedidos

CREATE OR REPLACE PROCEDURE SP_LISTAR_PRODUCTOS_PEDIDO(
    p_cursor OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT ID_PRODUCTO,
               NOMBRE,
               PRECIO_COSTO,
               PORCENTAJE_GANANCIA,
               PRECIO_VENTA
        FROM PRODUCTO
        ORDER BY NOMBRE;
END SP_LISTAR_PRODUCTOS_PEDIDO;
/

--Procedure SP_LISTAR_PRODUCTOS_PEDIDO compilado

--Nuevo pedido

CREATE OR REPLACE PROCEDURE SP_CREAR_PEDIDO(
    p_id_proveedor IN NUMBER,
    p_id_usuario IN NUMBER,
    p_id_pedido OUT NUMBER,
    p_mensaje OUT VARCHAR2,
    p_resultado OUT NUMBER
)
AS
    v_count NUMBER;
BEGIN
    p_resultado := 0;
    
    -- Validamos que el proveedor exista
    SELECT COUNT(*) INTO v_count FROM PROVEEDOR WHERE ID_PROVEEDOR = p_id_proveedor;
    IF v_count = 0 THEN
        p_mensaje := 'El proveedor no existe';
        p_resultado := 1;
        RETURN;
    END IF;
    
    -- Insertar el pedido
    INSERT INTO PEDIDO (ID_PEDIDO, ID_PROVEEDOR, ID_USUARIO, FECHA_PEDIDO, ESTADO, TOTAL)
    VALUES (SEQ_PEDIDO.NEXTVAL, p_id_proveedor, p_id_usuario, SYSDATE, 'PENDIENTE', 0)
    RETURNING ID_PEDIDO INTO p_id_pedido;
    
    COMMIT;
    p_mensaje := 'Pedido #' || p_id_pedido || ' creado exitosamente';
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_mensaje := SQLERRM;
        p_resultado := 1;
END SP_CREAR_PEDIDO;
/

--Procedure SP_CREAR_PEDIDO compilado

--Detalle para el pedido

CREATE OR REPLACE PROCEDURE SP_AGREGAR_DETALLE_PEDIDO(
    p_id_pedido IN NUMBER,
    p_id_producto IN NUMBER,
    p_cantidad IN NUMBER,
    p_precio_unitario IN NUMBER,
    p_mensaje OUT VARCHAR2,
    p_resultado OUT NUMBER
)
AS
    v_count NUMBER;
    v_estado VARCHAR2(20);
    v_subtotal NUMBER;
BEGIN
    p_resultado := 0;
    
    -- Validar que el pedido exista y este pendiente en el sistema.
    SELECT COUNT(*), ESTADO INTO v_count, v_estado 
    FROM PEDIDO WHERE ID_PEDIDO = p_id_pedido
    GROUP BY ESTADO;
    
    IF v_count = 0 THEN
        p_mensaje := 'El pedido no existe';
        p_resultado := 1;
        RETURN;
    END IF;
    
    IF UPPER(v_estado) != 'PENDIENTE' THEN
        p_mensaje := 'Solo se pueden agregar productos a pedidos en estado PENDIENTE';
        p_resultado := 1;
        RETURN;
    END IF;
    
    -- Validar que el producto exista
    SELECT COUNT(*) INTO v_count FROM PRODUCTO WHERE ID_PRODUCTO = p_id_producto;
    IF v_count = 0 THEN
        p_mensaje := 'El producto no existe';
        p_resultado := 1;
        RETURN;
    END IF;
    
    -- Validar cantidad positiva exista
    IF p_cantidad <= 0 THEN
        p_mensaje := 'La cantidad debe ser mayor a 0';
        p_resultado := 1;
        RETURN;
    END IF;
    
    -- Calcular subtotal
    v_subtotal := p_cantidad * p_precio_unitario;
    
    -- Insertar detalle
    INSERT INTO DETALLE_PEDIDO (ID_DETALLE, ID_PEDIDO, ID_PRODUCTO, CANTIDAD, PRECIO_UNITARIO, SUBTOTAL)
    VALUES (SEQ_DETALLE_PEDIDO.NEXTVAL, p_id_pedido, p_id_producto, p_cantidad, p_precio_unitario, v_subtotal);
    
    -- Actualizar el total del pedido en colones
    UPDATE PEDIDO SET TOTAL = NVL(TOTAL, 0) + v_subtotal
    WHERE ID_PEDIDO = p_id_pedido;
    
    COMMIT;
    p_mensaje := 'Producto agregado. Subtotal: ?' || v_subtotal;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_mensaje := SQLERRM;
        p_resultado := 1;
END SP_AGREGAR_DETALLE_PEDIDO;
/

--Procedure SP_AGREGAR_DETALLE_PEDIDO compilado

-- Detalles del pedido

CREATE OR REPLACE PROCEDURE SP_LISTAR_DETALLES_PEDIDO(
    p_cursor OUT SYS_REFCURSOR,
    p_id_pedido IN NUMBER
)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT DP.ID_DETALLE,
               P.ID_PRODUCTO,
               P.NOMBRE AS NOMBRE_PRODUCTO,
               DP.CANTIDAD,
               DP.PRECIO_UNITARIO,
               DP.SUBTOTAL
        FROM DETALLE_PEDIDO DP
        JOIN PRODUCTO P ON DP.ID_PRODUCTO = P.ID_PRODUCTO
        WHERE DP.ID_PEDIDO = p_id_pedido
        ORDER BY DP.ID_DETALLE;
END SP_LISTAR_DETALLES_PEDIDO;
/

--Procedure SP_LISTAR_DETALLES_PEDIDO compilado

--Pedidos pendientes

CREATE OR REPLACE PROCEDURE SP_LISTAR_PEDIDOS_PENDIENTES(
    p_cursor OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT P.ID_PEDIDO,
               PROV.NOMBRE AS NOMBRE_PROVEEDOR,
               U.NOMBRE AS USUARIO_CREADOR,
               TO_CHAR(P.FECHA_PEDIDO, 'DD/MM/YYYY HH24:MI') AS FECHA_PEDIDO,
               P.TOTAL,
               P.ESTADO
        FROM PEDIDO P
        JOIN PROVEEDOR PROV ON P.ID_PROVEEDOR = PROV.ID_PROVEEDOR
        JOIN USUARIO U ON P.ID_USUARIO = U.ID_USUARIO
        WHERE UPPER(P.ESTADO) = 'PENDIENTE'
        ORDER BY P.FECHA_PEDIDO DESC;
END SP_LISTAR_PEDIDOS_PENDIENTES;
/

--Procedure SP_LISTAR_PEDIDOS_PENDIENTES compilado

--Stock en bodega

CREATE OR REPLACE PROCEDURE SP_RECIBIR_PEDIDO(
    p_id_pedido IN NUMBER,
    p_id_usuario IN NUMBER,
    p_mensaje OUT VARCHAR2,
    p_resultado OUT NUMBER
)
AS
    CURSOR c_detalles IS
        SELECT dp.ID_PRODUCTO, dp.CANTIDAD
        FROM DETALLE_PEDIDO dp
        WHERE dp.ID_PEDIDO = p_id_pedido;
    
    v_estado VARCHAR2(20);
    v_count NUMBER;
    v_total_productos NUMBER := 0;
BEGIN
    p_resultado := 0;
    
    -- Validar que el pedido exista en el sistema
    SELECT COUNT(*), ESTADO INTO v_count, v_estado 
    FROM PEDIDO WHERE ID_PEDIDO = p_id_pedido
    GROUP BY ESTADO;
    
    IF v_count = 0 THEN
        p_mensaje := 'El pedido no existe';
        p_resultado := 1;
        RETURN;
    END IF;
    
    IF UPPER(v_estado) != 'PENDIENTE' THEN
        p_mensaje := 'El pedido ya fue ' || v_estado;
        p_resultado := 1;
        RETURN;
    END IF;
    
    -- Verificar que el pedido tenga productos
    SELECT COUNT(*) INTO v_count FROM DETALLE_PEDIDO WHERE ID_PEDIDO = p_id_pedido;
    IF v_count = 0 THEN
        p_mensaje := 'El pedido no tiene productos para recibir';
        p_resultado := 1;
        RETURN;
    END IF;
    
    -- Actualizar stock en bodega para cada producto
    FOR detalle IN c_detalles LOOP
        UPDATE PRODUCTO 
        SET STOCK_BODEGA = STOCK_BODEGA + detalle.CANTIDAD
        WHERE ID_PRODUCTO = detalle.ID_PRODUCTO;
        
        -- Registrar movimiento de inventario
        INSERT INTO MOVIMIENTO_INVENTARIO (ID_MOVIMIENTO, ID_PRODUCTO, ID_USUARIO, TIPO_MOVIMIENTO, CANTIDAD, FECHA)
        VALUES (SEQ_MOVIMIENTO.NEXTVAL, detalle.ID_PRODUCTO, p_id_usuario, 'ENTRADA POR PEDIDO', detalle.CANTIDAD, SYSDATE);
        
        v_total_productos := v_total_productos + 1;
    END LOOP;
    
    -- Actualizar estado del pedido y fecha de recepción
    UPDATE PEDIDO 
    SET ESTADO = 'RECIBIDO', FECHA_RECEPCION = SYSDATE
    WHERE ID_PEDIDO = p_id_pedido;
    
    COMMIT;
    p_mensaje := 'Pedido #' || p_id_pedido || ' recibido. Se actualizaron ' || v_total_productos || ' productos en bodega.';
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_mensaje := SQLERRM;
        p_resultado := 1;
END SP_RECIBIR_PEDIDO;
/

--Procedure SP_RECIBIR_PEDIDO compilado

-- Confirmados y cancelados

CREATE OR REPLACE PROCEDURE SP_LISTAR_HISTORIAL_PEDIDOS(
    p_cursor OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT P.ID_PEDIDO,
               PROV.NOMBRE AS NOMBRE_PROVEEDOR,
               U.NOMBRE AS USUARIO_CREADOR,
               TO_CHAR(P.FECHA_PEDIDO, 'DD/MM/YYYY HH24:MI') AS FECHA_PEDIDO,
               TO_CHAR(P.FECHA_RECEPCION, 'DD/MM/YYYY HH24:MI') AS FECHA_RECEPCION,
               P.TOTAL,
               P.ESTADO
        FROM PEDIDO P
        JOIN PROVEEDOR PROV ON P.ID_PROVEEDOR = PROV.ID_PROVEEDOR
        JOIN USUARIO U ON P.ID_USUARIO = U.ID_USUARIO
        WHERE UPPER(P.ESTADO) IN ('RECIBIDO', 'CANCELADO')
        ORDER BY P.FECHA_PEDIDO DESC;
END SP_LISTAR_HISTORIAL_PEDIDOS;
/

--Procedure SP_LISTAR_HISTORIAL_PEDIDOS compilado

--Alerta por stock bajo

CREATE OR REPLACE PROCEDURE SP_ALERTAS_STOCK_BAJO(
    p_cursor OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT M.CODIGO_MAQUINA,
               M.UBICACION,
               P.NOMBRE AS PRODUCTO,
               PM.STOCK_ACTUAL,
               PM.STOCK_MINIMO,
               (PM.STOCK_MINIMO - PM.STOCK_ACTUAL) AS CANTIDAD_NECESARIA
        FROM PRODUCTO_MAQUINA PM
        JOIN MAQUINA M ON PM.ID_MAQUINA = M.ID_MAQUINA
        JOIN PRODUCTO P ON PM.ID_PRODUCTO = P.ID_PRODUCTO
        WHERE PM.STOCK_ACTUAL < PM.STOCK_MINIMO
        ORDER BY (PM.STOCK_MINIMO - PM.STOCK_ACTUAL) DESC;
END SP_ALERTAS_STOCK_BAJO;
/

--Procedure SP_ALERTAS_STOCK_BAJO compilado


--pedido

SET SERVEROUTPUT ON;

-- Listar proveedores
DECLARE
    v_cursor SYS_REFCURSOR;
    v_id NUMBER;
    v_nombre VARCHAR2(100);
    v_contacto VARCHAR2(100);
    v_telefono VARCHAR2(20);
BEGIN
    SP_LISTAR_PROVEEDORES(v_cursor);
    DBMS_OUTPUT.PUT_LINE('*** PROVEEDORES ***');
    LOOP
        FETCH v_cursor INTO v_id, v_nombre, v_contacto, v_telefono;
        EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_id || ' | ' || v_nombre || ' | ' || v_contacto);
    END LOOP;
    CLOSE v_cursor;
END;
/

-- Crear un nuevo pedido
DECLARE
    v_id_pedido NUMBER;
    v_mensaje VARCHAR2(500);
    v_resultado NUMBER;
BEGIN
    SP_CREAR_PEDIDO(1, 1, v_id_pedido, v_mensaje, v_resultado);
    DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_resultado || ' - ' || v_mensaje);
    DBMS_OUTPUT.PUT_LINE('ID del nuevo pedido: ' || v_id_pedido);
END;
/

-- Agregar producto al pedido 
DECLARE
    v_mensaje VARCHAR2(500);
    v_resultado NUMBER;
BEGIN
    SP_AGREGAR_DETALLE_PEDIDO(1, 1, 50, 350, v_mensaje, v_resultado);
    DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_resultado || ' - ' || v_mensaje);
END;
/

-- Listar pedidos pendientes
DECLARE
    v_cursor SYS_REFCURSOR;
    v_id NUMBER;
    v_proveedor VARCHAR2(100);
    v_usuario VARCHAR2(100);
    v_fecha VARCHAR2(20);
    v_total NUMBER;
    v_estado VARCHAR2(20);
BEGIN
    SP_LISTAR_PEDIDOS_PENDIENTES(v_cursor);
    DBMS_OUTPUT.PUT_LINE('*** PEDIDOS PENDIENTES ***');
    LOOP
        FETCH v_cursor INTO v_id, v_proveedor, v_usuario, v_fecha, v_total, v_estado;
        EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Pedido #' || v_id || ' | Proveedor: ' || v_proveedor || ' | Total: ?' || v_total);
    END LOOP;
    CLOSE v_cursor;
END;
/

-- Recibir el pedido
DECLARE
    v_mensaje VARCHAR2(500);
    v_resultado NUMBER;
BEGIN
    SP_RECIBIR_PEDIDO(1, 1, v_mensaje, v_resultado);
    DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_resultado || ' - ' || v_mensaje);
END;
/
--
--*** PROVEEDORES ***
--2 | Alimentos S.A. | María González
--1 | Distribuidora Central | Carlos Rodríguez
--
--Procedimiento PL/SQL terminado correctamente.
--Resultado: 0 - Pedido #2 creado exitosamente
--ID del nuevo pedido: 2
--
--Procedimiento PL/SQL terminado correctamente.
--Resultado: 1 - Solo se pueden agregar productos a pedidos en estado PENDIENTE
--
--Procedimiento PL/SQL terminado correctamente.
--*** PEDIDOS PENDIENTES ***
--Pedido #2 | Proveedor: Distribuidora Central | Total: ?0
--
--Procedimiento PL/SQL terminado correctamente.
--Resultado: 1 - El pedido ya fue RECIBIDO
--
--Procedimiento PL/SQL terminado correctamente.
