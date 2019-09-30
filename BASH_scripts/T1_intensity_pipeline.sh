#!/bin/bash


#FSL: BET
bet_og() {
	echo "***** Brain Extraction for the Oringial Nifi image *****"
	for f in $(find $src_dir -type f -iname "*.nii")
	do
		echo $f
		ID_DOE=$(basename $f)
		ID="${ID_DOE%%_*}"
		DOE="${ID_DOE//*_}"
		DOE=${DOE:0:8}
		BET_ID=$ID"_"$DOE"_bet.nii"

		mkdir -p $src_dir/bet
		dest_dir=$src_dir"/bet/"$BET_ID

		bet $f $dest_dir -R -f 0.5 -g 0

	done
}


#Freesurfer: convert mgz to nii
fs_mgz2nii(){
	echo "***** convert Freesurfered mgz format to Nii format *****"
	for f in $(find $src_dir -type f -mindepth 1 -maxdepth 2 -iname "*.nii")
	do
		ID_DOE=$(basename $f)
		ID="${ID_DOE%%_*}"
		DOE="${ID_DOE//*_}"
		DOE=${DOE:0:8}
		fs_ID=$ID"_"$DOE"_fsT1.nii.gz"
		
		mkdir -p $src_dir/fs_T1

		path=$(find $fs_dir -name "$ID*" -type d)

		if [[ ! -z "${path// }" ]] #if string not empty
		then
			fs_subj_T1="$path/mri/brain.mgz"
			dest_file_name=$src_dir"/fs_T1/"$fs_ID
			echo "$fs_subj_T1: $dest_file_name"
			mri_convert $fs_subj_T1 $dest_file_name
		fi
	done
}


#FSL: FLIRT
flirt_fs2fsl(){
	echo "***** Register brain extracted Nifti to Freesurfered Nifti *****"
	echo "$src_dir"
	for f in $(find $src_dir/bet -type f -iname "*bet.nii.gz")
	do

		ID=$(basename $f)
		ID=${ID%%.*}
		ID=${ID%_*}

		fs_T1=$(find $src_dir/fs_T1 -name "$ID*" -type f)
		echo "$fs_T1"
		
		mkdir -p $src_dir/registered
		reg_T1=$ID"_registered.nii.gz"
		echo "reg_T1: $reg_T1"
		if [[ ! -z "${fs_T1// }" ]] #if string not empty
		then
			# echo "Hello"
			dest_file_name=$src_dir"/registered/"$reg_T1
			echo "$f+$fs_T1->$dest_file_name"
			flirt -in $f -ref $fs_T1 -out $dest_file_name \
			      -omat $src_dir"/registered/"$ID"_new.mat" \
				  -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 7  -interp trilinear
		fi
	done
}


#Freesurfer: extract regions of interest
fs_roi(){
	echo "***** Freesurfer: extract ROI binary mask *****"
	for f in $(find $fs_dir -type d -name "*")
	do
		source=$f"/mri/aseg.mgz"
		echo "$source"

		#cerebral WM
		mri_binarize --i $source  --match 2 41 --o $f"/mri/Cerebral_WM.nii.gz"

		#cerebral cortex
		mri_binarize --i $source  --match 3 42 --o $f"/mri/Cerebral_cortex.nii.gz"

		#cerebellum WM
		mri_binarize --i $source  --match 7 46 --o $f"/mri/Cerebellum_WM.nii.gz"

		#cerebellum cortex
		mri_binarize --i $source  --match 8 47 --o $f"/mri/Cerebellum_cortex.nii.gz"

		#Caudate
		mri_binarize --i $source  --match 11 50 --o $f"/mri/Caudate.nii.gz"

		#putamen
		mri_binarize --i $source  --match 12 51 --o $f"/mri/Putamen.nii.gz"

		#globus pallidus
		mri_binarize --i $source  --match 13 52 --o $f"/mri/Globus_pallidus.nii.gz"

		#Brain Stem
		mri_binarize --i $source  --match 16 --o $f"/mri/Brain_stem.nii.gz"
	done
}


#FSL: extract signal intensity
roi_sig_intensity(){
	echo "***** FSL: get the T1 Signal Intnesity for ROIs *****"
	#Declare the array of ROI 
	declare -a StrArr=("Cerebral_WM" "Cerebral_cortex" "Cerebellum_WM" "Cerebellum_cortex" "Caudate" "Putamen" "globus_pallidus" "Brain_stem")
	# dest="/Users/baymac/Desktop/Data_todo/T1_signal/Raw/"

	read -p  "Cohort: [BR MEN WH SH]:" study



	for f in $(find $fs_dir -type d -name "$study*")
	do
		roi_path=$f"/mri/"
		echo "roi_path: $roi_path"

		ID=$(basename $f)
		# ID=${ID%%.*}
		ID=${ID%_*}
		ID=${ID:0:cd d5}
		echo "ID: $ID"

		# echo "source dir: $src_dir"
		reg_T1=$(find $src_dir/registered -name "$ID*" -type f -iname "*.nii.gz")
		echo "reg_T1: $reg_T1"



		if [[ ! -z "${reg_T1// }" ]] #if string not empty
		then
			echo "reg_T1: $reg_T1"
			echo "roi_path: $roi_path"
			for roi in ${StrArr[@]}
			do
				echo "$roi: $roi_path$roi".nii.gz""
				fslmeants -i $reg_T1 -m $roi_path$roi".nii.gz" -o $src_dir"/"$ID"_"$roi"_T1_signal_meants.txt"
			done
		fi

		# paste $src_dir/temp*.txt >> $src_dir/$ID"_allROI.txt"
		# rm $src_dir/temp*.txt
	done


}


# main function
echo "======================= Running T1 signal intensity Extraction Pipeline ======================="
if [ "`whoami`" = "baymac" ]
then 
	fs_dir="/Applications/freesurfer/subjects"

	read -p "Please input source directory: " src_dir
	# read -p  Cohort: [BR MEN WH SH]: study

	# bet_og	
	# fs_mgz2nii
	# flirt_fs2fsl
	# fs_roi
	roi_sig_intensity

fi