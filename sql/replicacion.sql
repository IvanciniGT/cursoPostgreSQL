CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'password';

select * FROM pg_create_physical_replication_slot('replication_slot_esclavo1');