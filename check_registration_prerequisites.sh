#!/bin/bash

# ==========================================
# REGISTRATION PREREQUISITES CHECKER
# ==========================================
# Run this script before running registration_MASTER.sh
# to verify all required files and software are available
# ==========================================

echo "=========================================="
echo "REGISTRATION PREREQUISITES CHECKER"
echo "=========================================="
echo ""

# ==========================================
# CONFIGURATION - EDIT THESE PATHS
# ==========================================

# Test subject (use one subject for checking)
TEST_SUBJECT="m6"
TEST_RUN="1"
TEST_PE="u"

# Your data paths
RAW_DATA_DIR="/data02/share/bin-wu/data/marmoset/brain/nih_uwo/nih/NIH-data"
MBM_DIR="/data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1"
WORK_DIR="/work02/home/bin-wu/workspace/projects/marmoset_registration"

# ==========================================
# CHECK SOFTWARE
# ==========================================

echo "1. Checking software requirements..."
echo ""

ERRORS=0

# Check FSL
if command -v flirt &> /dev/null; then
    echo "  ✓ FSL (flirt) found: $(which flirt)"
else
    echo "  ✗ FSL (flirt) NOT FOUND"
    echo "    Solution: module load fsl OR export FSLDIR=/path/to/fsl"
    ERRORS=$((ERRORS + 1))
fi

# Check ANTs
if command -v antsRegistrationSyNQuick.sh &> /dev/null; then
    echo "  ✓ ANTs found: $(which antsRegistrationSyNQuick.sh)"
else
    echo "  ✗ ANTs NOT FOUND"
    echo "    Solution: module load ants OR export PATH=/path/to/ants/bin:\$PATH"
    ERRORS=$((ERRORS + 1))
fi

# Check AFNI
if command -v 3dcalc &> /dev/null; then
    echo "  ✓ AFNI (3dcalc) found: $(which 3dcalc)"
else
    echo "  ✗ AFNI (3dcalc) NOT FOUND"
    echo "    Solution: module load afni OR source AFNI setup"
    ERRORS=$((ERRORS + 1))
fi

if command -v 3dresample &> /dev/null; then
    echo "  ✓ AFNI (3dresample) found: $(which 3dresample)"
else
    echo "  ✗ AFNI (3dresample) NOT FOUND"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# ==========================================
# CHECK MBM TEMPLATE FILES
# ==========================================

echo "2. Checking MBM template files..."
echo ""

if [ -d "$MBM_DIR" ]; then
    echo "  ✓ MBM directory exists: $MBM_DIR"
else
    echo "  ✗ MBM directory NOT FOUND: $MBM_DIR"
    ERRORS=$((ERRORS + 1))
fi

# Check original template
if [ -f "$MBM_DIR/template_T2w_brain.nii.gz" ]; then
    echo "  ✓ Original T2 template exists"
else
    echo "  ✗ Original T2 template NOT FOUND"
    ERRORS=$((ERRORS + 1))
fi

# Check 0.5mm template
if [ -f "$MBM_DIR/template_T2w_brain_.5iso.nii.gz" ]; then
    echo "  ✓ Downsampled T2 template (0.5mm) exists"
else
    echo "  ⚠ Downsampled template NOT FOUND: template_T2w_brain_.5iso.nii.gz"
    echo "    Need to create it with:"
    echo "    3dresample -dxyz 0.5 0.5 0.5 -input template_T2w_brain.nii.gz -prefix template_T2w_brain_.5iso.nii.gz"
    ERRORS=$((ERRORS + 1))
fi

# Check tissue masks
for mask in gray_template_.5.nii white_matter_.5.nii csf_.5.nii; do
    if [ -f "$MBM_DIR/$mask" ]; then
        echo "  ✓ Tissue mask exists: $mask"
    else
        echo "  ⚠ Tissue mask NOT FOUND: $mask"
        echo "    Need to create from segmentation files"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""

# ==========================================
# CHECK RAW DATA
# ==========================================

echo "3. Checking raw data for test subject ($TEST_SUBJECT)..."
echo ""

SUBJ_DIR="$RAW_DATA_DIR/$TEST_SUBJECT"

if [ -d "$SUBJ_DIR" ]; then
    echo "  ✓ Subject directory exists: $SUBJ_DIR"
else
    echo "  ✗ Subject directory NOT FOUND: $SUBJ_DIR"
    ERRORS=$((ERRORS + 1))
fi

