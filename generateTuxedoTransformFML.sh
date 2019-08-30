#!/bin/bash

###############################################################
# Autor: Roque Javier Ducuara Sosa                            #
# Fecha: 2019/08/10                                           #
# Descripción: Shell encargado de armar el jar de los tuxedos #
# para el OSB                                                 #
###############################################################

fecha=`date +'%d-%m-%YT%H:%M:%S'`

# Solicita ruta de ejecutable jdk6
printf "\n%s" "*** Especifique la ruta de binarios de JDK 6 (por defecto es /usr/lib/jvm/oracle-java6/bin):"
read JAVA6_PATH
# Valida si se especifico ruta diferente por defecto
if [ "${JAVA6_PATH}" != "" ]; then
    JAVA6=${JAVA6_PATH}
else
    JAVA6=/usr/lib/jvm/oracle-java6/bin
fi
# Valida existencia de la ruta
if [ ! -d "${JAVA6}" ]; then
    echo "* La ruta ${JAVA6} del JDK configurado para compilar no existe. Verifique y vuelva a intentar."
    exit 1
fi
# Jar de Weblogic usado para la creación de las clases a partir de las tablas
# Solicita libreria de Weblogic necesaria para transformar tablas FML
printf "\n%s" "*** Especifique la ruta de la libreria Weblogic (por defecto ~/Oracle/Middleware/wlserver_10.3/server/lib/weblogic.jar):"
read WLJAR_PATH
if [ "${WLJAR_PATH}" != "" ]; then
    WLJAR=${WLJAR_PATH}
else
    WLJAR=~/Oracle/Middleware/wlserver_10.3/server/lib/weblogic.jar
fi
# Valida existencia de la libreria 
if [ ! -f "${WLJAR}" ]; then
    echo "* La ruta ${WLJAR} de la libreria de weblogic no existe. Verifique y vuelva a intentar."
    exit 2
fi
# Directorio padre del desarrollo
# Solicita ruta de directorios para compilar proyecto
printf "\n%s" "*** Especifique la ruta de directorios con fuentes a convertir (por defecto `pwd`/FML13):"
read dirPadre_PATH
if [ "${dirPadre_PATH}" != "" ]; then
    dirPadre="${dirPadre_PATH}"
else
    dirPadre="`pwd`/FML13"
fi
# Valida existencia de la libreria 
if [ ! -d "${dirPadre}" ]; then
    echo "* La ruta ${dirPadre} de fuentes a convertir no existe. Verifique y vuelva a intentar."
    exit 3
fi

# Ruta de las tablas FML
dirFML=${dirPadre}/fml
# Archivo de guía
dirMapeo=${dirPadre}/conf/archivo_mapeo.txt
# Carpeta donde están todos los .java
dirJava=${dirPadre}/java
# Carpeta de fuentes
dirSrc=${dirPadre}/src
# Ruta del archivo a crear
dirJar=${dirPadre}/bin
# Ruta de logs
dirLog=${dirPadre}/log

# Nombre del jar a crear
nombreJar=TuxedoFMLFieldMapping.jar

# Verifica la existencia de archivos con tablas FML para continuar el proceso
if [ `ls "${dirFML}" | wc -l` -eq 0 ]; then
    echo "* No existen archivos fuentes para convertir. Verifique y vuelva a intentar."
    exit 4
fi

cd ${dirJava}

####################################
# Proceso de creación de los .java #
####################################
echo "** Transformando archivos FML a archivos Java..."
for f in ${dirFML}/*
do
	${JAVA6}/java -cp ${WLJAR} weblogic.wtc.jatmi.mkfldclass32 $f
done


########################################
# Proceso de modificación de los .java #
########################################

echo "** Clasificando archivos Java..."

# Cargamos todos los .java en un arreglo
archivos=($(ls ${dirJava}))
# Cargamos todos el archivo de mapeo en otro arreglo
lista=($(cat ${dirMapeo}))
for archivo in ${archivos[@]}
do
	contador=0
	for i in ${lista[@]}
	do
		if [[ "opge.${archivo}" == "$i" ]]; then
			contador=1
			sed '1s/^/package tables.opge;\n\n/' ${dirJava}/${archivo} > ${dirSrc}/tables/opge/${archivo}
		fi
		if [[ "ppcs.${archivo}" == "$i" ]]; then
			contador=1
			sed '1s/^/package tables.ppcs;\n\n/' ${dirJava}/${archivo} > ${dirSrc}/tables/ppcs/${archivo}
		fi
		if [[ "ppga.${archivo}" == "$i" ]]; then
			contador=1
			sed '1s/^/package tables.ppga;\n\n/' ${dirJava}/${archivo} > ${dirSrc}/tables/ppga/${archivo}
		fi
	done
	if [[ "${contador}" == "0" ]]; then
		echo ${archivo} > ${dirLog}/pendiente-${fecha}.log
	fi
done

# Borramos los .java temporales, los que no tienen el paquete
#echo "Borrando .java sin paquetes"
#rm ${dirPadre}/java/*.java

# Compila archivos Java
echo "** Inicio de proceso de compilación de archivos Java..."
${JAVA6}/javac ${dirSrc}/tables/*/*.java -cp ${WLJAR} -d ${dirSrc}

# Genera paquete
echo "** Generando empaquetado de clases compiladas..."
cd ${dirSrc}
${JAVA6}/jar cf ${nombreJar} ./*
mv ${nombreJar} ${dirJar}
echo "**** Proceso terminado. *****"

exit 0
