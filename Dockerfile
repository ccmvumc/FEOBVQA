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

# Make directories for IO to bind
RUN mkdir /INPUTS /OUTPUTS

# Copy in our scripts
COPY src /opt/src/
COPY ext /opt/ext/
RUN chmod +x /opt/src/*.sh
RUN chmod +x /opt/ext/*
ENV PATH=/opt/ext:/opt/src:$PATH

# Configure default script to run
ENTRYPOINT ["/bin/bash", "/opt/src/run.sh"]

# Configure environment
ENV FSLOUTPUTTYPE=NIFTI_GZ
#ENV FSLMULTIFILEQUIT=TRUE
#ENV OS Linux
#ENV FS_OVERRIDE 0
#ENV SUBJECTS_DIR /opt/freesurfer/subjects
#ENV FSF_OUTPUT_FORMAT nii.gz
#ENV FREESURFER_HOME /opt/freesurfer
#ENV PATH=$PATH:/opt/freesurfer/bin:/usr/local/bin:/usr/bin:/bin
#ENV PYTHONPATH=""
#ENV FS_LICENSE=/opt/license.txt
#RUN touch /opt/license.txt

# Install packages
#RUN apt-get update && apt-get install -yq \
#    python-pip libfreetype6-dev pkg-config libxml2-dev libxslt1-dev \
#    python-dev zlib1g-dev python-numpy python-scipy python-requests \
#    python-urllib3 python-pandas libfreetype6-dev pkg-config libxml2-dev libxslt1-dev \
#    python-dev zlib1g-dev python-numpy python-scipy python-requests \
#    python-urllib3 python-pandas
