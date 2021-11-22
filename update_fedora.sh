#!/bin/bash

# Primera version para RedHat y derivados.

clear
echo ""
echo "			***** Script para Actualizacion y Limpieza de la Distribucion *****"
echo "			    		****** Autor: Daniel Gonzalez *******"
echo "					 	      Ver. 1.0"
echo ""
echo "Comandos a ejecutar:"
echo "1) sudo dnf -y upgrade"
echo "2) sudo dnf -y distro-sync"
echo "3) sudo dnf clean all"
echo "5) sudo dnf -y autoremove"
echo ""
echo "Solo ingrese la contraseña para dar privilegios de SuperUser y espere a que el Script termine:"
echo ""
sleep 2s
sudo dnf -y upgrade
echo ""
echo "-------------------------- !!! Ya estan los Paquetes Sincronizados y Actualizados !!! ----------------------"
echo "                    Ahora se actualizara la Distribucion, en caso de haber nuevas versiones"
echo ""
sudo dnf -y distro-sync
echo ""
echo "------------------------------- !!! Ya esta la Distribucion Actualizada !!! --------------------------------"
echo "            Ahora se limpiaran los archivos descargados de actualizaciones que ya no se necesitan"
echo ""
sudo dnf clean all
echo ""
echo "------------------------------------ !!! Limpieza Completada !!! ----------------------------------------"
echo "                         Por ultimo se eliminaran paquetes que ya no son utiles"
echo ""
sudo dnf -y autoremove
echo ""
echo "		            ******** Tarea de Actualizacion y Limpieza Terminada *******"
echo ""
