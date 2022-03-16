1º Maestro:
- Cambios fichero configuracion
- Fichero de conexiones/ autorizaciones
- CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'password';
- select * FROM pg_create_physical_replication_slot('replication_slot_esclavo1');
- Backup no es para ser usado en este sistema
- $ pg_basebackup -D /home/ubuntu/environment/datos/backup -S replication_slot_esclavo1 -X stream -P -U replicator -Fp -R
- 




1º Maestro
    - Su propio ficherod e configuracion, con informacion de los WAL para replicacion
        wal_level = replica	
        max_wal_senders = 10	
        max_replication_slots = 10
        ++++ Sabiendo que los parametros de abajo de esta linea el maestro los ignora... solo los leera el esclavo
        hot_standby = on                                Permitirle responder a queries de consolta
        hot_standby_feedback = on
    - hba.conf < Autorizacion para el usuario de replicacion
    - Arrancado
    - En nuestro caso ya teniamos una BBDD, si no la crearíamos
    - SQL: Crear un usuario de replicación
    - SQL: Preparar un slot de replicación < esclavo1
    - Hacemos un export de la BBDD preparado para ser llevado a un nodo replicado > BACKUP

2º Esclavo
    - La misma configuración que al maestro.
        Solo que él leera las variables de conf que el maestro ignoraba
    - El esclavo lo arranco con la carpeta de datos generada desde el export del maestro
    - Esa carpeta incluye varias cosas:
        - Datos... exportados a traves de WAL... que en el fichero postgresql.auto.conf le pido que restaure al arrancar.
        - postgresql.auto.conf < En ese fichero vienen los datos de conexión al maestro
        - Y viene también que ese fichero el que lo lea es un esclavo con un determnado nombre (SLOT)
        
