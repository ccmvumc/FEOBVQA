#!/bin/bash

cd /OUTPUTS/DATA/mri

# Create motion-corrected averaged PET
echo 'mcflirt PET'
mcflirt -in PET.nii.gz -report -plots -stats -meanvol -mats -rmsrel -rmsabs

# Register PET to FreeSurfer
echo 'Register PET to FreeSurfer orig'
mri_coreg \
--ref orig.mgz \
--ref-mask aparc+aseg.mgz \
--mov PET_mcf_meanvol.nii.gz \
--reg pet2fs.lta

# Apply inverse tranform to T1
mri_convert -ait pet2fs.lta orig.mgz orig2pet.nii.gz

# Apply inverse tranform to SEG
mri_convert -ait pet2fs.lta -rt nearest aparc+aseg.mgz aparc+aseg2pet.nii.gz

# Apply inverse tranform to WMPARC
mri_convert -ait pet2fs.lta -rt nearest wmparc.mgz wmparc2pet.nii.gz

# Create the transform from subject space to MNI space
export FSLDIR=/opt/ext
export SUBJECTS_DIR=/OUTPUTS
mkdir -p /OUTPUTS/DATA/mri/transforms
mkdir -p /OUTPUTS/DATA/scripts
mni152reg --s DATA --1 --save-vol

# Combine transforms to get from MNI to PET
mri_concatenate_lta \
-invert2 \
transforms/reg.mni152.1mm.lta \
pet2fs.lta \
mni2pet.lta

# Apply the MNI to PET transform to the Brodmann atlas and reslice to match
# PET space using nearest neighbor interpolation to keep labels.
mri_vol2vol \
--targ PET_mcf_meanvol.nii.gz \
--mov /opt/ext/brodmann.nii.gz \
--lta mni2pet.lta \
--interp nearest \
--o brodmann2pet.nii.gz

# Create binary masks of each ROI
echo 'Creating masks...'

# caudate
# 11  Left-Caudate
# 50  Right-Caudate
mri_binarize --i aparc+aseg2pet.nii.gz --match 11 50 --o ROI_caudate.nii.gz

# putamen
# 12  Left-Putamen
# 51  Right-Putamen
mri_binarize --i aparc+aseg2pet.nii.gz --match 12 51 --o ROI_putamen.nii.gz

# hippocampus
# 17  Left-Hippocampus
# 53  Right-Hippocampus
mri_binarize --i aparc+aseg2pet.nii.gz --match 17 53 --o ROI_hippocampus.nii.gz

# amygdala
# 18  Left-Amygdala
# 54  Right-Amygdala
mri_binarize --i aparc+aseg2pet.nii.gz --match 18 54 --o ROI_amygdala.nii.gz

# accubmens
# 26  Left-Accumbens-area
# 58  Right-Accumbens-area
mri_binarize --i aparc+aseg2pet.nii.gz --match 26 58 --o ROI_accumbens.nii.gz

# ventral dc
# 28  Left-VentralDC
# 60  Right-VentralDC
mri_binarize --i aparc+aseg2pet.nii.gz --match 28 60 --o ROI_ventraldc.nii.gz

# thalamus
# 10  Left-Thalamus
# 48  Right-Thalamus
mri_binarize --i aparc+aseg2pet.nii.gz --match 10 49 --o ROI_thalamus.nii.gz

# Frontal
# 1003,2003 caudalmiddlefrontal
# 1012,2012 lateralorbitofrontal
# 1014,2014 medialorbitofrontal
# 1018,2018 parsopercularis
# 1019,2019 parsorbitalis
# 1020,2020 parstriangularis
# 1027,2027 rostralmiddlefrontal
# 1028,2028 superiorfrontal
# 1032,2032 frontalpole
# Excludes 1017,2017,1024,2024
mri_binarize --i aparc+aseg2pet.nii.gz --match \
1003 1012 1014 1018 1019 1020 1027 1028 1032 \
2003 2012 2014 2018 2019 2020 2027 2028 2032 \
--o ROI_antflobe.nii.gz

# Lateral Parietal
# 1008,2008 inferiorparietal
# 1022,2022 postcentral
# 1025.2025 precuneus
# 1031,2031 supramarginal
mri_binarize --i aparc+aseg2pet.nii.gz --match \
1008 1022 1025 1031 \
2008 2022 2025 2031 \
--o ROI_latplobe.nii.gz

# Lateral Temporal
# 1015,2015    middletemporal
# 1030,2030    superiortemporal
# Excludes 1001,2001,1009,2009,1033,2033
mri_binarize --i aparc+aseg2pet.nii.gz --match \
1015 1030 \
2015 2030 \
--o ROI_lattlobe.nii.gz

# Anterior Cingulate
# 1002 caudalanteriorcingulate
# 1026 rostralanteriorcingulate
mri_binarize --i aparc+aseg2pet.nii.gz --match \
1002 1026 \
2002 2026 \
--o ROI_antcing.nii.gz

# Posterior Cingulate
# 1010 isthmuscingulate
# 1023 posteriorcingulate
mri_binarize --i aparc+aseg2pet.nii.gz --match \
1010 1023 \
2010 2023 \
--o ROI_postcing.nii.gz

# Create binary mask of Composite GM ROIs
mri_binarize --i aparc+aseg2pet.nii.gz --match \
1003 1012 1014 1018 1019 1020 1027 1028 1032 \
2003 2012 2014 2018 2019 2020 2027 2028 2032 \
1008 1022 1025 1031 \
2008 2022 2025 2031 \
1015 1030 \
2015 2030 \
1002 1010 1023 1026 \
2002 2010 2023 2026 \
--o ROI_compositegm.nii.gz

