#!/bin/bash

case=$1
method=$2
grid=$3
cores=$4

cd POVRAY_FILES/Case${case}/${method}/${grid}

for view in side_view top_view
do
    mkdir $view;
    sed -i -e "33 c camera{${view}}" camera.inc;
    bash runall.sh $cores;
    mv *.png *.gif $view;
done
