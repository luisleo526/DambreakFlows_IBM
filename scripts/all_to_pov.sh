cores=$1

ls code/out/*.vts | parallel -j$cores bash scripts/to_pov.sh {}