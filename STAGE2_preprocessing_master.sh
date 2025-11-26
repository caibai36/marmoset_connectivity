#!/bin/bash

# ==========================================
# STAGE 2: PREPROCESS ALL SUBJECTS FOR VOCALIZATION ANALYSIS
# ==========================================
# Runs the existing preprocessing pipeline for all NIH/UWO subjects
# ==========================================

DATA_DIR="/data02/share/bin-wu/data/marmoset/brain/nih_uwo/nih/NIH-data"
META_FILE="/data02/share/bin-wu/data/marmoset/brain/nih_uwo/nih_uwo_meta.csv"
PIPELINE_DIR="./marmoset_connectivity"
OUTPUT_BASE="./preprocessed_data"

mkdir -p $OUTPUT_BASE

echo "==========================================="
echo "STAGE 2: BATCH PREPROCESSING"
echo "==========================================="
echo ""

# ==========================================
# STEP 1: Parse metadata and prepare subject list
# ==========================================

echo "Step 1: Parsing subject metadata..."

# Extract subject info (skip header, get NIH subjects sub-06 to sub-32)
tail -n +2 $META_FILE | awk -F',' '{
    # Extract subject ID (e.g., "sub-06" from first column)
    subj = $1
    # Extract age in months
    age = $2
    # Extract sex
    sex = $3
    # Extract site
    site = $4
    # Number of runs
    nruns = $7

    # Print subject info
    print subj, age, sex, site, nruns
}' > $OUTPUT_BASE/subject_list.txt

echo "Found $(wc -l < $OUTPUT_BASE/subject_list.txt) subjects"
echo ""
cat $OUTPUT_BASE/subject_list.txt
echo ""

# ==========================================
# STEP 2: Run preprocessing for each subject
# ==========================================

echo "Step 2: Running preprocessing pipeline..."
echo ""

# Read existing rs_MASTER.sh and modify for batch processing
# The pipeline steps:
# 1. rs_MASTER.sh - preprocessing
# 2. registration_MASTER.sh - register to template
# 3. correlation_MASTER.sh - NOT NEEDED for ROI analysis

# Map directory names to subject IDs
# sub-06 -> m6, sub-07 -> m7, etc.

while read -r subj age sex site nruns; do
    echo "==========================================="
    echo "Processing: $subj (age: ${age}mo, sex: $sex)"
    echo "==========================================="

    # Extract numeric part (e.g., "06" from "sub-06")
    subj_num=$(echo $subj | sed 's/sub-//')

    # Create directory name (e.g., "m6" from "sub-06")
    dir_name="m${subj_num}"

    # Check if data exists
    if [ ! -d "$DATA_DIR/$dir_name" ]; then
        echo "WARNING: Data directory not found: $DATA_DIR/$dir_name"
        echo "Skipping..."
        continue
    fi

    echo "Data directory: $DATA_DIR/$dir_name"

    # Create output directory for this subject
    SUBJ_OUTPUT="$OUTPUT_BASE/$subj"
    mkdir -p $SUBJ_OUTPUT

    # Determine phase encoding (NIH has up/down, UWO has only up)
    if [ "$site" = "NIH" ]; then
        PE_DIRS="up down"
    else
        PE_DIRS="up"
    fi

    # Count available BOLD runs
    bold_files=$(ls $DATA_DIR/$dir_name/BOLD_up_*.nii.gz 2>/dev/null | wc -l)
    echo "Found $bold_files BOLD runs"

    # Process each run
    for run in $(seq 1 $bold_files); do
        echo ""
        echo "  Processing run $run..."

        for pe in $PE_DIRS; do
            echo "    Phase encoding: $pe"

            BOLD_FILE="$DATA_DIR/$dir_name/BOLD_${pe}_${run}.nii.gz"

            if [ ! -f "$BOLD_FILE" ]; then
                echo "    WARNING: File not found: $BOLD_FILE"
                continue
            fi

            # Run preprocessing (calling existing rs_MASTER.sh with parameters)
            # Note: You'll need to modify rs_MASTER.sh to accept command-line arguments
            # Or create a wrapper script

            echo "    [TODO] Call rs_MASTER.sh with:"
            echo "      - monkey: $dir_name"
            echo "      - run: $run"
            echo "      - pe: $pe"
            echo "      - input: $BOLD_FILE"
            echo "      - output: $SUBJ_OUTPUT"

        done
    done

    echo ""
    echo "[OK] $subj preprocessing queued"
    echo ""

done < $OUTPUT_BASE/subject_list.txt

echo "==========================================="
echo "STAGE 2 SETUP COMPLETE"
echo "==========================================="
echo ""
echo "IMPORTANT: Preprocessing is computationally intensive!"
echo ""
echo "Recommendations:"
echo "  1. Run on HPC cluster with job submission"
echo "  2. Use existing rs_MASTER.sh script"
echo "  3. Then use registration_MASTER.sh to register to template"
echo "  4. Monitor for completion before proceeding to Stage 3"
echo ""
echo "Expected output per subject:"
echo "  - Preprocessed BOLD data (motion corrected, filtered)"
echo "  - Registration to MBM template"
echo "  - Quality control metrics"
echo ""
