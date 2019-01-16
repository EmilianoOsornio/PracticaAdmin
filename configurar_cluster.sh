#!/bin/bash

#Validación de archivo de configuración
if [ $# -ne 1 ]
then
	echo "Proporciona el archivo de configuración" >&2
	exit 1
fi

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
        		echo "Error en línea $linenumber: $line " >&2
        		exit 1
        	else
        		param=("par1" "par2" "par3")
        		i=0
        		for word in $line;
	    		do
	    			param[i]=$word
	        		i=$(($i+1))
	        	done
	        	echo "Parámetros línea $linenumber: ${param[*]}"

		#MENU SERVICIOS
	        case ${param[1]} in
				"mount" )
					echo "Mount a maquina: ${param[0]} con archivo de configuracion: ${param[2]}"
				    scp ./servicios/mount.sh ${param[2]} ${param[0]}:/tmp/
					# Ejecutamos el script
					ssh -tn ${param[0]} /tmp/mount.sh /tmp/${param[2]##*/}
					;;
                		"raid" )
                    			echo "Creamos un RAID en la máquina ${param[0]} con el archivo de configuración ${param[2]}"
                    			# Movemos el script y el archivo de configuración al servidor
                    			echo "Movemos los archivos necesarios a la máquina remota"
                    			scp ./servicios/raid.sh ${param[2]} ${param[0]}:/tmp/
                    			# Ejecutamos el script
                    			echo "Ejecutamos el script en la máquina remota"
                    			ssh -tn ${param[0]} /tmp/raid.sh /tmp/${param[2]##*/}
                    			;;
				"lvm")
			    		scp ./servicios/lvm.sh ${param[2]} ${param[0]}:/tmp/
					# Ejecutamos el script
					ssh -tn ${param[0]} /tmp/lvm.sh /tmp/${param[2]##*/}
					;;
				"nis_server")
					echo "Creacion de servidor NIS con archivo de configuracion ${param[2]}"
					scp ./servicios/nis_server.sh ${param[2]} ${param[0]}:/tmp/
					# Ejecutamos script
					ssh -tn ${param[0]} /tmp/nis_server.sh /tmp/${param[2]##*/}
					;;
				"nis_client")
					echo "Creacion de cliente NIS con archivo de configuracion ${param[2]}"
                    			scp ./servicios/nis_client.sh ${param[2]} ${param[0]}:/tmp/
                    			#Ejecutamos el script
                    			ssh -tn ${param[0]} /tmp/nis_client.sh /tmp/${param[2]##*/}
					;;
                		"nfs_server")
                    			echo "Configuramos un servidor NFS en la máquina ${param[0]} con el archivo de configuración ${param[2]}"
                    			# Movemos el script y el archivo de configuración al servidor
                    			echo "Movemos los archivos necesarios a la máquina remota"
                    			scp ./servicios/nfs_server.sh ${param[2]} ${param[0]}:/tmp/
                    			#Ejecutamos el script
                    			echo "Ejecutamos el script en la máquina remota"
                    			ssh -tn ${param[0]} /tmp/nfs_server.sh /tmp/${param[2]##*/}
                    			;;
                		"nfs_client")
                    			echo "Configuramos un servidor NFS en la máquina ${param[0]} con el archivo de configuración"
                    			# Movemos el script y el archivo de configuración al servidor cliente
                    			echo "Movemos los archivos necesarios a la máquina remota"
                    			scp ./servicios/nfs_client.sh ${param[2]} ${param[0]}:/tmp
                    			# Ejecutamos el script
                    			echo "Ejecutamos el script en la máquina remota"
                    			ssh -tn ${param[0]} /tmp/nfs_client.sh /tmp/${param[2]##*/}
                    			;;
				"backup_server")
					scp ./servicios/backup_server.sh ${param[2]} ${param[0]}:/tmp/
					# Ejecutamos el script
					ssh -tn ${param[0]} /tmp/backup_server.sh /tmp/${param[2]##*/}
					;;
				"backup_client" )
					scp ./servicios/backup_client.sh ${param[2]} ${param[0]}:/tmp/
					# Ejecutamos el script
					ssh -tn ${param[0]} /tmp/backup_client.sh /tmp/${param[2]##*/}
					;;
				*)
		            echo "El servicio solicitado no existe" >&2
		            exit 1
			esac
    	fi
    fi
	linenumber=$((linenumber+1))
done < "$1"
