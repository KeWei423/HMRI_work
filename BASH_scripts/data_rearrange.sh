#!/bin/bash
###############################################################################
#
################################################################################


convert() {
    SOURCE=$1
    DEST=$2

    for dir in $(find $SOURCE -maxdepth 1 -mindepth 1 -type d)
    do
      echo "DIR: $dir"
      ID=$(basename $dir)
      for serdir in $(find $dir -mindepth 2 -maxdepth 2 -type d)
      do
        DOE=$(basename $(dirname $serdir))
        ID_DOE=$ID"_"$DOE
        sequence_dir=$(basename $serdir)
        #echo "ID_DOE: $ID_DOE"
        # echo "sequence_dir: $sequence_dir"
        mkdir -p $DEST/$ID_DOE/$sequence_dir
        dcm2niix -f %i_%p_%s_%t -w 0 -i y -o $DEST/$ID_DOE/$sequence_dir/ $serdir
      done
    done

    #delete empty folders
    find $DEST -type d -empty -delete
    return
}

nii_2_seqence_base(){
  SOURCE=$1
  DEST_Process="/Users/baymac/Desktop/Data_todo/To_Process"
  DEST_archive="/Volumes/Image_Repository/HMRI_Raw_NII/Sequence_based"

  key_words=("FSPGR_3D" "CUBE_FLAIR" "CUBE_T2" "BOLD" "ASL" "DTI" "DKI" "DWI")

  for key in "${key_words[@]}"
  do
    if [[ $key == "BOLD" ]]; then
      echo "*****cp $key files to $DEST_Process && $DEST_archive"
      for file in $(find $SOURCE -type f -mindepth 2 -name "*$key*")
      do
        # echo $file
        cp $file $DEST_Process/$key
        cp $file $DEST_archive/$key
      done
    elif [[ $key == "FSPGR_3D" ]] || [[ $key == "CUBE_FLAIR" ]] || [[ $key == "CUBE_T2" ]]; then
      echo "*****cp $key files to $DEST_Process && $DEST_archive"
      for file in $(find $SOURCE -type f -mindepth 2 -name "*$key*.nii" -not -name "*+C*" -not -name "*C+*")
      do
        # echo $file
        cp $file $DEST_Process/$key
        cp $file $DEST_archive/$key
      done
    else
      echo "*****cp $key files to $DEST_archive"
      for f in $(find $SOURCE -type f -mindepth 2 -name "*$key*.nii")
      do
        # echo "$f"
        cp $file $DEST_archive/$key
      done
    fi
  done
  return
}

nii_2_patient_base(){
  SOURCE=$1

  # study directories
  BR="/Volumes/Image_Repository/HMRI_Raw_NII/Patient_based/BR/3T"
  EX="/Volumes/Image_Repository/HMRI_Raw_NII/Patient_based/EX"
  MEN="/Volumes/Image_Repository/HMRI_Raw_NII/Patient_based/MEN"
  SH="/Volumes/Image_Repository/HMRI_Raw_NII/Patient_based/SH"
  WH="/Volumes/Image_Repository/HMRI_Raw_NII/Patient_based/WH/3T"

  echo "*****Archive subject nii into designated study folder"

  for d in $(find $SOURCE -type d -maxdepth 1)
  do
    # echo "$d"
    ID=$(basename $d)
    if [[ $ID == "BR"* ]]; then
      echo "## $ID --> $BR"
      mv $d $BR/
    elif [[ $ID == "EX"* ]]; then
      echo "## $ID --> $EX"
      mv $d $EX/
    elif [[ $ID == "MEN"* ]]; then
      echo "## $ID --> $MEN"
      mv $d $MEN/
    elif [[ $ID == "SH"* ]]; then
      echo "## $ID --> $SH"
      mv $d $SH/
    elif [[ $ID == "WH"* ]]; then
      echo "## $ID --> $WH"
      mv $d $WH/
    fi
  done
  return
}



distribute_nii(){
  # echo "distribution function $PWD"
  SOURCE=$1
  TO_ARCHIVE="/Volumes/Image_Repository/HMRI_Raw_NII"

  cd $SOURCE

  # TO-DO:
  # 0. Renames

  # 1. Put into to_process folder
  nii_2_seqence_base $SOURCE

  #2. put into archive folder
  nii_2_patient_base $SOURCE
}

dcm_2_patient_base (){
  SOURCE=$1

  # study directories
  BR="/Volumes/Image_Repository/HMRI_Raw_DCM/BR"
  EX="/Volumes/Image_Repository/HMRI_Raw_DCM/EX"
  MEN="/Volumes/Image_Repository/HMRI_Raw_DCM/MEN"
  SH="/Volumes/Image_Repository/HMRI_Raw_DCM/SH"
  WH="/Volumes/Image_Repository/HMRI_Raw_DCM/WH"

  echo "*****Archive subject DICOM into designated study folder"

  for d in $(find $SOURCE -type d -maxdepth 1)
  do
    ID=$(basename $d)
    if [[ $ID == "BR"* ]]; then
      echo "## $ID --> $BR"
      rsync -av --progress $d $BR
    elif [[ $ID == "EX"* ]]; then
      echo "## $ID --> $EX"
      rsync -av --progress $d $EX
    elif [[ $ID == "MEN"* ]]; then
      echo "## $ID --> $MEN"
      rsync -av --progress $d $MEN
    elif [[ $ID == "SH"* ]]; then
      echo "## $ID --> $SH"
      rsync -av --progress $d $SH
    elif [[ $ID == "WH"* ]]; then
      echo "## $ID --> $WH"
      rsync -av --progress $d $WH
    fi
  done
}

inputdir=$1
echo "Running image conversion script"
if [ "`whoami`" = "baymac" ] || [ "`whoami`" = "ke" ]; then

    #Folder needed to used
    temp_nii="/Users/baymac/Desktop/Data_todo/NII"


    # convert DICOM to NIFTI files
    echo "----------------------Convert DICOM to NIFTI_----------------------"
    convert "$inputdir" "$temp_nii"

    echo "----------------------Distribut NIFTI to Destination---------------"
    # sort the Pt_NIFTI to different destination
    distribute_nii "$temp_nii"

    # store the dcm to FALCON
    dcm_2_patient_base $inputdir

    echo "---------------------------------FINISHED--------------------------"
fi
