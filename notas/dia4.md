PostgreSQL

Ficheros con las tablas:
Ficheros llevan un acceso aleatorio.
Borramos una fila de una tabla?
    Se queda no solo el hueco... Todos los datos.
    PostgreSQL marcan la fila como eliminada.
    
Liberarlo que implica? Reescribir el fichero entero de la Tabla. TRABAJON !!!!!

# Indices
HASH
    Que se guarda?
        Una huella del dato original
    Cuesta muy poco mantenerlos y ocupan mucho menos
        = 
        <>  FULLSCAN DEL INDICE
    Creación
        CREATE INDEX Inscripciones_Fecha_Idx ON Inscripciones USING HASH(Fecha);
B-TREE      ***** Este es el índice por defecto
    Que se guarda?
        El dato original
    Operaciones:
        <   >   <=  >=  BETWEEN
        =  
        <>  FULLSCAN DEL INDICE
        IS NULL
        IS NOT NULL
        IN
        LIKE 'TEXTO%'
        ~ '^TEXTO'
    Creación:
        CREATE INDEX Inscripciones_Fecha_Idx ON Inscripciones(Fecha);
GIN -    Búsqueda fulltext
    Qué se guarda?
        Un índice invertido
    OPERACIONES ESPECIALES
        @@
    CREATE INDEX Cursos_Titulo_Idx ON Cursos USING GIN(to_tsvector('spanish', Titulo));
BRIN
    Es un poco especial. Es una variante de un B-TREE.
    Orientado a tabals muy grandes de datos
    
TABLA PERSONAS
Id  Nombre  Email   Estado                          DNI         FECHA DE ALTA(INDICE BTREE)
                        1   Alta                    AAAAAA
                        2   Baja                    BBBBBB
                        3   Baja temporal           CCCCCC
                        Esta columna no tiene una tabla de normalización
TOTALMENTE ORDENADOS


10 millones de datos ... query que devuelva 5 millones de datos:      Fecha de alta
    Nombre, apellidos
Se usa el índice? Podría ser... habrá que estudiarlo: EXPLAIN
    Quizás no se usa


Índice ? HASH Estado
11111111 Ubicaciones
22222222 Ubicaciones
33333333 Ubicaciones

índice ? BTREE DNI          LIKE 'AAAAAA%'          Si meto nombre y apellidos OCUPA UN MONTONON... Pero la búsqueda es ULTRARAPIDA
A
    AA
        AAAAAA
        AAAAAB
    AB
B
    BB                  
        BBBBBB          ID2     NOMBRE APELLIDOS
C
    CCCCCC              ID1
    
    ---> 5 Millones de datos IDs desordenados
            Ordenar 5 millones de IDs para luego entrar secuencialmente en el fichero. NI DE COÑA
            Extraer aleatoriamente los datos del fichero segun voy leyendo los ids
            Paso del indice y leo la tabla de arriba a abajo
    
10 millones


# Particionado de tablas

Esto para que sirve? Tener tablas más pequeñas

Estamos particionando tablas?
Estamos agrupando tablas bajo un nombre común?

TABLON: TABLITA A, TABLITA B, TABLITA C
TABLITA A, TABLITA B, TABLITA C: TABLON


Cuando me interesa particionar? 
Siempre? o no?
    Cuando hay muchos datos
    El hecho de que haya muchos datos es condición suficiente para partir la tabla? Condición NECESARIA
        Necesito grupos si no homogéneos... que efectivamente repartan
    Si realmente en los queries voy a atacar solo a una partición
        Al menos la mayoría de queries

TABLA 
    Partición 1 90% Exp. Archivados
    Partición 2 10% Exp. Abiertos
 
    Partición 1 2000-2005 24%
    Particion 2 2005-2010 26%
    Particion 3 2010-2015 25%
    Partición 4 Resto     25%
        Solo el 5% de las busquedas usan fechas? HE HECHO EL CANELO !!!!!
    
    Aunque no busque, hay una ventaja: Mantenimiento y Copias de seguridad
        De lo unico que tengo que hacer backups adicionales es de la ultima partición... Si las otras no cambian.
        ANALIZE < Regenerar estadísticas
        VACCUM  < Compartar datos para liberar espacio
        REINDEX < Regenerar los índices

Compañia de seguros:
    80% de las llamadas/consultas a la BBDD son sobre datos actuales... Partes e incedentes abiertos **** BENEFICIADO
    15% Sobre todos los datos                                                                        **** DEPENDE
                        Puedo salir perjudicado
     5% búsquedas sobre datos antiguos                                                               **** BENEFICIADO


App
    Menu
        Expedientes abiertos    -> filtro estado= abiertos -> particion2
            80%
        Expedientes cerrados    -> filtro estado= cerrados -> particion1
            5%
        Busqueda general        -> No hay filtro -> buscar en particion1+particion2
            15%
                Puede salir perjudicada
                    Juntar dos resulsets UNION ALL
                Sort
                    PostgreSQL llorar en el sort

