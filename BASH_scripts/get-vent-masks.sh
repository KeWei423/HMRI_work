#!/bin/bash

# Path to Freesurfer subjects folder
fsdir=/Applications/freesurfer/subjects

# Path to output folder for all ventricle masks
output=/Users/baymac/Desktop/Data_todo/Ventricle_morph/Ventricels

# String pattern to match (grabs first arg), so call the script like this:
# ./get-vent-masks.sh WH
matchstr=$1

for dir in $(find $fsdir -mindepth 1 -maxdepth 1 -type d -name "$matchstr*")
do
    cd $dir/mri
    pid=${dir#$fsdir/}
    echo $pid
    mri_binarize --i aparc+aseg.mgz --match 4 --o $output/"Laterial_vent/"$pid"_L_lat_vent_mask.nii.gz"
    mri_binarize --i aparc+aseg.mgz --match 5 --o $output/"Inf_Laterial_vent/"$pid"_L_Inf_Lat_vent_mask.nii.gz"
    mri_binarize --i aparc+aseg.mgz --match 14 --o $output/"third_vent/"$pid"_3rd_Vent_mask.nii.gz"
    mri_binarize --i aparc+aseg.mgz --match 15 --o $output/"forth_vent/"$pid"_4th_Vent_mask.nii.gz"
    mri_binarize --i aparc+aseg.mgz --match 43 --o $output/"Laterial_vent/"$pid"_R_lat_vent_mask.nii.gz"
    mri_binarize --i aparc+aseg.mgz --match 44 --o $output/"Inf_Laterial_vent/"$pid"_R_Inf_Lat_vent_mask.nii.gz"
    #
    mri_binarize --i aparc+aseg.mgz --match 4 --match 5 --match 14 --match 15 --match 43 --match 44 --o $output/"vent_mask/"$pid"_vent_mask.nii.gz"
done
