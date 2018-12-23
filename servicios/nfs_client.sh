#!/bin/bash

# Comprobamos que se pasa un fichero de configuración de nfs_client
if [ $# -ne 1 ]
then
	(>&2 echo "Proporciona el archivo de configuración de servidor nfs")
	exit 1
fi

# Hacemos un update para asegurarnos que podemos buscar el servicio mdadm
echo "Actualizando lista de paquetes..."
apt-get update &>/dev/null
echo "Lista de paquetes actualizados"

# Instalamos mdadm de tal forma que no pida interacción
echo "Instalando paquete nfs-common"
(apt-get -y install nfs-common) &> /dev/null
if [ $? -eq 0 ]
then
        echo "Se han instalado el paquete nfs-common"
else
        (>&2 echo "La instalación del paquete nfs-common ha fallado")
        (>&2 echo "Abortando ejecución...")
        exit 1
fi


# Uncomment line 6 and change domain in /etc/idmapd.conf
echo "Cambiando el nombre de dominio de NFS"
sed -i '7isrv.nfs.ASI2014' /etc/idmapd.conf

#Leemos el archivo de configuración
echo "Realizando configuración de cliente NFS..."
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
        	(>&2 echo "Error en línea $linenumber: $line ")
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
	echo "Si no existe las carpetas compartidas las creamos"
	mkdir -p ${param[2]}

	# Operación de montaje remoto
	echo "Realizamos la operación de montaje remoto..."
	mount -t nfs ${param[0]}:${param[1]} ${param[2]}
	if [ $? -eq 0 ]
	then
        	echo "El montaje se ha realizado correctamente"
	else
        	(>&2 echo "El montaje remoto ha fallado")
        	(>&2 echo "Abortando ejecución...")
        	exit 1
	fi

	# Añadimos las líneas en fstab
	echo "Incluimos la operación de montaje en el arranque del sistema"
	echo "${param[0]}:${param[1]} ${param[2]} nfs defaults 0 0" >> /etc/fstab

	echo "$line *" >> /etc/exports

	linenumber=$((linenumber+1))
	fi
	fi
done < "$1"
echo "Configuración de NFS realizada correctamente"
