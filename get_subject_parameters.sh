#!/bin/bash

# ==========================================
# GET PREPROCESSING PARAMETERS FOR A SUBJECT
# ==========================================
# Usage: bash get_subject_parameters.sh m6
# Outputs the parameters needed for rs_MASTER.sh
# ==========================================

if [ $# -eq 0 ]; then
    echo "Usage: $0 <subject>"
    echo "Example: $0 m6"
    exit 1
fi

SUBJECT=$1
BASE_DIR="/work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration"
RAW_DIR="${BASE_DIR}/raw_bold/${SUBJECT}"

if [ ! -d "$RAW_DIR" ]; then
    echo "ERROR: Subject directory not found: $RAW_DIR"
    exit 1
fi

echo "=========================================="
echo "PREPROCESSING PARAMETERS FOR: $SUBJECT"
echo "=========================================="
echo ""

# Count runs
N_RUNS=$(ls $RAW_DIR/BOLD_up_*.nii.gz 2>/dev/null | wc -l)
if [ $N_RUNS -eq 0 ]; then
    echo "ERROR: No BOLD files found for $SUBJECT"
    exit 1
fi

echo "Number of runs: $N_RUNS"
echo ""

# Get dimensions from first run
BOLD_FILE="$RAW_DIR/BOLD_up_1.nii.gz"

if [ ! -f "$BOLD_FILE" ]; then
    echo "ERROR: File not found: $BOLD_FILE"
    exit 1
fi

echo "Analyzing: $(basename $BOLD_FILE)"
echo ""

# Extract parameters
TR_COUNTS=$(fslinfo $BOLD_FILE | grep "^dim4" | awk '{print $2}')
TR=$(fslinfo $BOLD_FILE | grep "^pixdim4" | awk '{print $2}')
REG_VOL=$((TR_COUNTS / 2))

# Check for phase encodings
HAS_UP=$(ls $RAW_DIR/BOLD_up_*.nii.gz 2>/dev/null | wc -l)
HAS_DOWN=$(ls $RAW_DIR/BOLD_down_*.nii.gz 2>/dev/null | wc -l)

# Display parameters
echo "=========================================="
echo "COPY THESE LINES TO rs_MASTER_${SUBJECT}.sh:"
echo "=========================================="
echo ""
echo "######Update#######"
echo "set monkey = ($SUBJECT)"
echo "set run = ($(seq -s ' ' 1 $N_RUNS))"

if [ $HAS_UP -gt 0 ] && [ $HAS_DOWN -gt 0 ]; then
    echo "set pe = (up down)"
elif [ $HAS_UP -gt 0 ]; then
    echo "set pe = (up)"
fi

echo "set tr_counts = ($TR_COUNTS)"
echo "set reg_vol = ($REG_VOL)"
echo "set tr = ($TR)"
echo "set bp_l = (0.1)"
echo "set bp_h = (0.01)"
echo "set pe_correct = (no)"
echo "set acpr = (dummy)"
echo "set blur = (1.5)"
echo "set n_cpu = (8)"
echo ""
echo "set apth = ${BASE_DIR}/raw_bold/\${m}"
echo "set anat_pth = ${BASE_DIR}/anatomical/\${m}"
echo "set output_dir = ${BASE_DIR}/preprocessed/\${m}"
echo "###################"
echo ""

# Summary table
echo "=========================================="
echo "SUMMARY:"
echo "=========================================="
echo "Subject:          $SUBJECT"
echo "Runs:             $N_RUNS"
echo "Volumes/run:      $TR_COUNTS"
echo "Middle volume:    $REG_VOL"
echo "TR (seconds):     $TR"
echo "Phase encodings:  up$([ $HAS_DOWN -gt 0 ] && echo ", down" || echo " only")"
echo "Files verified:   ✓"
echo ""

# Check if symlinks exist
echo "Checking symlinks..."
if [ -f "$RAW_DIR/${SUBJECT}_rest-up_bold_1.nii.gz" ]; then
    echo "  ✓ Preprocessing symlinks exist"
else
    echo "  ⚠ Preprocessing symlinks NOT found"
    echo "    Run setup script again or create manually"
fi

echo ""
echo "=========================================="
echo "NEXT STEPS:"
echo "=========================================="
echo "1. Copy rs_MASTER.sh:"
echo "   cp /work02/.../marmoset_connectivity/rs_MASTER.sh ./rs_MASTER_${SUBJECT}.sh"
echo ""
echo "2. Edit rs_MASTER_${SUBJECT}.sh and paste the parameters above"
echo ""
echo "3. Run preprocessing:"
echo "   tcsh -xef rs_MASTER_${SUBJECT}.sh 2>&1 | tee ${BASE_DIR}/logs/preprocessing_${SUBJECT}.log"
echo ""
