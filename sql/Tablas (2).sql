create table rol(
    id_rol number primary key,
    nombre varchar2(50) not null,
    descripcion varchar2(200)
);

create table usuario(
    id_usuario number primary key,
    nombre varchar2(100) not null,
    email varchar2(100) not null unique,
    contrasena varchar2(100) not null,
    id_rol number not null,
    fecha_registro date default sysdate,
    constraint fk_usuario_rol foreign key (id_rol) references rol(id_rol)
);

create table categoria(
    id_categoria number primary key,
    nombre varchar2(50) not null unique,
    descripcion varchar2(200)
);

create table proveedor(
    id_proveedor number primary key,
    nombre varchar2(100) not null,
    contacto varchar2(100),
    telefono varchar2(20),
    email varchar2(100) unique,
    direccion varchar2(200),
    constraint check_email_proveedor check (instr(email, '@') > 0)
);

create table producto(
    id_producto number primary key,
    nombre varchar2(100) not null,
    id_categoria number not null,
    id_proveedor number not null,
    precio_costo number(10,2) not null,
    porcentaje_ganancia number(5,2) default 0,
    precio_venta number(10,2),
    stock_bodega number default 0,
    fecha_ingreso date default sysdate,
    constraint fk_producto_categoria foreign key (id_categoria) references categoria(id_categoria),
    constraint fk_producto_proveedor foreign key (id_proveedor) references proveedor(id_proveedor),
    constraint check_precio_costo check (precio_costo > 0),
    constraint check_stock_bodega check (stock_bodega >= 0)
);

create table maquina(
    id_maquina number primary key,
    codigo_maquina varchar2(20) not null unique,
    ubicacion varchar2(100) not null,
    capacidad_maxima number,
    estado varchar2(20) default 'Activa',
    fecha_instalacion date default sysdate,
    constraint check_estado_maquina check (estado in ('Activa', 'Inactiva', 'Mantenimiento'))
);

create table producto_maquina(
    id_producto_maquina number not null,
    id_producto number not null,
    id_maquina number not null,
    stock_actual number default 0,
    stock_minimo number not null,
    fecha_asignacion date default sysdate,
    constraint pk_producto_maquina primary key (id_producto_maquina),
    constraint fk_pm_producto foreign key (id_producto) references producto(id_producto),
    constraint fk_pm_maquina foreign key (id_maquina) references maquina(id_maquina),
    constraint check_pm_stock_actual check (stock_actual >= 0),
    constraint check_pm_stock_minimo check (stock_minimo > 0),
    constraint uk_producto_maquina unique (id_producto, id_maquina)
);

create table pedido(
    id_pedido number primary key,
    id_proveedor number not null,
    id_usuario number not null,
    fecha_pedido date default sysdate,
    fecha_recepcion date,
    estado varchar2(20) default 'Pendiente',
    total number(10,2) default 0,
    constraint fk_pedido_proveedor foreign key (id_proveedor) references proveedor(id_proveedor),
    constraint fk_pedido_usuario foreign key (id_usuario) references usuario(id_usuario),
    constraint check_estado_pedido check (estado in ('Pendiente', 'Recibido', 'Cancelado'))
);

create table detalle_pedido(
    id_detalle number primary key,
    id_pedido number not null,
    id_producto number not null,
    cantidad number not null,
    precio_unitario number(10,2) not null, 
    subtotal number(10,2),
    constraint fk_detalle_pedido foreign key (id_pedido) references pedido(id_pedido),
    constraint fk_detalle_producto foreign key (id_producto) references producto(id_producto),
    constraint check_cantidad_detalle check (cantidad > 0),
    constraint check_precio_unitario check (precio_unitario > 0)
);

create table movimiento_inventario(
    id_movimiento number primary key,
    id_producto number not null,
    id_usuario number not null,
    id_maquina number,
    tipo_movimiento varchar2(50) not null,
    cantidad number not null,
    fecha date default sysdate,
    motivo varchar2(200),
    constraint fk_mov_producto foreign key (id_producto) references producto(id_producto),
    constraint fk_mov_usuario foreign key (id_usuario) references usuario(id_usuario),
    constraint fk_mov_maquina foreign key (id_maquina) references maquina(id_maquina),
    constraint check_tipo_movimiento check (tipo_movimiento in ('Entrada por pedido', 'Recarga a maquina', 'Ajuste manual', 'Venta en maquina')),
    constraint check_cantidad_movimiento check (cantidad > 0)
);

create table venta(
    id_venta number primary key,
    id_producto_maquina number not null,
    id_usuario number not null,
    cantidad number not null,
    precio_unitario number(10,2) not null,
    total number(10,2),
    fecha_venta date default sysdate,
    constraint fk_venta_pm foreign key (id_producto_maquina) references producto_maquina(id_producto_maquina),
    constraint fk_venta_usuario foreign key (id_usuario) references usuario(id_usuario),
    constraint check_cantidad_venta check (cantidad > 0),
    constraint check_precio_venta check (precio_unitario > 0)
);