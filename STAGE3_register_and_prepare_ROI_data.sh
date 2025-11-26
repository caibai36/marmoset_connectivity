#!/bin/bash

# ==========================================
# STAGE 3: REGISTER TO TEMPLATE & PREPARE FOR ROI ANALYSIS
# ==========================================
# After preprocessing, register all data to MBM template space
# This enables ROI-based connectivity analysis
# ==========================================

PREPROCESSED_DIR="./preprocessed_data"
ROI_DIR="./marmoset_vocalization_ROIs"
MBM_TEMPLATE="/data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1/template_T2w_brain.nii.gz"
OUTPUT_DIR="./template_space_data"

mkdir -p $OUTPUT_DIR

echo "==========================================="
echo "STAGE 3: REGISTRATION TO MBM TEMPLATE"
echo "==========================================="
echo ""

# This stage assumes:
# 1. Preprocessing (Stage 2) is complete
# 2. ROI masks (Stage 1) are created
# 3. registration_MASTER.sh has been run

echo "Checking prerequisites..."

if [ ! -d "$ROI_DIR" ]; then
    echo "ERROR: ROI directory not found. Run Stage 1 first."
    exit 1
fi

if [ ! -d "$PREPROCESSED_DIR" ]; then
    echo "ERROR: Preprocessed data not found. Run Stage 2 first."
    exit 1
fi

echo "[OK] Prerequisites found"
echo ""

# ==========================================
# STEP 1: Verify registration outputs
# ==========================================

echo "Step 1: Verifying registration outputs..."
echo ""

# After running registration_MASTER.sh, you should have:
# - Individual T2 to template warps
# - Preprocessed BOLD in template space
# - Files named like: {monkey}_{pe}_bold_{run}_to_template_errts_.5iso_masked_gm.nii.gz

# Check for registered files
registered_count=0
for subj_dir in $PREPROCESSED_DIR/sub-*/; do
    if [ -d "$subj_dir" ]; then
        subj=$(basename $subj_dir)

        # Look for template space files
        template_files=$(find $subj_dir -name "*to_template*.nii.gz" 2>/dev/null | wc -l)

        if [ $template_files -gt 0 ]; then
            echo "[OK] $subj: $template_files files in template space"
            registered_count=$((registered_count + 1))
        else
            echo "[WARNING] $subj: No template space files found"
        fi
    fi
done

echo ""
echo "Total subjects with template space data: $registered_count"
echo ""

if [ $registered_count -eq 0 ]; then
    echo "ERROR: No registered data found. Please run registration_MASTER.sh first."
    exit 1
fi

# ==========================================
# STEP 2: Organize template space data
# ==========================================

echo "Step 2: Organizing template space data for ROI analysis..."
echo ""

# Create organized directory structure
mkdir -p $OUTPUT_DIR/registered_bold
mkdir -p $OUTPUT_DIR/roi_masks
mkdir -p $OUTPUT_DIR/metadata

# Copy ROI masks
echo "Copying ROI masks..."
cp $ROI_DIR/*.nii.gz $OUTPUT_DIR/roi_masks/ 2>/dev/null

# Create subject manifest
echo "subject_id,age_months,sex,site,template_space_files" > $OUTPUT_DIR/metadata/subject_manifest.csv

for subj_dir in $PREPROCESSED_DIR/sub-*/; do
    if [ -d "$subj_dir" ]; then
        subj=$(basename $subj_dir)

        # Get subject metadata from preprocessing
        age=$(grep "^$subj," $PREPROCESSED_DIR/subject_list.txt | cut -d' ' -f2)
        sex=$(grep "^$subj," $PREPROCESSED_DIR/subject_list.txt | cut -d' ' -f3)
        site=$(grep "^$subj," $PREPROCESSED_DIR/subject_list.txt | cut -d' ' -f4)

        # Find template space BOLD files
        template_files=$(find $subj_dir -name "*to_template*errts*.nii.gz" 2>/dev/null)

        if [ -n "$template_files" ]; then
            # Copy to organized location
            for tfile in $template_files; do
                fname=$(basename $tfile)
                cp $tfile $OUTPUT_DIR/registered_bold/${subj}_${fname}
            done

            nfiles=$(echo "$template_files" | wc -l)
            echo "$subj,$age,$sex,$site,$nfiles" >> $OUTPUT_DIR/metadata/subject_manifest.csv

            echo "[OK] $subj: $nfiles files copied"
        fi
    fi
done

echo ""
echo "[OK] Template space data organized"
echo ""

# ==========================================
# STEP 3: Quality control checks
# ==========================================

echo "Step 3: Quality control..."
echo ""

# Check ROI mask dimensions match template
echo "Checking ROI mask dimensions..."

template_dim=$(3dinfo -n4 $MBM_TEMPLATE 2>/dev/null || echo "UNKNOWN")
echo "Template dimensions: $template_dim"

for roi_mask in $OUTPUT_DIR/roi_masks/*.nii.gz; do
    if [ -f "$roi_mask" ]; then
        mask_name=$(basename $roi_mask)
        mask_dim=$(3dinfo -n4 $roi_mask 2>/dev/null || echo "UNKNOWN")

        if [ "$mask_dim" = "$template_dim" ]; then
            echo "  [OK] $mask_name: $mask_dim"
        else
            echo "  [WARNING] $mask_name: dimension mismatch ($mask_dim vs $template_dim)"
        fi
    fi
done

echo ""

# Check for common space across subjects
echo "Verifying all BOLD data in common template space..."
first_bold=$(ls $OUTPUT_DIR/registered_bold/*.nii.gz 2>/dev/null | head -1)
if [ -n "$first_bold" ]; then
    ref_dim=$(3dinfo -n4 $first_bold 2>/dev/null)
    echo "Reference BOLD dimensions: $ref_dim"

    mismatch=0
    for bold_file in $OUTPUT_DIR/registered_bold/*.nii.gz; do
        bold_dim=$(3dinfo -n4 $bold_file 2>/dev/null)
        if [ "$bold_dim" != "$ref_dim" ]; then
            echo "  [WARNING] $(basename $bold_file): dimension mismatch"
            mismatch=$((mismatch + 1))
        fi
    done

    if [ $mismatch -eq 0 ]; then
        echo "  [OK] All BOLD files have consistent dimensions"
    else
        echo "  [WARNING] $mismatch files have dimension mismatches"
    fi
fi

echo ""

# ==========================================
# SUMMARY
# ==========================================

echo "==========================================="
echo "STAGE 3 COMPLETE"
echo "==========================================="
echo ""
echo "Output directory: $OUTPUT_DIR"
echo ""
echo "Contents:"
echo "  - registered_bold/: All BOLD data in MBM template space"
echo "  - roi_masks/: Vocalization network ROI masks"
echo "  - metadata/: Subject information and file manifest"
echo ""
echo "Subject summary:"
wc -l < $OUTPUT_DIR/metadata/subject_manifest.csv
echo " subjects ready for ROI analysis"
echo ""
echo "Next step: Run STAGE 4 to extract ROI time series"
echo ""
