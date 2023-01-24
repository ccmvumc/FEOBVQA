echo "Running docker"
docker run \
-it --rm \
-v $HOME/TEST-FEOBVQA/INPUTS:/INPUTS \
-v $HOME/TEST-FEOBVQA/OUTPUTS:/OUTPUTS \
bud42/feobvqa:v1
