#!/bin/bash -x

# Comprobamos que se pasa un fichero de configuración de raid
if [ $# -ne 1 ]
then
	echo "Proporciona el archivo de configuración de raid"
	exit 1
fi

# Hacemos un update para asegurarnos que podemos buscar el servicio mdadm
apt-get update

# Instalamos mdadm de tal forma que no pida interacción
DEBIAN_FRONTEND=noninteractive apt-get install mdadm

# Cargamos las tres líneas que debería tener el fichero de configuración en tres variables
newDevice="$(sed -n 1p $1)"
raidLevel="$(sed -n 2p $1)"
devices="$(sed -n 3p $1)"
raidDevices="$(echo $devices | wc -w)"

# Creamos el array
yes | mdadm --create --verbose $newDevice --level=$raidLevel --raid-devices=$raidDevices $devices

if [ $? -ne 0 ]
then
	echo "Error en la creación del raid"
	exit 2
fi
