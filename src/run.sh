echo "Run FEOBVQA"

mkdir -p /OUTPUTS/DATA

/opt/src/prep_inputs.sh

/opt/src/proc.sh

# Create QA PDF
echo "Make PDF"
cd /OUTPUTS/DATA
xvfb-run -a --server-args "-screen 0 1920x1080x24" \
python /opt/src/make_pdf.py

echo "run DONE!"
