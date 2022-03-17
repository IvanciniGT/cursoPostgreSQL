Principal Monatmos maestro
    1   Instalación
    2   Configuración (replicación)
    3   Crear BBDD 
    4   usuario replciación y slot
    5   export

Secundario
    1   Instalación
    2   Configuración (con algunos cambios)
        2 prop replicación directamente en el fichero
        3 props adicionales que las suministrabamos con el .auto o dentro del fichero
                                                            ^ nos salia en el export... aunque había que tocarlo                
    3   Restaurar el backup: Copiar la carpeta
    

Teniamos 2 maquinas :
    maestro / activo: todo tipo de queries
    replica:          queries de consulta
    
Forzamos una muerte del activo
Promoción del replica a maestro

Maestro 1.... murió

Replica 1 -> maestro2 vivo...

Qué pasa con el maestro 1?
Ese murió
El maestro 2 es el que ahora tiene más datos... que no están en el maestro 1
Hay que llevar esos datos.

El maestro 1 si arranca, ya no va a ser el maestro 1... va a ser el replica 2

Maquina 1 *****
Maquina 2
    BB con los datos.. y estoy en una situación delicada

Maquina 1 se ha ido... ha muerto. HDD
    Me toca configurar una nueva desde 0

Maquina 2 se ha ido ... y consigo recuperar la máquina... y la instalación de postgreSQL también.
    Esta tiene configurado ser replica? NOP
    Va a arrancar como maestro.
    
    Qué tengo en ese momento? 2 maestros... un follon de narices.

2 opciones
    Para que el maestro1 siga siendo maestro1... y el maestro2 pase a ser replica
        exportar los datos y llevarlos al maestro1 
            Reinicio
        
        1 cambiar la configuración del maestro2... para que vuelva a ser replica... ? viable?
            Reinicio
            
    Cambiar al maestro 1 a replica2

Cualquiera de esas cosas las tengo que hacer yo.

-----
    ------------------------------------------- Standby
    
NAS       ------------------------------------- Maestro 
RAID0       ----------------------------------- Esclavo
HDD1
HDD2
NAS       ------------------------------------- Maestro 
RAID0       ----------------------------------- Esclavo
HDD1
HDD2
NAS       ------------------------------------- Maestro 
RAID0       ----------------------------------- Esclavo
HDD1
HDD2

RAID10

---------------------------
    
Maestro -IP1 -VIPA-maestro  \
Replica -IP2 -VIPA-replica  /    VIPA: Alguien que mande cosas a una maquina un otra

Maestro -IP1 -VIPA-maestro.  -VIPA-replica         String 
                                                    queries que hacen escritura VIPA-maestro
                                                    queries que no hacen escritura VIPA-replica

Replica -IP2  -VIPA-maestro.  -VIPA-replica



Cliente - VIPA pg_pool1 - Maestro
                ^       \ Replica
                v
               pg_pool2


H/A : Si una maquina se cae, que sigamos en marcha
      Activo/replica
      
      1 cosa más : balanceo:
            VIPA: keepAlived + 1-5 minutos       
            Opcion 1 VIPA: Maestro
            
            Opción 2 VIPA: maestro                          Spring
                     VIPA: replica
                     
            Opción 3: VIPA pg_pool 
                         + otro pg_pool en reserva
            
            
      pg_pool me da adicionalmente :
        1º pool de conexiones.... pero eso ya lo teneis resuelto: App Server
        2º separación de queries escritura/lectura para aprovechar la 2º máquina 
      
Ahora si se ha caido una máquina ya no tengo HA... lo tengo que resolver...


NIC virtualización a nivel de HW


# Instalación KeepAlived
sudo apt-get install keepalived -y
sudo systemctl start keepalived

# Para configurar spring:

Damos de alta los 2 datasource y 
Crear un router de datasource

Copiar código de :
https://stackoverflow.com/questions/9203122/routing-read-write-transactions-to-primary-and-read-only-transactions-to-replica


## Backups & Restore

PD_DATA: 
    Carpeta donde están los datos de la BBDD: data_directory

### Backup físico

Copiando archivos a nivel de SO.
Mucho más rápido.

#### Frío . OPCION PREFERIDA CUANDO ESTA DISPONIBLE !!!

cp PD_DATA MI-CARPETA-DE-BACKUPS
    zip
    tar 

#### Caliente

Es necesario que la BBDD esté en modo ArchiveLog < WAL

select pg_start_backup('nombre');
    Se dejan temporalmente de escribir cambios en los archivos de la BBDD.
    Solo en los WAL.
    
cp PD_DATA MI-CARPETA-DE-BACKUPS
    zip
    tar 
    rsync
    /var/postgresql/14/main -> /mnt/backups/backupHoy (nfs, icsci)

select pg_stop_backup('nombre');
    Se dejan temporalmente de escribir cambios en los archivos de la BBDD.
    Solo en los WAL.

### Backup para replicación

pg_basebackup
    Aunque sirve también para backup normal, ahí no se usa -> cp rsync tar
    Adicionalmente lleva utilizadades para replicación: genera información adicional para la replica: .auto y otros.

#### Restauración: Recopiar la carpeta

Servidor parado
Recopio carpeta
Arranco servidor

### Backup lógico

Exporto datos.

Me llevo la estructura de la BBDD y los 4 datos de inicio de una app.

#### Solo una tabla, database
    - pg_dump      -U usuario BASE-DATOS
    - pg_dump      -U usuario BASE-DATOS > backup.sql
    - pg_dumpall   -U usuario 
    En cualquiera de ellos: 
        - Fp Es el por defecto... sql
        - Ft        -f archivo.tar
        $ pg_dump -Ft -f backup.tar -U usuario BASE-DATOS
Restore: 
    psql -u.... -f backup.sql
        Funciona solo con archivos .sql
    pg_restore -U usuario -d BASE-DE-DATOS fichero
        Funciona tanto con archivos .sq como con archivos .tar
        
        
Backups & restore

1- Plan de backup confirmado con cliente.
2- Scripts cron > Maquina externa
3- Prueba de restore *******