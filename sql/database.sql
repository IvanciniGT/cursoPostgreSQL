-- Cursos
CREATE TABLE Cursos (
    Id          SMALLSERIAL     NOT NULL    PRIMARY KEY,                -- 2
    Duración    SMALLINT        NOT NULL,                               -- 2
    Importe     NUMERIC(7,2)    NOT NULL,                -- 99999,99     -- 12
    Titulo      VARCHAR(100)    NOT NULL                               -- 100
);
-- Empresas
CREATE TABLE Empresas(
    Id          SMALLSERIAL     NOT NULL    PRIMARY KEY,
    CIF         CHAR(10)        NOT NULL,
    Nombre      VARCHAR(100)    NOT NULL
);
-- Personas
CREATE TABLE Personas(
    Id          SERIAL          NOT NULL    PRIMARY KEY,        -- 4
    EmpresaId   SMALLINT,                                       -- 2
    NUMERO_DNI  INTEGER         NOT NULL,
    LETRA_DNI   CHAR(1)         NOT NULL,
    Nombre      VARCHAR(100)    NOT NULL,
    Apellidos   VARCHAR(100)    NOT NULL,
    Email       VARCHAR(100)    NOT NULL,
    FOREIGN KEY (EmpresaId) REFERENCES Empresas(Id)
);

--CARACTERES: 8 digitos + letra
--    8 digitos como caracteres: .... depende de qué?  Juego de caracteres: COLATE
--    UTF-8: Por ser un DNI: 8 bytes
--        En UTF-8 Cuanto ocupa un carácter? De 1 a 4 bytes... Depende del caracter: A,1, ( > 1 byte
--                                                                                   á, ñ: 2 bytes
--                                                                                   chino: 4 bytes
--        En UTF-16: De 2 a 4 bytes
--        En UTF-32: 4 bytes
--    Letra: 1 byte
--    Número : smallint ?? NO
--             int??       4 bytes 

--    Pregunta I:  ¿Quién debe garantizar que la letra corresponda al número? BBDD
--                    Lógica de negocio?
--                    Lógica de datos? 
--    Pregunta II: ¿Quién usa bastante PL/SQL?

-- Inscripciones
CREATE TABLE Inscripciones(
    CursoId     SMALLINT        NOT NULL,       -- 2
    PersonaId   INT             NOT NULL,       -- 4
    Fecha       DATE            NOT NULL,       -- 4
    Aprobado    BOOL            NOT NULL,       -- 1
    PRIMARY KEY (CursoId,PersonaId),
    FOREIGN KEY (CursoId)   REFERENCES Cursos(Id),
    FOREIGN KEY (PersonaId) REFERENCES Personas(Id)
);

-- DNI < Procedimientos almacenados, funciones

