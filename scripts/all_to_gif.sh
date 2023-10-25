cores=$1

find POVRAY_FILES -mindepth 3 -maxdepth 3 -type d -exec bash scripts/to_gif.sh {} $cores \;
