#!/bin/sh

DESIGN=$1
NWORST=$2
CC=$3
SI=$4
PEX=$5

#module load innovus/21.1
DESIGN=$DESIGN NWORST=$NWORST SI=$SI CC=$CC innovus -file run_invs.tcl
