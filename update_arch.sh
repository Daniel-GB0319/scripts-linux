#!/bin/bash

# Se creo la primera version del Script.

clear
echo ""
echo "			***** Script para Actualizacion y Limpieza de la Distribucion *****"
echo "			    		****** Autor: Daniel Gonzalez *******"
echo "					 	      Ver. 1.0"
echo ""
echo "Comandos a ejecutar:"
echo "1) sudo pacman -Syyu" #Sincroniza y Actualiza Paquetes
echo "2) pamac upgrade -a"  #Actualiza los paquetes de AUR
echo "3) pacman -Qdt" #Muestra una Lista de Paquetes Huerfanos
echo "4) sudo pacman -Rsn \$(pacman -Qdtq)" #Borra los Paquetes Huerfanos
echo "5) sudo pacman -Scc" #Borra cache de paquetes desinstalados
echo ""
echo "Solo ingrese la contraseña para dar privilegios de SuperUser y espere a que el Script termine:"
echo ""
sleep 2s
sudo pacman -Syyu 
echo ""
echo "--------------------------- !!! Ya estan los Paquetes Sincronizados y Actualizados !!! --------------------"
echo "                  Ahora se actualizaran los Paquetes de AUR en caso de haber nuevas versiones"
echo ""
pamac upgrade -a
echo ""
echo "------------------------------- !!! Ya estan los Paquetes AUR Actualizados !!! --------------------------------"
echo "                          Ahora se Limpíaran las Paqueterias/Dependencias Huerfanas"
echo ""
echo "Paquetes Huerfanos:"
echo ""
pacman -Qdt
echo ""
sudo pacman -Rsn $(pacman -Qdtq)
echo ""
echo "--------------------- ------- !!! Limpieza de Paquetes Huerfanos Completada !!! ----------------------------------------"
echo "                      Por ultimo se Borrara la cache de Paquetes Desinstalados o Antiguos"
echo ""
sudo pacman -Scc
echo ""
echo "		            ******** Tarea de Actualizacion y Limpieza Terminada *******"
echo ""
