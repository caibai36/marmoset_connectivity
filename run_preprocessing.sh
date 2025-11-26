#!/bin/bash

# ==========================================
# MARMOSET BOLD PREPROCESSING WRAPPER
# ==========================================
# Wrapper for rs_MASTER.sh to preprocess BOLD data
# Location: /work01/.../riken_mri_s0/local/fmri/local/
# ==========================================

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
WORK_BASE="/work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration"

if [ -f "$WORK_BASE/config_paths.sh" ]; then
    source "$WORK_BASE/config_paths.sh"
else
    echo "ERROR: Configuration file not found: $WORK_BASE/config_paths.sh"
    echo "Please run setup_directories_and_data.sh first"
    exit 1
fi

# Original scripts location
ORIGINAL_SCRIPTS="$ORIGINAL_SCRIPTS_DIR"
RS_MASTER="$ORIGINAL_SCRIPTS/rs_MASTER.sh"

# Check if rs_MASTER.sh exists
if [ ! -f "$RS_MASTER" ]; then
    echo "ERROR: rs_MASTER.sh not found at: $RS_MASTER"
    echo "Please check ORIGINAL_SCRIPTS_DIR in config_paths.sh"
    exit 1
fi

# ==========================================
# Usage
# ==========================================

usage() {
    cat << EOF
Usage: $0 <subject> [subject2] [subject3] ... | all

Preprocess BOLD fMRI data using rs_MASTER.sh

Arguments:
    subject     Subject ID (e.g., m6, m7, ...)
    all         Process all NIH subjects

Examples:
    $0 m6                  # Process subject m6
    $0 m6 m7 m8            # Process multiple subjects
    $0 all                 # Process all 27 NIH subjects

Output:
    preprocessed/<subject>/errts.<subject>_<pe>_bold_<run>.tproject.nii.gz
    preprocessed/<subject>/<subject>_<pe>_bold_<run>.mean.nii.gz

Logs:
    logs/preprocessing_<subject>.log

EOF
    exit 1
}

