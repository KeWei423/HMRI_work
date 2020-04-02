#!/bin/bash

root='/home/ke/Desktop/HABLE_vents'

for f in `ls $root`; do
    if [[ -d $root/$f && -f $root/$f/${f}_leftlatventricle.nii.gz && -f $root/$f/${f}_rightlatventricle.nii.gz ]]; then
        echo $root/$f/${f}_latventricles.nii.gz
        fslmaths $root/$f/${f}_leftlatventricle.nii.gz -div 4 $root/$f/left_temp.nii.gz
        fslmaths $root/$f/${f}_rightlatventricle.nii.gz -div 43 $root/$f/right_temp.nii.gz
        fslmaths $root/$f/left_temp.nii.gz -add $root/$f/right_temp.nii.gz $root/$f/${f}_latventricles.nii.gz
        rm -f $root/$f/left_temp.nii.gz
        rm -f $root/$f/right_temp.nii.gz
    fi
done
