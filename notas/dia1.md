# Contenedor

"Es un entorno aislado dentro de un SO. Linux donde ejecutar procesos."

Entorno aislado: 
- Tiene su propia configuración de RED -> Propia IP
- Sus propias variables de entorno independientes de las del host
- Tiene su proipio sistema de archivos
- Puede tener limitación de acceso a recursos HW de la máquina donde corre

Contenedor me permite conseguir algunas de las cosas que habiitualmente conseguimos mediante el uso de Maquinas virtuales.

App1     | App2 + App3
--------------------
C 1      | C 2
--------------------
    Gestor de Contenedores: Docker + Podman + Crio + Containerd
--------------------
    SO Kernel "Linux"
--------------------
    HIERRO

Contenedor en Windows? Si... pero con truco
Docker desktop for windows -> hyperv MV con un kernel de linux corriendo en el que se ejecutan los contenedores
Docker desktop for mac

# Dentro de un contenedor podemos tener corriendo TODOS LOS PROCESOS QUE QUERAMOS

# Tipos de software
SO
Driver
Aplicación          Software que ejecuto en primer plano y atiende peticiones de usuarios (personas físicas)
-------------------
Servicio            Software que corre en 2º plano... pero que abre un puerto para la comunicación con otros programas
                    Está atendiendo peticiones de otros programas.
                    Se ejecutan de forma indefinida en el tiempo.
Demonio             Software que corre en 2º plano... y actua según le viene bien
                    Se ejecutan de forma indefinida en el tiempo.
Script              Software que corre, hace sus tareas (secuencia de tareas) y acaba
Comando             Software que corre, hace su tarea y acaba

Cuando creamos un contenedor, lo hacemos desde una IMAGEN DE CONTENEDOR.

Las imágenes de contenedor:
Un triste fichero .tar que contiene una serie de caretas y archivos.
Una imágen de contenedor lleva dentro un programa YA INSTALADO por alguien.
Las imágenes de contenedor se diseñan de tal forma que admiten cierta parametrización:
- A través de variables de entorno
- A través de la inyección de ficheros de configuración

Las imágenes de contenedor se distribuyen a través de REGISTRIES DE REPOSITORIOS DE IMAGENES DE CONTENDOR:
>docker hub

# Observaciones
- Un contenedor no se ejecuta... Dentro de un contenedor se ejecutan procesos.
- Un contenedor no se mueve. Yo puedo crear clones de un contenedor... 
    básicamente crear contendores desde la misma imágen de contenedor
    

Habitualmente trabajamos con otra herramienta que se llama docker-compose.
Me permite configurar un contenedor desde un fichero YAML

Ejemplo de comando para instalar un postgresql mediante un contenedor
$ docker run --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -d postgres

Al crear un contenedor vamos a querer suministrar un MONTON de datos (configuraciones propias).
No es cómodo estar pasando todos esos parametros (configuraciones) en un comando.

Configuraciones?
- Puerto... No lo a querer cambiar nunca ¿?¿? ¿? Ahora lo vemos
- Datos de usuarios, contraseñas,....
- Donde se guardan los datos? Persistencia REAL
    - Los datos de los que quiero persistencia tras la eliminación de un contenedor los guardamos a nivel del FS del host
    - Esa carpeta la inyecto dentro del FS del contenedor
    - Como si comparto una carpeta entre host y contenedor
    - A esto se le denomina un VOLUMEN

Docker ha montado al ser instalado (DOCKER) en nuestra máquina una nueva interfaz de red.
Interfaz de red de docker: Es también una interfaz de red lógica igual que loopback
    172.17.0.1 HOST
    172.17.0.2  Contenedores
            .3

Para saber la IP de un contenedor: 
docker inspect NOMBRE

Habitualmente trabajamos con NAT (redirecciones de puertos)
En una (o varias) IPs del host , mapeamos un puerto al puerto del contenedor:


Cluster de Kubernetes < postgresql. con esta spec.
Maquina 1
    docker
Maquina 2
    docker
Maquina 3
    docker
    
    
# BBDD en general y PostgreSQL en particular

PostgreSQL  es una BBDD Relacional. 
Tablas... filas + columnas
Al final del recorrido... esos datos donde acaban? En ficheros de BBDD guardados en mi HDD

Columnas: Representan un dato que quiero almacenar dentro de una tabla de datos, asociado a una fila.
Esos datos tienen diferente naturaleza: TIPOS DE DATOS.
NUMERICOS
    ENTEROS
    DECIMALES
TEXTO
    DE TANAÑO FIJO
    DE TAMAÑO VARIABLE
    TEXTOS ESPECIALMENTE GRANDES -> CLOB
FECHAS
    FECHA
    HORA
    AMBOS
BINARIOS -> BLOB
LOGICOS

Qué estructura tienen esos ficheros? Cómo operamos sobre esos ficheros?
Las bases de datos manejan accesos aleatorios

En desarrollo de software hay 2 formas de abrir ficheros para su modificación y lectura...:
- Acceso secuencial: Leo el fichero de A a Z... entero... y si lo escribo...
    - Lo escribo entero (sobreescribo)
    - Lo abro en modo append: Añadir cosas al final
- Acceso aleatorio
    - Puedo poner la aguja del disco duro donde me interese... y leer lo que me interese o sobreescribir la parte que me interese
    - Tener control de donde me quiero posicionar:
        - O se de antemano el byte al que quiero ir... complejo 
        - Tengo una forma de calcularlo (FORMULA)
    Ventaja:
        - Más rápido al leer y al escribir un cambio
    Desventaja?
        - Más complejo
        - Los datos ocupan más... incluso mucho más....

TIPOS DE DATOS
ID -> 8 bytes
NOMBRE -> TEXTO 800 bytes
FECHA -> 16 bytes
800+16+8=824 *2 + 8
Hola............................................................. | 12-05-2022

# PostgreSQL
smallint, int2 :       2 bytes... con signo.       
2 bytes? 256x256    -32768 ... 0 32767
int, integer, int4
4 bytes?            -2147483648 ... 2147483647
bigint, int8
8 bytes

Si tengo una fila el PS... 
    con 2 campos bigint... Cuanto ocupa la fila? 16 bytes
    8|8=16
    campo smalint+campo int+campo smallint+campo bigint? 16 bytes
    2...4...2|8
    campo smallint + campo bigint + campo int + campo biint + campo smallint ? 40 bytes
    2(-6)|8|4(-4)|8|2(-6)
    campo smallint + campo smallint + campo int + campo bigint + campo biint ? 24 bytes
    2 +2 +4 | 8| 8 = 24 bytes
    
    Impacto gigante en el tamaño que ocupa la BBDD en disco
    Impacto en performance relativo (IO a disco)

PostgreSQL al guardar los datos los guarda por ORDEN Segun hemos definido el orden de las columnas... se respeta intermente el orden de las columnas que haya definido.
Y postgres va a ir cerrando bloques de 8 bytes. (PADDING DE PS)


RAM?
- DATOS DE TRABAJO: Ir almacenando información temporal no persistente... Información de trabajo: servlet
- CACHES



