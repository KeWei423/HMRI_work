#!/usr/bin/env bash
export FREESURFER_HOME=/Applications/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh

DEST_DIR="/Volumes/Image_Repository/Processed_Research_Data/FS_T1/"

for f in $(find $SUBJECTS_DIR -type f -name "T1.mgz")
do
  ID=$(basename $(dirname $(dirname $f)))
  echo "ID: $ID"
  filename=$ID"_FS_T1.nii"
  echo "filename: $filename"

  if  [[ $ID = BR* ]]
  then
    output=$DEST_DIR"BR/"$filename
  elif [[ $ID = SH* ]]
  then
    output=$DEST_DIR"SH/"$filename
  elif [[ $ID = WH* ]]
  then
    output=$DEST_DIR"WH/"$filename
  fi

  mri_convert -i $f -o $output

done
