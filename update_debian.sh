#!/bin/bash

# Se alinearon mensajes de comfirmacion para cada comando finalizado con exito.

clear
echo ""
echo "			***** Script para Actualizacion y Limpieza de la Distribucion *****"
echo "			    		****** Autor: Daniel Gonzalez *******"
echo "					 	      Ver. 1.4"
echo ""
echo "Comandos a ejecutar:"
echo "1) sudo apt update"
echo "2) sudo apt upgrade -y"
echo "3) sudo apt full-upgrade -y"
echo "4) sudo apt autoclean -y"
echo "5) sudo apt autoremove -y"
echo ""
echo "Solo ingrese la contraseña para dar privilegios de SuperUser y espere a que el Script termine:"
echo ""
sleep 2s
sudo apt update
echo ""
echo "----------------------------- !!! Ya estan los Repositorios Sincronizados !!! ------------------------------"
echo "            Ahora se actualizaran los Programas y/o Paqueterias en caso de haber nuevas versiones"
echo ""
sudo apt upgrade -y
echo ""
echo "----------------------- !!! Ya estan Actualizados los Programas y/o Paqueterias !!! ------------------------"
echo "                   Ahora se actualizara la Distribucion, en caso de haber nuevas versiones"
echo ""
sudo apt full-upgrade -y 
echo ""
echo "------------------------------- !!! Ya esta la Distribucion Actualizada !!! --------------------------------"
echo "            Ahora se limpiaran los archivos descargados de actualizaciones que ya no se necesitan"
echo ""
sudo apt autoclean -y
echo ""
echo "--------------------------------------- !!! Limpieza Completada !!! ----------------------------------------"
echo "                         Por ultimo se eliminaran paquetes que ya no son utiles"
echo ""
sudo apt autoremove -y
echo ""
echo "		            ******** Tarea de Actualizacion y Limpieza Terminada *******"
echo ""
