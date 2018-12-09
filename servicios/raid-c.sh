#!/bin/bash

# usando mdadm
# El fichero de perfil de servicio texto plano con 3 líneas
#   nombre-del-nuevo-dispositivo-raid   <>  /dev/md0
#   nivel-de-raid                       <> 1
#   dipositivo-1 [dispositivo-2 ...]    <> /dev/sdb1 /dev/sdc1
# DEBERÍAMOS ESTABLECER UNA REGLA DE CÓDIGOS DE SALIDA, DE TLA FORMA QUE SE PUEDA
# IDENTIFICAR DONDE HA FALLADO EL PROGRAMA

# Hacemos un update para asegurarnos que podemos buscar el servicio mdadm
apt-get update

# Instalamos mdadm de tal forma que no pida interacción
##DEBIAN_FRONTEND=noninteractive apt-get install mdadm

# Comprobamos que se pasa un fichero de configuración de raid
if [ $# -ne 1 ]
then
	echo "Proporciona el archivo de configuración de raid"
	exit 1
fi

#Variables
nombre-nuevo-dispositivo=$(sed -n 1p $1)
nivel-raid=$(sed -n 2p $1)
dispositivos=$(sed -n 3p $2)

echo $nombre-nuevo-dispositivo
echo $nivel-raid
echo $dispositivos



# Creamos el array
##yes | mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdc

# Tenemos que comprobar que el valor devuelto es 0 si se hace correctamente y distinto si no
#¿Habría que hacer algo más?
