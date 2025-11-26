#!/bin/bash

# ==========================================
# SETUP SCRIPT: Marmoset Vocalization Analysis
# ==========================================
# Creates directory structure and organizes data
# Run this BEFORE running registration_MASTER_UPDATED.sh
# ==========================================

# ==========================================
# CONFIGURATION - Your actual paths
# ==========================================

RAW_DATA_DIR="/data02/share/bin-wu/data/marmoset/brain/nih_uwo/nih/NIH-data"
WORK_BASE="/work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration"
MBM_TEMPLATE_DIR="/data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1_0.5mm"

echo "=========================================="
echo "MARMOSET REGISTRATION SETUP"
echo "=========================================="
echo ""

# ==========================================
# STEP 1: Create directory structure
# ==========================================

echo "Step 1: Creating directory structure..."
echo ""

mkdir -p $WORK_BASE/{preprocessed,anatomical,template_space,correlation,temp,roi_masks,logs}

echo "  Created directories in: $WORK_BASE"
echo "    - preprocessed/     : Preprocessed BOLD input (from rs_MASTER.sh)"
echo "    - anatomical/       : T2 and mask files per subject"
echo "    - template_space/   : Intermediate registration outputs"
echo "    - correlation/      : Final connectivity-ready files"
echo "    - temp/             : Temporary files (will be cleaned)"
echo "    - roi_masks/        : Vocalization network ROI masks"
echo "    - logs/             : Processing logs"
echo ""

# ==========================================
# STEP 2: Link/copy anatomical data
# ==========================================

echo "Step 2: Organizing anatomical data..."
echo ""

# NIH subjects (m6-m32, excluding m13)
SUBJECTS=(m6 m7 m8 m9 m10 m11 m12 m14 m15 m16 m17 m18 m19 m20 m21 m22 m23 m24 m25 m26 m27 m28 m29 m30 m31 m32)

for subj in "${SUBJECTS[@]}"; do
    if [ -d "$RAW_DATA_DIR/$subj" ]; then
        echo "  Processing $subj..."

        # Create subject anatomical directory
        mkdir -p $WORK_BASE/anatomical/$subj

        # Copy anatomical files
        if [ -f "$RAW_DATA_DIR/$subj/InplaneT2.nii.gz" ]; then
            cp "$RAW_DATA_DIR/$subj/InplaneT2.nii.gz" \
               "$WORK_BASE/anatomical/$subj/"
            echo "    ✓ Copied InplaneT2.nii.gz"
        else
            echo "    ✗ InplaneT2.nii.gz not found"
        fi

        if [ -f "$RAW_DATA_DIR/$subj/mask.nii.gz" ]; then
            cp "$RAW_DATA_DIR/$subj/mask.nii.gz" \
               "$WORK_BASE/anatomical/$subj/"
            echo "    ✓ Copied mask.nii.gz"
        else
            echo "    ✗ mask.nii.gz not found"
        fi
    else
        echo "  ⚠ Subject directory not found: $RAW_DATA_DIR/$subj"
    fi
done

echo ""

# ==========================================
# STEP 3: Verify template files
# ==========================================

echo "Step 3: Verifying MBM template files..."
echo ""

# Check required template files
REQUIRED_FILES=(
    "template_T2w_brain_0.5mm.nii.gz"
    "segmentation_three_types_prob_1_gray_0.5mm.nii.gz"
    "segmentation_three_types_prob_2_white_0.5mm.nii.gz"
    "segmentation_three_types_prob_3_csf_0.5mm.nii.gz"
    "atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz"
    "atlas_MBM_subcortical_beta_0.5mm.nii.gz"
)

MISSING=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$MBM_TEMPLATE_DIR/$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ MISSING: $file"
        MISSING=$((MISSING + 1))
    fi
done

if [ $MISSING -gt 0 ]; then
    echo ""
    echo "  ERROR: $MISSING template files missing!"
    echo "  Please verify template directory: $MBM_TEMPLATE_DIR"
else
    echo ""
    echo "  ✓ All template files found!"
fi

echo ""

# ==========================================
# STEP 4: Create subject metadata file
# ==========================================

echo "Step 4: Creating subject metadata file..."
echo ""

# Copy metadata from original location
METADATA_SRC="/data02/share/bin-wu/data/marmoset/brain/nih_uwo/nih_uwo_meta.csv"

