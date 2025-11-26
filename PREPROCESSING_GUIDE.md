# Complete BOLD Preprocessing Guide

## Overview

This guide explains how to preprocess raw BOLD fMRI data using the existing `rs_MASTER.sh` script from the marmoset_connectivity repository.

**Purpose:** Convert raw BOLD files to preprocessed, motion-corrected, filtered data ready for registration.

---

## What is rs_MASTER.sh?

`rs_MASTER.sh` is a comprehensive preprocessing script that performs:

1. **Volume removal** - Remove first 10 volumes (steady-state)
2. **Distortion correction** - FSL TOPUP for phase encoding artifacts (NIH data only)
3. **Despiking** - Remove outlier timepoints (AFNI 3dDespike)
4. **Slice timing correction** - Align slices temporally (AFNI 3dTshift)
5. **Motion correction** - Register to reference volume (AFNI 3dvolreg)
6. **Spatial smoothing** - 1.5mm FWHM Gaussian blur
7. **Motion regression** - Remove motion artifacts (12 parameters)
8. **Bandpass filtering** - 0.01-0.1 Hz (resting-state frequencies)
9. **Censoring** - Exclude high-motion volumes (>0.5mm)
10. **Nuisance regression** - Remove trends, motion confounds

**Input:** Raw BOLD files (`BOLD_up_1.nii.gz`, `BOLD_down_1.nii.gz`)
**Output:** Preprocessed files (`errts.m6_u_bold_1.tproject.nii.gz`, mean images)

---

## Directory Structure

```
/work01/.../riken_mri_s0/
├── local/fmri/local/           # Scripts location
│   ├── run_preprocessing.sh    # Wrapper script (use this!)
│   └── rs_MASTER_adapted.sh    # Adapted from original
└── exp/mri/sandbox/marmoset_registration/
    ├── raw_bold/m6/            # INPUT: Raw BOLD files
    │   ├── BOLD_up_1.nii.gz
    │   ├── BOLD_down_1.nii.gz
    │   ├── SEEPI_up.nii.gz
    │   └── SEEPI_down.nii.gz
    ├── preprocessed/m6/        # OUTPUT: Preprocessed files
    │   ├── errts.m6_u_bold_1.tproject.nii.gz
    │   ├── m6_u_bold_1.mean.nii.gz
    │   └── ...
    └── anatomical/m6/          # Anatomical reference
        ├── InplaneT2.nii.gz
        └── mask.nii.gz
```

---

## Raw BOLD Data Format (NIH 7T)

### File Naming Pattern

```
/data02/share/bin-wu/data/marmoset/brain/nih_uwo/nih/NIH-data/m6/
├── BOLD_up_1.nii.gz      # Run 1, phase encoding = up
├── BOLD_up_2.nii.gz      # Run 2, phase encoding = up
├── BOLD_up_3.nii.gz
├── BOLD_up_4.nii.gz
├── BOLD_up_5.nii.gz
├── BOLD_up_6.nii.gz
├── BOLD_up_7.nii.gz
├── BOLD_up_8.nii.gz
├── BOLD_down_1.nii.gz    # Run 1, phase encoding = down
├── BOLD_down_2.nii.gz
├── BOLD_down_3.nii.gz
├── BOLD_down_4.nii.gz
├── BOLD_down_5.nii.gz
├── BOLD_down_6.nii.gz
├── BOLD_down_7.nii.gz
├── BOLD_down_8.nii.gz
├── SEEPI_up.nii.gz       # Spin echo for distortion correction
├── SEEPI_down.nii.gz
├── InplaneT2.nii.gz      # Anatomical reference
└── mask.nii.gz           # Brain mask
```

### BOLD File Properties (Example: m6)

```bash
# Check dimensions
fslinfo BOLD_up_1.nii.gz

# Output:
dim1    56              # X dimension
dim2    72              # Y dimension
dim3    38              # Z dimension (slices)
dim4    512             # Time points
pixdim1 0.500000        # Voxel size X (0.5mm)
pixdim2 0.500000        # Voxel size Y (0.5mm)
pixdim3 0.500000        # Voxel size Z (0.5mm)
pixdim4 2.000000        # TR = 2 seconds
```

