#!/bin/bash

traverse() {
    for dir in $(find $PWD -maxdepth 1 -mindepth 1 -type d)
    do
      echo "DIR: $dir"
    	DEST="/Users/baymac/Desktop/Data_todo/NII"

      ID=$(basename $dir)
      echo "ID: $ID"
      if [[ $ID == [0-9]* ]]; then
        for serdir in $(find $dir -mindepth 2 -maxdepth 2 -type d)
        do
          # echo "Serdir: $serdir"
          DOE=$(basename $serdir)
          DOE=${DOE:0:10}
          ID_DOE=$ID"_"$DOE
          sequence_dir=$(basename $(dirname $serdir))

          mkdir -p $DEST/$ID_DOE/$sequence_dir
          dcm2niix -f %i_%p_%t -o $DEST/$ID_DOE/$sequence_dir/ $serdir
        done
      else
        for serdir in $(find $dir -mindepth 2 -maxdepth 2 -type d)
        do
          DOE=$(basename $(dirname $serdir))
          ID_DOE=$ID"_"$DOE
          sequence_dir=$(basename $serdir)
          echo "ID_DOE: $ID_DOE"
          echo "sequence_dir: $sequence_dir"
          mkdir -p $DEST/$ID_DOE/$sequence_dir
          dcm2niix -f %i_%p_%t -o $DEST/$ID_DOE/$sequence_dir/ $serdir
        done
      fi
    done
    return
}

inputdir=$1
echo "Running image conversion script."
if [ "`whoami`" = "baymac" ]
then
    traverse
fi
echo "-----------!!!!!Finished image conversion script!!!!--------------"
