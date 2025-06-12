Soluciones Sesión 7: PL/SQL. Cursores
EJERCICIOS PROPUESTOS
1. Obtener el número de sucursal, la dirección y provincia de las distintas sucursales de
la biblioteca.
Solución:
SET SERVEROUTPUT ON
DECLARE
 poblacion_suc univ.sucursal.poblacion%TYPE;
 provincia_suc univ.sucursal.provincia%TYPE;
 codigo_suc univ.sucursal.codigo%TYPE;
 CURSOR C1 IS SELECT codigo,poblacion, provincia FROM sucursal;
BEGIN
 DBMS_OUTPUT.PUT_LINE('DIRECCIÓN DE LAS SUCURSALES');
 DBMS_OUTPUT.PUT_LINE(rpad('CODIGO',8, ' ')|| ' ' ||
rpad('POBLACION', 15, ' ')|| chr(9) || rpad('PROVINCIA',15, ' '));
 OPEN C1;
 LOOP
 FETCH C1 INTO codigo_suc, poblacion_suc, provincia_suc;
 EXIT WHEN C1%NOTFOUND;

 DBMS_OUTPUT.PUT_LINE(rpad(codigo_suc,8, ' ')|| ' ' ||
rpad(poblacion_suc, 15, ' ') || chr(9) || rpad(provincia_suc, 15, ' '));

END LOOP;
 CLOSE C1;
END;
/
Nota: obsérvese que para dar formato a la salida se han usado las funciones de Oracle
chr y rpad. Véase en la documentación de Oracle el funcionamiento de estas funciones.
2. Realizar un programa en el que dada una provincia se indique qué sucursales y
poblaciones de dicha provincia existen para la biblioteca.
Solución:
set serveroutput on
set verify on
ACCEPT provincia PROMPT 'Introduzca la provincia, por favor: ';
declare
 pobla_suc sucursal.poblacion%TYPE;
 cod_suc sucursal.codigo%TYPE;
 prov sucursal.provincia%TYPE :=&provincia;
 CURSOR C1 IS SELECT codigo, poblacion from sucursal where provincia =
upper(prov);
BEGIN
2
DBMS_OUTPUT.PUT_LINE('CODIGO_SUC'||chr(9) ||'POBLACION_SUC');
 OPEN C1;
 LOOP
 FETCH C1 into cod_suc, pobla_suc;
 EXIT WHEN C1%NOTFOUND;

 DBMS_OUTPUT.PUT_LINE(cod_suc||chr(9)||chr(9) ||pobla_suc);

 END LOOP;
 CLOSE C1;
END;
/
O usando un cursor parametrizado:
declare
 pobla_suc sucursal.poblacion%TYPE;
 cod_suc sucursal.codigo%TYPE;
 CURSOR C1 ( provi sucursal.provincia%TYPE)
 IS SELECT codigo, poblacion from sucursal where provincia = upper(provi);
BEGIN
 DBMS_OUTPUT.PUT_LINE('CODIGO_SUC'||chr(9) ||'POBLACION_SUC');
 OPEN C1 (&PROVINCIA);
 LOOP
 FETCH C1 into cod_suc, pobla_suc;
 EXIT WHEN C1%NOTFOUND;

 DBMS_OUTPUT.PUT_LINE(cod_suc||chr(9)||chr(9) ||pobla_suc);

 END LOOP;
 CLOSE C1;
END;
/
O usando un procedimiento:
create or replace procedure sucprov (provincia sucursal.provincia%type) is
 pobla_suc sucursal.poblacion%TYPE;
 cod_suc sucursal.codigo%TYPE;
 CURSOR C1 ( provi sucursal.provincia%TYPE)
 IS SELECT codigo, poblacion from sucursal where provincia = upper(provi);
BEGIN
 DBMS_OUTPUT.PUT_LINE('CODIGO_SUC'||chr(9) ||'POBLACION_SUC');
 OPEN C1 (provincia);
 LOOP
 FETCH C1 into cod_suc, pobla_suc;
 EXIT WHEN C1%NOTFOUND;

 DBMS_OUTPUT.PUT_LINE(cod_suc||chr(9)||chr(9) ||pobla_suc);

 END LOOP;
 CLOSE C1;
END;
/
exec sucprov ('salamanca')
3
3. Obtener un listado de los lectores que tienen actualmente en préstamo el libro con
identificado por su ISBN, desglosado por sucursales y ordenado alfabéticamente
dentro de cada sucursal.
ISBN: 56893
 SUCURSAL:1
 PEDRO ABARCA MARTIN
 LUIS ALVAREZ BENITO
 JOSE BENITO BERNAL
 MARIA BLANCO MENDEZ
 RAMON CASTILLA TAPIA
 OVIDIO CEREZO CUADRADO
 JOAQUIN DOMINGUEZ MORALES
..................
 SUCURSAL:2
 PEDRO ABARCA MARTIN
 LUIS ALVAREZ BENITO
 JOSE BENITO BERNAL
 MARIA BLANCO MENDEZ
 RAMON CASTILLA TAPIA
 OVIDIO CEREZO CUADRADO
