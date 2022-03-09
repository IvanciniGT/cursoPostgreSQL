

--Query:
--Nombre de las personas y de las empresas(si tienen) que tienen cursos este mes

--3 tablas:
--Empresas -1-n- Personas -1-n- Inscripciones
--                        INNER
--         RIGHT OUTER JOIN
SELECT 
    Personas.Nombre,
    Personas.Apellidos,
    Empresas.Nombre
FROM
    Empresas 
    RIGHT OUTER JOIN    Personas        ON Personas.EmpresaId = Empresas.Id
    INNER JOIN          Inscripciones   ON Personas.Id = Inscripciones.PersonaId
WHERE 
    extract('month' FROM Inscripciones.Fecha) = extract('month' FROM current_date) and
    extract('year' FROM Inscripciones.Fecha)  = extract('year' FROM current_date)
;

----

-- Query: Listado de todos los cursos con el total de inscripciones
--        que hay para este mes de cada uno
SELECT 
    Personas.Nombre,
    Personas.Apellidos,
    Empresas.Nombre
FROM
    Empresas 
    RIGHT OUTER JOIN    Personas        ON Personas.EmpresaId = Empresas.Id
    INNER JOIN          Inscripciones   ON Personas.Id = Inscripciones.PersonaId
WHERE 
    extract('month' FROM Inscripciones.Fecha) = extract('month' FROM current_date) and
    extract('year' FROM Inscripciones.Fecha)  = extract('year' FROM current_date)
;










INNER JOIN                  Me toma solo los datos que existen en ambas tablas
OUTER JOIN                  
    LEFT OUTER JOIN         Me toma los datos que existen en ambas tablas y 
                            además los que existen solo en la primera
    RIGHT OUTER JOIN        Me toma los datos que existen en ambas tablas y 
                            además los que existen solo en la segunda
    FULL OUTER JOIN         Me toma los datos comunes + los que existen solo en cada una de ellas



