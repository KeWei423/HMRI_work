#!/bin/bash
input=$1
dest="/Users/baymac/Desktop/Data_todo/HABLE/NII/Baseline"

for f in $(find $input -type f -name "ples*nii")
do

  echo $f
  f_name=$(basename $f)
  PID="${f_name:15:4}"
  echo $PID

  f_dir=$(find $dest -type d -name "$PID*")
  # echo $f_dir

  cp $f $f_dir"/SAG_MPRAGE/"

done
