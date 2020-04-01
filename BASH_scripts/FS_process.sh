#!/bin/bash

post_recon_all () {
    f_name_final=$1

    # This is for the mri convert (adapted from Ke's One-Note)
    subject_dir=$FREESURFER_HOME/subjects/$f_name_final
    post_recon_file=$subject_dir/post_recon_log.txt
    echo "subject dir : $subject_dir" >> $post_recon_file
    brain_file=$subject_dir/mri/brain.mgz
    echo "brain_file : $brain_file" >> $post_recon_file

    O_IFS=$IFS
    IFS='/'
    read -a array <<< $brain_file
    pid=${array[-3]}
    IFS=$O_IFS
    fs_T1_dir=~/Desktop/convert_mgz
    mkdir -p "$fs_T1_dir"
    mri_convert $brain_file $fs_T1_dir/${pid}_FS_T1.nii.gz >> $post_recon_file
    echo "source $fs_T1_dir/${pid}_FS_T1.nii.gz" >> $post_recon_file
    echo "dest   $subject_dir/${pid}_FS_T1.nii.gz" >> $post_recon_file
    cp $fs_T1_dir/${pid}_FS_T1.nii.gz $subject_dir

    wm_file=$subject_dir/mri/wm.mgz
    mri_convert $wm_file $fs_T1_dir/${pid}_FS_WM.nii.gz >> $post_recon_file
    echo "source $fs_T1_dir/${pid}_FS_WM.nii.gz" >> $post_recon_file
    echo "dest   $subject_dir/${pid}_FS_WM.nii.gz" >> $post_recon_file
    cp $fs_T1_dir/${pid}_FS_WM.nii.gz $subject_dir
    echo "------------------- mri convert finished  -------------------" >> $post_recon_file


    # This is for the T1 intensity (adpated from Ke's One-Note)
    aseg_file=$subject_dir/mri/aseg.mgz
    echo $aseg_file >> $post_recon_file
    t1_si=~/Desktop/T1_SI
    mkdir -p "$t1_si"
    mri_segstats --seg $aseg_file --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --nonempty --exclude 0 --sum $t1_si/${pid}_SI.txt --in $brain_file >> $post_recon_file
    cp $t1_si/${pid}_SI.txt $subject_dir
    echo "------------------- T1-intensity finished  -------------------" >> $post_recon_file

    # This is for geting region masks (adpated from Karen's One-Note)
    aparc_aseg_file=$subject_dir/mri/aparc+aseg.mgz
    echo "$aparc_aseg_file" >> $post_recon_file
    ribbon_file=$subject_dir/mri/ribbon.mgz
    echo "$ribbon_file" >> $post_recon_file
    wmparc_file=$subject_dir/mri/wmparc.mgz
    echo "$wmparc_file" >> $post_recon_file
    masks=~/Desktop/mask
    mkdir -p "$masks"

    # WH mask
    mri_binarize --i $aparc_aseg_file --wm --o $masks/${pid}_WM_mask.nii.gz --erode 1 >> $post_recon_file

    # Deep gray matter
    mri_binarize --i $aseg_file --match 10 --match 49 --match 11 --match 50 --match 12 --match 51 --match 13 --match 52 --o $masks/${pid}_deepgm_mask.nii.gz >> $post_recon_file

    # Cortex
    mri_binarize --i $aseg_file --match 3 --match 42 --o $masks/${pid}_cortex_mask.nii.gz >> $post_recon_file

    # Thalamus
    mri_binarize --i $aseg_file --match 10 --match 49 --o $masks/${pid}_thalamus_mask.nii.gz >> $post_recon_file

    # Frontal gray matter
    mri_binarize --i $aparc_aseg_file --match 1026 --match 2026 --o $masks/${pid}_fgm_mask.nii.gz >> $post_recon_file

    # Frontal white matter
    mri_binarize --i $wmparc_file --match 3003 --match 4003 --match 3012 --match 4012 --match 3014 --match 4014 --match 3018 --match 4018 --match 3019 --match 4019 --match 3020 --match 4020 --match 3027 --match 4027 --match 3028 --match 4028 --match 3032 --match 4032 --o $masks/${pid}_fwm_mask.nii.gz >> $post_recon_file

    # Posterior gray matter
    mri_binarize --i $aparc_aseg_file --match 1025 --match 2025 --match 1023 --match 2023 --match 1010 --match 2010 --o $masks/${pid}_pgm_mask.nii.gz >> $post_recon_file

    # Posterior white matter
    mri_binarize --i $wmparc_file --match 3025 --match 4025 --match 3029 --match 4029 --match 3008 --match 4008 --o $masks/${pid}_pwm_mask.nii.gz >> $post_recon_file

    # Basal ganglia
    mri_binarize --i $aseg_file --match 11 --match 50 --match 12 --match 51 --match 13 --match 52 --o $masks/${pid}_bg_mask.nii.gz >> $post_recon_file

    # All Ventricals w/ CSF
    mri_binarize --i $aparc_aseg_file --match 4 --match 5 --match 14 --match 15 --match 24 --match 31 --match 43 --match 44 --match 63 --o $masks/${pid}_all_vent_mask.nii.gz >> $post_recon_file

    # Lateral Ventricals
    mri_binarize --i $aparc_aseg_file --match 4 --match 5 --match 31 --match 43 --match 44 --match 63 --o $masks/${pid}_lat_vent_mask.nii.gz >> $post_recon_file

    # 3rd Ventrical
    mri_binarize --i $aparc_aseg_file --match 14 --o $masks/${pid}_3rd_vent_mask.nii.gz >> $post_recon_file

    # 4th Ventrical
    mri_binarize --i $aparc_aseg_file --match 15 --o $masks/${pid}_4th_vent_mask.nii.gz >> $post_recon_file

    # CSF
    mri_binarize --i $aparc_aseg_file --match 24 --o $masks/${pid}_csf_mask.nii.gz >> $post_recon_file

    subject_masks_dir=$subject_dir/masks
    mkdir -p $subject_masks_dir
    cp $masks/${pid}* $subject_masks_dir
    echo "------------------- masks finished  -------------------" >> $post_recon_file
}

work_dir="/home/ke/Desktop/FS3"

for f in $(find $work_dir -type f -iname "*.nii"); do

    # This is for recon-all (adpated from Ke's One-Note)
    echo $f
    name=$(basename $f)
    echo $name
    OIFS=$IFS
    IFS='_'
    read -r -a array <<< $name
    IFS=$OIFS
    f_name=${array[0]}_${array[-1]}
    f_name_final=${f_name::-10}
    echo ID: $f_name_final
    f_dir="$work_dir"/$f_name_final
    echo $f_dir
    recon-all -i $f -s $f_dir -openmp 10 -parallel -autorecon-all
    echo ------------------- recon-all finished  -------------------

    (post_recon_all $f_name_final) &

done
