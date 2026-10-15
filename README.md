<div align="center">

# 🗄️ SQLPlus & MongoDB

**Ejercicios comparativos de bases de datos relacionales (Oracle) y NoSQL (MongoDB)**

[![Oracle](https://img.shields.io/badge/Oracle-SQL*Plus-F80000?style=flat&logo=oracle&logoColor=white)](https://www.oracle.com/database/technologies/appdev/sql.html)
[![MongoDB](https://img.shields.io/badge/MongoDB-7.x-47A248?style=flat&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![SQL](https://img.shields.io/badge/SQL-PL%2FSQL-336791?style=flat)](https://en.wikipedia.org/wiki/SQL)
[![Status](https://img.shields.io/badge/Status-Completado-1F7A8C?style=flat)]()

[Descripción](#-sobre-el-proyecto) · [Modelo de datos](#-modelo-de-datos) · [Comparativas](#-comparativas-sql-vs-nosql) · [Capturas](#-capturas) · [Stack](#-stack-tecnológico)

</div>

---

## 📖 Sobre el proyecto

Este repositorio reúne una serie de **ejercicios prácticos** desarrollados durante la asignatura de **Sistemas de Bases de Datos** de la Ingeniería Informática en la Universidad de Salamanca.

El objetivo no era solo aprender a usar dos sistemas distintos, sino **implementar el mismo modelo de datos en dos paradigmas opuestos** y comparar las diferencias reales entre ellos: la rigidez y potencia del **modelo relacional** (Oracle SQL\*Plus) frente a la **flexibilidad y velocidad de lectura** del modelo documental (MongoDB).

Cada ejercicio resuelve el mismo caso de uso en ambos sistemas, lo que permite ver de un vistazo **cómo cambia el código, el modelado y las decisiones de diseño** según el paradigma elegido.

> 📌 **Proyecto académico** desarrollado para la asignatura de *Sistemas de Bases de Datos* (curso 2024-2025).

---

## 📘 Modelo de datos

Los ejercicios se basan en el modelo lógico de una **red de bibliotecas** (esquema `univ`), que incluye libros, autores, sucursales y préstamos.

### Esquema Entidad-Relación

<div align="center">

![Esquema ER](./docs/er-schema.png)

*El esquema completo con la estructura de tablas está en [`docs/tablas.pdf`](./docs/tablas.pdf).*

</div>

### Entidades principales

| Tabla | Descripción |
| :--- | :--- |
| **LIBRO** | Libros con ISBN, título, año de edición y editorial. |
| **AUTOR** | Autores con código, nombre, año de nacimiento y fallecimiento. |
| **NACIONALIDAD** | Nacionalidades de los autores. |
| **EDITORIAL** | Editoriales que publican libros. |
| **ESCRIBE** | Relación N:M entre autores y libros. |
| **SUCURSAL** | Sucursales de la red de bibliotecas. |
| **DISPONE** | Ejemplares disponibles por sucursal. |
| **LECTOR** | Usuarios registrados. |
| **PRESTAMO** | Registro de préstamos activos e históricos. |

---

## ⚖️ Comparativas SQL vs NoSQL

Esta es la parte más interesante del proyecto: **el mismo caso de uso, dos implementaciones**.

### 1. Insertar un libro

<table>
<tr>
<th>🐘 Oracle SQL*Plus</th>
<th>🍃 MongoDB</th>
</tr>
<tr>
<td>

```sql
INSERT INTO LIBRO 
  (ISBN, Titulo, Ano_Edicion, Cod_Editorial)
VALUES 
  ('978-84-376-0494-7', 
   'Cien años de soledad', 
   1967, 
   'ED001');
```

**Ventajas**: validación automática de tipos, integridad referencial con `Cod_Editorial`.

**Inconvenientes**: si mañana quieres añadir un campo, hay que hacer `ALTER TABLE`.

</td>
<td>

```javascript
db.libros.insertOne({
  isbn: "978-84-376-0494-7",
  titulo: "Cien años de soledad",
  ano_edicion: 1967,
  editorial: {
    codigo: "ED001",
    nombre: "Sudamericana"
  },
  generos: ["realismo mágico", "novela"]
});
```

**Ventajas**: esquema flexible, se pueden anidar documentos (editorial dentro del libro).

**Inconvenientes**: hay que garantizar la integridad manualmente.

</td>
</tr>
</table>

### 2. Consultar préstamos activos

<table>
<tr>
<th>🐘 Oracle SQL*Plus</th>
<th>🍃 MongoDB</th>
</tr>
<tr>
<td>

```sql
SELECT l.Nombre AS Lector,
       li.Titulo AS Libro,
       p.Fecha_Prestamo,
       p.Fecha_Devolucion
FROM PRESTAMO p
  JOIN LECTOR l ON p.Cod_Lector = l.Codigo
  JOIN DISPONE d ON p.Cod_Ejemplar = d.Codigo
  JOIN LIBRO li ON d.ISBN = li.ISBN
WHERE p.Fecha_Devolucion IS NULL
ORDER BY p.Fecha_Prestamo DESC;
```

**4 JOINs** para reconstruir la información completa.

</td>
<td>

```javascript
db.prestamos.find(
  { fecha_devolucion: null },
  { 
    lector: 1, 
    "ejemplar.libro.titulo": 1, 
    fecha_prestamo: 1 
  }
).sort({ fecha_prestamo: -1 });
```

**1 consulta**, sin JOINs. Toda la info ya está anidada en el documento.

</td>
</tr>
</table>

### 3. Contar cuántos libros ha escrito cada autor

<table>
<tr>
<th>🐘 Oracle SQL*Plus</th>
<th>🍃 MongoDB</th>
</tr>
<tr>
<td>

```sql
SELECT a.Nombre, COUNT(*) AS Total_Libros
FROM AUTOR a
  JOIN ESCRIBE e ON a.Codigo = e.Cod_Autor
GROUP BY a.Nombre
ORDER BY Total_Libros DESC;
```

**Agregación relacional** con `GROUP BY` y `COUNT`.

</td>
<td>

```javascript
db.autores.aggregate([
  {
    $lookup: {
      from: "escribe",
      localField: "_id",
      foreignField: "cod_autor",
      as: "libros"
    }
  },
  {
    $project: {
      nombre: 1,
      total_libros: { $size: "$libros" }
    }
  },
  { $sort: { total_libros: -1 } }
]);
```

**Pipeline de agregación** con `$lookup` (equivalente a JOIN) y `$size`.

</td>
</tr>
</table>

---

## 🔍 Conceptos trabajados

### En Oracle SQL*Plus

- **Cursores explícitos e implícitos** para procesar resultados fila a fila.
- **Transacciones** con `COMMIT`, `ROLLBACK` y `SAVEPOINT`.
- **Triggers** para validar reglas de negocio e integridad referencial.
- **PL/SQL**: bloques anónimos, procedimientos y funciones.
- **Vistas y sinónimos** para simplificar consultas complejas.
- **Índices** para optimizar el rendimiento.

### En MongoDB

- **Consultas con filtros** (`find`, `findOne`) y proyecciones.
- **Pipeline de agregación** (`$match`, `$group`, `$lookup`, `$sort`).
- **Documentos embebidos** vs **referencias** entre colecciones.
- **Índices** con `createIndex` y análisis con `explain()`.
- **Bulk operations** para inserciones masivas eficientes.

## 🚀 Cómo reproducirlo

### Requisitos

- **Acceso a un servidor Oracle** con el esquema `univ` cargado (o cuenta en [Oracle Live SQL](https://livesql.oracle.com/)).
- **MongoDB 7+** instalado localmente o acceso a [MongoDB Atlas](https://www.mongodb.com/atlas).
- **Cliente SSH** para conectar con el servidor `olivo.usal.es`.

### Conexión a Oracle SQL*Plus

```bash
ssh -l TU_LOGIN olivo.usal.es
sqlplus /@univ
```

Una vez dentro, carga el script de creación de tablas:

```sql
SQL> @scripts/crear_tablas.sql
SQL> @scripts/cargar_datos.sql
```

### Configuración de MongoDB

```bash
mongosh
```

```javascript
use biblioteca_univ
load("scripts/setup_mongodb.js")
```

---

## 🛠️ Stack tecnológico

| Categoría | Tecnología |
| :--- | :--- |
| **Base de datos relacional** | Oracle Database 19c |
| **Cliente SQL** | SQL\*Plus |
| **Lenguajes SQL** | SQL · PL/SQL |
| **Base de datos NoSQL** | MongoDB 7.x |
| **Cliente NoSQL** | mongosh · MongoDB Compass |
| **Consultas NoSQL** | JavaScript (BSON) · Aggregation Pipeline |
| **Acceso remoto** | SSH |
| **Sistema** | Debian/Linux (servidor olivo.usal.es) |

---

## 📂 Estructura del repositorio

```
SQLPlus-MongoDB/
├── Práctica/
│   ├── SQL/
│   │   ├── 01_consultas_basicas.sql
│   │   ├── 02_cursores.sql
│   │   ├── 03_transacciones.sql
│   │   ├── 04_triggers.sql
│   │   └── 05_plsql.sql
│   └── MongoDB/
│       ├── 01_find.js
│       ├── 02_aggregations.js
│       ├── 03_indexes.js
│       └── 04_bulk_ops.js
├── docs/
│   ├── er-schema.png          # Diagrama Entidad-Relación
│   ├── tablas.pdf             # Estructura de tablas
│   ├── memoria.pdf            # Memoria completa
│   └── screenshots/
└── README.md
```

---

## 🎓 Conclusiones

Después de trabajar el mismo modelo en ambos paradigmas, la conclusión es clara: **no hay un paradigma mejor, sino uno más adecuado según el caso**.

| Criterio | Gana Oracle (SQL) | Gana MongoDB (NoSQL) |
| :--- | :--- | :--- |
| **Integridad de datos** | ✅ Constraints, FK, triggers | ⚠️ Hay que garantizarla manualmente |
| **Consultas complejas** | ✅ JOINs potentes | ✅ Aggregation pipeline más expresivo |
| **Velocidad de lectura** | ⚠️ Requiere JOINs | ✅ Documentos anidados sin JOINs |
| **Flexibilidad del esquema** | ❌ Rígido | ✅ Esquema dinámico |
| **Transacciones ACID** | ✅ Robustas y maduras | ✅ Mejoradas desde v4.0 |
| **Escalabilidad horizontal** | ⚠️ Compleja (sharding) | ✅ Nativa (replica sets, sharding) |
| **Madurez del ecosistema** | ✅ +40 años de herramientas | ✅ Moderno y activo |

**Lecciones clave:**

- El **modelado en NoSQL** requiere pensar en las consultas *antes* de diseñar las colecciones. En SQL, el modelo se normaliza primero y las consultas se adaptan después.
- **Anidar vs referenciar** en MongoDB es el equivalente a **normalizar vs desnormalizar** en SQL. La decisión depende del patrón de lectura.
- Los **triggers de Oracle** son potentes pero complejos de depurar. En MongoDB, la lógica vive en la aplicación o en *change streams*.
- **Ambos sistemas son necesarios** en un stack moderno: SQL para transacciones críticas, NoSQL para datos cambiantes y lecturas rápidas.


## 📚 Referencias

- [Oracle — SQL\*Plus User's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqpug/)
- [MongoDB — Manual oficial](https://www.mongodb.com/docs/manual/)
- [MongoDB Aggregation Pipeline](https://www.mongodb.com/docs/manual/core/aggregation-pipeline/)
- [Oracle Live SQL](https://livesql.oracle.com/)

---

## 👤 Autor

**Alberto García Martín** — Ingeniero Informático

- 🌐 Portfolio: [albertogm.dev](https://albertogm.dev)
- 💼 LinkedIn: [in/albertogarciamartin](https://www.linkedin.com/in/albertogarciamartin/)
- 🐙 GitHub: [@albergm02](https://github.com/albergm02)
- 📧 Email: alberto.g.m.0214@gmail.com

---

<div align="center">

**⭐ Si este repositorio te resulta útil para comparar SQL y NoSQL, considera darle una estrella.**

</div>
