#!/bin/bash

#Servicio Nis_server

# Comprobamos que se pasa un fichero de configuración de mount
if [ $# -ne 1 ]
then
	echo "Proporciona el archivo de configuración de nis_server"
	exit 1
fi

#Nombramos las variables del archivo de configuracion
domain="$(sed -n 1p $1)"

#Checamos que el archivo de configuración tenga parametros

if [ -z "$domain" ]
then
	echo "El archivo de configuracion esta vacío"
else
	#Creamos el servidor nis
	echo "El nombre del dominio nis sera: $domain"
	domainname $domain
	domainname
fi
