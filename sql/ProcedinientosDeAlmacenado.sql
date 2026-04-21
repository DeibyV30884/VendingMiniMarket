-- Insertar categirias (Se hizo de primero para poder probar que funcione bien la conexion y el java)
CREATE OR REPLACE PROCEDURE SP_INSERTAR_CATEGORIA(
    VNOMBRE IN VARCHAR2,
    VDESC IN VARCHAR2
)
AS
    VCONT NUMBER;
BEGIN
    SELECT COUNT(*) INTO VCONT
    FROM CATEGORIA
    WHERE UPPER(NOMBRE) = UPPER(VNOMBRE);
    
    IF VCONT > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Ya existe esa categoria');
    END IF;
    
    INSERT INTO CATEGORIA VALUES (
        SEQ_CATEGORIA.NEXTVAL,
        VNOMBRE,
        VDESC
    );
    COMMIT;
END;

-- Una prueba para ver si esta guardando los datos
EXEC SP_INSERTAR_CATEGORIA('Lacteos', 'Leches y quesos');

SELECT * FROM CATEGORIA;





-- Para insertar proveedores

CREATE OR REPLACE PROCEDURE SP_INSERTAR_PROVEEDOR(
    VNOMBRE IN VARCHAR2,
    VCONTACTO IN VARCHAR2,
    VTEL IN VARCHAR2,
    VEMAIL IN VARCHAR2,
    VDIR IN VARCHAR2
)
AS
    VCONT NUMBER;
BEGIN
    -- Validar formato email
    IF FN_VALIDAR_EMAIL(VEMAIL) = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El formato del email no es correcto');
    END IF;

    -- Validar formato telefono
    IF FN_VALIDAR_TELEFONO(VTEL) = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'El telefono tiene que ser con el formato XXXX-XXXX');
    END IF;

    -- Verificar que el email no este duplicado
    SELECT COUNT(*) INTO VCONT
    FROM PROVEEDOR
    WHERE UPPER(EMAIL) = UPPER(VEMAIL);

    IF VCONT > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Ya hay un proveedor con ese email');
    END IF;

    INSERT INTO PROVEEDOR VALUES (
        SEQ_PROVEEDOR.NEXTVAL,
        VNOMBRE,
        VCONTACTO,
        VTEL,
        VEMAIL,
        VDIR
    );
    COMMIT;
END;

-- Prueba
EXEC SP_INSERTAR_PROVEEDOR('PepsiCo CR', 'Luis Mora', '8888-4444', 'luis@pepsico.com', 'Cartago, Costa Rica');
SELECT * FROM PROVEEDOR;





-- Para insertar un nuevo producto
CREATE OR REPLACE PROCEDURE SP_INSERTAR_PRODUCTO(
    VNOMBRE IN VARCHAR2,
    VID_CATEGORIA IN NUMBER,
    VID_PROVEEDOR IN NUMBER,
    VPRECIO_COSTO IN NUMBER,
    VPORCENTAJE_GANANCIA IN NUMBER,
    VSTOCK_BODEGA IN NUMBER
)
AS
BEGIN
    INSERT INTO PRODUCTO VALUES (
        SEQ_PRODUCTO.NEXTVAL,
        VNOMBRE,
        VID_CATEGORIA,
        VID_PROVEEDOR,
        VPRECIO_COSTO,
        VPORCENTAJE_GANANCIA,
        FN_CALCULAR_PRECIO(VPRECIO_COSTO, VPORCENTAJE_GANANCIA),
        VSTOCK_BODEGA,
        SYSDATE
    );
    COMMIT;
END;

-- Prueba
EXEC SP_INSERTAR_PRODUCTO('Pepsi 350ml', 1, 1, 450, 30, 40);
SELECT * FROM PRODUCTO;




-- SP para el login, retorna datos del usuario si las credenciales son correctas
CREATE OR REPLACE PROCEDURE SP_LOGIN(
    VEMAIL    IN  VARCHAR2,
    VPASS     IN  VARCHAR2,
    VNOMBRE   OUT VARCHAR2,
    VROL      OUT VARCHAR2,
    VID_ROL   OUT NUMBER,
    VID_USUARIO OUT NUMBER
)
AS
    VCONT NUMBER;
