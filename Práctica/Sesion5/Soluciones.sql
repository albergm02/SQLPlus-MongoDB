/**** Sistemas de Bases de Datos. Sesión 6: PL/SQL***/

/*
1.Escribir un bloque PL/SQL que calcule la media de tres números y saque el resultado por pantalla.
*/

SET SERVEROUTPUT ON
DECLARE
     A NUMBER;
     B NUMBER;
     c NUMBER;
     D NUMBER;
     
BEGIN
      A := 2;
      B := 4;
      C := 10;
      D  := (A + B + C)/3;
      DBMS_OUTPUT.PUT_LINE('la media de los valores' );
      DBMS_OUTPUT.PUT_LINE(A ||',' ||B || ' y ' || c || ' es ');
      DBMS_OUTPUT.PUT_LINE(D);
END;
/



/*
2.Escribir un bloque en PL/SQL que acceda a la base de datos UNIV y saque por pantalla
 los datos del autor MARIO VARGAS LLOSA. Realice el tratamiento de errores necesario.
*/

SET SERVEROUTPUT ON -- se mostrarán las salidas por pantalla
DECLARE
     codigo_a univ.autor.codigo%TYPE;
     nombre_a  univ.autor.nombre%TYPE;
     apellido_a univ.autor.apellido%TYPE;
     fecha_nacimiento univ.autor.ano_nac%TYPE;
     fecha_Fall univ.autor.ano_fall%TYPE;
     Nacionalidad univ.autor.cod_nacion%TYPE;
BEGIN
      SELECT *
      INTO codigo_a, nombre_a, apellido_a, fecha_nacimiento, fecha_Fall, Nacionalidad
      FROM univ.autor
      WHERE nombre= 'MARIO' and apellido='VARGAS LLOSA';
      DBMS_OUTPUT.PUT_LINE('Los datos del autor son:');
      DBMS_OUTPUT.PUT_LINE(codigo_a ||'-'|| nombre_a||'-'|| apellido_a||'-'|| fecha_nacimiento||'-'|| fecha_Fall||'-'||Nacionalidad);
EXCEPTION
 -- rutina genérica de tratamiento de cualquier tipo de error
 WHEN others then raise_application_error (-20100,'error#'||sqlcode||' desc#: '|| sqlerrm);
     
END;
/


/*
3.	Escribir un bloque PL/SQL que muestre por pantalla el número total de libros,
 autores, editoriales, sucursales y lectores que hay en la base de datos UNIV. 
    a.	Realice el tratamiento de errores necesario.
    b.	En caso de que el número de lectores supere en un 20% al número de libros.
        Sacar un mensaje por pantalla que indique “Aumentar fondo de préstamo”.

*/

SET SERVEROUTPUT ON -- se mostrarán las salidas por pantalla
DECLARE
    total_libros NUMBER;
    total_editorial NUMBER;
    total_autor NUMBER;
    total_lector NUMBER;
    total_sucursal NUMBER;
BEGIN
     SELECT count(*) INTO total_libros from univ.libro;
     SELECT count(*) INTO total_editorial from univ.editorial;
     SELECT count(*) INTO total_autor from univ.autor;
     SELECT count(*) INTO total_lector from univ.lector;
     SELECT count(*) INTO total_sucursal from univ.sucursal;
     DBMS_OUTPUT.PUT_LINE('El número total de libros es:'|| total_libros);
     DBMS_OUTPUT.PUT_LINE('El número total de editoriales es:'|| total_editorial);
     DBMS_OUTPUT.PUT_LINE('El número total de autores es:'|| total_autor);
     DBMS_OUTPUT.PUT_LINE('El número total de lectores es:'|| total_lector);
     DBMS_OUTPUT.PUT_LINE('El número total de sucursales es:'|| total_sucursal );
  IF (total_lector>(1.2*total_libros)) THEN
   DBMS_OUTPUT.PUT_LINE('AUMENTAR FONDO DE PRESTAMO');
  END IF;
EXCEPTION
 -- rutina genérica de tratamiento de cualquier tipo de error
 WHEN others then raise_application_error (-20100,'error#'||sqlcode||' desc#: '|| sqlerrm);
     
END;
/

