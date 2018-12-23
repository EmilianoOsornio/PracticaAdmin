#!/bin/bash

#Validación de archivo de configuración

if [ $# -ne 1 ]
then
	echo "Proporciona el archivo de configuración"
	exit 1
fi

# Lo comento porque un archivo de texto plano no tiene porque ser un txt
#if [[ ${1: -4} != ".txt" ]]
#then
#	echo "El archivo de configuración debe de ser .txt"
#	exit 1
#fi

#Leemos el archivo de configuración (ignorando líneas en blanco
# y comentarios)
linenumber=1
while IFS='' read -r line || [[ -n "$line" ]];
do

	if [ "$line" != "" ] && [[ "$line" != '#'* ]]
	then
    	#Contamos que cada línea tenga tres argumentos y los guardamos en el arreglo param
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

	        #MENU SERVICIOS
	        case ${param[1]} in
	        	#SERVICIO MOUNT
				"mount" )
					lines=("" "")
					echo "Mount a maquina: ${param[0]} con archivo de configuracion: ${param[2]}"
					cont=0
					while IFS='' read -r line || [[ -n "$line" ]]; do
						lines[cont]=$line
						cont=$(($cont+1))
					done < "${param[2]}"

					#Manejo de archivo de configuracion para MOUNT
					if [ $cont != 2 ]
			        then
			        	if [ $cont == 0 ]
			        	then
			        		echo "Error de sintaxis, archivo de configuracion vacío"
			        	elif [ $cont == 1 ]
			        	then
			        		echo "Error de sintaxis, falta el punto de montado"
			        	else
			        		echo "Error de sintaxis"
			        	fi
			        else
			        #SE REALIZA EL MONTADO
			        	echo "Hola"
			        fi

					;;
				#SERVICIO RAID
				"raid" )
					echo "Creamos un RAID en la máquina ${param[0]} con el archivo de configuración ${param[2]}"
					# Movemos el script y el archivo de configuración al servidor
					echo "Movemos los archivos necesarios a la máquina remota"
					scp ./raid.sh ${param[2]} ${param[0]}:/tmp/
					# Ejecutamos el script
					echo "Ejecutamos el script en la máquina remota"
					ssh -t ${param[0]} /tmp/raid.sh /tmp/${param[2]}
					;;
				"lvm")
					echo "lvm" ;;
				"nis_server")
					# Movemos el script y el archivo de configuración al servidor
                                        scp ./nis_server.sh ${param[2]} ${param[0]}:/tmp/
                                        #Ejecutamos el script
                                        ssh -tn ${param[0]} /tmp/nis_server.sh /tmp/${param[2]}
					echo "nis_server" ;;
				"nis_client")
					# Movemos el script y el archivo de configuración al servidor
                                        scp ./nis_client.sh ${param[2]} ${param[0]}:/tmp/
                                        #Ejecutamos el script
                                        ssh -tn ${param[0]} /tmp/nis_client.sh /tmp/${param[2]}
					echo "nis_client" ;;
				"nfs_server")
					echo "Configuramos un servidor NFS en la máquina ${param[0]} con el archivo de configuración ${param[2]}"
					# Movemos el script y el archivo de configuración al servidor
					echo "Movemos los archivos necesarios a la máquina remota"
					scp ./nfs_server.sh ${param[2]} ${param[0]}:/tmp/
					#Ejecutamos el script
					echo "Ejecutamos el script en la máquina remota"
					ssh -tn ${param[0]} /tmp/nfs_server.sh /tmp/${param[2]}
				"nfs_client")
					echo "Configuramos un servidor NFS en la máquina ${param[0]} con el archivo de configuración $
					# Movemos el script y el archivo de configuración al servidor cliente
					echo "Movemos los archivos necesarios a la máquina remota"
					scp ./nfs_client.sh ${param[2]} ${param[0]}:/tmp
					# Ejecutamos el script
					echo "Ejecutamos el script en la máquina remota"
					ssh -tn ${param[0]} /tmp/nfs_client.sh /tmp/${param[2]}
				"backup_server")
					echo "backup_server" ;;
				"backup_client" )
					echo "backup_client" ;;
			esac
    	fi
    fi
linenumber=$((linenumber+1))
done < "$1"
