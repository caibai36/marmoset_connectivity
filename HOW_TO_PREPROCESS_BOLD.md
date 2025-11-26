# How to Preprocess BOLD Data - Practical Guide

## TL;DR Quick Answer

**You need to run the existing `rs_MASTER.sh` script** from the marmoset_connectivity repository.

**Location:** `/work02/home/bin-wu/workspace/projects/tests/test_fmri/marmoset_connectivity/rs_MASTER.sh`

**Steps:**
1. Edit `rs_MASTER.sh` to set paths and subject info
2. Run it manually for each subject
3. Copy outputs to the registration pipeline

---

## Understanding rs_MASTER.sh

`rs_MASTER.sh` is a **tcsh script** (not bash) that processes one subject at a time.

### Current Structure

The script has variables at the top that you MUST edit:

```tcsh
#!/bin/tcsh -xef

# user specifications
set monkey = ()  # e.g., (m6)
set run = ()     # e.g., (1 2 3 4 5 6 7 8)
set pe = (u)     # phase encoding: u=up, d=down

# Paths to edit
set apth =       # path to BOLD files
set anat_pth =   # path to anatomical files
set output_dir = # output directory
```

**You need to fill these in manually for each subject.**

---

## Practical Workflow: Two Options

### Option A: Use Original rs_MASTER.sh (Manual)

This is the most reliable approach since the script is already tested.

#### Step 1: Prepare Data

```bash
# Data is already linked by setup_directories_and_data.sh
cd /work01/.../riken_mri_s0/exp/mri/sandbox/marmoset_registration

# Verify raw data exists
ls raw_bold/m6/BOLD_*.nii.gz
ls anatomical/m6/InplaneT2.nii.gz
```

#### Step 2: Copy and Edit rs_MASTER.sh

```bash
# Copy the script to a working location
cp /work02/.../marmoset_connectivity/rs_MASTER.sh \
   /work01/.../riken_mri_s0/local/fmri/local/rs_MASTER_m6.sh

# Edit for subject m6
nano rs_MASTER_m6.sh
```

**Edit these lines:**

```tcsh
#!/bin/tcsh -xef

# Subject m6
set monkey = (m6)
set run = (1 2 3 4 5 6 7 8)
set pe = (u d)  # NIH has both up and down

# Paths (ABSOLUTE PATHS REQUIRED)
set apth = /work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration/raw_bold
set anat_pth = /work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration/anatomical
set output_dir = /work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration/preprocessed
set temp_dir = /work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration/temp
```

**IMPORTANT:** Check the script expects these file names:
- Input: `${apth}/${m}/BOLD_${p}p_${r}.nii.gz` (note "up" vs "u")
- You may need to rename: `BOLD_up_1.nii.gz` → `BOLD_u_1.nii.gz`

#### Step 3: Check File Naming

The script expects specific naming. Check what format your files are in:

```bash
# Your files are named:
ls raw_bold/m6/
# BOLD_up_1.nii.gz
# BOLD_down_1.nii.gz

# Script might expect:
# BOLD_u_1.nii.gz
# BOLD_d_1.nii.gz
```

**Fix if needed:**

```bash
cd raw_bold/m6

# Create symlinks with expected names
for i in {1..8}; do
    ln -s BOLD_up_${i}.nii.gz BOLD_u_${i}.nii.gz
    ln -s BOLD_down_${i}.nii.gz BOLD_d_${i}.nii.gz
done

# Or for SEEPI files if needed
ln -s SEEPI_up.nii.gz SEEPI_u.nii.gz
ln -s SEEPI_down.nii.gz SEEPI_d.nii.gz
```

#### Step 4: Load Modules and Run

```bash
# Load required software
module load afni/20.3.02
module load fsl/6.0.4

# Run preprocessing
cd /work01/.../riken_mri_s0/local/fmri/local
tcsh -xef rs_MASTER_m6.sh 2>&1 | tee ../../../exp/mri/sandbox/marmoset_registration/logs/preprocessing_m6.log
```

**Time:** ~2-3 hours for one subject (16 runs)

#### Step 5: Verify Outputs

