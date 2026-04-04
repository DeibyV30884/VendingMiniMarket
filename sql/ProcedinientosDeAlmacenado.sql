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
