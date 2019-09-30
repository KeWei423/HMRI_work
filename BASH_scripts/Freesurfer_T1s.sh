#!/bin/bash

freesurfer_mri () {
	echo "***** get the T1 intensity from subject/mri/aparc_aseg.mgz *****"

	colorLUT="/Applications/freesurfer/FreeSurferColorLUT.txt"
	dest="/Users/baymac/Desktop/results"

	read -p  "Cohort: [BR MEN WH SH]": study

	for d in $(find $fs_dir -name "$study*")
	do
		aseg_file=$d"/mri/aseg.mgz"
		brain_file=$d"/mri/brain.mgz"
		echo "$aseg_file"
		echo "$brain_file"
		ID=$(basename $d)
		echo "$ID"

		mri_segstats --seg $aseg_file --ctab $colorLUT --nonempty --excludeid 0  --sum $dest"/"$ID".csv" --in $brain_file
	done

}



# main function
# echo "======================= Fs ======================="
if [ "`whoami`" = "baymac" ]
then 
	fs_dir="/Applications/freesurfer/subjects"

	# read -p "Please input source directory: " src_dir
	# read -p  Cohort: [BR MEN WH SH]: study

	freesurfer_mri

fi