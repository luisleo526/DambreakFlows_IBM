#!/bin/bash

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

declare -a params=(
    "16 4 0.01"
    "24 4 0.01"
    "32 5 0.01"
)

declare -a methods=(
    "2 MPLS 0.01"
    "3 CLSVOF 0.005"
)

rm -rf logs/$case
mkdir -p logs/$case

for paramArgs in "${params[@]}"; 
do
    read -a paramInfo <<< "$paramArgs" 
    for methodArgs in "${methods[@]}";
    do
        read -a methodInfo <<< "$methodArgs"
        name="Case${case}_${methodInfo[1]}_${paramInfo[0]}"

        sed -i -e "2 c ${methodInfo[0]}" input/default.txt
        sed -i -e "4 c ${name}" input/default.txt
        sed -i -e "12 c ${paramInfo[1]}" input/default.txt
        sed -i -e "14 c ${paramInfo[0]} 10" input/default.txt
        sed -i -e "26 c ${mathodInfo[2]} 0.5" input/default.txt

        nohup bash -c "time ./RUN" &> logs/$case/$name&
        sleep 3

    done     
done