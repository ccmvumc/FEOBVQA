# /INPUTS/

if [ -d "$HOME/TEST-FEOBVQA_v2/OUTPUTS" ]; then
    echo "Already exists, delete first"
    exit 1;
fi

echo "Prepping dirs"
mkdir -p $HOME/TEST-FEOBVQA_v2/INPUTS
mkdir -p $HOME/TEST-FEOBVQA_v2/OUTPUTS

echo "Downloading inputs"

curl -s -k -n \
"https://xnat.vanderbilt.edu/xnat/data/projects/DSCHOL/subjects/DST3050001/experiments/DST3050001_MR1/assessors/DSCHOL-x-DST3050001-x-DST3050001_MR1-x-FS7_v1-x-00d5341d/out/resources/SUBJ/files/mri/orig.mgz" \
-o "$HOME/TEST-FEOBVQA_v2/INPUTS/orig.mgz"

curl -s -k -n  \
"https://xnat.vanderbilt.edu/xnat/data/projects/DSCHOL/subjects/DST3050001/experiments/DST3050001_MR1/assessors/DSCHOL-x-DST3050001-x-DST3050001_MR1-x-FS7_v1-x-00d5341d/out/resources/SUBJ/files/mri/aparc%2Baseg.mgz" \
-o "$HOME/TEST-FEOBVQA_v2/INPUTS/aparc+aseg.mgz"

curl -s -k -n  \
"https://xnat.vanderbilt.edu/xnat/data/projects/DSCHOL/subjects/DST3050001/experiments/DST3050001_MR1/assessors/DSCHOL-x-DST3050001-x-DST3050001_MR1-x-FS7_v1-x-00d5341d/out/resources/SUBJ/files/mri/wmparc.mgz" \
-o "$HOME/TEST-FEOBVQA_v2/INPUTS/wmparc.mgz"

curl -s -k -n  \
"https://xnat.vanderbilt.edu/xnat/data/projects/DSCHOL/subjects/DST3050001/experiments/DST3050001_MR1/assessors/DSCHOL-x-DST3050001-x-DST3050001_MR1-x-FS7_v1-x-00d5341d/out/resources/SUBJ/files/mri/brainmask.mgz" \
-o "$HOME/TEST-FEOBVQA_v2/INPUTS/brainmask.mgz"

curl -s -k -n  \
"https://xnat.vanderbilt.edu/xnat/data/projects/DSCHOL/subjects/DST3050001/experiments/DST3050001_PET2/scans/7305/resources/NIFTI/files/7305__research_only_BR_DY1mm_CTAC_1mm__Brain_Dynamic.nii.gz" \
-o "$HOME/TEST-FEOBVQA_v2/INPUTS/PET.nii.gz"

echo "Running docker"
docker run \
-it --rm \
-v $HOME/TEST-FEOBVQA_v2/INPUTS:/INPUTS \
-v $HOME/TEST-FEOBVQA_v2/OUTPUTS:/OUTPUTS \
bud42/feobvqa:v2
