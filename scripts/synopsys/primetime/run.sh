#!/bin/sh

DESIGN=$1
NWORST=$2
CC=$3
SI=$4
PEX=$5
#export LD_PRELOAD=/usr/lib64/libz.so.1.2.11
#module load primetime/O-2018.06-SP5-2

DESIGN=$DESIGN CC=$CC SI=$SI PEX=$PEX NWORST=$NWORST pt_shell -file run_pt.tcl

