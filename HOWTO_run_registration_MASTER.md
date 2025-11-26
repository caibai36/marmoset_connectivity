# Step-by-Step Guide: Running registration_MASTER.sh

## Overview

The `registration_MASTER.sh` script registers preprocessed BOLD fMRI data to the MBM template space. This is **STAGE 2.5** - run AFTER preprocessing (rs_MASTER.sh) but BEFORE ROI analysis.

---

## Prerequisites

### 1. Completed Preprocessing
You must have already run `rs_MASTER.sh` which produces:
- `errts.{monkey}_{pe}_bold_{run}.tproject.nii.gz` - preprocessed BOLD data
- `{monkey}_{pe}_bold_{run}.mean.nii.gz` - mean functional image

### 2. Anatomical Data
For each subject (e.g., m6, m7, ...):
- `InplaneT2.nii.gz` - T2-weighted anatomical scan
- `mask.nii.gz` - brain mask

### 3. MBM Template Files
Download and prepare MBM v3 template (see Step 1 below)

### 4. Software Requirements
- **FSL** (flirt command)
- **ANTs** (antsRegistrationSyNQuick.sh, antsApplyTransforms)
- **AFNI** (3dcalc, 3dmaskave, 3dresample)

---

## STEP 1: Prepare MBM Template Files

### Download MBM v3 Atlas

```bash
# Your MBM location
MBM_DIR="/data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1"

# Check if template exists
ls -lh $MBM_DIR/template_T2w_brain.nii.gz
ls -lh $MBM_DIR/mask_brain.nii.gz
```

### Downsample Template to 0.5mm Isotropic

The script expects 0.5mm isotropic resolution. Check current resolution and downsample if needed:

```bash
cd $MBM_DIR

# Check current dimensions
3dinfo -n4 template_T2w_brain.nii.gz

# If not 0.5mm isotropic, downsample:
3dresample -dxyz 0.5 0.5 0.5 \
           -input template_T2w_brain.nii.gz \
           -prefix template_T2w_brain_.5iso.nii.gz

# Also downsample tissue masks
3dresample -dxyz 0.5 0.5 0.5 \
           -input segmentation_three_types_prob_1_gray.nii.gz \
           -prefix gray_template_.5.nii

3dresample -dxyz 0.5 0.5 0.5 \
           -input segmentation_three_types_prob_2_white.nii.gz \
           -prefix white_matter_.5.nii

3dresample -dxyz 0.5 0.5 0.5 \
           -input segmentation_three_types_prob_3_csf.nii.gz \
           -prefix csf_.5.nii
```

### Verify Template Files

You should now have:
```bash
ls -lh $MBM_DIR/*.5*
# Expected output:
# template_T2w_brain_.5iso.nii.gz
# gray_template_.5.nii
# white_matter_.5.nii
# csf_.5.nii
```

---

## STEP 2: Set Up Directory Structure

### Create Working Directories

```bash
# Main working directory
WORK_DIR="/work02/home/bin-wu/workspace/projects/marmoset_registration"
mkdir -p $WORK_DIR
cd $WORK_DIR

# Create subdirectories
mkdir -p preprocessed     # Input: preprocessed BOLD from rs_MASTER.sh
mkdir -p anatomical       # Input: T2 and masks per subject
mkdir -p template_space   # Output: registered data
mkdir -p correlation      # Output: ready for connectivity analysis
mkdir -p temp            # Temporary files (will be deleted)
```

### Organize Your Data

#### Example for subject m6:

```bash
# Your raw data location
RAW_DATA="/data02/share/bin-wu/data/marmoset/brain/nih_uwo/nih/NIH-data"

# Copy/link anatomical data
mkdir -p $WORK_DIR/anatomical/m6
cp $RAW_DATA/m6/InplaneT2.nii.gz $WORK_DIR/anatomical/m6/
cp $RAW_DATA/m6/mask.nii.gz $WORK_DIR/anatomical/m6/

# Preprocessed BOLD data should be from rs_MASTER.sh output
# Assuming you ran rs_MASTER.sh and have these files:
# Copy to preprocessed directory with correct naming
# Expected format: errts.m6_u_bold_1.tproject.nii.gz
```