if [ -f "$METADATA_SRC" ]; then
    cp "$METADATA_SRC" "$WORK_BASE/subject_metadata.csv"
    echo "  ✓ Metadata copied to: $WORK_BASE/subject_metadata.csv"
    echo ""
    echo "  Subject summary:"
    tail -n +2 "$WORK_BASE/subject_metadata.csv" | \
        awk -F',' '{print "    " $1 " - Age: " $2 "mo, Sex: " $3 ", Site: " $4}' | head -10
    echo "    ..."
else
    echo "  ⚠ Metadata file not found: $METADATA_SRC"
fi

echo ""

# ==========================================
# STEP 5: Create README with instructions
# ==========================================

cat > $WORK_BASE/README.txt << 'EOFREADME'
MARMOSET VOCALIZATION DEVELOPMENT ANALYSIS
==========================================

Directory Structure:
--------------------
preprocessed/     - Preprocessed BOLD from rs_MASTER.sh (INPUT - you need to populate this)
anatomical/       - T2 and mask files per subject (READY)
template_space/   - Intermediate registration files (OUTPUT)
correlation/      - Final connectivity-ready files (OUTPUT)
temp/            - Temporary processing files (OUTPUT)
roi_masks/       - Vocalization network ROI masks (created by STAGE1)
logs/            - Processing logs

Quick Start:
------------
1. Run preprocessing first (rs_MASTER.sh) to generate:
   - errts.{subject}_{pe}_bold_{run}.tproject.nii.gz
   - {subject}_{pe}_bold_{run}.mean.nii.gz
   Place these in: preprocessed/

2. Run registration:
   tcsh -xef registration_MASTER_UPDATED.sh 2>&1 | tee logs/registration.log

3. Run vocalization analysis pipeline:
   bash STAGE1_create_marmoset_vocalization_ROIs.sh
   bash STAGE3_register_and_prepare_ROI_data.sh
   python STAGE4_extract_ROI_timeseries.py
   python STAGE5_compute_connectivity.py
   python STAGE6_developmental_analysis.py
   python STAGE7_cross_species_comparison.py

Files Required in preprocessed/:
---------------------------------
For each subject (e.g., m6), run (e.g., 1), and phase encoding (e.g., u):
- errts.m6_u_bold_1.tproject.nii.gz  (preprocessed 4D BOLD)
- m6_u_bold_1.mean.nii.gz            (mean functional image)

Expected Outputs in correlation/:
----------------------------------
- {subject}_{pe}_bold_{run}_to_template_0.5mm_masked_gm.nii.gz
- {subject}_{pe}_bold_{run}_nui_regressors.1D

These files are ready for ROI-based connectivity analysis!
EOFREADME

echo "  ✓ README created: $WORK_BASE/README.txt"
echo ""

# ==========================================
# STEP 6: Create quick reference script
# ==========================================

cat > $WORK_BASE/check_status.sh << EOFCHECK
#!/bin/bash

# Quick status checker

WORK_BASE="$WORK_BASE"

echo "=========================================="
echo "MARMOSET REGISTRATION STATUS CHECK"
echo "=========================================="
echo ""

echo "Anatomical files ready:"
ls -d \$WORK_BASE/anatomical/m* 2>/dev/null | wc -l | xargs echo "  Subjects:"

echo ""
echo "Preprocessed BOLD files:"
ls \$WORK_BASE/preprocessed/errts.*.nii.gz 2>/dev/null | wc -l | xargs echo "  Files:"

echo ""
echo "Registered files (template space):"
ls \$WORK_BASE/correlation/*_to_template_0.5mm_masked_gm.nii.gz 2>/dev/null | wc -l | xargs echo "  Files:"

echo ""
echo "Disk usage:"
du -sh \$WORK_BASE
du -sh \$WORK_BASE/*

echo ""
EOFCHECK

chmod +x $WORK_BASE/check_status.sh
echo "  ✓ Status checker created: $WORK_BASE/check_status.sh"
echo ""

# ==========================================
# SUMMARY
# ==========================================

echo "=========================================="
echo "SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "Working directory: $WORK_BASE"
echo ""
echo "Next steps:"
echo ""
echo "1. Run preprocessing (rs_MASTER.sh) if not done yet"
echo "   Output should go to: $WORK_BASE/preprocessed/"
echo ""
echo "2. Run registration:"
echo "   cd /path/to/scripts"
echo "   tcsh -xef registration_MASTER_UPDATED.sh 2>&1 | tee $WORK_BASE/logs/registration.log"
echo ""
echo "3. Check status anytime:"
echo "   bash $WORK_BASE/check_status.sh"
echo ""
echo "For detailed instructions, see:"
echo "   $WORK_BASE/README.txt"
echo ""
