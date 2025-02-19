#!/bin/sh


DESIGN=$1
NWORST=$2
CC=$3
SI=$4
PEX=$5

#module load tempus/21.1

DESIGN=$DESIGN NWORST=$NWORST CC=$CC SI=$SI PEX=$PEX tempus -file run_tps.tcl
