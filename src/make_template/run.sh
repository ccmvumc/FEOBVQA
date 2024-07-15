# get the norm factor
#NORMFACTOR=`grep supravwm_eroded PETbyROI.csv | awk -F',' '{print $4}'`
#echo $NORMFACTOR
#
# apply factor to get suvr
#fslmaths PET_mcf_meanvol.nii.gz -div $NORMFACTOR SUVR.nii.gz
#
# get suvr in mni
#export FREESURFER_HOME=/Applications/freesurfer/7.4.0
#source $FREESURFER_HOME/SetUpFreeSurfer.sh
#mri_convert -ait mni2pet.lta SUVR.nii.gz SUVR2mni.nii.gz

# Make template from T1s, save transforms
mri_robust_template \
--mov D*/mni152.orig.mgz \
--template DSCHOL15-mni152.orig.mgz \
--satit \
--lta \
DSCHOL202/to_template.lta \
DST3050001/to_template.lta \
DST3050002/to_template.lta \
DST3050003/to_template.lta \
DST3050012/to_template.lta \
DST3050033/to_template.lta \
DST3050041/to_template.lta \
DST3050042/to_template.lta \
DST3050045/to_template.lta \
DST3050052/to_template.lta \
DST3050059/to_template.lta \
DST3050060/to_template.lta \
DST3050061/to_template.lta \
DST3050062/to_template.lta \
DST3050071/to_template.lta


# Apply transforms to SUVR
for i in D*;do mri_convert -at $i/to_template.lta $i/SUVR2mni.nii.gz $i/tSUVR2mni.nii.gz;done

# Average the SUVR2mni
mri_average -noconform */SUVR2mni.nii.gz  DSCHOL15-mri_average-SUVR2mni.nii.gz 

# T1
for i in D*;do mri_convert -at $i/to_template.lta $i/mni152.orig.mgz $i/tmni152.orig.nii.gz;done
mri_average -noconform */tmni152.orig.nii.gz  DSCHOL15-mri_average-tmni152.orig.nii.gz 