**Total data per subject:**
- 8 runs × 2 phase encodings = 16 BOLD files
- Each file: 56×72×38×512 = ~80 MB
- Total per subject: ~1.3 GB

---

## Quick Start: Using the Wrapper Script

### Option 1: Process One Subject (Recommended for Testing)

```bash
cd /work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/local/fmri/local

# Process subject m6
bash run_preprocessing.sh m6
```

This will:
- Process all runs for m6 (both up and down phase encodings)
- Save outputs to: `exp/mri/sandbox/marmoset_registration/preprocessed/m6/`
- Save log to: `exp/mri/sandbox/marmoset_registration/logs/preprocessing_m6.log`

### Option 2: Process All Subjects

```bash
bash run_preprocessing.sh all
```

This will process all 27 NIH subjects (m6-m32, excluding m13).

**Estimated time:** ~2-3 hours per subject = 60-80 hours total

### Option 3: Process Specific Subjects

```bash
# Process just a few subjects
bash run_preprocessing.sh m6 m7 m8
```

---

## Step-by-Step Manual Processing

If you need to run preprocessing manually for one file:

### Step 1: Prepare Environment

```bash
# Load required modules
module load afni/20.3.02
module load fsl/6.0.4

# Set working directory
cd /work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration

# Source configuration
source config_paths.sh
```

### Step 2: Set Variables for One Run

```bash
# Subject and run info
SUBJECT="m6"
RUN="1"
PE="u"  # u=up, d=down

# Input files
INPUT_BOLD="raw_bold/${SUBJECT}/BOLD_${PE}p_${RUN}.nii.gz"  # Note: "up" or "down" in filename
SEEPI_UP="raw_bold/${SUBJECT}/SEEPI_up.nii.gz"
SEEPI_DOWN="raw_bold/${SUBJECT}/SEEPI_down.nii.gz"
ANAT_T2="anatomical/${SUBJECT}/InplaneT2.nii.gz"
MASK="anatomical/${SUBJECT}/mask.nii.gz"

# Output directory
OUTPUT_DIR="preprocessed/${SUBJECT}"
mkdir -p $OUTPUT_DIR
```

### Step 3: Preprocessing Steps

#### 3.1 Remove First 10 Volumes

```bash
3dcalc -a ${INPUT_BOLD}'[10..$]' \
       -expr 'a' \
       -prefix ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_trimmed.nii.gz
```

**Why:** First volumes have non-steady-state signal

#### 3.2 Distortion Correction (NIH data only)

```bash
# Merge SEEPI images
fslmerge -t ${OUTPUT_DIR}/seepi_merged.nii.gz \
         $SEEPI_UP $SEEPI_DOWN

# Create acquisition parameters file
cat > ${OUTPUT_DIR}/acqparams.txt << EOF
0 -1 0 0.03
0 1 0 0.03
EOF

# Run TOPUP
topup --imain=${OUTPUT_DIR}/seepi_merged.nii.gz \
      --datain=${OUTPUT_DIR}/acqparams.txt \
      --config=b02b0.cnf \
      --out=${OUTPUT_DIR}/topup_results \
      --fout=${OUTPUT_DIR}/topup_field \
      --iout=${OUTPUT_DIR}/topup_unwarped

# Apply to BOLD data
applytopup --imain=${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_trimmed.nii.gz \
           --datain=${OUTPUT_DIR}/acqparams.txt \
           --inindex=1 \
           --topup=${OUTPUT_DIR}/topup_results \
           --out=${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_dc.nii.gz \
           --method=jac
```

**Why:** Corrects geometric distortions from phase encoding

#### 3.3 Despiking

```bash
3dDespike -prefix ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_despike.nii.gz \
          ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_dc.nii.gz
```

**Why:** Removes transient spike artifacts

#### 3.4 Slice Timing Correction

