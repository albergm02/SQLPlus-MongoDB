-- 1. Aumentar en 3 el número de ejemplares del libro con ISBN 5025496 para la sucursal 9
UPDATE DISPONE 
SET Num_Ejemplares = Num_Ejemplares + 3
WHERE ISBN = '5025496' AND Cod_Suc = 9;

-- 2. Actualizar dirección del lector con código 7395860
UPDATE LECTOR 
SET Direccion = 'C/Sevilla, 1', Poblacion = 'Aldeadávila', Provincia = 'Salamanca'
WHERE Codigo = 7395860;

-- 3. Actualizar la sucursal con código 15
UPDATE SUCURSAL 
SET Direccion = 'C/ SAN AGUSTÍN, 10', Poblacion = 'SEGOVIA'
WHERE Codigo = 15;

-- 4. Actualizar direcciones de los lectores
UPDATE LECTOR 
SET Direccion = 'Av. de Alemania, 49', Poblacion = 'Miajadas', Provincia = 'Cáceres'
WHERE Codigo = 71259836;

UPDATE LECTOR 
SET Direccion = 'Daoiz y Velarde, 24', Poblacion = 'Benavente', Provincia = 'Zamora'
WHERE Codigo = 94246322;

-- 5. Insertar el nuevo libro en la base de datos
INSERT INTO LIBRO (ISBN, Titulo, Ano_Edicion, Cod_Editorial) 
VALUES ('8408104829', 'EL PREMIO ERES TÚ', 2001, (SELECT Codigo FROM EDITORIAL WHERE Nombre = 'Planeta'));

INSERT INTO ESCRIBE (ISBN, Cod_Autor)
VALUES ('8408104829', (SELECT Codigo FROM AUTOR WHERE Nombre = 'Javier' AND Apellido = 'Moro'));

INSERT INTO DISPONE (Cod_Suc, ISBN, Num_Ejemplares, Num_Disponibles)
SELECT Codigo, '8408104829', 1, 1 FROM SUCURSAL;

-- 6. Añadir una nueva sucursal en Soria
INSERT INTO SUCURSAL (Codigo, Direccion, Poblacion, Provincia) 
VALUES (16, 'Calle de los Caballeros, 32', 'Soria', 'Soria');

-- 7. Dotar la nueva sucursal con los mismos libros que la sucursal 2
INSERT INTO DISPONE (Cod_Suc, ISBN, Num_Ejemplares, Num_Disponibles)
SELECT 16, ISBN, Num_Ejemplares, Num_Disponibles FROM DISPONE WHERE Cod_Suc = 2;

-- 8. Eliminar al lector Francisco Roldán y sus datos
DELETE FROM PRESTAMO WHERE Cod_Lector = (SELECT Codigo FROM LECTOR WHERE Nombre = 'Francisco' AND Ape_1 = 'Roldán');
DELETE FROM LECTOR WHERE Nombre = 'Francisco' AND Ape_1 = 'Roldán';

-- 9. Incrementar en dos unidades disponibles el libro más prestado
UPDATE DISPONE 
SET Num_Disponibles = Num_Disponibles + 2
WHERE ISBN = (SELECT ISBN FROM PRESTAMO GROUP BY ISBN ORDER BY COUNT(*) DESC LIMIT 1);

-- 10. Incrementar en 1 ejemplar los libros con más de 4 préstamos
UPDATE DISPONE 
SET Num_Ejemplares = Num_Ejemplares + 1
WHERE ISBN IN (SELECT ISBN FROM PRESTAMO GROUP BY ISBN HAVING COUNT(*) > 4);

-- 11. Eliminar todos los préstamos de lectores de Zamora
DELETE FROM PRESTAMO WHERE Cod_Lector IN (SELECT Codigo FROM LECTOR WHERE Provincia = 'Zamora');

