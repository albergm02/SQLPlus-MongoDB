// 8. Obtener el número de lectores que hay en cada provincia.
db.LECTOR.aggregate ([{ $group: {_id: "$PROVINCIA", numLectores  } }])

// 9. Obtener los nombres de los lectores y los títulos de los libros que han tenido en
préstamo cada uno de ellos
db.LECTOR.aggregate ([{ $lookup: { from: "LIBRO", localField: "PRESTAMOS.ISBN", foreignField: "ISBN", as: "LEIDOS"}},
                      {$project: { NOMBRE: 1, APE_1: 1, APE_2: 1, TITULOS: "$LEIDOS.TITULO" } }])

// 10. Para cada lector, obtener su nombre y los nombres de los autores de los libros que
ha leído.
db.LECTOR.aggregate ([{ $lookup: { from: "AUTOR", localField: "PRESTAMOS.ISBN", foreignField: "LIBROS.ISBN", as: "AUTORESLEIDOS" }}, 
                      { $project: { NOMBRE: 1, APE_1: 1, APE_2: 1, AUTORES: "$AUTORESLEIDOS"}}, 
                      { $project: { _id: 0, "AUTORES._id": 0, "AUTORES.NACION": 0, "AUTORES.ANO_NAC": 0, "AUTORES.ANO_FALL": 0, "AUTORES.LIBROS": 0}