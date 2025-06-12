SPOOL autores_nacionales.lst;

SET PAGESIZE 20;
SET LINESIZE 150;

PROMPT === LISTADO DE AUTORES CON FECHA CONOCIDA Y SU NACIONALIDAD ===

SELECT A.Nombre, A.Apellido, N.Nombre AS Nacionalidad, A.Ano_Nac, A.Ano_Fall
FROM AUTOR A 
JOIN NACIONALIDAD N ON A.Cod_Nacion = N.Codigo
WHERE A.Ano_Nac IS NULL OR A.Ano_Fall IS NULL
ORDER BY A.Apellido;

SPOOL OFF;