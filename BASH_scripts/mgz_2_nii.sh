#!/bin/bash

path=$1

for file in $(find $path -name "brain.mgz"); do
    echo $file
    O_IFS=$IFS
    IFS='/'
    read -a array <<< $file
    pid=${array[-3]}
    IFS=$O_IFS
    mkdir -p $path/fs_T1
    f_path=$path/fs_T1/${pid}_FS_T1.nii.gz
    echo $f_path
    mri_convert $file $f_path
done