BEGIN
    SELECT COUNT(*) INTO VCONT
    FROM USUARIO U
    JOIN ROL R ON U.ID_ROL = R.ID_ROL
    WHERE UPPER(U.EMAIL) = UPPER(VEMAIL)
    AND U.CONTRASENA = VPASS;
    
    IF VCONT = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Correo o contraseña incorrectos');
    END IF;
    
    SELECT U.NOMBRE, R.NOMBRE, R.ID_ROL, U.ID_USUARIO
    INTO VNOMBRE, VROL, VID_ROL, VID_USUARIO
    FROM USUARIO U
    JOIN ROL R ON U.ID_ROL = R.ID_ROL
    WHERE UPPER(U.EMAIL) = UPPER(VEMAIL)
    AND U.CONTRASENA = VPASS;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20006, 'Error en el login: ' || SQLERRM);
END;




-- Este SP abre el cursor dinamico
CREATE OR REPLACE PROCEDURE SP_CUR_BUSCAR_PRODUCTOS(
    DATOS OUT SYS_REFCURSOR,
    VCRITERIO IN VARCHAR2
)
AS
    VSQL VARCHAR2(1000);
BEGIN
    VSQL := 'SELECT P.ID_PRODUCTO, P.NOMBRE, C.NOMBRE AS CATEGORIA,
                    PR.NOMBRE AS PROVEEDOR, P.STOCK_BODEGA, P.PRECIO_VENTA
             FROM PRODUCTO P
             JOIN CATEGORIA C ON P.ID_CATEGORIA = C.ID_CATEGORIA
             JOIN PROVEEDOR PR ON P.ID_PROVEEDOR = PR.ID_PROVEEDOR
             WHERE REGEXP_LIKE(P.NOMBRE, :P1, ''i'')
             ORDER BY P.NOMBRE';

    OPEN DATOS FOR VSQL USING VCRITERIO;
END;




-- SP para eliminar, lanza excepcion si tiene stock en maquinas
CREATE OR REPLACE PROCEDURE SP_ELIMINAR_PRODUCTO(VID IN NUMBER)
AS
    VSTOCK NUMBER;
BEGIN
    -- Verifica si tiene stock activo en alguna maquina
    SELECT NVL(SUM(STOCK_ACTUAL), 0) INTO VSTOCK
    FROM PRODUCTO_MAQUINA
    WHERE ID_PRODUCTO = VID;

    IF VSTOCK > 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 
            'No se puede eliminar: el producto tiene stock activo en maquinas.');
    END IF;

    DELETE FROM PRODUCTO WHERE ID_PRODUCTO = VID;
    COMMIT;
END;




CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_PRODUCTO(
    VID IN NUMBER,
    VNOMBRE IN VARCHAR2,
    VPRECIO_COSTO IN NUMBER,
    VPORCENTAJE_GANANCIA IN NUMBER,
    VSTOCK_BODEGA IN NUMBER
)
AS
BEGIN
    UPDATE PRODUCTO SET
        NOMBRE = VNOMBRE,
        PRECIO_COSTO = VPRECIO_COSTO,
        PORCENTAJE_GANANCIA = VPORCENTAJE_GANANCIA,
        PRECIO_VENTA = FN_CALCULAR_PRECIO(VPRECIO_COSTO, VPORCENTAJE_GANANCIA),
        STOCK_BODEGA = VSTOCK_BODEGA
    WHERE ID_PRODUCTO = VID;
    COMMIT;
END;


-- SP Crear pedido (encabezado)
CREATE OR REPLACE PROCEDURE SP_CREAR_PEDIDO(
    VID_PROVEEDOR IN  NUMBER,
    VID_USUARIO   IN  NUMBER,
    VID_PEDIDO    OUT NUMBER
)
AS
BEGIN
    VID_PEDIDO := SEQ_PEDIDO.NEXTVAL;
    INSERT INTO PEDIDO (
        ID_PEDIDO, ID_PROVEEDOR, ID_USUARIO,
        FECHA_PEDIDO, FECHA_RECEPCION, ESTADO, TOTAL
    ) VALUES (
        VID_PEDIDO, VID_PROVEEDOR, VID_USUARIO,
        SYSDATE, NULL, 'Pendiente', 0
    );
    COMMIT;