```bash
# Check outputs
ls preprocessed/m6/errts.m6_*_bold_*.tproject.nii.gz

# Should see 16 files:
# errts.m6_u_bold_1.tproject.nii.gz
# errts.m6_u_bold_2.tproject.nii.gz
# ...
# errts.m6_d_bold_8.tproject.nii.gz

# Also check mean images:
ls preprocessed/m6/m6_*_bold_*.mean.nii.gz
```

---

### Option B: Create Simplified Preprocessing Script

If rs_MASTER.sh is too complex, create a simplified version.

#### Create: `preprocess_simple.sh`

```bash
cat > /work01/.../local/fmri/local/preprocess_simple.sh << 'EOF'
#!/bin/bash

# Simple BOLD preprocessing
# Usage: bash preprocess_simple.sh m6 1 u

SUBJECT=$1
RUN=$2
PE=$3  # u or d

# Paths
BASE="/work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration"
RAW_DIR="$BASE/raw_bold/$SUBJECT"
ANAT_DIR="$BASE/anatomical/$SUBJECT"
OUT_DIR="$BASE/preprocessed/$SUBJECT"
TEMP_DIR="$BASE/temp/$SUBJECT"

mkdir -p $OUT_DIR $TEMP_DIR

# Convert PE: u->up, d->down for file names
if [ "$PE" = "u" ]; then
    PE_LONG="up"
else
    PE_LONG="down"
fi

INPUT="$RAW_DIR/BOLD_${PE_LONG}_${RUN}.nii.gz"
OUTPUT="$OUT_DIR/errts.${SUBJECT}_${PE}_bold_${RUN}.tproject.nii.gz"
MEAN_OUT="$OUT_DIR/${SUBJECT}_${PE}_bold_${RUN}.mean.nii.gz"

echo "Processing: $SUBJECT run $RUN PE $PE"

# 1. Remove first 10 volumes
3dcalc -a ${INPUT}'[10..$]' \
       -expr 'a' \
       -prefix ${TEMP_DIR}/trimmed.nii.gz

# 2. Despike
3dDespike -prefix ${TEMP_DIR}/despike.nii.gz \
          ${TEMP_DIR}/trimmed.nii.gz

# 3. Slice timing correction
3dTshift -prefix ${TEMP_DIR}/tshift.nii.gz \
         -tpattern altplus \
         -TR 2.0 \
         ${TEMP_DIR}/despike.nii.gz

# 4. Motion correction
NVOLS=$(3dinfo -nv ${TEMP_DIR}/tshift.nii.gz)
REFVOL=$((NVOLS / 2))

3dvolreg -prefix ${TEMP_DIR}/volreg.nii.gz \
         -base ${REFVOL} \
         -1Dfile ${OUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_motion.1D \
         ${TEMP_DIR}/tshift.nii.gz

# 5. Create mean
3dTstat -mean -prefix $MEAN_OUT ${TEMP_DIR}/volreg.nii.gz

# 6. Spatial smoothing
3dmerge -1blur_fwhm 1.5 \
        -doall \
        -prefix ${TEMP_DIR}/smooth.nii.gz \
        ${TEMP_DIR}/volreg.nii.gz

# 7. Bandpass filtering + regression
3dTproject -input ${TEMP_DIR}/smooth.nii.gz \
           -prefix $OUTPUT \
           -mask $ANAT_DIR/mask.nii.gz \
           -polort 2 \
           -passband 0.01 0.1 \
           -ort ${OUT_DIR}/${SUBJECT}_${PE}_bold_${RUN}_motion.1D

# Cleanup
rm -rf $TEMP_DIR

echo "Done: $OUTPUT"
EOF

chmod +x preprocess_simple.sh
```

#### Run Simplified Version

```bash
# Process one run
bash preprocess_simple.sh m6 1 u

# Process all runs for m6
for pe in u d; do
    for run in {1..8}; do
        bash preprocess_simple.sh m6 $run $pe
    done
done
```

**Note:** This is simplified - missing distortion correction and some QC steps.

---

## File Naming Reference

### Input Files (Raw BOLD)

