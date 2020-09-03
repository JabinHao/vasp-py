#! /usr/bin/env bash

# To save the results of last calculation and calculate continue
# To use it: save_calculation.sh N ,note that N is hte time it calculation

mv POSCAR POSCAR-$1
mv OUTCAR OUTCAR-$1
mv OSZICAR OSZICAR-$1
mv vasprun.xml vasprun.xml-$1
mv CONTCAR POSCAR
