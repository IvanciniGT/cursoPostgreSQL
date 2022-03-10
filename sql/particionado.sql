-- Personas
CREATE TABLE personas2 (
    id              SERIAL          NOT NULL, 
    estado          SMALLINT        NOT NULL,
    otros_datos     VARCHAR(100)    NOT NULL,
    PRIMARY KEY (id, estado)
)   PARTITION BY LIST(estado);
-- LIST: Una serie de valores predefinidos sobre los que particionar

CREATE TABLE personas_alta PARTITION OF personas2 FOR VALUES IN (1);
CREATE TABLE personas_baja PARTITION OF personas2 FOR VALUES IN (2);
CREATE TABLE personas_otros PARTITION OF personas2 DEFAULT; -- el resto

INSERT INTO personas2 (estado,otros_datos) VALUES (1,'Ivan');
INSERT INTO personas2 (estado,otros_datos) VALUES (1,'Carlos');
INSERT INTO personas2 (estado,otros_datos) VALUES (2,'Emiliano');
INSERT INTO personas2 (estado,otros_datos) VALUES (2,'Gustavo');
INSERT INTO personas2 (estado,otros_datos) VALUES (3,'Ramon');
INSERT INTO personas2 (estado,otros_datos) VALUES (4,'Jose Luis');