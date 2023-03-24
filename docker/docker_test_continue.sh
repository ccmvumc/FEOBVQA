echo "Running docker"
docker run \
-it --rm \
-v $HOME/TEST-FEOBVQA_v2/INPUTS:/INPUTS \
-v $HOME/TEST-FEOBVQA_v2/OUTPUTS:/OUTPUTS \
bud42/feobvqa:v2
