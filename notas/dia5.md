# Regeneración de índices:

En la RAM ( o en una cache) el indice está ordenado.
Pero no tiene por qué ser así en el fichero del índice en el HDD

----

amarillo 234  243 4234 2

anajandado 234 243 2 432 23 

azul 17 19 23 56

blanco  923 492 29 27389 4

cian 12389 2398742398 243 98

---
Al leer esto de fichero del indice, es necesario consolidarlo en la cache. 
Eso puede ser costoso. Tanto como para hacer que postgre no use un índice

Los índices se van degradando con el tiempo. Toca mantenerlos. Es una de las operaciones más frecuentes.
Más que la regeración de estadísticas. Aunque ya puestos se suelen hacer en paralelo.

REINDEX INDEX indice;                Reindexa un índice
REINDEX TABLE tabla;                 Reindexa todos los indices de la tabla
REINDEX DATABASE basededatos;

Esto debe programarse en el tiempo:
REINDEX
ANALYZE
VACUUM

------
Otra operación bien importante: BACKUP ( > RESTORE )

- Backup lógico
    Exporto los datos
        Los puedo hacer en caliente- QUERY -> fichero .sql
        Muy ineficiente. Me tumba el sistema.
- Backup físico **** MUCHO MAS EFICIENTE... Problema
    Copio (hago backup) de los ficheros que hay en el disco duro
    Problema, que nadie toque el fichero mientras se está copiando.
        Backup en frio (parando la BBDD)
            Solo es cuestión de copiar la carpeta donde postgresql guarda los datos (PG_DATA)
        Backup en caliente
            Necesitamos haber configurado la BBDD en modo ArchiveLog
                                                            RedoLogs
            En este escenario se va anotando en unos ficheros (WAL) todas las queries que se hacen sobre el sistema
                                                                            Insert, Delete , Update

            Esos ficheros los voy cerrando... cuando llegan a un tamaño.
                Los voy rotando: 10 archivelog 1Mb


# Domingo a las 3:00 paro BBDD y hago copia en FRIO
    A partir de ahñi, cada dia a las 9:00 copio los archive logs

Joda el ordenador o HDD.... Eso lo resolvemos RAID, Cluster con replicación: HA

- 1 que a postgre se le vaya la cabeza y deje un fichero corrupto. Puede pasar... a postgreSQL y a Oracle
- 2 más habitual... Que un usuario la ha jodido... y ha tirado la query que no debía.
    - Implica que los fallos a veces se detectan a posteriori
No me vale con una única copia de seguridad de la BBDD. Necesito varias... Para ser capaz de recuperar el estado de la BBDD
X días atrás




# Configuración de postgreSQL

2 características diferencian a un entorno de producción de otros entornos:
- Alta disponibilidad (HA)  Tiene que ver con INTENTAR ASEGURAR un determinado tiempo de servicio de una app.
- Escalabilidad             Que el entorno se adapte a las necesidades de cada momento.


Yo puedo asegurar un 100% del tiempo? Imposible
Ordenador < PG + Weblogic.  Puedo garantizar que el HDD no se joda. NO 

90% de tiempo de uso: En un año 36 dias sin fucnionar... RUINA                              €
99%                   En un año 3.5 dias si sistema.     PELUQUERIA DE LA ESQUINA           €€
99.9%                 En un año 8 horas el sistema abajo - Backups                          €€€€€
99.99%                En un año 30 hora sin sistema... No hay opción de bakups en frio      €€€€€€€€€€€
    Me implica un sistema que permita backups en caliente 100% soportado (postgreSQL ya no sería mi herramienta)

Cluster: 
- Un conjunto de máquinas / procesos que hacen todos el mismo trabajo... o al menos que hacen un trabajo coordinado.
    Clusters Activo / Pasivo
    Clusters Activo / Activo

## Cluster Activo - Pasivo: ALTA DISPONIBILIDAD

2 o más copias del sistema... Pero solo 1 en funcionamiento. Si esta se cae, entra otra en su lugar
REEMPLAZO

## Cluster Activo - Activo

2 o más copias del sistema... Todas en funcionamiento simultaneo: ESCALABILIDAD


BBDD, INDEXADORES (elasticsearch), Sistemas de mensajería (ActiveMQ, KAFKA), REDIS son muy especiales con los cluster

Qué implica adicionalmente el montar un cluster?

