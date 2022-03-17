Hierro sobre las máquinas.

Maquina 1
    Maestro A
    Replica B
    
    Gustavo
    Carlos

Maquina 2
    Replica A
    Maestro B
    
    Ramon
    Emiliano

Balanceo de carga << Estrategias + Spring


---
De la docu de postgreSQL:

```bash
# Create the file repository configuration:
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update the package lists:
sudo apt-get update

# Install the latest version of PostgreSQL.
# If you want a specific version, use 'postgresql-12' or similar instead of 'postgresql':
sudo apt-get -y install postgresql
```

Lo que tenemos es un servicio de systemd (linux)
Servicios
Montajes de volumenes

$ sudo systemctl start   NOMBRE_SERVICIO
                stop
                status
                restart     Operam sobre la ejecución actual de SO.
                
                enable      Arranque autom a partir del siguiente rearranque
                disable

Linux < Unix 

386BSD Problemas legales AT&T
GNU.  Montaron todo lo que hacia falta para un SO completo: menos una cosa: KERNEL
Linus Torwalds:
    Linux <<< Kernel SO + usado en el mundo: ANDROID: Linux + librerias google
    
    Linus + GNU = GNU/Linux SO Completo.. Supuestamente cumple con la espec. UNIX®

# Unix® ~ 400 versiones

¿Qué es UNIX?
Es una especificación de cómo hacer un SO:
    - POSIX
    - SUS

¿Qué era UNIX?

Era un SO. Propiedad de lab Bell - AT&T

HP:     HP-UX   SO Unix®
Oracle: Solaris SO Unix®
IBM:    AIX     SO Unix®
Apple:  MacOS   SO Unix®

SysV de UNIX < initScripts
init.d rc 0-6



0.0.0.0/0
???.???.???.???

127.0.0.1/32