UNION       DISTINCT (horrible desde punto de vista de rendimiento) < Implica un ORDER
UNION ALL


Me interesa?
    Si uso mucho los datos de la partición 2... DPM !!!!


## LIMITACIONES

### Puedo tener ids repetidos al ser tratadas como tablas diferentes

Al tener la tabla particionada, el PK, debe incluir el campo de particionado
Eso implica que un mismo id (lo que sería para nosotros el PK real) puede aparecer varias veces:
Y no solo en tablas separadas, sino en la misma tabla.

CREATE TABLE personas_alta PARTITION OF personas2 FOR VALUES IN (1,2);
Persona 1,1
Persona 1,2
CREATE TABLE personas_baja PARTITION OF personas2 FOR VALUES IN (3,6);
Persona 1,3
Persona 1,6
CREATE TABLE personas_otros PARTITION OF personas2 DEFAULT; -- el resto
Persona 1,5
Persona 1,4
Persona 1,17

Lo más que me puedo asegurar es tener 1 por tabla y no más de 1 por tabla:
Esto me obliga a crear un UNIQUE KEY (ID) A nivel de cada partición.
CREATE TABLE personas_alta PARTITION OF personas2 FOR VALUES IN (1,2);
Persona 1,1
CREATE TABLE personas_baja PARTITION OF personas2 FOR VALUES IN (3,6);
Persona 1,6
CREATE TABLE personas_otros PARTITION OF personas2 DEFAULT; -- el resto
Persona 1,17
-- El que nos salva en este escenario es el SERIAL / SEQUENCE!
-- El campo es automático

### No puedo defenir en la tabla principal triggers de tipo before

Si que puedo definir esos triggers en cada una de las particiones

### PostgreSQL no crea una partición por defecto.

Como meta un dato que no pueda ir a ninguna tabla precreada... aquello EXPLOTA.
Necesito crear yo la partición por defecto

### Una columna que se use para particionado RANGE no admite valores NULL

# Particionamiento múltiple

PostgreSQL admite PARTICIONAMIENTO MULTIPLE

Tabla1 Particionado por el campo fecha
    < 2005 Particionada por gravedad
        1
        2
        3
    2005 - 2010  Particionada por gravedad
        1
        2
        3
    2010 - 2015 Particionada por gravedad
        1
        2
        3
    > 2015 Particionada por gravedad
        1
        2
        3
        
# Limitación:
Las subtablas deben llevar el mismo esquema de particionado


Por ejemplo, mas cosas sobre particionado:
- Cada tabla particionada la podría guardar en un disco distinto.
    - A efectos de rendimiento no lo debería notar mucho.... El dato está en RAM en caché
    - Al escribir si acaso... solo si estoy saturando el disco

Partición de datos en uso (expedientes abiertos):       NVME
Partoición de datos cerrados que casi ni se consultan : HDD

Una BBDD puede ir lenta por varios motivos:
    Desastre queries
    Falta de indices
    Falta de RAM
    IO en escritura (insert y updates) satura el HDD

El motor quiere subir a RAM: SHARED POOL < 40% del total en una máquina dedicada
    Base de datos (tablas)
    Indices
    Planes de ejecución de queries



# Mantenimiento de la BBDD

Varias operaciones que deben hacerse de continuo en producción. 
Algunas de ellas las hace la BBDD (TODAS)... el problema es CUANDO

## Regeneración de estadísticas

Sobre todo después de cargas masivas lo tengo que hacer

-- Regenera las estadísticas de una tabla solo para unas columnas;
ANALIZE TABLA (COLUMNA1, COLUMNA2, ....);

-- Regenera las estadísticas de una tabla;
ANALIZE TABLA;

-- Regenera las estadísticas totales;
ANALIZE ;
    

TABLA usuarios:
id, nombre, edad, dni, fecha alta
    ******  ****  ***  No cambian con el paso del tiempo sognificativamente
Con el sistema en producción y ya en marcha desde hace tiempo....

Qué estadisticas me interesa recalcular con más frecuencia? PROPORCIONES DE LOS DISTINTOS VALORES DE LOS DATOS
id, fecha de alta

## Compactado de las tablas de la BBDD. Reescribo los ficheros de las tablas:
## Tablas más pequeñas, que ocupan menos en HDD
## Impacto en redimiento cuando leo los datos.

No me interesa que PostgreSQL decida cuando hacerlo, ya que deja la tabla bloqueada... Me interesa programarlo.

VACUUM;
VACUUM TABLA;

VACUUM ANALYZE;
VACUUM ANALYZE TABLA;

Esto deja la tabla bloqueada.

