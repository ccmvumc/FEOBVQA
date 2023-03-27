FROM python:3.8-slim-buster

RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
    bc libglu1 libgomp1 libxmu6 libxt6 tar curl tcsh \
    xvfb xauth ghostscript libgs-dev unzip xorg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && chmod 777 /opt && chmod a+s /opt

# Install sclimbic
RUN curl -sSL --retry 5 \
    https://surfer.nmr.mgh.harvard.edu/pub/dist/sclimbic/sclimbic-linux-20210725.tar.gz \
    | tar xz -C /opt

# Set up environment
ENV FREESURFER_HOME /opt/sclimbic
ENV PATH=$PATH:/opt/sclimbic/bin:/usr/local/bin:/usr/bin:/bin
ENV SURFER_SIDEDOOR 1
ENV FSLOUTPUTTYPE=NIFTI_GZ

# Install python packages for making pdf
RUN pip install pandas nibabel matplotlib

# Make directories for IO to bind
RUN mkdir /INPUTS /OUTPUTS

# Copy in our scripts
COPY src /opt/src/
COPY ext /opt/ext/

# Copy in additional files needed to run mni152reg
COPY MNI152_T1_1mm_brain.nii.gz /opt/ext/data/standard/MNI152_T1_1mm_brain.nii.gz
COPY ext/fsl.5.0.2.xyztrans.sch /opt/sclimbic/bin/fsl.5.0.2.xyztrans.sch
COPY ext/flirt.newdefault.20080811.sch /opt/sclimbic/bin/flirt.newdefault.20080811.sch

RUN chmod +x /opt/src/*.sh
RUN chmod +x /opt/ext/*
ENV PATH=/opt/ext:/opt/src:$PATH
RUN chmod g+r /opt/ext/*

# Configure default script to run
ENTRYPOINT ["/bin/bash", "/opt/src/run.sh"]
