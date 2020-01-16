#! /usr/bin/env bash

# this script is used to make sure if the task has converged
# Folders should be named in numerical order
# To use it: convergence.sh N,note that N is the number of your tasks

test -d ./1 || (echo "dir not exist" && exit 1)
echo -e "\n"
echo -e "========================================================================================\n"
for (( i = 1; i < $1+1 ; i++))
do
#	echo $i
	if [ -d $i ]
	then
		if [ -f $i/input/OUTCAR ]
		then
			cd $i/input/
			result=`grep "reached required" OUTCAR`
			if [ -n "$result" ]
			then
				echo -e "$i\c " && grep "reached required" OUTCAR
			else	
				echo "$i   task does not reach convergence"
			fi
			cd ../..
		else
			echo "$i   task has not completed!"
		fi
	else
		echo "dir $i does not exit"
	fi
done
echo -e "\n========================================================================================\n"
