echo "Run FEOBVQA"

mkdir -p /OUTPUTS/DATA/mri

# Copy inputs to outputs
echo 'prep'
/opt/src/prep.sh

# Run the main processing steps
echo 'proc'
/opt/src/proc.sh

# Create stats
echo "Make stats"
cd /OUTPUTS/DATA
python /opt/src/make_stats.py

# Create QA PDF
echo "Make PDF"
cd /OUTPUTS/DATA
xvfb-run -a --server-args "-screen 0 1920x1080x24" \
python /opt/src/make_pdf.py

echo "run DONE!"
