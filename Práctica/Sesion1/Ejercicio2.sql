-- Abrimos el spool para guardar la salida en un archivo de texto
SPOOL listado_prestamos.lst;

-- Consulta que lista los préstamos ordenados por sucursal y fecha
SELECT P.Cod_Suc, S.Direccion, P.ISBN, P.Cod_Lector, P.Fecha_Ini, P.Fecha_Dev
FROM PRESTAMO P
JOIN SUCURSAL S ON P.Cod_Suc = S.Codigo
ORDER BY P.Cod_Suc, P.Fecha_Ini;

-- Cerramos el spool para finalizar la escritura en el archivo
SPOOL OFF;