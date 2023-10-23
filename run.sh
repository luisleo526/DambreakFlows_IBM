root=$(pwd)

for grid in 16 24 32
do
    for case in A B C D
    do
        for method in MPLS CLSVOF
        do
            cp $root/POVRAY_FILES/*  ${root}/Case${case}/${method}/${grid}/
            cd $root/Case${case}/${method}/${grid}/ && bash runall.sh 96
        done
    done
done