---

## STEP 3: Configure registration_MASTER.sh

### Make a Copy

```bash
cd $WORK_DIR
cp /home/user/marmoset_connectivity/registration_MASTER.sh ./
```

### Edit the Script

Open the script and configure these variables:

```bash
nano registration_MASTER.sh
```

#### Configuration for Subject m6 (as example):

```tcsh
#!/bin/tcsh -xef

# ==========================================
# USER SPECIFICATIONS - EDIT THESE
# ==========================================

# Subject IDs (directory names: m6, m7, m8, etc.)
set monkey = (m6)  # Start with one subject for testing

# Run numbers (how many BOLD runs per subject)
# For NIH data, typically 8 runs
set run = (1 2 3 4 5 6 7 8)

# Phase encoding directions
# NIH: up and down
# UWO: only up
set pe = (u d)  # u=up, d=down

# ==========================================
# DIRECTORY PATHS - EDIT THESE
# ==========================================

# Path to preprocessed BOLD files (output from rs_MASTER.sh)
set apth = /work02/home/bin-wu/workspace/projects/marmoset_registration/preprocessed

# Path to anatomical files (T2 and mask)
set anat_pth = /work02/home/bin-wu/workspace/projects/marmoset_registration/anatomical

# Output directory for correlation-ready files
set corrpth = /work02/home/bin-wu/workspace/projects/marmoset_registration/correlation

# Path to MBM template and masks
set mskpth = /data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1

# Main output directory
set output_dir = /work02/home/bin-wu/workspace/projects/marmoset_registration/template_space

# Temporary directory (will be cleaned up)
set temp_dir = /work02/home/bin-wu/workspace/projects/marmoset_registration/temp

# Rest of script stays the same...
```

---

## STEP 4: Prepare Input Files

### For Each Subject, You Need:

#### In anatomical directory:

```bash
$anat_pth/m6/
├── InplaneT2.nii.gz    # T2 anatomical
└── mask.nii.gz         # Brain mask
```

#### In preprocessed directory (from rs_MASTER.sh):

```bash
$apth/
├── errts.m6_u_bold_1.tproject.nii.gz   # Preprocessed BOLD run 1, up
├── errts.m6_u_bold_2.tproject.nii.gz   # Run 2
├── ...
├── errts.m6_d_bold_1.tproject.nii.gz   # Preprocessed BOLD run 1, down
├── ...
├── m6_u_bold_1.mean.nii.gz             # Mean functional, run 1 up
├── m6_u_bold_2.mean.nii.gz
└── ...
```

### Verify Files Exist

```bash
# Check anatomical files
ls -lh $WORK_DIR/anatomical/m6/

# Check preprocessed BOLD files
ls -lh $WORK_DIR/preprocessed/errts.m6_u_bold_*.nii.gz
ls -lh $WORK_DIR/preprocessed/m6_u_bold_*.mean.nii.gz

# Check template files
ls -lh $MBM_DIR/template_T2w_brain_.5iso.nii.gz
ls -lh $MBM_DIR/gray_template_.5.nii
ls -lh $MBM_DIR/white_matter_.5.nii
ls -lh $MBM_DIR/csf_.5.nii
```

---

## STEP 5: Run Registration (Test with One Subject First)

### Test Run for One Subject

```bash
cd $WORK_DIR

# Start with just one subject and one run for testing
# Edit registration_MASTER.sh:
# set monkey = (m6)
# set run = (1)
# set pe = (u)

# Run the script
tcsh -xef registration_MASTER.sh 2>&1 | tee registration_m6_log.txt
```

### What the Script Does (Step by Step):

1. **BOLD → T2 Registration (Line 32-34)**
   - Registers mean functional image to T2 anatomical
   - Output: `temp/m6_u_bold_1.mean_to_t2.nii.gz`
   - Transform: `temp/m6_u_bold_1.mean_to_t2.mat`