......................
Solución:
CREATE OR REPLACE PROCEDURE PRESTAMOSLIBRO (L_ISBN IN libro.isbn%type) IS
suc univ.prestamo.cod_suc%type;
suc_actual univ.prestamo.cod_suc%type := 0;
nom lector.nombre%type;
ap1 lector.ape_1%type;
ap2 lector.ape_2%type;
CURSOR MICUR (miisbn libro.isbn%type) IS
select cod_suc, nombre, ape_1, ape_2 from univ.prestamo p, lector l
where isbn=miisbn and p.cod_lector=l.codigo and p.fecha_dev is null
order by cod_suc;
BEGIN
DBMS_OUTPUT.PUT_LINE(' ISBN: ' || L_isbn);
open MICUR(L_ISBN);
LOOP
 fetch micur into suc, nom, ap1, ap2;
 exit when micur%notfound;
 if suc <> suc_actual
 then
 suc_actual:=suc;
 DBMS_OUTPUT.PUT_LINE(chr(9)||'SUCURSAL: ' || suc );
 end if;
 DBMS_OUTPUT.PUT_LINE(chr(9)|| chr(9) ||nom||' ' ||ap1||' ' ||ap2);
 END LOOP;
 CLOSE MICUR;
END;
/
exec prestamosLibro ( 5024932)
4
4. Obtener el expediente de préstamos realizados por un lector cualquiera del que se
conoce su código. En el expediente debe aparecer el código y nombre del lector y a
continuación un listado de los libros tomados en préstamo por orden cronológico de
la fecha en la que se inició dicho préstamo. El expediente mostrará el ISBN de
dichos libros, la fecha de devolución, si ha sido devuelto, y la sucursal en la que
realizó dicho préstamo. Al final de dicho expediente se dará el número total de
préstamos realizados y pendientes.
CÓDIGO: 5268 NOMBRE: CASADO LAFUENTE, PEDRO

SUCURSAL ISBN FECHA_INI FECHA_DEV
 11 5025772 26-MAY-91 27-MAY-91
 14 5023732 15-MAY-93 16-MAY-93
 7 5023156 10-SEP-96 27-SEP-96
 1 5025340 05-FEB-97 12-FEB-97
 9 5023096 05-JUN-98 06-JUN-98
 7 5024176 20-DEC-03 28-DEC-03
 6 5023540 14-JUL-04 26-JUL-04
 13 5023048 27-FEB-08 28-FEB-08
 13 5023516 19-JUL-10
 6 5024020 25-SEP-10
 11 5023168 05-AUG-11
 2 5023876 25-SEP-11
NÚMERO TOTAL DE PRÉSTAMOS: 12 PENDIENTES: 4
Solución:
CREATE OR REPLACE FUNCTION TOTALPRESTAMOSLECTOR (COD_L IN lector.codigo%type)
RETURN integer IS
 n integer;
begin
 select count (*) into n from prestamo where cod_lector=cod_l;
 return n;
end;
/
CREATE OR REPLACE FUNCTION PRESTAMOSPENDIENTESLECTOR (COD_L IN
lector.codigo%type)
RETURN integer IS
 n integer;
begin
 select count (*) into n from prestamo where cod_lector=cod_l
 and fecha_dev is null;
 return n;
end;
/
CREATE OR REPLACE PROCEDURE PRESTAMOSLECTOR (COD_L IN lector.codigo%type) IS
suc univ.prestamo.cod_suc%type;
isbn univ.prestamo.isbn%type;
f_i univ.prestamo.fecha_ini%type;
f_d univ.prestamo.fecha_dev%type;
nom lector.nombre%type;
ap1 lector.ape_1%type;
ap2 lector.ape_2%type;
TotalPres integer;
PresPend integer;
5
CURSOR MICUR (lector lector.codigo%type) IS
select cod_suc, isbn, Fecha_ini, fecha_dev from univ.prestamo p
where cod_lector=lector
order by fecha_ini;
BEGIN
select nombre, ape_1, ape_2 into nom, ap1, ap2 from lector where codigo =
cod_l;
DBMS_OUTPUT.PUT_LINE(' CODIGO: ' || COD_L || chr(9) || ' NOMBRE: ' || nom ||
' ' || ap1|| ' ' || ap2);
DBMS_OUTPUT.PUT_LINE('SUCURSAL ' || 'ISBN'|| chr(9) || 'FECHA_INICIO'||
chr(9) ||'FECHA_DEVOLUCION');
open MICUR(COD_L);
LOOP
 fetch micur into suc, isbn, f_i, f_d;
 exit when micur%notfound;
 DBMS_OUTPUT.PUT_LINE(suc || chr(9) || isbn || chr(9) || f_i|| chr(9) ||
f_d);
END LOOP;
CLOSE MICUR;
-- Escribimos los totales haciendo uso de las funciones antes creadas
TotalPres := TOTALPRESTAMOSLECTOR (COD_L);
PresPend := PRESTAMOSPENDIENTESLECTOR (COD_L);
DBMS_OUTPUT.PUT_LINE(' NUMERO TOTAL DE PRESTAMOS: '|| TotalPres|| chr(9) ||
' PENDIENTES: '|| PresPend );
END;
/
exec prestamoslector(94246322)