# Check arguments
if [ $# -eq 0 ]; then
    usage
fi

# ==========================================
# Process one subject
# ==========================================

process_subject() {
    local SUBJECT=$1

    echo "=========================================="
    echo "PREPROCESSING: $SUBJECT"
    echo "=========================================="
    echo ""

    # Check if subject exists
    if [ ! -d "$RAW_BOLD_DIR/$SUBJECT" ]; then
        echo "ERROR: Subject directory not found: $RAW_BOLD_DIR/$SUBJECT"
        return 1
    fi

    # Create output directory
    mkdir -p "$PREPROCESSED_DIR/$SUBJECT"
    mkdir -p "$LOGS_DIR"

    # Log file
    LOGFILE="$LOGS_DIR/preprocessing_${SUBJECT}.log"

    echo "Subject: $SUBJECT"
    echo "Raw data: $RAW_BOLD_DIR/$SUBJECT"
    echo "Output: $PREPROCESSED_DIR/$SUBJECT"
    echo "Log: $LOGFILE"
    echo ""

    # Count BOLD files
    N_UP=$(ls $RAW_BOLD_DIR/$SUBJECT/BOLD_up_*.nii.gz 2>/dev/null | wc -l)
    N_DOWN=$(ls $RAW_BOLD_DIR/$SUBJECT/BOLD_down_*.nii.gz 2>/dev/null | wc -l)

    echo "Found: $N_UP BOLD_up files, $N_DOWN BOLD_down files"
    echo ""

    # Process each run
    echo "Processing runs..."
    echo ""

    # Phase encodings
    for PE in up down; do
        # Get run count
        N_RUNS=$(ls $RAW_BOLD_DIR/$SUBJECT/BOLD_${PE}_*.nii.gz 2>/dev/null | wc -l)

        if [ $N_RUNS -eq 0 ]; then
            echo "  No BOLD_${PE} files found, skipping..."
            continue
        fi

        # Convert PE naming: up->u, down->d
        if [ "$PE" = "up" ]; then
            PE_SHORT="u"
        else
            PE_SHORT="d"
        fi

        # Process each run
        for RUN in $(seq 1 $N_RUNS); do
            echo "  Processing: ${SUBJECT}, phase encoding ${PE}, run ${RUN}"

            # Check if output already exists
            OUTPUT_FILE="$PREPROCESSED_DIR/$SUBJECT/errts.${SUBJECT}_${PE_SHORT}_bold_${RUN}.tproject.nii.gz"

            if [ -f "$OUTPUT_FILE" ]; then
                echo "    Output exists, skipping..."
                continue
            fi

            # Input files
            INPUT_BOLD="$RAW_BOLD_DIR/$SUBJECT/BOLD_${PE}_${RUN}.nii.gz"
            SEEPI_UP="$RAW_BOLD_DIR/$SUBJECT/SEEPI_up.nii.gz"
            SEEPI_DOWN="$RAW_BOLD_DIR/$SUBJECT/SEEPI_down.nii.gz"
            ANAT_T2="$ANATOMICAL_DIR/$SUBJECT/InplaneT2.nii.gz"
            MASK="$ANATOMICAL_DIR/$SUBJECT/mask.nii.gz"

            # Check inputs exist
            if [ ! -f "$INPUT_BOLD" ]; then
                echo "    ERROR: Input not found: $INPUT_BOLD"
                continue
            fi

            # Call preprocessing function
            # NOTE: You need to adapt rs_MASTER.sh to accept these parameters
            # Or create a simplified preprocessing script

            echo "    Running rs_MASTER.sh..."
            echo "    (See log: $LOGFILE)"

            # Example call (you'll need to adapt based on rs_MASTER.sh structure):
            # bash $RS_MASTER \
            #      --subject $SUBJECT \
            #      --run $RUN \
            #      --pe $PE_SHORT \
            #      --input $INPUT_BOLD \
            #      --output $PREPROCESSED_DIR/$SUBJECT \
            #      >> $LOGFILE 2>&1

            # For now, print what would be run
            echo "    TODO: Adapt rs_MASTER.sh or create simplified preprocessing"
            echo "    Input: $INPUT_BOLD"
            echo "    Output: $OUTPUT_FILE"
            echo ""

        done
    done

    echo "[COMPLETE] $SUBJECT"
    echo ""

    return 0
}

# ==========================================
# Main processing loop
# ==========================================

# Get subject list
if [ "$1" = "all" ]; then
    SUBJECTS=(${NIH_SUBJECTS[@]})
else
    SUBJECTS=("$@")
fi

echo "=========================================="
echo "MARMOSET BOLD PREPROCESSING"
echo "=========================================="
echo ""
echo "Subjects to process: ${SUBJECTS[@]}"
echo "Total: ${#SUBJECTS[@]} subjects"
echo ""

# Confirm
read -p "Continue? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted"
    exit 0
fi

# Process each subject
SUCCESS=0
FAILED=0

for SUBJ in "${SUBJECTS[@]}"; do
    if process_subject $SUBJ; then
        SUCCESS=$((SUCCESS + 1))
    else
        FAILED=$((FAILED + 1))
    fi
done

# Summary
echo "=========================================="
echo "PREPROCESSING COMPLETE"
echo "=========================================="
echo ""
echo "Successful: $SUCCESS"
echo "Failed: $FAILED"
echo ""
echo "Check status: bash $WORK_BASE/check_status.sh"
echo ""

# ==========================================
# IMPORTANT NOTE
# ==========================================

cat << 'EOFNOTE'

NOTE: This is a WRAPPER script.

You need to either:

1. OPTION A: Adapt rs_MASTER.sh to accept command-line arguments
   Edit rs_MASTER.sh to accept: --subject, --run, --pe, --input, --output

2. OPTION B: Create a simplified preprocessing script
   See PREPROCESSING_GUIDE.md for step-by-step commands

3. OPTION C: Manually run rs_MASTER.sh for each subject
   Edit rs_MASTER.sh variables and run:
   cd /work02/.../marmoset_connectivity
   tcsh -xef rs_MASTER.sh

Current status: This script creates the directory structure and
identifies files to process, but does NOT yet call the actual
preprocessing pipeline.

For detailed manual preprocessing, see:
    PREPROCESSING_GUIDE.md

EOFNOTE
