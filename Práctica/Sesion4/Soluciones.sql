/**** Sistemas de Bases de Datos. Sesi�n 4: Disparadores ***/

/*
1.	Se desea llevar un control de las actualizaciones que se realizan sobre una base de datos que 
est� compuesta por las siguientes tablas:
PROYECTO (COD_PROY, NOMBRE, PRESUPUESTO)
DEPARTAMENTO (COD_DPTO, NOMBRE, DIRECCION, NUM_EMPLADOS)
Para ello, se crea una tabla donde se registrar� cada acci�n que se realice sobre las tablas anteriores. 
Dicha tabla tendr� el siguiente esquema:
REGISTRO (FECHA, USUARIO, TABLA, COD_ITEM, ACCION)
En la tabla REGISTRO se incluir� una tupla por cada acci�n que se realice en las tablas anteriores 
que incluir� los siguientes atributos:
-	Fecha en la que se ha realizado la modificaci�n
-	Usuario que ha realizado la acci�n
-	Nombre de la tabla modificada (PROYECTO o DEPARTAMENTO)
-	Clave de la tupla insertada, cambiada o borrada
-	Acci�n que se ha realizado (INSERT, UPDATE o DELETE)

Crear las tres tablas indicadas y los disparadores necesarios para registrar los datos de modificaci�n 
de las tablas.
*/

/* Creaci�n de las tablas */

create table PROYECTO 
(COD_PROY integer not null primary key, 
 NOMBRE varchar(20) not null, 
 PRESUPUESTO decimal(8,2));

create table DEPARTAMENTO 
(COD_DPTO integer not null primary key, 
 NOMBRE varchar (20) not null,
 DIRECCION varchar(30),
 NUM_EMPLEADOS integer default 0 not null);
 
create table REGISTRO
(ID integer not null primary key, 
 FECHA date default sysdate,
 USUARIO varchar(20) not null,
 TABLA varchar(20) not null check (TABLA='PROYECTO' or TABLA='DEPARTAMENTO'),
 COD_ITEM integer not null,
 ACCION char(1) check (ACCION='I' or ACCION='U' or ACCION='D') not null);

/* Creaci�n de secuencia y trigger para generar claves para registro */

create sequence CLAVE_REG;

create trigger CLAVREGISTRO
before insert on REGISTRO 
for each row
BEGIN
select clave_reg.NEXTVAL into :NEW.ID from DUAL;
END;
/

/*Creaci�n de los disparadores: uno por cada tabla y tipo de acci�n */

create trigger INS_PROY
after insert on PROYECTO 
for each row
BEGIN
insert into registro (USUARIO, TABLA, COD_ITEM, ACCION) VALUES (user, 'PROYECTO', :new.cod_proy, 'I');
END;
/

create trigger DEL_PROY
after delete on PROYECTO 
for each row
BEGIN
insert into registro (USUARIO, TABLA, COD_ITEM, ACCION) VALUES (user, 'PROYECTO', :old.cod_proy, 'D');
END;
/

create trigger UPD_PROY
after update on PROYECTO 
for each row
BEGIN
insert into registro (USUARIO, TABLA, COD_ITEM, ACCION) VALUES (user, 'PROYECTO', :old.cod_proy, 'U');
END;
/

create trigger INS_DPT
after insert on DEPARTAMENTO 
for each row
BEGIN
insert into registro (USUARIO, TABLA, COD_ITEM, ACCION) VALUES (user, 'DEPARTAMENTO', :new.cod_dpto, 'I');
END;
/

create trigger DEL_DPT
after delete on DEPARTAMENTO 
for each row
BEGIN
insert into registro (USUARIO, TABLA, COD_ITEM, ACCION) VALUES (user, 'DEPARTAMENTO', :old.cod_dpto, 'D');
END;
/

create trigger UPD_DPT
after update on DEPARTAMENTO 
for each row
BEGIN
insert into registro (USUARIO, TABLA, COD_ITEM, ACCION) VALUES (user, 'DEPARTAMENTO', :old.cod_dpto, 'U');
END;
/


/* SENTENCIAS PARA PROBAR EL FUNCIONAMIENTO DE LOS DISPARADORES ANTERIORES */

insert into proyecto values (100, 'PUENTE', 25000);
update proyecto set presupuesto = presupuesto*1.1 where cod_proy=100;
insert into proyecto values (200, 'PLAZA', 50000);
delete from proyecto where cod_proy= 200;

insert into departamento values (33, 'INFORMATICA', 'GRAN VIA 23', 0);
update departamento set direccion = 'GRAN VIA 55' where cod_dpto=33;
insert into departamento values (77, 'CONTABILIDAD', 'PLAZA DEL OESTE 23', 0);
delete from departamento where cod_dpto= 33;