2. **Apply Transform to Preprocessed BOLD (Line 36-38)**
   - Applies registration to full 4D preprocessed data
   - Output: `temp/errts.m6_u_bold_1.tproject_to_t2.nii.gz`

3. **Mask Registration (Line 40-50)**
   - Registers brain mask to T2
   - Creates skull-stripped T2
   - Output: `temp/m6_InplaneT2_masked.nii.gz`

4. **T2 → Template Registration (Line 53-55)** ⏱️ SLOW STEP
   - Nonlinear registration using ANTs
   - Takes 10-30 minutes per subject
   - Output: `temp/m6_t2_to_template_.5iso_Warped.nii.gz`
   - Transforms: `temp/m6_t2_to_template_.5iso_0GenericAffine.mat`
                `temp/m6_t2_to_template_.5iso_1Warp.nii.gz`

5. **Apply to BOLD (Line 57-59)**
   - Brings BOLD data to template space
   - Output: `temp/errts.m6_u_bold_1.tproject_to_template.nii.gz`

6. **Gray Matter Masking (Line 62-64)**
   - Masks with gray matter template
   - Output: `correlation/m6_u_bold_1_to_template_errts_.5iso_masked_gm.nii.gz`

7. **Nuisance Regressors (Line 67-77)**
   - Extracts white matter and CSF signals
   - Output: `correlation/m6_u_bold_1_nui_regressors.1D`

---

## STEP 6: Monitor Progress

### Check Log Output

```bash
# Watch progress in real-time
tail -f registration_m6_log.txt

# Look for errors
grep -i "error\|fail\|warning" registration_m6_log.txt
```

### Check Intermediate Files

```bash
# After each major step, check outputs exist:

# After BOLD to T2
ls -lh temp/m6_u_bold_1.mean_to_t2.nii.gz

# After T2 to template (this is the slow step)
ls -lh temp/m6_t2_to_template_.5iso_Warped.nii.gz

# Final output in template space
ls -lh correlation/m6_u_bold_1_to_template_errts_.5iso_masked_gm.nii.gz
```

### Expected File Sizes

```
m6_u_bold_1.mean_to_t2.nii.gz           ~1-5 MB
errts.m6_u_bold_1.tproject_to_t2.nii.gz ~50-200 MB
m6_t2_to_template_.5iso_Warped.nii.gz   ~10-30 MB
*_to_template_errts_.5iso_masked_gm.nii.gz ~100-300 MB
```

---

## STEP 7: Verify Registration Quality

### Visual Inspection

```bash
# View T2 registered to template
fsleyes $MBM_DIR/template_T2w_brain_.5iso.nii.gz \
        temp/m6_t2_to_template_.5iso_Warped.nii.gz &

# View BOLD in template space overlaid on template
fsleyes $MBM_DIR/template_T2w_brain_.5iso.nii.gz \
        correlation/m6_u_bold_1_to_template_errts_.5iso_masked_gm.nii.gz &
```

### Check Alignment

Look for:
- ✅ Brain boundaries align
- ✅ Ventricles match
- ✅ Cortical features aligned
- ❌ Obvious misalignment or distortion

---

## STEP 8: Batch Process All Subjects

### Once Test is Successful

Edit `registration_MASTER.sh` to include all subjects:

```tcsh
# All NIH subjects
set monkey = (m6 m7 m8 m9 m10 m11 m12 m14 m15 m16 m17 m18 m19 m20 m21 m22 m23 m24 m25 m26 m27 m28 m29 m30 m31 m32)

# All runs (most NIH subjects have 8 runs)
set run = (1 2 3 4 5 6 7 8)

# Both phase encodings for NIH
set pe = (u d)
```

### Submit as Batch Job (Recommended)

Create a job submission script for your cluster:

```bash
cat > submit_registration.sh << 'EOF'
#!/bin/bash
#SBATCH --job-name=marmoset_reg
#SBATCH --time=48:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --output=registration_%j.log

# Load modules
module load fsl/6.0.4
module load ants/2.3.5
module load afni/20.3.02

# Run registration
cd /work02/home/bin-wu/workspace/projects/marmoset_registration
tcsh -xef registration_MASTER.sh
EOF

# Submit job
sbatch submit_registration.sh
```

### OR Run Subjects in Parallel

```bash
# Process each subject in background
for subj in m6 m7 m8; do
    echo "Processing $subj..."

    # Edit script for this subject only
    sed "s/set monkey = .*/set monkey = ($subj)/" registration_MASTER.sh > reg_${subj}.sh

    # Run in background
    tcsh -xef reg_${subj}.sh > reg_${subj}.log 2>&1 &

    # Limit number of parallel jobs
    while [ $(jobs -r | wc -l) -ge 4 ]; do
        sleep 60
    done
done

# Wait for all to complete
wait
echo "All subjects complete!"
```

---

## STEP 9: Verify All Outputs

### Check Completion

```bash
# Count expected output files
# For NIH subjects: 8 runs × 2 phase encodings = 16 files per subject

# Expected per subject
EXPECTED=16

for subj in m6 m7 m8 m9 m10 m11 m12 m14 m15 m16 m17 m18 m19 m20 m21 m22 m23 m24 m25 m26 m27 m28 m29 m30 m31 m32; do
    count=$(ls correlation/${subj}_*_to_template_errts_.5iso_masked_gm.nii.gz 2>/dev/null | wc -l)
    echo "$subj: $count / $EXPECTED files"

    if [ $count -ne $EXPECTED ]; then
        echo "  WARNING: Missing files for $subj"
    fi
done
```

### Create Summary

```bash
# Generate summary report
cat > registration_summary.txt << EOF
REGISTRATION SUMMARY
====================
Date: $(date)

Template: $MBM_DIR/template_T2w_brain_.5iso.nii.gz

Subjects processed:
EOF

for subj in m6 m7 m8 m9 m10 m11 m12 m14 m15 m16 m17 m18 m19 m20 m21 m22 m23 m24 m25 m26 m27 m28 m29 m30 m31 m32; do
    count=$(ls correlation/${subj}_*_masked_gm.nii.gz 2>/dev/null | wc -l)
    echo "$subj: $count files" >> registration_summary.txt
done

cat registration_summary.txt
```

---

## STEP 10: Proceed to ROI Analysis

### Your Output Files

After successful registration, you'll have:

```
correlation/
├── m6_u_bold_1_to_template_errts_.5iso_masked_gm.nii.gz
├── m6_u_bold_2_to_template_errts_.5iso_masked_gm.nii.gz
├── ...
├── m6_u_bold_1_nui_regressors.1D
├── m6_u_bold_2_nui_regressors.1D
└── ...
```

### Next Steps

Now you can proceed with:
1. **STAGE 3:** Organize template space data
2. **STAGE 4:** Extract ROI time series
3. **STAGE 5:** Compute connectivity matrices

---

## Troubleshooting

### Common Issues

#### 1. "Command not found: flirt"
**Solution:** Load FSL module
```bash
module load fsl
# Or set FSLDIR
export FSLDIR=/usr/local/fsl
source $FSLDIR/etc/fslconf/fsl.sh
```

#### 2. "Command not found: antsRegistrationSyNQuick.sh"
**Solution:** Load ANTs and add to PATH
```bash
module load ants
# Or
export ANTSPATH=/usr/local/ants/bin/
export PATH=$ANTSPATH:$PATH
```

#### 3. "3dcalc: command not found"
**Solution:** Load AFNI
```bash
module load afni
# Or source AFNI setup
source /usr/local/afni/AFNI_setup.sh
```

#### 4. Registration fails with "cannot find template"
**Solution:** Check template path
```bash
# Verify path in script
grep "mskpth" registration_MASTER.sh

# Check file exists
ls -lh $mskpth/template_T2w_brain_.5iso.nii.gz
```