```bash
3dTshift -prefix ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_tshift.nii.gz \
         -tpattern altplus \
         -TR 2.0 \
         ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_despike.nii.gz
```

**Why:** Aligns slices acquired at different times

**Note:** `altplus` = alternating increasing slice acquisition (verify with your data!)

#### 3.5 Motion Correction

```bash
# Find middle volume as reference
NVOLS=$(3dinfo -nv ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_tshift.nii.gz)
REFVOL=$((NVOLS / 2))

# Run motion correction
3dvolreg -prefix ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_volreg.nii.gz \
         -base ${REFVOL} \
         -1Dfile ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_motion.1D \
         -1Dmatrix_save ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_volreg.aff12.1D \
         ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_tshift.nii.gz

# Create mean image
3dTstat -mean \
        -prefix ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}.mean.nii.gz \
        ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_volreg.nii.gz
```

**Why:** Corrects head motion between volumes

#### 3.6 Spatial Smoothing

```bash
3dmerge -1blur_fwhm 1.5 \
        -doall \
        -prefix ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_smooth.nii.gz \
        ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_volreg.nii.gz
```

**Why:** Increases SNR, reduces noise

**FWHM:** 1.5mm (small smoothing for marmoset brain)

#### 3.7 Temporal Filtering & Regression

```bash
# Create motion derivatives
1d_tool.py -infile ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_motion.1D \
           -derivative \
           -write ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_motion_deriv.1D

# Bandpass filter + motion regression
3dTproject -input ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_smooth.nii.gz \
           -prefix ${OUTPUT_DIR}/errts.${SUBJECT}_${PE}_bold_${RUN}.tproject.nii.gz \
           -mask $MASK \
           -polort 2 \
           -passband 0.01 0.1 \
           -ort ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_motion.1D \
           -ort ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_motion_deriv.1D \
           -censor ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_censor.1D
```

**Why:**
- Bandpass: Keep 0.01-0.1 Hz (resting-state frequencies)
- Motion regression: Remove motion confounds
- Polort 2: Remove polynomial trends

#### 3.8 Create Censor File (Motion Threshold)

```bash
1d_tool.py -infile ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_motion.1D \
           -set_nruns 1 \
           -show_censor_count \
           -censor_prev_TR \
           -censor_motion 0.5 ${OUTPUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}
```

**Why:** Exclude volumes with >0.5mm motion

---

## Understanding the Output Files

### Final Preprocessed File

```bash
preprocessed/m6/errts.m6_u_bold_1.tproject.nii.gz
```

This file contains:
- ✓ Trimmed (first 10 volumes removed)
- ✓ Distortion corrected
- ✓ Despiked
- ✓ Slice-time corrected
- ✓ Motion corrected
- ✓ Smoothed (1.5mm FWHM)
- ✓ Bandpass filtered (0.01-0.1 Hz)
- ✓ Motion regressed
- ✓ High-motion volumes censored

**This is ready for registration to template!**

### Mean Functional Image

```bash
preprocessed/m6/m6_u_bold_1.mean.nii.gz
```

**Purpose:** Used for registration (BOLD → T2 → Template)

### Motion Parameters

```bash
preprocessed/m6/m6_u_bold_1_motion.1D
```

**Format:** 6 columns (x, y, z translations + rotations)
**Use:** QC - check if motion is acceptable

### Other QC Files

```
m6_u_bold_1_motion_deriv.1D     # Motion derivatives
m6_u_bold_1_censor.1D           # Censored volumes (0=exclude, 1=keep)
m6_u_bold_1_volreg.aff12.1D     # Volume registration matrices
```

---

## Quality Control (QC)

### Check Motion

```bash
# Plot motion parameters
1dplot -jpeg preprocessed/m6/motion_plot.jpg \
       preprocessed/m6/m6_u_bold_1_motion.1D

# Get motion summary
1d_tool.py -infile preprocessed/m6/m6_u_bold_1_motion.1D \
           -show_mmms
```

**Acceptable:** Mean FD < 0.2mm, max < 0.5mm

### Check Temporal SNR