# Create binary mask of Cortical GM
mri_binarize --i aparc+aseg2pet.nii.gz --match \
1003 1012 1014 1017 1018 1019 1020 1024 1027 1028 1032 \
2003 2012 2014 2017 2018 2019 2020 2024 2027 2028 2032 \
1008 1022 1025 1029 1031 \
2008 2022 2025 2029 2031 \
1001 1006 1007 1009 1015 1016 1030 1033 1034 \
2001 2006 2007 2009 2015 2016 2030 2033 2034 \
1005 1011 1013 1021 \
2005 2011 2013 2021 \
1002 1010 1023 1026 \
2002 2010 2023 2026 \
1035 2035 \
1002 1010 1023 1026 \
2002 2010 2023 2026 \
--o ROI_cortgm.nii.gz

# Create binary mask of cortical white matter
mri_binarize --i aparc+aseg2pet.nii.gz --match \
2 41 77 251 252 253 254 255 \
--o ROI_cortwm.nii.gz

# Create binary mask of cerebellar GM
# 8,47  Cerebellum-Cortex
mri_binarize --i aparc+aseg2pet.nii.gz --match \
8 47 \
--o ROI_cblmgm.nii.gz

# Create binary mask of cerebellar WM
# 7,46   Cerebellum-White-Matter
mri_binarize --i aparc+aseg2pet.nii.gz --match \
7 46 \
--o ROI_cblmwm.nii.gz

# Create binary mask of cerebellum
# 7,46   Cerebellum-White-Matter
# 8,47  Cerebellum-Cortex
mri_binarize --i aparc+aseg2pet.nii.gz --match \
7 8 46 47 \
--o ROI_cblmtot.nii.gz

# Create combined ROI image for display purposes
fslmaths.fsl ROI_antflobe -mul 1 temp
fslmaths.fsl ROI_latplobe -mul 2 -add temp temp
fslmaths.fsl ROI_lattlobe -mul 3 -add temp temp
fslmaths.fsl ROI_antcing  -mul 4 -add temp temp
fslmaths.fsl ROI_postcing -mul 5 -add temp temp
fslmaths.fsl ROI_cblmgm   -mul 6 -add temp temp
fslmaths.fsl ROI_cblmwm   -mul 7 -add temp temp
mv temp.nii.gz ROI_SEG.nii.gz

# WMPARC supra-ventricular white matter
#3003,4003  wm-xh-caudalmiddlefrontal
#3017,4017  wm-xh-paracentral
#3022,4022  wm-xh-postcentral
#3024,4024  wm-xh-precentral
#3027,4027  wm-xh-rostralmiddlefrontal
#3028,4028  wm-xh-superiorfrontal
#3029,4029  wm-xh-superiorparietal
#3031,4031  wm-xh-supramarginal
mri_binarize --i wmparc2pet.nii.gz --match \
3003 3017 3022 3024 3027 3028 3029 3031 \
4003 4017 4022 4024 4027 4028 4029 4031 \
--o ROI_supravwm.nii.gz

# Erode the mask
mri_binarize --i ROI_supravwm.nii.gz --min 1 --erode 1 --o ROI_supravwm_eroded.nii.gz

# Make eroded cerebral wm mask
mri_binarize --i ROI_cortwm.nii.gz --min 1 --erode 1 --o ROI_cortwm_eroded.nii.gz

# Make Brodmann ROIs masked by cortical gray
for i in {1..47}
do
    mri_binarize --i brodmann2pet.nii.gz --match $i --mask ROI_cortgm.nii.gz --o ROI_BA${i}.nii.gz
done

# Output stats
TXT=PETbyROI.csv

echo 'Calculating stats...'

# Write header line
echo "ROI,MIN,MAX,MEAN,STD,VOL" > $TXT

# Write ROI rows
ROI=(supravwm supravwm_eroded cortwm_eroded antflobe latplobe lattlobe antcing postcing compositegm cortwm cblmgm cblmwm)
for r in "${ROI[@]}"
do
    echo -n $r >> $TXT
    mri_segstats --seg ROI_${r}.nii.gz --i PET_mcf_meanvol.nii.gz --id 1 --sum ${r}_stats.txt
    grep Seg0001 ${r}_stats.txt | awk '{print ","$8","$9","$6","$7","$4}' >> $TXT
done

# Subcortical ROIs
ROI=(caudate amygdala hippocampus accumbens thalamus putamen ventraldc)
for r in "${ROI[@]}"
do
    echo -n $r >> $TXT
    mri_segstats --seg ROI_${r}.nii.gz --i PET_mcf_meanvol.nii.gz --id 1 --sum ${r}_stats.txt
    grep Seg0001 ${r}_stats.txt | awk '{print ","$8","$9","$6","$7","$4}' >> $TXT
done

# Brodmann Areas
for i in {1..11} {17..30} {32..32} {34..47}
do
    echo -n "ROI_BA${i}" >> $TXT
    mri_segstats --seg ROI_BA${i}.nii.gz --i PET_mcf_meanvol.nii.gz --id 1 --sum BA${i}_stats.txt
    grep Seg0001 BA${i}_stats.txt | awk '{print ","$8","$9","$6","$7","$4}' >> $TXT
done


echo 'DONE!'
