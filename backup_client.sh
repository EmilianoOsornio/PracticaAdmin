#!/bin/bash


#COMPROBACIONES PARA QUE SE PUEDA ESTABLECER COMO CLIENTE DE BACKUP

#1-El fichero de configuracion debe de tener 4 lineaS exactas, lo comprobamos

#2-Comprobar que el directorio local existe y tiene algo

#3-Comprobar que el directorio del servidor de backup existe y esta vacio

#4-Comprobar que el cliente tiene permisos de escritura sobre el directorio del servidor

#5-Comprobar que estan instalados los paquetes de rsync

#6-Se añade entrada en el crontab para la realizacion periodica del backup

#Se asume que la ip es valida y pertenece al servidor



#1
if [ $(wc -l < $1) -ne 4 ]
then
	echo "El fichero $1 no tiene el numero de lineas esperado" >&2
	echo "Abortando ejecucion..." >&2
	exit 1
fi
echo "El fichero $1 posee el numero de lineas necesarias"

dirlocal=$(sed -n 1p $1)
ipdestino=$(sed -n 2p $1)
dirremoto=$(sed -n 3p $1)
periodicidad=$(sed -n 4p $1)

#2
if [ -d $dirlocal ]
then
	echo "El directorio de backup $dirbackup existe"
else
	echo "El directorio local no existe y no se puede realizar backup" >&2
	echo "Abortando ejecucion..." >&2
	exit 1
fi

#3
echo "Procedemos a ver si el directorio de destino existe"
if ssh $(whoami)@$ipdestino  "[ -d $dirremoto ]"
then
	echo "El directorio remoto existe"
	echo "Procedemos a comprobar si tambien tiene permisos de escritura"
	#4
	if ssh $(whoami)@$ipdestino  "[ -w $dirremoto ]"
	then
		echo "El directorio remoto tiene permisos de escritura"
	else
		echo "El directorio remoto no tiene permisos de escritura, no se puede realizar el backup" >&2
		echo "Abortando ejecucion..." >&2
		exir 1
	fi
else
	echo "El directorio remoto no existe, no se puede realizar el backup" >&2
	echo "Abortando ejecucion..." >&2
	exit 1
fi
#5
echo "Comprobamos si los paquetes de rsync estan instalados"
dpkg -l | grep "^ii" | awk '{ print $2 }' | grep "^rsync$"
if [ $? -eq 0 ]
then
	echo "Los paquetes de rsync estan ya instalados en el sistema"
else
	echo "Los paquetes de rsync no estan instalados en el sistema"
	echo "Procedemos a instalarlos"
	sudo apt-get update &>/dev/null
	sudo apt-get install rsync -y &>/dev/null
	if [ $? -eq 0 ]
	then
		echo "La instalacion de rsync ha sido satisfcatoria"
	else
		echo "Fallo en la instalacion de rsync" >&2
		echo "Abortando ejecucion..." >&2
		exit 1
	fi
fi
#6
echo "Añadimos al crontab la ejecucion del backup cada $periodicidad horas"
echo "0 $periodicidad * * * rsync -avzrte ssh $dirlocal $(whoami)@$ipdestino:$dirremoto" >> /etc/crontab
echo "Añadida la ruta al crontab"
echo "Se ha configurado el backup correctamente"
exit 0
