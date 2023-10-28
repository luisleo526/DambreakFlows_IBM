#!/bin/bash

directory=$1
cores=$2

find POVRAY_FILES -maxdepth 1 -type f -name "*.inc" -exec cp {} $directory \;
cd $directory

for view in side_view top_view
do
    mkdir -p $view
    sed -i -e "33 c camera{${view}}" camera.inc;
    find . -maxdepth 1 -type f -name "*.pov" -exec povray {} +H1080 +W1920 +R3 +A +WT$cores +FN \; -exec sh -c 'mv "${0%.pov}.png" "${1}/${0%.pov}.png"' {} $view \;
    cd $view
    ffmpeg -f image2 -i %d.png output.gif
    cd ..
done
