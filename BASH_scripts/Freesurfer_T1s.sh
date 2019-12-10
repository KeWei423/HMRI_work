#!/bin/bash

freesurfer_mri () {
	echo "***** get the T1 intensity from subject/mri/aparc_aseg.mgz *****"

	colorLUT="/Applications/freesurfer/FreeSurferColorLUT.txt"
	dest="/Users/baymac/Desktop/results"

	# read -p  "Cohort: [BR MEN WH SH]": study

	for d in $(find $SUBJECTS_DIR -name "BR*")
	do
		# echo "d: $d"
		aseg_file=$d"/mri/aseg.mgz"
		brain_file=$d"/mri/T1.mgz"
		echo "seg: $aseg_file"
		echo " T1: $brain_file"
		ID=$(basename $d)
		echo "$ID"

		mri_segstats --seg $aseg_file \
								 --ctab $colorLUT \
								 --nonempty --exclude 0 \
								 --sum $dest"/"$ID"_T1.csv" \
								 --in $brain_file
	done

}



# main function
# echo "======================= Fs ======================="
if [ "`whoami`" = "baymac" ]
then
	# read -p "Please input source directory: " src_dir
	# read -p  Cohort: [BR MEN WH SH]: study

	freesurfer_mri

fi


mri_segstats --seg BR001_3T_20170511/mri/aseg.mgz
						 --ctab /Applications/freesurfer/FreeSurferColorLUT.txt
						 --nonempty --exclude 0
						 --sum /Users/baymac/Desktop/test_Br001.csv
						 --in BR001_3T_20170511/mri/T1.mgz

						 seg: /Applications/freesurfer/subjects/BR019_3T_20171220/mri/aseg.mgz
 T1: /Applications/freesurfer/subjects/BR019_3T_20171220/mri/T1.mgz
