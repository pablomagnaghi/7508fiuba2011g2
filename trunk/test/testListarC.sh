#!/bin/bash

# Autor: Carlos Pantelides 74901
# 
# Test para listarc.pl

#bootstrap
. ../extras/setGrupoCarlos.sh
# iniciarC.sh
RUN="../grupo2/inst/comandos/listarC.pl"


extraDiff() {
	if [ $1 -eq 1 ]; then
		echo "------------------------------------------------------------------"
		echo "Fail....";
		echo "$2" > esperado.txt
		echo "$3" > salida.txt
		diff --side-by-side esperado.txt salida.txt
		echo "------------------------------------------------------------------"
	fi
}

testExitNoSalida() {
	$RUN > /dev/null 2>&1
	exit=$?
	assertEquals "Mal exit status" 3 $exit
}

testOutputNoSalida() {
	$RUN 2>&1 | grep -q -e "Debe proveer un destino -c o -e"
	exit=$?
	assertEquals "Mal mensaje error" 0 $exit
}

testSalida() {
	$RUN -c 2>&1 | grep -q -e "Salida a pantalla seleccionada"
	exit=$?
	assertEquals "-c No salida a pantalla" 0 $exit

	$RUN -e 2>&1 | grep -q -e "Salida a archivo seleccionada"
	exit=$?
	assertEquals "-e No salida a archivo" 0 $exit

	o=$($RUN -e -c 2>&1)
	echo $o | grep -q -e "Salida a archivo seleccionada"
	exit=$?
	assertEquals "-e -c No salida a archivo" 0 $exit

	echo $o | grep -q -e "Salida a pantalla seleccionada"
	exit=$?
	assertEquals "-c -e No salida a archivo" 0 $exit
}

testExitArgumentoDesconocido() {
	$RUN -x  > /dev/null 2>&1
	exit=$?
	assertEquals "Mal exit status -x" 2 $exit

	$RUN -x -E 1 > /dev/null 2>&1
	exit=$?
	assertEquals "Mal exit status -x -E 1" 2 $exit

	$RUN -E 1 -x  > /dev/null 2>&1
	exit=$?
	assertEquals "Mal exit status -E 1 -x" 2 $exit
}


testOutputArgumentoDesconocido() {
	$RUN -x 2>&1 | grep -q -e "Argumento desconocido"
	exit=$?
	assertEquals "-x Argumento desconocido no detectado" 0 $exit

	$RUN -E 1 -x 2>&1 | grep -q -e "Argumento desconocido"
	exit=$?
	assertEquals "-E 1 -x Argumento desconocido no detectado" 0 $exit

	$RUN -x -E 1 2>&1 | grep -q -e "Argumento desconocido"
	exit=$?
	assertEquals "-x -E 1 Argumento desconocido no detectado" 0 $exit
}

testExitCriteriosVacios() {
	$RUN -c -E  > /dev/null 2>&1
	exit=$?
	assertEquals "Critero vacio -E no detectado" 4 $exit

	$RUN -c -C  > /dev/null 2>&1
	exit=$?
	assertEquals "Critero vacio -C no detectado" 4 $exit

	$RUN -c -N  > /dev/null 2>&1
	exit=$?
	assertEquals "Critero vacio -N no detectado" 4 $exit

	$RUN -c -S  > /dev/null 2>&1
	exit=$?
	assertEquals "Critero vacio -S no detectado" 4 $exit
}

testOutputCriteriosVacios() {
	$RUN -E 2>&1 | grep -q -e "Debe proveer algun elemento para -E"
	exit=$?
	assertEquals "Critero vacio -E no detectado" 0 $exit

	$RUN -C 2>&1 | grep -q -e "Debe proveer algun elemento para -C"
	exit=$?
	assertEquals "Critero vacio -C no detectado" 0 $exit

	$RUN -N 2>&1 | grep -q -e "Debe proveer algun elemento para -N"
	exit=$?
	assertEquals "Critero vacio -N no detectado" 0 $exit

	$RUN -S 2>&1 | grep -q -e "Debe proveer algun elemento para -S"
	exit=$?
	assertEquals "Critero vacio -S no detectado" 0 $exit
}


testOutputFicha() {

esperado="Encuesta Nro: 1024 realizada por EPORRA Elisa Porra el dia 20110907

Cliente 30354444882, Modalidad P, Sitio E y Persona II

Encuesta aplicada E01 Estándar para nuevos clientes compuesta por 9 preguntas

Puntaje obtenido: 12 calificación: amarillo
--------------------------------------------------------------------------------"

	salida=$( $RUN 2>/dev/null -e -c -E EPORRA -F  )
	assertEquals "Salida de ficha no coincide" "$esperado" "$salida"
	extraDiff $? "$esperado" "$salida"
}


testOutputReporteSinAgrupacionUnCaso() {
esperado="+-------+----------+----------+----------+
|       |    verde | amarillo |     rojo |
+-------+----------+----------+----------+
| todos |       -- |        1 |       -- |
+-------+----------+----------+----------+"
	salida=$( $RUN 2>/dev/null -e -c -E EPORRA )
	assertEquals "Salida de reporte  no coincide" "$esperado" "$salida"
	extraDiff $? "$esperado" "$salida"
}

testOutputReporteSinAgrupacionVariosCasos() {
esperado="+-------+----------+----------+----------+
|       |    verde | amarillo |     rojo |
+-------+----------+----------+----------+
| todos |        2 |        3 |        2 |
+-------+----------+----------+----------+"
	salida=$( $RUN 2>/dev/null -e -c )
	assertEquals "Salida de reporte  no coincide" "$esperado" "$salida"
	extraDiff $? "$esperado" "$salida"
}

notestOutputReporteAgrupadoPorEncuestadorUnCaso() {
esperado="+--------+----------+----------+----------+
|        |    verde | amarillo |     rojo |
+--------+----------+----------+----------+
| EPORRA |        2 |        3 |        2 |
+--------+----------+----------+----------+"
	salida=$( $RUN 2>/dev/null -e -c )
	assertEquals "Salida de reporte  no coincide" "$esperado" "$salida"
	extraDiff $? "$esperado" "$salida"
}


. shunit2/shunit2
