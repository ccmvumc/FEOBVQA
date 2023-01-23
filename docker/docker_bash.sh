docker run \
-it --rm \
--entrypoint /bin/bash \
-v $HOME/TEST-FEOBVQA/INPUTS:/INPUTS \
-v $HOME/TEST-FEOBVQA/OUTPUTS:/OUTPUTS \
bud42/feobvqa:v1
