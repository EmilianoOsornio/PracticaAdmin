#!/bin/bash

#Servicio Mount

# Comprobamos que se pasa un fichero de configuración de mount
if [ $# -ne 1 ]
then
	echo "Proporciona el archivo de configuración de mount" >&2
	exit 1
fi

#Nombramos las variables del archivo de configuracion
device="$(sed -n 1p $1)"
mountPoint="$(sed -n 2p $1)"


#Checamos que el archivo de configuración tenga parametros

if [ -z "$device" ] && [ -z "$mountPoint" ]
then
	echo "El archivo de configuracion esta vacío" >&2
	exit 1
elif [ -z "$mountPoint" ]
then
	echo "Error de sintaxis, falta el punto de montado" >&2
	exit 1
fi

###Se realiza el montado

echo "Montando $device en el directorio $mountPoint..."

#Checamos si existe el directorio, de lo contrario se crea
if [ ! -d "$mountPoint" ]
then
    echo "El directorio no existe, creando directorio  $mountPoint..."
    mkdir -m777 $mountPoint
#Checamos si el directorio está vacío
elif [ "$(ls -A $mountPoint)" ]
then
	echo "El directorio contiene archivos, no se puede realizar el montaje" >&2
	exit 1
else
	echo "El directorio está vacío, se puede realizar el montaje"
fi

#Verificamos el tipo del dispositivo que se quiere montar, si está vacío entonces no existe
deviceType=`/sbin/blkid -s TYPE -o value $device`

echo $deviceType
if [ -z "$deviceType" ]
then
	echo "El dispositivo especificado para el montaje no existe" >&2
	exit 1
fi

#Modificamos /etc/fstab para que el dispositivo se monte siempre al arrancar la maquina

echo "Agregando dispositivo a /etc/fstab"
echo "$device $mountPoint $deviceType defaults 0 2" >> /etc/fstab


echo "Realizando mount..."
#Relizamos el montaje
mount -t $deviceType $device $mountPoint

#Checamos si el mount pudo ejecutarse
if [ $? -eq 0 ]
then
	echo "Se realizó el montaje con éxito"
	exit 0
else
	echo "No se pudo realizar el montado" >&2
	exit 1
fi
