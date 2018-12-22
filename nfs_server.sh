#!/bin/bash

# Comprobamos que se pasa un fichero de configuración de nfs_server
if [ $# -ne 1 ]
then
	echo "Proporciona el archivo de configuración de servidor nfs"
	exit 1
fi

# Hacemos un update para asegurarnos que podemos buscar el servicio mdadm
apt-get update

# Instalamos mdadm de tal forma que no pida interacción
apt-get -y install nfs-kernel-server

# Uncomment line 6 and change domain in /etc/idmapd.conf
sed -i '7isvr.nfs.ASI2014' /etc/idmapd.conf

# Append each line in the configuration file to /etc/exports
#Leemos el archivo de configuración
linenumbernfss=1
while IFS='' read -r line || [-n "$line" ]];
do

	echo "$line *" >> /etc/exports

	linenumbenfssr=$((linenumbernfss+1))
done < "$1"

# Hacemos efectivos los cambios en /etc/exports
exportfs -ra

# Reiniciamos el servidor NFS
/etc/init.d/nfs-kernel-server restart

if [ $? -ne 0 ]
then
	echo "No se ha iniciado correctamente el servicio nfs_server"
	exit 2
fi
