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
    