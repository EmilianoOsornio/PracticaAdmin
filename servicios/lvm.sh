#!/bin/bash 
#export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"
#FICHERO PASADO AL SCRIPT COMO ARGUMENTO
#nombre-del-grupo-de-volumenes									serverdata
#lista-de-dispositivos-en-el-grupo								/dev/sdb1 /dev/sdc1 /dev/sdd1
#nombre-del-primer-volumen tamano-del-primer-volumen			software 100GB
#nombre-del-segundo-volumen tamano-del-segundo-volumen			users 500GB
#1 COMPROBACIONES PREVIAS AL LVM
#1.1- Nº de lineas del fichero pasado pasa el minimo
if [ $(wc -l < $1) -lt 3 ]
then
	echo "El fichero $1 no tiene el numero de lineas esperado" >&2
	echo "Abortando ejecucion..." >&2
	exit 1
fi
echo "El fichero $1 cumple con el minimo numero de lineas necesarias"
#1.2-Se tiene que comprobar si estan instalados los paquetes de lvm
dpkg -l | grep "^ii" | awk '{ print $2 }' | grep "^lvm2$"
if [ $? -eq 0 ]
then
	echo "Los paquetes de lvm2 estan ya instalados en el sistema"
else
	echo "Los paquetes de lvm2 no estan instalados en el sistema"
	echo "Instalamos los paquetes de lvm."
	sudo apt-get update &>/dev/null
	sudo apt-get install lvm2 -y &>/dev/null
	if [ $? -eq 0 ]
	then
		echo "Se han instalado los paquetes de lvm" 
	else
		echo "La instalacion de los paquetes lvm ha fallado" >&2
		echo "Abortando ejecucion..." >&2
		exit 1
	fi
fi
#Nos guardamos las lineas del fichero de configuracion del servicio que leemos
#Siendo la 1º linea -> nombre-del-grupo-de-volumenes					Ej: serverdata
#2º linea -> lista-de-dispositivos-en-el-grupo							Ej:	/dev/sdb1 /dev/sdc1 /dev/sdd1
#3º linea -> nombre-del-primer-volumen tamano-del-primer-volumen		Ej:	software 100GB
#nombre-del-segundo-volumen tamano-del-segundo-volumen					Ej:	users 500GB
#etc...
nombregrupo=$(sed -n 1p $1)
dispositivos=$(sed -n 2p $1)
listadisp=($dispositivos)
tamanogrupodisps=0
lineaaleer=0
for ((i=0; i<${#listadisp[@]} ;i++))
do
	echo "Comprobando si el dispositivo ${lista[i]} existe"
	comprobar="${listadisp[i]##*/}"
	lsblk | echo $comprobar
	if [ $? -eq 0 ]
		then
			echo "El dispositivo existe"
			#Tamaño del dispositivo con GB
			tamGB=$(lsblk ${listadisp[i]} -b -o SIZE | sed -n 2p | awk '{ byte =$1 /1024/1024/1024 ; print byte "GB" }')
			tamReal=${tamGB::-2} #Tamaño del dispositivo sin el GB
			tamanogrupodisps=$(($tamanogrupodisps+$tamReal))
		else
			echo "El dispositivo no existe" >&2
			echo "Abortando ejecucion..." >&2
			exit 1
	fi
done
if [ $tamanogrupodisps -eq 0 ]
then
	echo "El tamaño de grupo de dispositivos es 0" >&2
	echo "Abortando ejecucion..." >&2
	exit 1
fi
echo "El tamaño de los dispositivos es > 0"
echo "Inicializamos los discos fisicos"
pvcreate $dispositivos
if [ $? -ne 0 ]
then
	echo "La inicializacion de los discos fisicos ha fallado" >&2
	echo "Abortando ejecucion..." >&2
	exit 1
fi
echo "Los discos fisicos se han creado correctamente"
echo "Procedemos a crear el grupo de volumenes"
vgcreate $nombregrupo $dispositivos
if [ $? -ne 0 ]
then
	echo "La creacion del grupo de volumenes ha fallado" >&2
	echo "Abortando ejecucion..." >&2
    exit 1
fi
echo "El grupo de volumenes se ha creado correctamente"
#BUCLE PARA PROCESAR TODAS LAS LINEAS QUE VIENEN DE LOS VOLUMENES LOGICOS
while read volumen
do
	echo "$volumen"
	lineaaleer=$(($lineaaleer+1))
	if [ $lineaaleer -gt 2 ]
	then
		#Para ver que en la linea de el volumen te pasan al menos dos argumentos
		args=($volumen)
		if  [ ${#args[@]} -eq 2 ]
		then
			echo "Comprobamos si el tamano del volumen logico no excede el del grupo de volumenes"
			congb=${args[1]}
			singb=${congb::-2}
			if [ $singb -gt $tamanogrupodisps ]
			then
				echo "El tamano del volumen excede el tamano disponible" >&2
				echo "Abortando ejecucion..." >&2
				exit 1
			else
				echo "Procediendo a crear el volumen logico con el nombre ${arg[0]} y tamano ${arg[1]}"
				#2.3- Creamos los volumenes logicos,
				#(crearemos un unico volumen llamado data-lv01, pero se pueden crear mas de un volumen en el grupo de volumenes)
				lvcreate --name ${args[0]} --size $singb $nombregrupo
				if [ $? -eq 0 ]
				then
					echo "Se ha creado el volumen logico ${a[0]}"
					#$nombregrupo/${args[0]} /dev ext4 defaults 0 >> /etc/fstab
					tamanogrupodisps=$(($tamanogrupodisps-$singb))
				else
					echo "Ha fallado la creacion del volumen logico" >&2
					echo "Abortando ejecucion..." >&2
					exit 1
				fi
			fi
		else
			echo "El numero de argumentos esperado es 2" >&2
			echo "Abortando ejecucion..." >&2
			exit 1
		fi
	fi
done<$1
echo "Terminado con exito la creacion de los lvm"
exit 0




