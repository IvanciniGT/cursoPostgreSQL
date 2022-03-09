# Tipos de datos en PostgreSQL

## Numericos

### smallint, int2 

2 bytes con signo:-32768 <> 32767

### integer, int, int4

4 bytes con signo:-2kM <> 2kM

### bigint, int8

8 bytes con signo

### Numeric(Número de dígitos, Decimales)

8 bytes con signo

## Textos

### CHAR(n) , CHARACTER(n)
Textos de longitud finita y constante

### VARCHAR(n)
Textos de longitud variables

### TEXT
Equivalente a un CLOB en Oracle. Textos grandes... de verdad

## Lógicos: Boolean, bool: true / false

## Fechas

### timestamp with[out] time zone <> 8 bytes

Guarda tanto fecha, como hora

### date

Solo fecha, sin información horaria <> 4 bytes

### time with[out] time zone <> 8 bytes

# BYTEA < Equivalente a un BLOB de Oracle

## Serial

### smallserial : Campo con incremento automatico sobre un int2=smallint

### serial : Campo con incremento automatico sobre un int4=int=integer

### bigserial : Campo con incremento automatico sobre un int8=bigint

SELECT lastval();



# Indices:

Tabla de datos

Cursos
Id  Nombre      Importe     Duración
-------------------------------------
1   SQL         1000        10
2   PostgreSQL  2000        20
3   Mysql       1700        23
4   OracleText  2500        35


select * from cursos where importe = 1700;
> FULL SCAN:    Leer la tabla completa fila a fila

Orden de complejidad: O(n)

select * from cursos where id=3;
> INDICE:       Busqueda binaria: Indice

Orden de complejidad: O(log(n))

Diccionario: Abro a la mitad... y veo la palabra... si me he pasado o no...
me quedo solo ya con una mitad.

Para poder hacer una búsqueda binaria, que necesito: Los datos ordenados.
Que tal se le da a un ordenador ordenar valores?     FATAL!!!!

De hecho por eso una BB prefiere hacer un fullscan antes que ordenar para despues aplicar una busqueda binaria.

Que es un índice?

Copia ordenada de los distintos datos de una columna... con ubicaciones.
Un índice se guarda en un fichero aparte de la tabla.

-----------------------
INDICE      FILAS:
-----------------------



1000        1   17      32  44  56


1700        3
1720        6
1850        5

2000        2



2500        4



-----------------------
1000        98  118
-----------------------
Los indices hay que estarlos regenerando de continuo.

Qué pasa si ahora se da de alta una fila nueva en cursos... con el valor 1850?

Estadísticas de la BBDD ... Para saber el mejor sitio por el que partir a la hora de hacer una búsqueda.

Las estadísticas de un a BBDD también hay que regenerarlas de ven en cuando.
    Despues de cargas masivas siempore regenero estadísticas.
    
    
## Ejemplos
Nombre del curso < Indice?

Y si hago muchas busquedas por nombre de empresa?

1000000 de cursos < 

# Query 1

SELECT id 
FROM cursos 
WHERE
    Titulo = 'VALOR';

Me interesa un indice? Me acelera un indice?
SI
Me interesa ese caso? NO me interesa...
Que el usuario va a conocer de antemano los titulos exactos? 
Ni de coña

# Query 2

SELECT id 
FROM cursos 
WHERE
    Titulo LIKE 'VALOR%';   

DNI
CIF
EMAIL

--- Está búsqueda es la típica de los formarios autocompletar
    
Me interesa un indice? Me acelera un indice?
SUPER SI!!!!

# Query 2

SELECT id 
FROM cursos 
WHERE
    UPPER(Titulo) LIKE UPPER('%VALOR%');   

Me interesa un indice? Me acelera un indice?
NO... Ni de coña.

ESTA QUERY NO LA HAGO NI DE COÑA. PROHIBIDO!!!

Indice de tipo FULLTEXT: Texto completo.
Oracle-Text

Aquí se montan índices invertidos.
Texto completo:
    Ignore case
    palabras sueltas
    En cualqueir orden
    Con palabras intermedias
    Quitando acentos
Básicamente la búsqueda que hago en google


## Indices invertidos: GIN

------------------------
Tabla: Cursos
Id  Titulos
------------------------
1    Programación con JAVA
2    Introducción a JAVA
3    JAVA para novatos
4    SQL y JAVA
5    Introducción a SQL
6    POSTGRESQL
------------------------

Contengan: JAVA
...where Titulo LIKE "%JAVA%".. Desde el punto de vista de rendimiento CATASTROFICO

Crear un índice invertido: Normalizo términos
- Quitar acentos
- Cambiar a minusculas
- quitar plurales
- Eliminar "stop words" palabras vacias, que no aportan valor

ESTO ES EL INDICE INVERTIDO: Esto es lo que se guarda.
TERMINOS:           DONDE ESTAN:
introduccion        2(1) 5(1)
java                1(3) 2(3) 3(1) 4(3)
novatos             3(3)
postgresql          6(1)
programacion        1(1)
sql                 4(1) 5(3)



Query: "Introducción al JAVA" -> aplicar las mismas transformaciones:
introduccion -> 2, 5    |
java -> 1, 2, 3, 4      |   -2-

Que palabras se consideran stopwords? En ingles o en español?
Ingles: the, a, an, and, or
Español: Un una uno, unas unos, los las el la, del de con...

Tenemos un monton de diccionarios precargados en postgres... Incluso con SINONIMOS
Yo puedo montar mi propoi diccionario... Para casos raros


1290371289379012739817249879081327409821374987320497123984732