END;

-- SP Agregar detalles de pedido
CREATE OR REPLACE PROCEDURE SP_AGREGAR_DETALLE_PEDIDO(
    VID_PEDIDO       IN NUMBER,
    VID_PRODUCTO     IN NUMBER,
    VCANTIDAD        IN NUMBER,
    VPRECIO_UNITARIO IN NUMBER
)
AS
BEGIN
    INSERT INTO DETALLE_PEDIDO (
        ID_DETALLE, ID_PEDIDO, ID_PRODUCTO,
        CANTIDAD, PRECIO_UNITARIO, SUBTOTAL
    ) VALUES (
        SEQ_DETALLE_PEDIDO.NEXTVAL,
        VID_PEDIDO,
        VID_PRODUCTO,
        VCANTIDAD,
        VPRECIO_UNITARIO,
        VCANTIDAD * VPRECIO_UNITARIO
    );

    -- Recalcula el total del encabezado
    UPDATE PEDIDO
    SET TOTAL = (
        SELECT NVL(SUM(SUBTOTAL), 0)
        FROM DETALLE_PEDIDO
        WHERE ID_PEDIDO = VID_PEDIDO
    )
    WHERE ID_PEDIDO = VID_PEDIDO;

    COMMIT;
END;


-- SP Resivir pedido
-- Suma stock_bodega y registra movimiento

CREATE OR REPLACE PROCEDURE SP_RECIBIR_PEDIDO(
    VID_PEDIDO  IN NUMBER,
    VID_USUARIO IN NUMBER
)
AS
    VESTADO VARCHAR2(20);
BEGIN
    -- Valida estado actual
    SELECT ESTADO INTO VESTADO
    FROM PEDIDO
    WHERE ID_PEDIDO = VID_PEDIDO;

    IF VESTADO != 'Pendiente' THEN
        RAISE_APPLICATION_ERROR(-20020,
            'El pedido no puede recibirse porque ya fue procesado.');
    END IF;

    -- Recorre el detalle con cursor FOR implícito
    FOR REC IN (
        SELECT ID_PRODUCTO, CANTIDAD, PRECIO_UNITARIO
        FROM DETALLE_PEDIDO
        WHERE ID_PEDIDO = VID_PEDIDO
    ) LOOP
        -- Suma al stock en bodega
        UPDATE PRODUCTO
        SET STOCK_BODEGA = STOCK_BODEGA + REC.CANTIDAD
        WHERE ID_PRODUCTO = REC.ID_PRODUCTO;

        -- Registra el movimiento de inventario
        -- id_maquina es NULL porque es entrada por pedido, no recarga
        INSERT INTO MOVIMIENTO_INVENTARIO (
            ID_MOVIMIENTO, ID_PRODUCTO, ID_USUARIO,
            ID_MAQUINA, TIPO_MOVIMIENTO, CANTIDAD,
            FECHA, MOTIVO
        ) VALUES (
            SEQ_MOVIMIENTO.NEXTVAL,
            REC.ID_PRODUCTO,
            VID_USUARIO,
            NULL,
            'Entrada por pedido',
            REC.CANTIDAD,
            SYSDATE,
            'Recepcion de pedido #' || VID_PEDIDO
        );
    END LOOP;

    -- Marca el pedido como recibido
    UPDATE PEDIDO
    SET ESTADO = 'Recibido',
        FECHA_RECEPCION = SYSDATE
    WHERE ID_PEDIDO = VID_PEDIDO;

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20022, 'El pedido no existe.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20023, 'Error al recibir pedido: ' || SQLERRM);
END;

-- SP Cancelar pedido (solo ADMIN desde Java)

CREATE OR REPLACE PROCEDURE SP_CANCELAR_PEDIDO(VID_PEDIDO IN NUMBER)
AS
    VESTADO VARCHAR2(20);
