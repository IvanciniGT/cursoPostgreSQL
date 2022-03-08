
-- Indice típico para numeros, fechas, textos autocompletar ( busquedas like XXX% )
CREATE INDEX Inscripciones_Fecha_Idx ON Inscripciones(Fecha);

-- Indice invertido. Apto para busquedas de texto completo
CREATE INDEX Cursos_Titulo_Idx ON Cursos USING GIN(to_tsvector('spanish', Titulo));
-- Este tipo de indices, posteriormente hay que usar una funcion especial para activar su uso
-- Función: Titulo @@ to_tsquery('spanish', TEXTO)