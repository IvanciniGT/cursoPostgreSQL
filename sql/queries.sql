

--Query:
--Nombre de las personas y de las empresas(si tienen) que tienen cursos este mes

--3 tablas:
--Empresas -1-n- Personas -1-n- Inscripciones
--                        INNER
--         RIGHT OUTER JOIN
EXPLAIN 
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

-- Inscripciones.Fecha >= Dia 1 de este mes and
-- Inscripciones.Fecha < Dia 1 del proximo mes
-- Inscripciones.Fecha BETWEEN  Dia 1 de este mes AND Dia 1 del proximo mes









-- INNER JOIN                  Me toma solo los datos que existen en ambas tablas
-- OUTER JOIN                  
--    LEFT OUTER JOIN         Me toma los datos que existen en ambas tablas y 
--                            además los que existen solo en la primera
--    RIGHT OUTER JOIN        Me toma los datos que existen en ambas tablas y 
--                            además los que existen solo en la segunda
--    FULL OUTER JOIN         Me toma los datos comunes + los que existen solo en cada una de ellas

SELECT to_tsvector('spanish', 'introducción');

SELECT titulo
FROM CURSOS
WHERE 
 Titulo @@ to_tsquery('spanish','Introducción');


SELECT titulo
FROM CURSOS
WHERE 
 to_tsvector('spanish',Titulo) @@ 'Introducción';

SELECT titulo
FROM CURSOS
WHERE 
 to_tsvector('spanish',Titulo) @@ to_tsquery('spanish','Introducción');

SELECT cfgname FROM pg_ts_config;


--Listado de alumnos que ya han hecho cursos con nosotros (antes de este mes)
DROP VIEW ANTIGUOS_ALUMNOS;
CREATE VIEW ANTIGUOS_ALUMNOS AS
SELECT DISTINCT
    Inscripciones.PersonaId
FROM
    Inscripciones
WHERE 
    Inscripciones.Fecha < TO_DATE( 
                                        CONCAT( '01-', 
                                                 extract('month' FROM current_date), 
                                                 '-',
                                                 extract('year' FROM current_date)
                                        ),
                                        'dd-MM-YYYY');
-- GROUP BY Inscripciones.PersonaId;

-- DISTINCT -> ORDER < Peor que le puedo pedir a una BBDD... mucho peor que un fullscan

-- Una view es como un alias a una query...
-- Cuando solicito usar la view, se lanza la query.. no estña precalculada.
-- Lo que si está precalculado es el plan de ejecución,
-- Así como la compilación(parseo- análisis sintáctico, validación) de la query

-- Listado de cursos y personas que tienen una inscrpicion este mes, y saber si son antiguos alumnos.
-- (Es decir, si en meses anteriores ya han hecho alguna formación)



SELECT
    Cursos.Titulo as Curso,
    Inscripciones.Fecha,
    Personas.Id || ' ' || Personas.Nombre || ' ' || Personas.Apellidos as Persona,
    CASE 
        WHEN ANTIGUOS_ALUMNOS.PersonaId is null THEN 'Nuevo'
        ELSE 'Antiguo'
    END as Antiguo
FROM
    Cursos 
    INNER JOIN Inscripciones ON Cursos.Id = Inscripciones.CursoId
    INNER JOIN Personas ON Inscripciones.PersonaId = Personas.Id
    LEFT OUTER JOIN ANTIGUOS_ALUMNOS ON Personas.Id = ANTIGUOS_ALUMNOS.PersonaId
WHERE 
    Inscripciones.Fecha >= TO_DATE( 
                                        CONCAT( '01-', 
                                                 extract('month' FROM current_date), 
                                                 '-',
                                                 extract('year' FROM current_date)
                                        ),
                                        'dd-MM-YYYY')

                                        -- TO_DATE( texto, formato)
                                        -- CONCAT(str1,str2,str3)
                                        -- str1 || str2 || str3
                                        -- La diferencia entre || concat es como se comportan ante nulos
                                        -- Concat si hay un nulo, lo trata como ""
                                        -- || si hay un nulo, se devuelve nulo de forma global
                                        -- Si str2 es nulo:
                                            -- CONCAT(str1,str2,str3) -> str1str3
                                            -- str1 || str2 || str3.  -> null

SELECT
    Cursos.Titulo as Curso,
    Inscripciones.Fecha,
    Personas.Id || ' ' || Personas.Nombre || ' ' || Personas.Apellidos as Persona,
    CASE 
        WHEN Personas.Id in (
            SELECT PersonaId from ANTIGUOS_ALUMNOS -- WHERE PersonaId = Personas.Id
        ) THEN 'Antiguo'
        ELSE 'Nuevo'
    END as Antiguo
FROM
    Cursos 
    INNER JOIN Inscripciones ON Cursos.Id = Inscripciones.CursoId
    INNER JOIN Personas ON Inscripciones.PersonaId = Personas.Id
WHERE 
    Inscripciones.Fecha >= TO_DATE( 
                                        CONCAT( '01-', 
                                                 extract('month' FROM current_date), 
                                                 '-',
                                                 extract('year' FROM current_date)
                                        ),
                                        'dd-MM-YYYY')