BEGIN
    SELECT ESTADO INTO VESTADO
    FROM PEDIDO
    WHERE ID_PEDIDO = VID_PEDIDO;

    IF VESTADO != 'Pendiente' THEN
        RAISE_APPLICATION_ERROR(-20021,
            'Solo se pueden cancelar pedidos en estado Pendiente.');
    END IF;

    UPDATE PEDIDO
    SET ESTADO = 'Cancelado'
    WHERE ID_PEDIDO = VID_PEDIDO;

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20024, 'El pedido no existe.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20025, 'Error al cancelar: ' || SQLERRM);
END;


CREATE SEQUENCE SEQ_MAQUINA START WITH 1 INCREMENT BY 1;

-- SP para insertar maquina
CREATE OR REPLACE PROCEDURE SP_INSERTAR_MAQUINA(
    VCODIGO     IN VARCHAR2,
    UBICACION   IN VARCHAR2,
    VCAPACIDAD  IN NUMBER,
    VESTADO     IN VARCHAR2
)
AS
    VCONT NUMBER;
BEGIN
    -- Verificar codigo duplicado
    SELECT COUNT(*) INTO VCONT
    FROM MAQUINA
    WHERE UPPER(CODIGO_MAQUINA) = UPPER(VCODIGO);
    
    IF VCONT > 0 THEN
        RAISE_APPLICATION_ERROR(-20030, 
            'Ya existe una máquina con ese código.');
    END IF;

    -- Validar estado
    IF VESTADO NOT IN ('Activa', 'Inactiva', 'Mantenimiento') THEN
        RAISE_APPLICATION_ERROR(-20031, 
            'Estado inválido. Use: Activa, Inactiva o Mantenimiento.');
    END IF;

    INSERT INTO MAQUINA (
        ID_MAQUINA, CODIGO_MAQUINA, UBICACION, 
        CAPACIDAD_MAXIMA, ESTADO, FECHA_INSTALACION
    ) VALUES (
        SEQ_MAQUINA.NEXTVAL, VCODIGO, UBICACION,
        VCAPACIDAD, VESTADO, SYSDATE
    );
    COMMIT;
END;


CREATE OR REPLACE PROCEDURE SP_RECARGAR_PRODUCTO(
    VID_MAQUINA  IN NUMBER,
    VID_PRODUCTO IN NUMBER,
    VCANTIDAD    IN NUMBER,
    VID_USUARIO  IN NUMBER
)
AS
    -- Variables para recibir el FETCH
    VCODIGO_MAQ    VARCHAR2(20);
    VNOMBRE_PROD   VARCHAR2(100);
    VSTOCK_BODEGA  NUMBER;
    VSTOCK_ACTUAL  NUMBER;
    VCAPACIDAD_MAX NUMBER;
    VID_PM         NUMBER;

    -- Cursor: recibe lo que retorna la función (igual que el profesor)
    CUR SYS_REFCURSOR;
