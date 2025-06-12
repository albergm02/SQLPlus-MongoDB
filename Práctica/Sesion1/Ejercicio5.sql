SPOOL listado_libros.lst;

SET PAGESIZE 10;
SET LINESIZE 100;

PROMPT === LISTADO DE LIBROS EN SUCURSALES 1, 2 Y 3 ===

SELECT D.Cod_Suc, S.Direccion, L.ISBN, L.Titulo, D.Num_Ejemplares, D.Num_Disponibles
FROM DISPONE D 
JOIN LIBRO L ON D.ISBN = L.ISBN
JOIN SUCURSAL S ON D.Cod_Suc = S.Codigo
WHERE D.Cod_Suc IN (1, 2, 3)
ORDER BY D.Cod_Suc, L.ISBN;

PAUSE Presiona ENTER para continuar con más libros...

SPOOL OFF;

