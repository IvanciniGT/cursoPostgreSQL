-- Personas
CREATE TABLE personas (
    id              SERIAL          NOT NULL PRIMARY KEY, 
    estado          SMALLINT        NOT NULL,
    otros_datos     VARCHAR(100)    NOT NULL
)   PARTITION BY LIST(estado);
-- LIST: Una serie de valores predefinidos sobre los que particionar

CREATE TABLE personas_alta PARTITION OF personas FOR VALUES IN (1);
CREATE TABLE personas_baja PARTITION OF personas FOR VALUES IN (2);
CREATE TABLE personas_otros PARTITION OF personas DEFAULT; -- el resto

INSERT INTO personas (1,'Ivan');
INSERT INTO personas (1,'Carlos');
INSERT INTO personas (2,'Emiliano');
INSERT INTO personas (2,'Gustavo');
INSERT INTO personas (3,'Ramon');
INSERT INTO personas (4,'Jose Luis');
