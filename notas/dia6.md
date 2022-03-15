1º Maestro:
- Cambios fichero configuracion
- Fichero de conexiones/ autorizaciones
- CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'password';
- select * FROM pg_create_physical_replication_slot('replication_slot_esclavo1');
- Backup no es para ser usado en este sistema
- $ pg_basebackup -D /home/ubuntu/environment/datos/backup -S replication_slot_esclavo1 -X stream -P -U replicator -Fp -R