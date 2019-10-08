#!/bin/bash

# Path to Freesurfer subjects folder
fsdir=/Applications/freesurfer/subjects

# Path to output folder for all ventricle masks
output=/Users/baymac/Desktop/Data_todo/Ventricle

# String pattern to match (grabs first arg), so call the script like this:
# ./get-vent-masks.sh WH
matchstr=$1

for dir in $(find $fsdir -mindepth 1 -maxdepth 1 -type d -name "$matchstr*")
do
    cd $dir/mri
    pid=${dir#$fsdir/}
    echo $pid
    mri_binarize --i aparc+aseg.mgz --match 4,14,15,43,24 --o $output/$pid.vent.mask.nii.gz
done
