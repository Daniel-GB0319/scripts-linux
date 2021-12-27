#!/bin/bash

# Se alinearon mensajes de comfirmacion para cada comando finalizado con exito. 27/Dic/2021

clear
echo ""
echo "		***** Script para Actualizacion y Limpieza de la Distribucion *****"
echo "		    		****** Autor: Daniel Gonzalez *******"
echo "				 	     Ver. 1.4.1"
echo ""
echo "Comandos a ejecutar:"
echo "1) sudo apt update"
echo "2) sudo apt upgrade -y"
echo "3) sudo apt full-upgrade -y"
echo "4) sudo apt autoclean -y"
echo "5) sudo apt autoremove -y"
echo ""
echo "Ingrese la contraseña para dar privilegios Root y espere a que el Script termine:"
echo ""
sleep 2s
sudo apt update
echo ""
echo "------------------------ !!! Repositorios Sincronizados !!! --------------------------"
echo "     Ahora se actualizaran los Programas/Paqueterias en caso de haber nuevas versiones"
echo ""
sudo apt upgrade -y
echo ""
echo "-------------------- !!! Programas/Paqueterias Actualizados !!! ----------------------"
echo "        Ahora se actualizara la Distribucion, en caso de haber nuevas versiones"
echo ""
sudo apt full-upgrade -y 
echo ""
echo "------------------------ !!! Distribucion Actualizada !!! ----------------------------"
echo "           Ahora se limpiaran los archivos de actualizacion innecesarios"
echo ""
sudo apt autoclean -y
echo ""
echo "--------------------------- !!! Limpieza Completada !!! ------------------------------"
echo "                  Por ultimo se eliminaran paquetes innecesarios"
echo ""
sudo apt autoremove -y
echo ""
echo "		 ******** Tarea de Actualizacion y Limpieza Terminada *******"
echo ""
