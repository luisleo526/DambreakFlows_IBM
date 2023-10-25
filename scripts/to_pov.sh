#!/bin/bash

filepath=$1
filename=$(basename $filepath)
IFS='_' read -r -a args <<< "$filename"
directory=POVRAY_FILES/${args[0]}/${args[1]}/${args[2]}
mkdir -p $directory
pvpython VTS-to-POVRAY/single_POVRAY_extractor.py -i $filepath -o ${directory}/${args[3]}