```bash
3dTstat -mean -prefix preprocessed/m6/m6_u_bold_1_mean_temp.nii.gz \
        preprocessed/m6/errts.m6_u_bold_1.tproject.nii.gz

3dTstat -stdev -prefix preprocessed/m6/m6_u_bold_1_stdev_temp.nii.gz \
        preprocessed/m6/errts.m6_u_bold_1.tproject.nii.gz

3dcalc -a preprocessed/m6/m6_u_bold_1_mean_temp.nii.gz \
       -b preprocessed/m6/m6_u_bold_1_stdev_temp.nii.gz \
       -expr 'a/b' \
       -prefix preprocessed/m6/m6_u_bold_1_tsnr.nii.gz

# View TSNR
afni preprocessed/m6/m6_u_bold_1_tsnr.nii.gz &
```

**Good TSNR:** > 50 in gray matter

### Visual Inspection

```bash
# View preprocessed data
afni preprocessed/m6/errts.m6_u_bold_1.tproject.nii.gz &

# Check for:
# - Residual motion artifacts
# - Signal dropouts
# - Edge artifacts from smoothing
# - Coverage (full brain visible)
```

---

## Troubleshooting

### Issue: "3dTproject: command not found"

```bash
module load afni/20.3.02
```

### Issue: "topup: command not found"

```bash
module load fsl/6.0.4
source $FSLDIR/etc/fslconf/fsl.sh
```

### Issue: Excessive motion (>50% volumes censored)

**Solution:** Exclude this run from analysis, or adjust threshold

```bash
# Check censored count
1d_tool.py -infile preprocessed/m6/m6_u_bold_1_censor.1D -show_censor_count
```

### Issue: Out of memory

**Solution:** Process one run at a time, increase job memory

### Issue: Different slice timing pattern

**Solution:** Check acquisition parameters, adjust -tpattern:
- `altplus` - Alternating increasing
- `altminus` - Alternating decreasing
- `seqplus` - Sequential increasing
- `seqminus` - Sequential decreasing

---

## Expected Processing Time

**Per run (512 volumes):**
- Distortion correction: ~5 min
- Despiking: ~1 min
- Slice timing: ~1 min
- Motion correction: ~2 min
- Smoothing: ~30 sec
- Regression/filtering: ~1 min
- **Total: ~10 min per run**

**Per subject (16 runs):**
- **~2.5 hours**

**All 27 subjects:**
- **~67 hours (3 days) if sequential**
- **~7 hours if 10 parallel jobs**

---

## Batch Processing Recommendations

### Run on Compute Cluster

```bash
# Create array job for all subjects
cat > submit_preprocessing.sh << 'EOF'
#!/bin/bash
#SBATCH --job-name=preproc_marmoset
#SBATCH --array=0-26
#SBATCH --time=4:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

# Subject list
SUBJECTS=(m6 m7 m8 m9 m10 m11 m12 m14 m15 m16 m17 m18 m19 m20 m21 m22 m23 m24 m25 m26 m27 m28 m29 m30 m31 m32)
SUBJ=${SUBJECTS[$SLURM_ARRAY_TASK_ID]}

# Load modules
module load afni fsl

# Run preprocessing
bash run_preprocessing.sh $SUBJ
EOF

# Submit
sbatch submit_preprocessing.sh
```

---

## Next Step After Preprocessing

Once preprocessing is complete:

```bash
# Check outputs
bash check_status.sh

# Expected: 432 files (27 subjects × 16 runs)
ls preprocessed/*/errts.*.nii.gz | wc -l

# Proceed to registration
bash run_registration.sh m6  # Test one
bash run_registration.sh all # Run all
```

---

## Summary Checklist

Before registration, verify:

- [ ] All subjects have preprocessed files
- [ ] Mean functional images created
- [ ] Motion parameters look acceptable
- [ ] No excessive censoring (>50% volumes)
- [ ] TSNR > 50 in gray matter
- [ ] Visual QC passed (no obvious artifacts)

**Then proceed to:** `run_registration.sh`
