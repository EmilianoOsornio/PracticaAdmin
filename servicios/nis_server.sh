#!/bin/bash

#Servicio Nis_server
#Obtenemos ip propia por si se requiere en un futuro
myIp=`/sbin/ifconfig eth1 | grep 'inet addr:' | cut -d: -f2| cut -d' ' -f1`

# Comprobamos que se pasa un fichero de configuración de mount
if [ $# -ne 1 ]
then
	echo "Proporciona el archivo de configuración de nis_server" >&2
	exit 1
fi

#Nombramos las variables del archivo de configuracion
domain="$(sed -n 1p $1)"
echo "El archivo de configuracion tiene: domain"
#Checamos que el archivo de configuración tenga parametros

if [ -z "$domain" ]
then
	echo "El archivo de configuracion esta vacío" >&2
	exit 1
else
	# Realizamos la instalación de nis
	echo "Actualizando..."
	apt-get update &>/dev/null
	echo "Instalando nis..."
	DEBIAN_FRONTEND=noninteractive apt-get -y install nis &>/dev/null
	echo "nis instalado"
	echo "El nombre del dominio nis sera: $domain"
	#Cambiamos hostname y defaultdomain
	sed -i "s/^ASI2014.*/$domain/" /etc/hostname
	hostname $domain
	sed -i "s/^ASI2014.*/$domain/" /etc/defaultdomain
	domainname $domain

	#Establecemos la maquina como servidor (NISSERVER=master)
	sed -i "s/^NISSERVER=.*/NISSERVER=master/" /etc/default/nis

	#Modificamos /var/yp/Makefile (MERGE_PASSWD=true / MERGE_GROUP=true)
	sed -i "s/^MERGE_PASSWD=.*/MERGE_PASSWD=true/" /var/yp/Makefile
	sed -i "s/^MERGE_GROUP=.*/MERGE_GROUP=true/" /var/yp/Makefile

	#Añadimos direccion ip para servicio NIS en /etc/hosts y borramos la creada por default
	sed -i '/ASI2014/d' /etc/hosts ##Borrando ip
	echo "$myIp $domain" >> /etc/hosts ##Añadiendo la propia

	# Reiniciamos nis para cambiar los nombres automaticamente
	service nis restart

	#Actualizamos la base de datos de nis
	EOF | /usr/lib/yp/ypinit -m

	#Reiniciamos nis
	service nis restart
	echo "Se configuro la máquina servidora con dominio: $domain"
	exit 0
fi
