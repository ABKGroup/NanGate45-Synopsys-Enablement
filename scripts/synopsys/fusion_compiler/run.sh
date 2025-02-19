#!/bin/sh

DESIGN=$1
NWORST=$2
CC=$3
SI=$4
PEX=$5
#module load fusion_compiler/T-2022.03-SP2

DESIGN=$DESIGN NWORST=$NWORST SI=$SI CC=$CC fc_shell -file run_fc.tcl
