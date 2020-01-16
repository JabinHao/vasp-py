#! /usr/bin/env bash

# To generate KPOINTS file
# Written by jipengHao on 2019-12-29
# To use it: kpoints.sh 3 3 1

echo K-POINTS > KPOINTS        #First line
echo 0 >> KPOINTS              #Auto Generate scheme
echo Gamma Centered >> KPOINTS #Gamma Centered MP grids
echo $1 $2 $3 >> KPOINTS       #Sibdivisios for N1,N2 and N3
echo 0 0 0 >> KPOINTS          #Optional shift of the mesh