Cluster ACTIVO / ACTIVO
    Maquina 1: IP1
        Tomcat  IP1:8080            <  IP BC                    <    Cliente
    Maquina 2: IP2                      (proxy revero: apache, nginx, haproxy)
        Tomcat  IP2:8080            <
    
    Qué más necesito? Un balanceador de carga

Cluster ACTIVO / PASIVO
    Puedo montar un balanceador... y que detecte el que está off y mande las peticiones al otro.
    VIPA: Dirección IP Virtual
    
    Maquina 1: RUNNING      
        Servicio
    Maquina 2: STANDBY      < VIPA
        Sin servicio
    
PostgreSQL

# Estrategia 1: Activo pasivo con datos en un sistema de almacenamiento EXTERNO
    
    Datos es lo más sagrado que existe... Los quiero en un RAID o equivalente. 
                                          Quiero REDUNDANCIA A NIVEL FISICO DE LOS DATOS
        
    Quien opera sobre esos datos.. Proceso a nivel de SO corriendo (postgreSQL)
    
    Pregunta... me interesa el postgreSQL ejecutarlo en la misma máquina donde están los datos?
        Puede ser... aunque no es lo habitual
    
    Si se jode la maquina (Fuente de alimentación, tarjeta de red)
        Me quedo sin los datos... por ahora... están ahí a salvo,.. pero inaccesibles.
    
    Solemos montar los datos en un sistema de almacenamiento externo: CABINAS DE ALMACENAMIENTO
                                                                      NAS: NFS, cephFS, CIFS
    
    2 maquinas 
        1 funcionando -> Apuntando a los datos de la cabina
        1 standby. A la espera...
    Si la que está funcionando se cae, inmediatamente levanto la otra, trabajando sobre los mismos datos.
    
    Cluster Activo/Pasivo           H/A
    
    Problema ?????
        Que beneficio le saco a la segunda máquina? Ninguno... Solo está por si las moscas.
    
    Hoy en día, los entornos de producción se montan con KUBERNETES -> contenedores
    Puedo crear un contenedor en segundos.
    Clusters de kubernetes:
        Maquina 1               20 apps... 10 maquinas + 12 maquinas (3 en standby)
            tomcat1
        Maquina 2
            tomcat1
        Maquina 3
        ...
        Maquina N
            postgreSQL
    
# Estrategia 2:

Maquina 1
    postgreSQL1 con sus datos   MAESTRO
                V                           BC                  Cliente (Vuestra app java)
Maquina 2       V   sincrona / asincrona
    postgreSQL2 con sus datos   REPLICAS
                V 
Maquina 3       V
    postgreSQL3 con sus datos   REPLICAS
    
2 opciones:
    - postgreSQL2 esté sirviendo peticiones         Cluster activo/activo ******
    - postgreSQL2 no esté sirviendo peticiones      Cluster activo/pasivo
    - hibridos

En esta estrategia... donde está el problema? Necesito asegurar sincronización entre los postgreSQL

Esta estragia... me da HA? SI
                 me da escalabilidad? Depende... el tipo de operación:
                    Lectura de datos... tengo escalabilidad?    SI... tengo 2 sitios de los que potencialmente leer
                    Puedo hacer el doble de lecturas que antes (que con una máquina)
                    Escritura de datos... tengo escalabilidad?  NO... tengo que escribir en los 2... estoy igual que antes

Qué beneficio le saco a la máquina 2 y 3 ? Si... al menos puedo hacer más consultas 
(que no actualizaciones) pero si consultas

ANTES, esta opción era la más usada... ya que me permitía sacarle un redimiento a la maquina 2.
Y sigue siendolo... en entornos un poco casposos (un poco desfasados).
    
La sincronización de datos se puede hacer:
                   Cuando el maestro escribe                            Desde el punto de vista del usuario
                   --------------------------------------------------------------------------------------------------
    sincrona:      Espera a la replica a que conteste que lo guardó     Cuando me dan el OK a la transacción,
                                                                        tengo certeza de que el dato está a salvo? SI
                                                                        Si hago corriendo una query para ssacar el dato, me sale?  SI
                                                                        Cuanto tarda esto? Al menos el doble que sin tener replicación.
    
    asincrona:     No espera a la replica a que conteste                Cuando me dan el OK a la transacción,
                                                                        tengo certeza de que el dato está a salvo? NO
                                                                        Si hago corriendo una query para sacar el dato, me sale?  DEPENDE... a quién le pregunte
                                                                            MAESTRO: SI
                                                                            ESCLAVO: NO
                                                                        Cuanto tarda esto? Aquí no hay penalización de tiempos.

