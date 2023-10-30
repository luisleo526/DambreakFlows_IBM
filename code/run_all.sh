#!/bin/bash

FILE="input/default.txt"
case=$1

if [ $case = "A" ];then
	sed -i -e "62 c 0.408" input/default.txt
elif [ $case = "B" ];then
	sed -i -e "62 c 0.696" input/default.txt
elif [ $case = "C" ];then
	sed -i -e "62 c 0.952" input/default.txt
elif [ $case = "D" ];then
	sed -i -e "62 c 1.194" input/default.txt
fi

declare -a grids=(
    "16 4"
    "24 4"
    "32 5"
)

declare -a methods=(
    "2   MPLS 0.005 15"
    "3 CLSVOF 0.005 20"
)

rm -rf logs/$case
mkdir -p logs/$case

for grid in "${grids[@]}"; 
do
    read -a gridArgs <<< "$grid" 
    for method in "${methods[@]}";
    do
        read -a methodArgs <<< "$method"
        name="Case${case}_${methodArgs[1]}_${gridArgs[0]}"

        sed -i -e "2 c ${methodArgs[0]}" $FILE
        sed -i -e "4 c ${name}" $FILE
        sed -i -e "12 c ${gridArgs[1]}" $FILE
        sed -i -e "14 c ${gridArgs[0]} 10" $FILE
        sed -i -e "24 c 30.0 0.5 ${methodArgs[3]}" $FILE
        sed -i -e "26 c ${methodArgs[2]} 0.1" $FILE

        nohup bash -c "time ./RUN" &> logs/$case/$name&
        sleep 2

    done     
done