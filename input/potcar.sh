#! /usr/bin/env bash

# Create a GGA_PAW POTCAR file
# Written by jipengHao on 2019-12-29
# To use it: potcar.sh element1 element2 ..

# Define local potpaw_GGA pseudopotential repository:
repo="/home/mse/jphao/package/vasp-psudopotential/paw_pbe"    #your path of pseudopotential file
 
# Check if older version of POTCAR is present
if [ -f POTCAR ];then
	mv -f POTCAR old-POTCAR
	echo "** Warning: old POTCAR file found and renamed to 'old-POTCAR'."
fi

# Main loop - concatenate the appropritatePOTCARs(or archievs)
for i in $*
do
	if test -f $repo/$i/POTCAR
	then
		cat $repo/$i/POTCAR>> POTCAR
	elif [ -f $repo/$i/POTCAR.Z ] || [ -f $repo/$i/POTCAR.gz ]
	then
		zcat $repo/$i/POTCAR.*>>POTCAR
	else
		echo "** Warning: No suitable POTCAR for element '$i' found! Skipped this element."
	fi
done
