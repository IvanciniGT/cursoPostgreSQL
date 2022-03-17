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