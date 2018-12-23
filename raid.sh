#!/bin/bash

# Comprobamos que se pasa un fichero de configuración de raid
if [ $# -ne 1 ]
then
	(>&2 echo "Proporciona el archivo de configuración de raid")
	exit 1
fi

if [ $(wc -l < $1) -ne 3 ]
then
	echo "El fichero de configuración $1 no tiene el numero de lineas esperado" >&2
	echo "Abortando ejecucion..." >&2
	exit 1
fi

# Hacemos un update para asegurarnos que podemos buscar el servicio mdadm
echo "Actualizando lista de paquetes..."
apt-get update > /dev/null
echo "Lista de paquetes actualizados"


# Instalamos mdadm de tal forma que no pida interacción
echo "Instalando paquete mdadm..."
DEBIAN_FRONTEND=noninteractive apt-get install mdadm > /dev/null
if [ $? -eq 0 ]
then
	echo "Se han instalado los paquetes de mdadm"
else
	(>&2 echo "La instalacion de los paquetes mdadm ha fallado")
	(>&2 echo "Abortando ejecución...")
	exit 1
fi

# Cargamos las tres líneas que debería tener el fichero de configuración en tres variables
newDevice="$(sed -n 1p $1)"
raidLevel="$(sed -n 2p $1)"
devices="$(sed -n 3p $1)"
raidDevices="$(echo $devices | wc -w)"

# Creamos el array
echo "Creando el RAID..."
yes | mdadm --create --verbose $newDevice --level=$raidLevel --raid-devices=$raidDevices $devices > /dev/null
if [ $? -eq 0 ]
then
	echo "RAID creado correctamente"
else
	(>&2 echo "Error en la creación del RAID")
	(>&2 echo "Abortando ejecucion...")
	exit 1
fi
