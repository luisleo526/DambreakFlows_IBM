#!/bin/bash

case=$1
method=$2
grid=$3

mkdir POVRAY_FILES/Case$case/$method/$grid

pvbatch VTS-to-POVRAY/POVRAY_extractor.py -r new/out -p Case$case_$method_$grid*.vts -t Phi -o POVRAY_FILES/Case$case/$method/$grid

find POVRAY_FILES -maxdepth 1 -type f -exec cp {} POVRAY_FILES/Case$case/$method/$grid \;
