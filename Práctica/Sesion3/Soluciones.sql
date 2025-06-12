/*
SISTEMAS DE BASES DE DATOS
SESIÓN 3: Creación /eliminación de índices, vistas y sinónimos. 
		  Privilegios de acceso. Modificación definición de tablas
*/

/*
1.	Se ha observado que una parte importante de las consultas a la base de datos que requieren mejorar su eficiencia acceden 
	a los datos de la tabla LECTOR según el valor de la PROVINCIA. 
	¿Qué podemos hacer para mejorar los tiempos de respuesta de dichas consultas?
*/
create index I_PROV_LECTOR on lector (provincia);

/*
2.	Crear una vista para seleccionar los códigos de los préstamos activos (libros no devueltos) junto a los códigos de los lectores.
*/
create view PRESTAMOSACTIVOS as
select codigo Cod_Prestamo, cod_lector from prestamo where fecha_dev is null;

/*
3.	Crear una vista que liste los libros que se encuentran en la actualidad prestados, incluyendo el ISBN y título. 
	Generar dicha esta vista eliminando las filas duplicadas.
*/
create view LIBROSENPRESTAMO as
select distinct l.ISBN, Titulo from prestamo p, libro l where l.isbn=p.isbn and fecha_dev is null;
/* NOTA: Nótese que si se omite la opción distinct, cada libro aparecerá tantas veces como préstamos activos tenga */


/*
4.	Crear una vista para el fondo de préstamo de la sucursal 3, indicando el ISBN, título del libro 
	y el número de ejemplares asignados y disponibles para dicha sucursal.
*/
create view LIBROSSUC3 as
select l.ISBN, titulo, num_ejemplares, num_disponibles from libro l, dispone d
where l.isbn=d.isbn and cod_suc=3;



/*
5.	Crear una vista que liste todas las columnas de la tabla PRESTAMO para aquellos prestamos finalizados en la sucursal 1.
*/
create view FINALIZADOSSUC1 as
select * from prestamo
where fecha_dev is not null and cod_suc=1;



/*
6.	Usar la vista anterior para insertar una nueva tupla en la tabla PRESTAMO correspondiente a un préstamo iniciado hoy y no finalizado
	 de la sucursal 4. 
	Comprobar la diferencia de comportamiento si la vista está creada con la claúsula WITH CHECK OPTION o no.
*/

insert into FINALIZADOSSUC1 values (10000, 15838332, 5025700, 4, sysdate, NULL);
/* La tupla se inserta sin problemas aunque luego no se puede recuperar con una select sobre esa vista pero sí sobre la tabla PRESTAMOS */
select * from FINALIZADOSSUC1 where codigo=10000; /* No recupera nada */
select * from PRESTAMO where codigo=10000; /* Sí recupera la tupla insertada */

/* Creamos de nuevo la vista con la opción WITH CHECK OPTION y probamos a probar una insercción similar */
drop view FINALIZADOSSUC1;
create view FINALIZADOSSUC1 as
select * from prestamo
where fecha_dev is not null and cod_suc=1
with check option;

insert into FINALIZADOSSUC1 values (10001, 15838332, 5025700, 4, sysdate, NULL);
/* La tupla no se inserta. Se obtiene un mensaje de error :  view WITH CHECK OPTION where-clause violation  */


/*
7.	Modificar la vista anterior de forma que no pueda realizarse ninguna modificación sobre ella. 
	Intentar borrar con esa vista los préstamos finalizados hace más de 5 años. ¿Cuál es la salida?
*/

drop view FINALIZADOSSUC1;
create view FINALIZADOSSUC1 as
select * from prestamo
where fecha_dev is not null and cod_suc=1
with read only;
delete from finalizadossuc1 where fecha_dev < sysdate - 365*5;
/* Al intentar hacer el delete se obtiene un mensaje de error que indica que no es posible hacer ese borrado */

/*
8.	Examínese la diferencia entre tener un privilegio sobre una tabla y tenerlo sobre una vista definida sobre esa tabla. 
	En especial, la manera en que un usuario puede tener un privilegio (por ejemplo SELECT) sobre una vista sin tenerlo 
	también sobre todas las tablas subyacentes.
*/
/* Creamos una tabla cualquiera, por ejemplo una tabla que sea copia de alguna de las de la base de datos                                 */
create table xxx as select * from libro;
/* creamos una vista que use esa tabla                                                                                                    */
create view unavista as select * from xxx;
/* autorizamos a un compañero o a todo el mundo a hacer conultas sobre la vista                                                           */
grant select on unavista to public;
/* ahora, cuando la persona autorizada intente consultar la tabla xxx no podrá hacerlo, pero sí podrá consultar la vista unavista         */
/* recuérdese que quien quiera acceder a la vista o tabla que hemos creado deberá preceder el nombre del objeto con el de nuestro usuario */
/* por ejemplo: select * from OPS$Ixxxxxxx.unavista;                                                                                      */
/* para saber qué usuario somos: select user form dual;                                                                                   */


