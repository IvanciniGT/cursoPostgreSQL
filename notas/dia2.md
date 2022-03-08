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