SPOOL listado_libros_parametro.lst;

SET PAGESIZE 30;
SET LINESIZE 100;



ACCEPT cod_suc NUMBER PROMPT 'Introduzca el codigo de la sucursal: ';

PROMPT === Listado de los libros de la sucursal &cod_suc ===

SELECT L.Titulo, D.Num_Ejemplares, D.Num_Disponibles
FROM DISPONE D
JOIN LIBRO L ON D.ISBN = L.ISBN
JOIN SUCURSAL S ON D.Cod_Suc = S.Codigo
WHERE D.Cod_Suc = &cod_suc
ORDER BY L.ISBN;

SET PAUSE ON;
PAUSE Presione ENTER para continuar...

SPOOL OFF;
