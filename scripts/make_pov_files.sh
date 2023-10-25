#!/bin/bash

case=$1
method=$2
grid=$3

directory=POVRAY_FILES/Case${case}/${method}/${grid}

mkdir -p $directory

pvbatch VTS-to-POVRAY/POVRAY_extractor.py -r new/out -p Case${case}_${method}_${grid}*.vts -t Phi -o $directory

find POVRAY_FILES -maxdepth 1 -type f -exec cp {} $directory \;
