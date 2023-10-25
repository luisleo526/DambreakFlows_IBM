cores=$1

ls new/out/*.vts | parallel -j$cores bash scripts/to_pov.sh {}