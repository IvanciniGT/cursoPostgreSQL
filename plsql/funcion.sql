CREATE OR REPLACE FUNCTION letra_dni(numero_dni int4)
RETURNS char AS $$
DECLARE
    letra_devolver char(1);
BEGIN
    -- var tipo valor;
    SELECT LETRA INTO letra_devolver FROM LETRAS_DNI WHERE RESTO=MOD(numero_dni,23);
    RETURN letra_devolver;
END;
$$ LANGUAGE plpgsql;
-- Oracle:  RETURN char IS
-- Oracle / show errors;

CREATE OR REPLACE FUNCTION validar_letra()
RETURNS trigger AS 
$$
BEGIN
    IF ( letra_dni(NEW.numero_dni) <> NEW.letra_dni ) THEN
    -- En caso de que no encajen el calculado y el suministrado... EXPLOSION!!!
        RAISE EXCEPTION 'Letra de control del DNI incorrecta';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

    
-- Trigger: EVENTOS: INSERT or UPDATE
CREATE TRIGGER validador_letra_dni BEFORE INSERT OR UPDATE ON Personas
FOR EACH ROW EXECUTE PROCEDURE validar_letra();
