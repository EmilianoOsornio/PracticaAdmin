#!/bin/bash -x


#COMPROBACIONES PARA QUE SE PUEDA ESTABLECER COMO SERVIDOR DE BACKUP

#1-El fichero de configuracion debe de tener 1 unica linea, lo comprobamos

#2.1-Se debe comprobar tambien que el directorio donde se va a realizar el backup existe y 2.2- esta vacio

#3-Estan instalados los paquetes de rsync


#1
if [ $(wc -l < $1) -ne 1]
then
	echo "El fichero $1 no tiene el numero de lineas esperado"
	exit 1
fi
echo "El fichero $1 posee el numero de lineas necesarias"

dirbackup=$(sed -n 1p $1)

#2.1
if [ -d $dirbackup ]
then
	echo "El directorio de backup $dirbackup existe"
	#2.2
	if [ "$(ls -A $dirbackup)" ]
	then
		echo "El directorio no esta vacio, por lo tanto no se puede usar para backup"
		exit 1
	else
		echo "El directorio de backup $dirbackup tambien esta vacio"
		#3
		echo "Comprobamos si los paquetes de rsync estan instalados"
		dpkg -l | grep "^ii" | awk '{ print $2 }' | grep "^rsync$"
		if [ $? -eq 0 ]
		then
			echo "Los paquetes de rsync estan ya instalados en el sistema"
		else
			echo "Los paquetes de rsync no estan instalados en el sistema"
			echo "Procedemos a instalarlos"
			sudo apt-get update
			sudo apt-get install rsync -y
			if [ $? -eq 0 ]
			then
				echo "La instalacion de rsync ha sido satisfcatoria"
			else
				echo "Fallo en la instalacion de rsync"
				exit 1
			fi
		fi
	fi	
else
	echo "El directorio $dirbackup no existe"
	exit 1
fi
echo " Se ha configurado correctamente el directorio de backup"
exit 0









