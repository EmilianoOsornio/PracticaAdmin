#!/bin/bash

# Comprobamos que se pasa un fichero de configuración de nfs_server
if [ $# -ne 1 ]
then
	(>&2 echo "Proporciona el archivo de configuración de servidor nfs")
	exit 1
fi

# Hacemos un update para asegurarnos que podemos buscar el servicio mdadm
echo "Actualizando lista de paquetes..."
apt-get update &> /dev/null
echo "Lista de paquetes actualizados"

# Instalamos mdadm de tal forma que no pida interacción
echo "Instalando paquete nfs-kernel-server"
(apt-get -y install nfs-kernel-server) &> /dev/null
if [ $? -eq 0 ]
then
        echo "Se han instalado el paquete nfs-kernel-server"
else
        (>&2 echo "La instalación del paquete nfs-kernel-server ha fallado")
        (>&2 echo "Abortando ejecución...")
        exit 1
fi

# Uncomment line 6 and change domain in /etc/idmapd.conf
echo "Cambiando el nombre de dominio de NFS"
sed -i '7isvr.nfs.ASI2014' /etc/idmapd.conf

# Append each line in the configuration file to /etc/exports
#Leemos el archivo de configuración
echo "Estableciendo las rutas a compartir en el archivo /etc/exports"
linenumbernfss=1
while IFS='' read -r line || [-n "$line" ]];
do

	echo "$line *(rw,sync,no_subtree_check)" >> /etc/exports

	linenumbenfssr=$((linenumbernfss+1))
done < "$1"

# Hacemos efectivos los cambios en /etc/exports
exportfs -ra &> /dev/null
if [ $? -eq 0 ]
then
        echo "Cambios incluidos en /etc/exports satisfactoriamente"
else
        (>&2 echo "No se han podido incluir satisfactoriamente los cambios en /etc/exports")
        (>&2 echo "Abortando ejecución...")
        exit 1
fi


# Reiniciamos el servidor NFS
echo "Reiniciamos el servicio del servidor NFS..."
/etc/init.d/nfs-kernel-server restart
if [ $? -eq 0 ]
then
        echo "Servicio del servidor NFS reiniciado satisfactoriamente"
else
        (>&2 echo "No se ha podido reiniciar el servicio servidor de NFS")
        (>&2 echo "Abortando ejecución...")
        exit 1
fi