MAESTRO < Imagina que tengo mi BBDD... donde meto datos.
    V SINCRONO
REPLICA < Para garantia de datos y además queries de trabajo del dia a dia
    V Asincrona
REPLICA < Para lo colgaos de las queries


Estas estrategias anteriores... son consideradas activo / pasivo (1 único maestro)

Muchas BBDD permiten montar clusters reales ACTIVO / ACTIVO. Follón tremendo: pero aqui si tengo HA + escalabilidad
En cada máquina solo hay una parte de los datos.
    Esto está guay para inserciones y modificaciones... Me penaliza las búsquedas.
    
PostgreSQL no tienen NADA para montar Activo/Activo (varios maestros) - Oracle  - RAC
                                                                        MariaDB - Galera

## Parámetros de configuración IMPORTANTES de POSTGRES en producción

# Memoria
La bbdd necesita mucha memoria.... para 2 cosas:

- Memoria de trabajo                ***** Limite lo impone la máquina de la que dispongo.    Depende de: La cantidad de queries
    - Queries < Número de conexiones a la BBDD
- Cache                             ***** Limite lo impone la máquina de la que dispongo.    Depende de: Tamaño de mi BBDD
    - Tablas e indices
    - Planes de ejecución
    - Procedimientos almacenados
    - 
## Cuanta memoria dejo a postgreSQL para guardar datos en cache: Algo razonable sería en torno al 30-40% de la RAM de la maquina.
shared_buffers =            # Es memoria que postgre puede y va a areservar para usarla como cache
effective_cache_size =      # Es una estimación de cuanta memoria puede llegar a usar el SO para buffers y cache
                            # Esto es información para el optimizador de queries... para calcular los planes de ejecución.
                            # La recomendación es : >70%<-80% de la RAM total del sistema < Aquí va a haber paginación (swapping)
work_mem= 4Mbs, 8Mbs
# Memoria de trabajo Esta es la memoria máxima RAM que se permite usar para cada operación puntual que se realice

Si tengo 8Mbs.... y tengo 100 conexiones: 800 Mbs... Si cada conexión hace varias cosas en paralelo... más bloques.
# Procesos de trabajo

maintenance_work_mem = 1GB 2GB
ANALIZE
VACCUUM
REINDEX

## Número de conexiones máximo
max_connections = 100 # Esto está intimamente ligado con la memoria que necesito
max_worker_processes ~ Estan condicionados por el número de CPUs de que disponga. / Ejecutores 
max_parallel_worker_per_gather ^ 20-25%

# Red, identificacion

# Logs & WAL
wal_buffers = 10-40Mb           # Problema: Si es pequeño,peor para el rendimiento
                                            Si es muy grande y el sistema se cae entes de escribir al HDD muchos datos pierdo.

100Gb BBDD entera en RAM... impensable 
La teoria me dice que para que entre etera en RAM: 0.5 Tbs de RAM....
-> Habrá muchas tablas... Todas las estoy usando continuamente?
Particionado:
Nuevos de trabajo 10% -> RAM        10Gbs + indices 
                  90% historico... solo se consultan muy de vez en cuando.


A lo mejor la BBDD solo es de escritura.---> ETL ---> Datawarehouse

Cuando trabajais desde JAVA... cómo abris una conexión a una BBDD?
Se trabaja con un pool de conexiones:

100 solicitudes de conexión
Si solo hay 3 conexiones posibles a BBDD en JAVA las meto en una cola
                        -------
                            C1
                        -------
                            C2
                        -------
                            C3
                        -------
Por qué?
Y no simplemente abro más conexiones con la BBDD? En una BBDD cada conexión e un proceso a nivel de SO.
Abrir una conexión implica: cargar un programa en RAM... y reservar RAM para ese programa, para que ponga sus datos.

Tengo algún problema por tener X(menos de 32) CPUs en abrir 800.000 de conexiones? Me da igual.
Esos programas abren hilos de ejecución, que son los que efectivamente hacen unu trabajo.
    Y cuando quieran acceder a la CPU? No... y que se hace? Se encolan (SO de tiempo compartido)

Donde está el problema en abrir muchas conexiones? RAM

Memoria: Algún sitio donde poder dejar datos:
- RAM
- HDD ** Peor rendimiento




Pool Tomcat  min, current, max 100
Cada vez que tu abres una conexión, se reserva esa RAM