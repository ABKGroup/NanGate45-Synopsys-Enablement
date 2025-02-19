#!/bin/sh

DESIGN=$1
NWORST=$2
CC=$3
SI=$4
PEX=$5

#module load star_rc/O-2018.06-SP5-6
DESIGN=$DESIGN CC=$CC python3 run_starRC.py

