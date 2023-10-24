#!/bin/bash

case=$1

if [ $case = "A" ];then
	u = "0.408"
elif [ $case = "B" ];then
	u = "0.696"
elif [ $case = "C" ];then
	u = "0.952"
elif [ $case = "D" ];then
	u = "1.194"
fi

declare -a params=(
    "16 4 0.01"
    "24 4 0.01"
    "32 5 0.01"
)

declare -a methods=(
    "2 MPLS"
    "3 CLSVOF"
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

        sed -i -e "4 c ${name}" input/default.txt
        sed -i -e "12 c ${paramInfo[1]}" input/default.txt
        sed -i -e "14 c ${paramInfo[0]} 10" input/default.txt
        sed -i -e "26 c ${paramInfo[2]} 0.5" input/default.txt

        nohup ./RUN &> logs/$case/$name&
        sleep 3

    done     
done