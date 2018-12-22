#!/bin/bash

# Comprobamos que se pasa un fichero de configuración de nfs_client
if [ $# -ne 1 ]
then
	echo "Proporciona el archivo de configuración de servidor nfs"
	exit 1
fi

# Hacemos un update para asegurarnos que podemos buscar el servicio mdadm
apt-get update

# Instalamos mdadm de tal forma que no pida interacción
apt-get -y install nfs-common

# Uncomment line 6 and change domain in /etc/idmapd.conf
sed -i '7isrv.nfs.ASI2014' /etc/idmapd.conf

# Append each line in the configuration file to /etc/exports
#Leemos el archivo de configuración
linenumber=1
while IFS='' read -r line || [[ -n "$line" ]];
do
	if [ "$line" != "" ] && [[ "$line" != '#'* ]]
        then
	count=0
	for word in $line;
    	do
        	count=$(($count+1))
        done

        if [ $count != 3 ]
        then
        	echo "Error en línea $linenumber: $line "
        else
        	param=("par1" "par2" "par3")
        	i=0
        	for word in $line;
	    	do
	    		param[i]=$word
	        	i=$(($i+1))
	        done
	echo "Parametros: ${param[*]}"

	# Si no existe creamos la carpeta
	mkdir -p ${param[2]}

	# Operación de montaje remoto
	mount -t nfs ${param[0]}:${param[1]} ${param[2]}

	# Añadimos las líneas en fstab
	echo "${param[0]}:${param[1]} ${param[2]} nfs defaults 0 0"

	echo "$line *" >> /etc/exports

	linenumber=$((linenumber+1))
	fi
	fi
done < "$1"

# Reiniciamos el servidor NFS
#/etc/init.d/nfs-kernel-server restart

if [ $? -ne 0 ]
then
	echo "No se ha iniciado correctamente el servicio nfs_client"
	exit 2
fi
