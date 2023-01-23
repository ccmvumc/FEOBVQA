FROM freesurfer/freesurfer:7.2.0

#RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
#    apt-utils ca-certificates unzip xorg wget xvfb \
#    bc libgomp1 libxmu6 libxt6 tcsh tar \
#    ghostscript libgs-dev \
#    libglu1 curl \
#    && apt-get clean \
#    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
#    && chmod 777 /opt && chmod a+s /opt

# Configure environment
#ENV FSLOUTPUTTYPE=NIFTI_GZ
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
#    python-urllib3 python-pandas
RUN yum install -y epel-release && yum clean all
RUN yum install -y python-pip && yum clean all
#libfreetype6-dev pkg-config libxml2-dev libxslt1-dev \
#    python-dev zlib1g-dev python-numpy python-scipy python-requests \
#    python-urllib3 python-pandas
RUN pip install pandas matplotlib seaborn --upgrade

# Copy in our scripts
COPY src /opt/src/
RUN chmod +x /opt/src/*.sh
RUN chmod +x /opt/src/mcflirt
ENV PATH=/opt/src:$PATH

# Make directories for I/O to bind
RUN mkdir /INPUTS /OUTPUTS

# Configure default script to run
ENTRYPOINT ["/bin/bash", "/opt/src/run.sh"]