```
raw_bold/m6/
├── BOLD_up_1.nii.gz       # As downloaded
├── BOLD_up_2.nii.gz
...
├── BOLD_down_1.nii.gz
...
├── SEEPI_up.nii.gz
└── SEEPI_down.nii.gz
```

### Expected by rs_MASTER.sh (may vary)

Check the script - it might expect:
- `BOLD_u_1.nii.gz` (short PE naming)
- OR `BOLD_up_1.nii.gz` (your current naming)

**Solution:** Create symlinks if names don't match

### Output Files (Preprocessed)

```
preprocessed/m6/
├── errts.m6_u_bold_1.tproject.nii.gz   # Preprocessed 4D BOLD
├── m6_u_bold_1.mean.nii.gz             # Mean functional
├── m6_u_bold_1_motion.1D               # Motion parameters
...
```

**These names are REQUIRED for registration_MASTER.sh!**

---

## Batch Processing All Subjects

### Create Subject-Specific Scripts

```bash
cd /work01/.../local/fmri/local

# For each subject, create a script
for SUBJ in m6 m7 m8 m9 m10 m11 m12 m14 m15 m16 m17 m18 m19 m20 m21 m22 m23 m24 m25 m26 m27 m28 m29 m30 m31 m32; do
    # Copy template
    cp /work02/.../marmoset_connectivity/rs_MASTER.sh rs_MASTER_${SUBJ}.sh

    # Edit automatically (or manually)
    sed -i "s/set monkey = ()/set monkey = (${SUBJ})/" rs_MASTER_${SUBJ}.sh
    sed -i "s|set apth = |set apth = /work01/.../marmoset_registration/raw_bold|" rs_MASTER_${SUBJ}.sh
    # ... etc for other paths
done
```

### Submit as Array Job

```bash
cat > submit_preprocessing_array.sh << 'EOFJOB'
#!/bin/bash
#SBATCH --job-name=marmoset_preproc
#SBATCH --array=0-26
#SBATCH --time=4:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --output=logs/preproc_%A_%a.log

# Load modules
module load afni/20.3.02
module load fsl/6.0.4

# Subject array
SUBJECTS=(m6 m7 m8 m9 m10 m11 m12 m14 m15 m16 m17 m18 m19 m20 m21 m22 m23 m24 m25 m26 m27 m28 m29 m30 m31 m32)
SUBJ=${SUBJECTS[$SLURM_ARRAY_TASK_ID]}

# Run preprocessing
cd /work01/.../local/fmri/local
tcsh -xef rs_MASTER_${SUBJ}.sh
EOFJOB

sbatch submit_preprocessing_array.sh
```

---

## What You Actually Need to Do

### Minimum Steps:

1. **Check rs_MASTER.sh structure**
   ```bash
   head -50 /work02/.../marmoset_connectivity/rs_MASTER.sh
   ```

   See what variables need to be set

2. **Create one test script for m6**
   ```bash
   cp rs_MASTER.sh rs_MASTER_m6.sh
   nano rs_MASTER_m6.sh  # Edit paths
   ```

3. **Fix file naming if needed**
   ```bash
   cd raw_bold/m6
   # Create symlinks if rs_MASTER expects different names
   ```

4. **Run test**
   ```bash
   tcsh -xef rs_MASTER_m6.sh 2>&1 | tee preproc_m6.log
   ```

5. **Verify outputs**
   ```bash
   ls preprocessed/m6/errts.*.nii.gz
   ```

6. **If successful, repeat for all subjects**

---

## Summary

**The BOLD data preprocessing must be done with `rs_MASTER.sh` or a simplified equivalent.**

**You cannot skip this step** - the registration script expects:
- `errts.{subject}_{pe}_bold_{run}.tproject.nii.gz`
- `{subject}_{pe}_bold_{run}.mean.nii.gz`

**Most practical approach:**
1. Use existing `rs_MASTER.sh`
2. Edit it for each subject
3. Run manually or as batch job
4. Then proceed to registration

**After preprocessing completes**, you can run:
```bash
bash run_registration.sh m6
```

See `PREPROCESSING_GUIDE.md` for detailed technical explanation of what each preprocessing step does.
