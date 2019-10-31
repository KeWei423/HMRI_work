#!/bin/bash

work_dir="/home/ke/Desktop/test"
for f in $(find $work_dir -type f -iname "*.nii")
do

	echo $f
	name=$(basename $f)
	echo $name
    OIFS=$IFS
    IFS='_'
    read -r -a array <<< $name
    IFS=$OIFS
    f_name=${array[0]}_${array[-1]}
    f_name_final=${f_name::-10}
    echo ID: $f_name_final
    f_dir="$work_dir"/$f_name_final
    echo $f_dir
	# recon-all -i $f -s $name -sd $sd -openmp 8 -parallel -autorecon-all
	recon-all -i $f -s $name -openmp 12 -parallel -autorecon-all
done

