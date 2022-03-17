# Fichero para el maestro.Si se cae el proceso
master_ip="172.31.1.24" # IPS REALES
slave_ip="172.43.1.13"
pg_ctl="/usr/lib/postgresql/14/bin/pg_ctl"
pg_home="/var/lib/postgresql/14/main/"
 
(echo >/dev/tcp/"$master_ip"/5432) &>/dev/null && echo "All is OK"; exit 0 
|| sudo -u postgres "$pg_ctl -D $pg_home promote"; exit 1
