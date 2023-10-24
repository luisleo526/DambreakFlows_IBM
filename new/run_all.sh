#!/bin/bash

declare -a cases=(
    "A 0.408"
    "B 0.696"
    "C 0.952"
    "D 1.194"
)

declare -a params=(
    "16 4 0.005"
    "24 4 0.005"
    "32 5 0.005"
)

declare -a methods=(
    "2 MPLS"
    "3 CLSVOF"
)


for caseArgs in "${cases[@]}"; 
do
    read -a caseInfo <<< "$caseArgs"
    for paramArgs in "${params[@]}"; 
    do
    	read -a paramInfo <<< "$paramArgs" 
    	for methodArgs in "${methods[@]}";
    	do
    		read -a methodInfo <<< "$methodArgs"
    		sed -i -e "4 c Case${caseInfo[0]}_${methodInfo[1]}_${paramInfo[0]}" input/default.txt
    	done	 
    done
done