/* Probamos que se registran correctamente las eliminaciones de varias tuplas hechas en una �nica sentencia */
insert into proyecto values (250, 'CASA GRANDE', 15000);
insert into proyecto values (300, 'ROTONDA', 26000);
insert into proyecto values (350, 'CAMINO', 32000);
insert into proyecto values (400, 'ACERA', 18000);
delete from proyecto where cod_proy > 300;

select * from registro;


/*
2.	Crear una nueva tabla EMPLEADO (DNI, NOMBRE, APELLIDO, COD_DEPTO). 
Crear los disparadores precisos para que el atributo derivado NUM_EMPLEADOS de la tabla 
DEPARTAMENTO se mantenga consistente  con el contenido de la tabla EMPLEADOS de modo autom�tico.
*/

create table EMPLEADO 
(DNI integer not null primary key, 
 NOMBRE varchar (20),
 APELLIDO varchar (30),
 COD_DEPTO integer references DEPARTAMENTO);

create trigger DEL_EMP
after delete on EMPLEADO 
for each row
when (old.cod_depto is not null)
BEGIN
update DEPARTAMENTO set num_empleados=num_empleados-1 where cod_dpto=:old.cod_depto;
END;
/

create trigger UPD_EMP
after update of cod_depto on EMPLEADO 
for each row
when (new.cod_depto is not null or old.cod_depto is not null)
BEGIN
update DEPARTAMENTO set num_empleados=num_empleados+1 where cod_dpto=:new.cod_depto;
update DEPARTAMENTO set num_empleados=num_empleados-1 where cod_dpto=:old.cod_depto;
END;
/

/* Sentencias para probar estos disparadores */

/* Creamos tres departamentos sin empleados */
insert into departamento values (33, 'INFORMATICA', 'GRAN VIA 23', 0);
insert into departamento values (53, 'ANALISIS', 'PLAZA DE CUBA 18', 0);
insert into departamento values (83, 'VENTAS', 'CALLE ANCHA 35', 0);

/* Insertamos 5 nuevos empleados, 2 para uno de los departamentos y tres para otro */
insert into empleado values (123456, 'PATRICIA', 'PEREZ', 33);
insert into empleado values (456789, 'RAMIRO', 'RODRIGUEZ', 33);
insert into empleado values (147258, 'MARTA', 'MARTIN', 53);
insert into empleado values (258369, 'SERGIO', 'SERRANO', 53);
insert into empleado values (963741, 'BELEN', 'BENITO', 53);

/* Comprobamos que se han actualizado los n�meros de empleados en la tabla DEPARTAMENTO */
select * from departamento;

/* Cambiamos a un empleado de departamento */
update empleado set cod_depto=83 where dni=147258;
select * from departamento;

/* Borramos un empleado */
delete from empleado where dni=963741;
select * from departamento;

/* Prueba con un empleado que no se asigna a ning�n departamento y luego se modifica para asignarlo a uno */
insert into empleado values (1564862, 'ALBERTO', 'ALVAREZ', null);
select * from departamento;

update empleado set cod_depto=83 where dni=1564862;
select * from departamento;

update empleado set cod_depto=null where dni=1564862;
select * from departamento;


/*
3.	Crear dos tablas con los mismos esquemas de las tablas DISPONE y la tabla PRESTAMO de la base de datos 
	usada en las pr�cticas (no es necesario definir en ellas  las claves externas correspondientes al resto de las 
	tablas de la base de datos de pr�cticas). Crear los disparadores necesarios para que el atributo derivado 
	NUM_DISPONIBLES de la tabla creada a imagen de DISPONE se mantenga consistente de manera autom�tica. 
	Se desea impedir que en la tabla creada a imagen de PRESTAMO se realicen modificaciones sobre las columnas 	ISBN o COD_SUC. 
	Crear un disparador que garantice que no se producir�n modificaciones de este tipo.
*/

CREATE TABLE MI_DISPONE (
Cod_Suc integer not null ,  
ISBN varchar(10) not null, 
Num_Ejemplares integer, 
Num_Disponibles integer,
primary key (Cod_Suc, ISBN),
check (Num_Disponibles <= Num_Ejemplares AND Num_Disponibles >=0 AND Num_Ejemplares >=0)
);

CREATE TABLE MI_PRESTAMO (
Codigo integer not null primary key, 
Cod_Lector integer not null , 
ISBN varchar(10) not null, 
Cod_Suc integer not null, 
Fecha_Ini date not null, 
Fecha_Dev date,
foreign key (Cod_Suc, ISBN) references mi_dispone (Cod_Suc, ISBN)
);

