#! /usr/bin/env bash

#===============================================================================#
# to delete output files of VASP but keep the input files                       #
# use it while task failed and want to restart from the begining                 #
# written by jphao on 2019.12.30                                                #
# to use it: dele.sh path                                                       #
#===============================================================================#

read -p $'Enter your dir, please:\n' path
while [ "$path" == "" ]
do
	echo "you did not enter any path, the default path is /home, command dennied."
	echo "please enter again:"
	read  path
done
if test -d $path
then
	echo "This dir $_ is exit"
else
	echo  "This dir $_ does not exit" 
	exit 2
fi
cd $path
full_path = $(pwd)
echo "your path is $full_path"
for i in $(ls)
do
	  if [[ $i != "INCAR" ]] && [[ $i != "POSCAR" ]] && [[ $i != "KPOINTS" ]] && [[ $i != "POTCAR" ]]
	  then
		echo "delete file $i"
		rm $i
	  else
		continue
	  fi
	  echo "output files have been deleted!"
done
cd ..