BEGIN
    -- Validar cantidad positiva
    IF VCANTIDAD <= 0 THEN
        RAISE_APPLICATION_ERROR(-20040,
            'La cantidad a recargar debe ser mayor a cero.');
    END IF;

    -- Llamar la función y recibir el cursor (patrón del profesor)
    CUR := FN_CUR_DATOS_RECARGA(VID_MAQUINA, VID_PRODUCTO);
    FETCH CUR INTO VCODIGO_MAQ, VNOMBRE_PROD,
                   VSTOCK_BODEGA, VSTOCK_ACTUAL,
                   VCAPACIDAD_MAX, VID_PM;
    CLOSE CUR;

    -- Validar que se encontró el registro
    IF VID_PM IS NULL THEN
        RAISE_APPLICATION_ERROR(-20042,
            'El producto no está asignado a esa máquina.');
    END IF;

    -- Validar stock suficiente en bodega
    IF VSTOCK_BODEGA < VCANTIDAD THEN
        RAISE_APPLICATION_ERROR(-20041,
            'Stock en bodega insuficiente. Disponible: ' || VSTOCK_BODEGA);
    END IF;

    -- Validar que no supere la capacidad máxima
    IF (VSTOCK_ACTUAL + VCANTIDAD) > VCAPACIDAD_MAX THEN
        RAISE_APPLICATION_ERROR(-20044,
            'Supera capacidad maxima. ' ||
            'Capacidad: ' || VCAPACIDAD_MAX ||
            ' | Stock actual: ' || VSTOCK_ACTUAL ||
            ' | Maximo a recargar: ' || (VCAPACIDAD_MAX - VSTOCK_ACTUAL));
    END IF;

    -- Descontar de bodega
    UPDATE PRODUCTO
    SET STOCK_BODEGA = STOCK_BODEGA - VCANTIDAD
    WHERE ID_PRODUCTO = VID_PRODUCTO;

    -- Sumar a la máquina
    UPDATE PRODUCTO_MAQUINA
    SET STOCK_ACTUAL = STOCK_ACTUAL + VCANTIDAD
    WHERE ID_PRODUCTO_MAQUINA = VID_PM;

    -- Registrar movimiento
    INSERT INTO MOVIMIENTO_INVENTARIO (
        ID_MOVIMIENTO, ID_PRODUCTO, ID_USUARIO,
        ID_MAQUINA, TIPO_MOVIMIENTO, CANTIDAD,
        FECHA, MOTIVO
    ) VALUES (
        SEQ_MOVIMIENTO.NEXTVAL,
        VID_PRODUCTO,
        VID_USUARIO,
        VID_MAQUINA,
        'Recarga a maquina',
        VCANTIDAD,
        SYSDATE,
        'Recarga: ' || VNOMBRE_PROD || ' en maquina ' || VCODIGO_MAQ
    );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        IF CUR%ISOPEN THEN
            CLOSE CUR;
        END IF;
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20043, 'Error en recarga: ' || SQLERRM);
END SP_RECARGAR_PRODUCTO;



CREATE OR REPLACE PROCEDURE SP_ASIGNAR_PRODUCTO_MAQUINA(
    VID_MAQUINA   IN NUMBER,
    VID_PRODUCTO  IN NUMBER,
    VSTOCK_MINIMO IN NUMBER
)
AS
    VCODIGO_MAQ    VARCHAR2(20);
    VCAPACIDAD_MAX NUMBER;
    VCONT          NUMBER;
    CUR            SYS_REFCURSOR;
BEGIN
    IF VSTOCK_MINIMO <= 0 THEN
        RAISE_APPLICATION_ERROR(-20050,
            'El stock mínimo debe ser mayor a cero.');
    END IF;

    -- Patrón del profesor: función retorna cursor, SP hace FETCH/CLOSE
    CUR := FN_CUR_DATOS_MAQUINA(VID_MAQUINA);
    FETCH CUR INTO VCODIGO_MAQ, VCAPACIDAD_MAX;
    CLOSE CUR;

    IF VCODIGO_MAQ IS NULL THEN
        RAISE_APPLICATION_ERROR(-20051, 'La máquina no existe.');
    END IF;

    SELECT COUNT(*) INTO VCONT
    FROM PRODUCTO_MAQUINA
    WHERE ID_MAQUINA  = VID_MAQUINA
      AND ID_PRODUCTO = VID_PRODUCTO;

    IF VCONT > 0 THEN
        RAISE_APPLICATION_ERROR(-20052,
            'Ese producto ya está asignado a la máquina ' || VCODIGO_MAQ || '.');
    END IF;

    INSERT INTO PRODUCTO_MAQUINA (
        ID_PRODUCTO_MAQUINA, ID_PRODUCTO, ID_MAQUINA,
        STOCK_ACTUAL, STOCK_MINIMO, FECHA_ASIGNACION
    ) VALUES (
        SEQ_PRODUCTO_MAQUINA.NEXTVAL,
        VID_PRODUCTO,
        VID_MAQUINA,
        0,
        VSTOCK_MINIMO,
        SYSDATE
    );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        IF CUR%ISOPEN THEN CLOSE CUR; END IF;
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20053,
            'Error al asignar producto: ' || SQLERRM);
END SP_ASIGNAR_PRODUCTO_MAQUINA;