/* Rellenamos inicialmente las tablas con los mismos datos de las tablas DISPONE y PRESTAMO originales */

insert into MI_DISPONE select * from dispone;
insert into MI_PRESTAMO select * from prestamo;

/* Triggers para el mantenimiento del atributo derivado NUM_DISPONIBLES de MI_DISPONE */

create or replace trigger INS_MIPRES
after insert on MI_PRESTAMO 
for each row
when (new.fecha_dev is null)
BEGIN
update MI_DISPONE set num_disponibles=num_disponibles-1 where ISBN=:new.ISBN and cod_suc=:new.cod_suc;
END;
/

create or replace trigger DEL_MIPRES
after delete on MI_PRESTAMO 
for each row
when (old.fecha_dev is null)
BEGIN
update MI_DISPONE set num_disponibles=num_disponibles+1 where ISBN=:old.ISBN and cod_suc=:old.cod_suc;
END;
/

create or replace trigger UPD_FDEV_MIPRES
after update of FECHA_DEV on MI_PRESTAMO 
for each row
when (old.fecha_dev is null and new.fecha_dev is not null)
BEGIN
update MI_DISPONE set num_disponibles=num_disponibles+1 where ISBN=:old.ISBN and cod_suc=:old.cod_suc;
END;
/

create or replace trigger UPD_MIPRES
after update of COD_SUC, ISBN on MI_PRESTAMO 
for each row
BEGIN
raise_application_error(-20000, 'OPERACION NO PERMITIDA');
END;
/


/* Comprobamos el funcionamiento de los triggers  simulando prestamos y devoluciones de libros */
select * from mi_dispone where cod_suc=17 and isbn='5023876';
insert into mi_prestamo values (919191, 123, '5023876', 17, sysdate, null);
select * from mi_dispone where cod_suc=17 and isbn='5023876';

update mi_prestamo set fecha_dev=sysdate where codigo=919191;
select * from mi_dispone where cod_suc=17 and isbn='5023876';

delete from mi_prestamo where codigo=919191;
select * from mi_dispone where cod_suc=17 and isbn='5023876';

/*
4.	La biblioteca desea incentivar los h�bitos de lectura de sus socios estableciendo una clasificaci�n de los mismos en funci�n 
	del n�mero de prestamos que han realizado. Solo se incluir�n en la clasificaci�n aquellos lectores que hayan realizado 
	como m�nimo 10 pr�stamos. En el caso de que varios lectores coincidan con el mismo n� de prestamos, se les asignar�n n�meros
	consecutivos en la clasificaci�n sin importar el criterio. 
	Para ello, se desea crear una tabla que contenga las siguientes columnas: n� de orden en la clasificaci�n a fecha de hoy, 
	c�digo del lector y n� de prestamos realizados.
		a.	Crear la tabla anterior tomando como clave primaria el n� de orden en la clasificaci�n.
		b.	Crear una secuencia que se utilizar� para obtener los valores de la clave primaria de la tabla anterior.
		c.	Crear un trigger que genere de forma autom�tica durante la inserci�n los valores para la clave de la tabla.
		d.	Rellenar la tabla con los valores correspondientes a partir del contenido de la Base de Datos en el momento actual.
*/

create table clasificacion (
posicion integer not null primary key,
cod_lector integer not null references lector,
num_prestamos integer not null check (num_prestamos >=10));

create sequence seq_clas;

create or replace trigger TRIG_CLAS
before insert on clasificacion 
for each row
begin
select seq_clas.NEXTVAL into :NEW.posicion from DUAL;
end;
/

insert into clasificacion (cod_lector, num_prestamos)
select cod_lector, count(*) from prestamo
group by cod_lector
having count(*)>=10
order by 2 desc;


/*
5.	Eliminar todos los objetos de la base de datos creados a lo largo de esta sesi�n.
*/


drop trigger CLAVREGISTRO;
drop trigger INS_PROY;
drop trigger DEL_PROY;
drop trigger UPD_PROY;
drop trigger INS_DPT;
drop trigger DEL_DPT;
drop trigger UPD_DPT;
drop table PROYECTO;
drop table DEPARTAMENTO;
drop table REGISTRO;
drop sequence CLAVE_REG;

drop trigger INS_EMP;
drop trigger DEL_EM;
drop trigger UPD_EM;
drop table EMPLEADO;

drop trigger INS_MIPRES;
drop trigger DEL_MIPRES;
drop trigger UPD_FDEV_MIPRES;
drop trigger UPD_MIPRES
drop table MI_DISPONE;
drop table MI_PRESTAMO;

drop trigger TRIG_CLAS;
drop table clasificacion;
drop sequence seq_clas;