# Check anatomical files
if [ -f "$SUBJ_DIR/InplaneT2.nii.gz" ]; then
    echo "  ✓ InplaneT2.nii.gz exists"
    # Show dimensions
    if command -v fslinfo &> /dev/null; then
        dims=$(fslinfo "$SUBJ_DIR/InplaneT2.nii.gz" | grep "^dim[1-3]" | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
        echo "    Dimensions: $dims"
    fi
else
    echo "  ✗ InplaneT2.nii.gz NOT FOUND"
    ERRORS=$((ERRORS + 1))
fi

if [ -f "$SUBJ_DIR/mask.nii.gz" ]; then
    echo "  ✓ mask.nii.gz exists"
else
    echo "  ✗ mask.nii.gz NOT FOUND"
    ERRORS=$((ERRORS + 1))
fi

# Check BOLD files
bold_up_count=$(ls $SUBJ_DIR/BOLD_up_*.nii.gz 2>/dev/null | wc -l)
bold_down_count=$(ls $SUBJ_DIR/BOLD_down_*.nii.gz 2>/dev/null | wc -l)

echo "  Found $bold_up_count BOLD_up runs"
echo "  Found $bold_down_count BOLD_down runs"

if [ $bold_up_count -eq 0 ]; then
    echo "  ⚠ No BOLD_up files found - check data location"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# ==========================================
# CHECK PREPROCESSED DATA (if exists)
# ==========================================

echo "4. Checking for preprocessed data..."
echo ""

if [ -d "$WORK_DIR/preprocessed" ]; then
    echo "  ✓ Preprocessed directory exists: $WORK_DIR/preprocessed"

    # Check for expected preprocessed files
    expected_errts="errts.${TEST_SUBJECT}_${TEST_PE}_bold_${TEST_RUN}.tproject.nii.gz"
    expected_mean="${TEST_SUBJECT}_${TEST_PE}_bold_${TEST_RUN}.mean.nii.gz"

    if [ -f "$WORK_DIR/preprocessed/$expected_errts" ]; then
        echo "  ✓ Preprocessed BOLD exists: $expected_errts"
        if command -v 3dinfo &> /dev/null; then
            dims=$(3dinfo -n4 "$WORK_DIR/preprocessed/$expected_errts")
            echo "    Dimensions: $dims"
        fi
    else
        echo "  ⚠ Preprocessed BOLD NOT FOUND: $expected_errts"
        echo "    You need to run rs_MASTER.sh first"
    fi

    if [ -f "$WORK_DIR/preprocessed/$expected_mean" ]; then
        echo "  ✓ Mean functional exists: $expected_mean"
    else
        echo "  ⚠ Mean functional NOT FOUND: $expected_mean"
        echo "    You need to run rs_MASTER.sh first"
    fi
else
    echo "  ⚠ Preprocessed directory does not exist"
    echo "    You need to:"
    echo "    1. Create $WORK_DIR/preprocessed"
    echo "    2. Run rs_MASTER.sh to generate preprocessed data"
fi

echo ""

# ==========================================
# CHECK DIRECTORY STRUCTURE
# ==========================================

echo "5. Checking directory structure..."
echo ""

for dir in preprocessed anatomical template_space correlation temp; do
    if [ -d "$WORK_DIR/$dir" ]; then
        echo "  ✓ Directory exists: $dir"
    else
        echo "  ⚠ Directory missing: $dir"
        echo "    Create with: mkdir -p $WORK_DIR/$dir"
    fi
done

echo ""

# ==========================================
# SUMMARY
# ==========================================

echo "=========================================="
echo "SUMMARY"
echo "=========================================="
echo ""

if [ $ERRORS -eq 0 ]; then
    echo "✓ ALL CHECKS PASSED!"
    echo ""
    echo "You are ready to run registration_MASTER.sh"
    echo ""
    echo "Next steps:"
    echo "  1. Edit registration_MASTER.sh with your paths"
    echo "  2. Test with one subject first"
    echo "  3. Run: tcsh -xef registration_MASTER.sh"
    exit 0
else
    echo "✗ FOUND $ERRORS ISSUES"
    echo ""
    echo "Please fix the issues above before running registration_MASTER.sh"
    echo ""
    echo "Common fixes:"
    echo "  - Load required modules: module load fsl ants afni"
    echo "  - Create 0.5mm template: 3dresample -dxyz 0.5 0.5 0.5 -input template.nii.gz -prefix template_.5iso.nii.gz"
    echo "  - Run preprocessing first: rs_MASTER.sh"
    echo "  - Create directory structure: mkdir -p $WORK_DIR/{preprocessed,anatomical,template_space,correlation,temp}"
    exit 1
fi