/*
9.	Crear un sinónimo para la tabla dispone y hacer uso de él para consultar un listado por sucursal de los ISBN que tienen a su disposición.
*/
create synonym MIDISPONE for dispone;
select cod_suc, isbn from midispone order by 1; 


/*
10.	Un análisis de la base de datos muestra que es necesario añadir un campo más a la tabla sucursal, 
	para almacenar el nombre de la sucursal. Haga una copia de la tabla sucural y posteriormente, realice en esa tabla las operaciones necesarias 
	para incluir el nuevo dato.
*/
create table copiasucursal as select * from sucursal;
alter table copiasucursal
add nombre varchar(20); 

/*
11.	Se desea disponer de una nueva tabla AUTORESP que contenga información de los autores de nacionalidad española. 
	En esa tabla, cada autor tendrá un nuevo atributo que llamaremos CodAutorEsp que será la clave primaria de esa tabla. 
	El valor del atributo  CodAutorEsp no tiene por qué coincidir con el código que el autor tenga en la tabla AUTOR. 
	El valor de este código se generará de manera automática mediante una secuencia. 
		a.	Crear la secuencia necesaria.
		b.	Crear la tabla que contenga los siguientes atributos: CodAutorEsp, Nombre, Apellido.
		c.	Rellenar la nueva tabla con los datos de los escritores españoles que se obtengan de la tabla AUTOR.
*/


create sequence clave_autoresp;

create table AUTORESP (
CodAutorEsp		integer not null primary key,
Nombre			VARCHAR(50),
Apellido		VARCHAR(50));

insert into autoresp select clave_autoresp.nextval, nombre, apellido from autor 
where cod_nacion=(select codigo from nacionalidad where nombre='ESPANA');


/*
12.	Crear una relación ANUNCIO que permita que los distintos usuarios de la base de datos inserten anuncios de cualquier tipo. 
	El esquema de la relación será: ANUNCIO (Codigo, autor, texto). 
	El Código deberá ser único y creado automáticamente mediante una secuencia. 
	El atributo autor se rellenará por defecto con el user de quien realice la inserción. 
	Se darán permisos para que cualquier usuario pueda hacer insercciones y consultas en la tabla.
	Probar a insertar alguna tupla en nuestra tabla y también en la creada por algún compañero.
*/

create sequence clave_anuncio;
grant all on clave_anuncio to public;

create table ANUNCIO (
codigo integer not null primary key,
autor  varchar(20) default user,
texto  varchar (30));

grant all on anuncio to public;

insert into anuncio (codigo, texto) values (clave_anuncio.nextval, 'vendo moto barata');
insert into anuncio (codigo, texto) values (clave_anuncio.nextval, 'se pasan trabajos a ordenador');

insert into otrousuario.anuncio (codigo, texto) values (otrousuario.clave_anuncio.nextval, 'compro libros antiguos');


/*
13. Crear una vista MISANUNCIOS que recupere los datos de los anuncios cuyo autor coincida con el usuario 
	que está consultando la vista. Dar los permisos adecuados a dicha vista. 
	Realizar las pruebas del funcionamiento de esta vista cooperando con un compañero. 
	Hay que recordar que varios usuarios pueden crear objetos con el mismo nombre y que se puede acceder a los objetos 
	creados por otros usuarios mediante esquema.objeto, siendo esquema el usuario propietario del objeto.
*/

create view misanuncios as select * from anuncio where autor=user;
grant select on misanuncios to public;

select * from misanuncios;
select * from anuncio;

/*  Si en nuestra tabla, además de nosotros ha insertado tuplas algún compañero, los resultados de las consulta a la vista 
	misanuncios serán distintos de los de la consulta a la tabla anuncio*/



/*
14.	Eliminar todos los índices, vistas, tablas,  sinónimos y secuencias creados en los ejercicios anteriores.
*/
drop index I_PROV_LECTOR;
drop view PRESTAMOSACTIVOS;
drop view LIBROSENPRESTAMO;
drop view LIBROSSUC3;
drop view FINALIZADOSSUC1;
drop view UNAVISTA;
drop table xxx;
drop synonym MIDISPONE;
drop table COPIASUCURSAL;
drop table AUTORESP;
drop view MISANUNCIOS;
drop table ANUNCIO;
drop sequence Clave_autoresp;
drop sequence Clave_anuncio;