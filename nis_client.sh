#!/bin/bash -x

#Servicio Nis_client
#Obtenemos ip propia por si se requiere en un futuro
myIp=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2| cut -d' ' -f1`
##Funcinon para ver si una ip es válida
function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

# Comprobamos que se pasa un fichero de configuración de mount
if [ $# -ne 1 ]
then
	echo "Proporciona el archivo de configuración de nis_client"
	exit 1
fi

#Nombramos las variables del archivo de configuracion
domain="$(sed -n 1p $1)"
nisServer="$(sed -n 2p $1)"

echo "El archivo de configuracion tiene: $domain $nisServer"

#Checamos que el archivo de configuración tenga parametros

if [ -z "$domain" ] && [ -z "$nisServer" ]
then
	echo "El archivo de configuracion esta vacío"
elif [ -z "$nisServer" ]
then
	echo "Error de sintaxis, falta servidor nis al que se desea conectar"
else
	#Checamos que nisServer sea una ip válida
	#valid_ip $nisServer
    #if [ $? -eq 0 ]
    #then
    	echo "Se configurará el cliente con dominio: $domain sobre el servidor $nisServer"
		# Realizamos la instalación de nis
		apt-get update
		DEBIAN_FRONTEND=noninteractive apt-get -y install nis

		#Cambiamos hostname y defaultdomain
		sed -i "s/^ASI2014.*/$domain/" /etc/hostname
		hostname $domain
		sed -i "s/^ASI2014.*/$domain/" /etc/defaultdomain

		#Modificamos /etc/yp.conf, añadiendo el nombre del dominio del cliente y el servidor nis al que se desea conectar
		echo "domain $domain server $nisServer" >> /etc/yp.conf

		#Modificamos /etc/nsswitch.conf para describir para que info se usa nis
		sed -i 's/compat/compat nis/g' /etc/nsswitch.conf
		sed -i 's/dns/dns nis/g' /etc/nsswitch.conf

		echo "$nisServer $domain" >> /etc/hosts

		#Añadimos en /etc/pam.d/common-session
		echo "session optional        pam_mkhomedir.so skel=/etc/skel umask=077" >> /etc/pam.d/common-session

		#Reiniciamos rpcbind y nis
		service rpcbind restart
		service nis restart

		nomdom=$domain
		echo "Se configuro la maquina como cliente, con el dominio: $nomdom"

		echo "Prueba con ypcat passwd"
		ypcat passwd
	#else
		#echo "El servidor especificado no es una dirección ip válida"
	#fi
fi