/*4.	Se desea llevar un control de las actualizaciones que se realizan sobre una base de datos que está compuesta por las siguientes tablas:
PROYECTO (COD_PROY, NOMBRE, PRESUPUESTO)
DEPARTAMENTO (COD_DPTO, NOMBRE, DIRECCION, NUM_EMPLADOS)
Para ello, se crea una tabla donde se registrará cada acción que se realice sobre las tablas anteriores. Dicha tabla tendrá el siguiente esquema:
REGISTRO (FECHA, USUARIO, TABLA, COD_ITEM, ACCION)
En la tabla REGISTRO se incluirá una tupla por cada acción que se realice en las tablas anteriores y que contendrá los siguientes atributos:
-	Fecha en la que se ha realizado la modificación
-	Usuario que ha realizado la acción
-	Nombre de la tabla modificada (PROYECTO o DEPARTAMENTO)
-	Clave de la tupla insertada, cambiada o borrada
-	Acción que se ha realizado (INSERT, UPDATE o DELETE)
Una vez creadas las tablas en la sesión anterior
a)	Crear  mediante los mecanismos de control del PL/SQL los dos disparadores necesarios para registrar los datos de modificación en cada una
 de las tablas PROYECTO y DEPARTAMENTO. Consultar el contenido de la tabla REGISTRO para comprobar que los disparadores han funcionado correctamente.

*/


/*
5.	Los organizadores de un campamento de verano para niños necesitan disponer de una base de datos para gestionar la información relativa al mismo.
Se establecen las siguientes especificaciones: 
en el campamento se alojarán niños entre los 10 y los 14 años; 
a cada niño interesado en asistir se le abre una ficha de inscripción en la que figuran su nombre y su edad; 
los niños hasta los 12 años serán alojados en cabañas mientras que los niños mayores de 12 años se alojarán en tiendas de campaña; 
estas tiendas y cabañas tienen diferente número de plazas y en ningún caso podrán alojarse en ninguna de ellas un número de niños superior a su capacidad. 
Se deberán escribir las sentencias de DDL necesarias para implementar un diseño de base de datos relacional que garantice el cumplimiento de todas 
las reglas de integridad descritas.
*/

/* Creación de las tablas */

create table alojamiento (
id integer not null primary key,
capacidad integer,
tipo char(1) check (tipo='T' OR tipo='C'));

create table nino (
id integer not null primary key,
nombre varchar(20),
edad integer,
alojado_en integer references alojamiento);


 
/* Creación del disparador de verificación de reglas de integridad */
CREATE OR REPLACE TRIGGER binino
before insert on nino
FOR EACH ROW
when (new.alojado_en is not null)

DECLARE 
   tipoaloj 		alojamiento.tipo%TYPE;
   ocupacion 		integer;
   ocupmax 			integer;
   Mal_Alojamiento 		EXCEPTION;
   Alojamiento_Completo EXCEPTION;
BEGIN
   select tipo, capacidad into tipoaloj, ocupmax from alojamiento where id=:new.alojado_en;

   if tipoaloj='C' and :new.edad > 12 or tipoaloj='T' and :new.edad <= 12
    then raise Mal_Alojamiento;
   end if;

   select count(*) into ocupacion from nino where alojado_en=:new.alojado_en;

   if ocupacion>=ocupmax
    then raise Alojamiento_Completo;
   end if;

EXCEPTION
WHEN Mal_Alojamiento then raise_application_error (-20101,'ERROR Infante alojado en tipo incorrecto');
WHEN Alojamiento_Completo then raise_application_error (-20102,'ERROR El alojamiento asignado está completo');
WHEN others then raise_application_error (-20100,'error#'||sqlcode||'desc#: '|| sqlerrm);
END;
/

/* Inserción de datos de prueba */

insert into alojamiento values (1, 3, 'C');
insert into alojamiento values (2, 3, 'C');
insert into alojamiento values (3, 4, 'T');
insert into alojamiento values (4, 4, 'T');


insert into nino values (1, 'PEPE', 10, 1);
insert into nino values (2, 'JUAN', 11, 1);
insert into nino values (3, 'LOLA', 12, 1);
insert into nino values (4, 'CLARA', 13, 3);
insert into nino values (5, 'INES', 14, 4);

/* Inserciones no validas por violar reglas de integridad */
insert into nino values (6, 'MARIO', 9, 1);
insert into nino values (7, 'JUAN', 13, 2);
insert into nino values (8, 'MARIA', 10, 3);
insert into nino values (9, 'CARLA', 15, 1);