#### 5. "Input file not found"
**Solution:** Check naming convention
```bash
# Script expects specific naming:
# errts.{monkey}_{pe}_bold_{run}.tproject.nii.gz
# {monkey}_{pe}_bold_{run}.mean.nii.gz

# Verify your files match:
ls -lh preprocessed/errts.m6_u_bold_1.tproject.nii.gz
ls -lh preprocessed/m6_u_bold_1.mean.nii.gz
```

#### 6. ANTs registration is very slow
**Solution:** This is normal! ANTs SyN registration takes 10-30 minutes per subject.
- Use multiple CPU cores: `export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=8`
- Run subjects in parallel on cluster
- Be patient!

#### 7. Output files are empty or very small
**Solution:** Check for errors in previous steps
```bash
# Check if preprocessed BOLD exists and has timepoints
3dinfo -n4 preprocessed/errts.m6_u_bold_1.tproject.nii.gz
# Should show: 56 72 38 500 (or similar with many timepoints)

# Check if mask is not empty
3dinfo -n4 anatomical/m6/mask.nii.gz
```

---

## Quick Reference: File Naming Convention

### Input Files Required

| File Type | Location | Naming Pattern | Example |
|-----------|----------|----------------|---------|
| Preprocessed BOLD | `apth/` | `errts.{m}_{p}_bold_{r}.tproject.nii.gz` | `errts.m6_u_bold_1.tproject.nii.gz` |
| Mean functional | `apth/` | `{m}_{p}_bold_{r}.mean.nii.gz` | `m6_u_bold_1.mean.nii.gz` |
| T2 anatomical | `anat_pth/{m}/` | `InplaneT2.nii.gz` | `anatomical/m6/InplaneT2.nii.gz` |
| Brain mask | `anat_pth/{m}/` | `mask.nii.gz` | `anatomical/m6/mask.nii.gz` |

### Output Files Generated

| File Type | Location | Naming Pattern |
|-----------|----------|----------------|
| Registered BOLD (GM masked) | `corrpth/` | `{m}_{p}_bold_{r}_to_template_errts_.5iso_masked_gm.nii.gz` |
| Nuisance regressors | `corrpth/` | `{m}_{p}_bold_{r}_nui_regressors.1D` |
| T2 to template warp | `temp_dir/` | `{m}_t2_to_template_.5iso_Warped.nii.gz` |
| Affine transform | `temp_dir/` | `{m}_t2_to_template_.5iso_0GenericAffine.mat` |
| Warp field | `temp_dir/` | `{m}_t2_to_template_.5iso_1Warp.nii.gz` |

**Legend:**
- `{m}` = monkey ID (e.g., m6, m7)
- `{p}` = phase encoding (u or d)
- `{r}` = run number (1, 2, 3, ...)

---

## Estimated Processing Time

| Step | Time per Subject | Total for 27 Subjects |
|------|------------------|----------------------|
| BOLD → T2 | ~2 min | ~1 hour |
| T2 → Template (ANTs) | ~20 min | ~9 hours |
| Apply transforms | ~5 min | ~2 hours |
| Masking & regressors | ~2 min | ~1 hour |
| **TOTAL** | **~30 min** | **~13 hours** |

*Times vary by computing resources and data size*

---

## Summary Checklist

- [ ] Downloaded and prepared MBM template (0.5mm isotropic)
- [ ] Created directory structure
- [ ] Organized anatomical data (T2 + masks)
- [ ] Located preprocessed BOLD files from rs_MASTER.sh
- [ ] Edited registration_MASTER.sh with correct paths
- [ ] Tested with one subject successfully
- [ ] Verified registration quality visually
- [ ] Batch processed all subjects
- [ ] Verified all output files exist
- [ ] Ready for STAGE 3: ROI analysis

---

**Next:** After registration completes, proceed to `STAGE3_register_and_prepare_ROI_data.sh`
