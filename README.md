# 📚 Database Systems – University of Salamanca

This repository contains practical exercises developed during the **Database Systems course** of the **Computer Engineering degree** at the **University of Salamanca**. The tasks focus on working with **SQL*Plus (Oracle)** and **MongoDB**, applying database concepts such as:

- ✅ Cursors
- 🔁 Transactions
- 🧠 Triggers
- 🧾 Structured Query Language (SQL)
- 🌱 NoSQL (MongoDB)

---

## 📘 Database Schema

The exercises are based on the following logical model of a **library network database** (`univ` schema). It includes books, authors, branches, and loan records.

### 🧩 Entity-Relationship Model:

> ![ER Schema](https://i.imgur.com/kSkxVbm.png)  

If you want to see the complete table structure, refer to the [`Tablas.pdf`](./Tablas.pdf) provided in the repository.

### 🔢 Tables Used:

- **LIBRO** (`ISBN`, `Titulo`, `Ano_Edicion`, `Cod_Editorial`)
- **AUTOR** (`Codigo`, `Nombre`, `Ano_Nac`, `Ano_Fall`, `Cod_Nacion`)
- **NACIONALIDAD**, **EDITORIAL**, **ESCRIBE**, **SUCURSAL**
- **DISPONE**, **LECTOR**, **PRESTAMO**

---

## 🖥️ SQL*Plus (Oracle DB)

The SQL exercises were conducted using the terminal-based tool **SQL\*Plus**, connecting to the Oracle server:

```bash
ssh -l your_login olivo.usal.es
sqlplus /
