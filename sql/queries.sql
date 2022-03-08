

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
    INNER JOIN          Inscripciones   ON Personas.Id = Inscripciones.PersonasId
WHERE 
    extract('month',Inscripciones.Fecha) = extract('month', current_date) and
    extract('year',Inscripciones.Fecha)  = extract('year', current_date)
;

----

-- Query: Listado de todos los cursos con el total de inscripciones
--        que hay para este mes de cada uno

SELECT  
    Cursos.Titulo,
    COUNT(*) as Inscripciones,
FROM
    Cursos 
    LEFT OUTER JOIN Inscripciones ON Cursos.Id = Inscripciones.CursoId    
WHERE 
    extract('month',Inscripciones.Fecha) = extract('month', current_date) and
    extract('year',Inscripciones.Fecha)  = extract('year', current_date)










INNER JOIN                  Me toma solo los datos que existen en ambas tablas
OUTER JOIN                  
    LEFT OUTER JOIN         Me toma los datos que existen en ambas tablas y 
                            además los que existen solo en la primera
    RIGHT OUTER JOIN        Me toma los datos que existen en ambas tablas y 
                            además los que existen solo en la segunda
    FULL OUTER JOIN         Me toma los datos comunes + los que existen solo en cada una de ellas



