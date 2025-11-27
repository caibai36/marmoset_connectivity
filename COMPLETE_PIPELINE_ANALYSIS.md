# Complete Marmoset Connectivity Pipeline Analysis
## Original Codebase Documentation

**Date:** 2025-11-27
**Purpose:** Comprehensive analysis of the original marmoset_connectivity preprocessing workflows

---

## Table of Contents

1. [Original Preprocessing Pipeline](#1-original-preprocessing-pipeline)
2. [Registration Workflow](#2-registration-workflow)
3. [ROI Extraction Methods](#3-roi-extraction-methods)
4. [Connectivity Analysis Pipeline](#4-connectivity-analysis-pipeline)
5. [Marmoset-Specific Considerations](#5-marmoset-specific-considerations)
6. [Key Parameters Summary](#6-key-parameters-summary)
7. [Differences from Human fMRI Processing](#7-differences-from-human-fmri-processing)

---

## 1. Original Preprocessing Pipeline

### Main Script: `rs_MASTER.sh`

**Language:** tcsh (NOT bash)
**Purpose:** Preprocesses resting-state fMRI data for marmoset subjects

### Complete Processing Steps (in order):

#### Step 1: Volume Removal (Line 99-104)
```tcsh
3dTcat -prefix pb00.${m}_${p}_bold_${r}.tcat \
       ${apth}/${m}_rest-${p}_bold_${r}.nii.gz'[10..$]'
```
- **Removes first 10 volumes** for steady-state stabilization
- Standard practice for fMRI to allow magnetization to reach equilibrium

#### Step 2: Outlier Detection (Line 109-115)
```tcsh
3dToutcount -automask -fraction -polort 5 -legendre \
            pb00.${m}_${p}_bold_${r}.tcat+orig \
            > outcount.${m}_${p}_bold_${r}.1D
```
- Computes outlier fraction for each volume
- Used for quality control
- Polort 5 = 5th order polynomial detrending

#### Step 3: Despiking (Line 118-121)
```tcsh
3dDespike -NEW -nomask \
          -prefix pb01.${m}_${p}_bold_${r}.despike \
          pb00.${m}_${p}_bold_${r}.tcat+orig
```
- **Removes temporal spikes** from BOLD signal
- -NEW: Uses newer L1 algorithm (more robust)
- Critical for marmosets (small movements create large signal changes)

#### Step 4: Slice Timing Correction (Line 123-126)
```tcsh
3dTshift -tzero 0 -quintic \
         -prefix pb02.${m}_${p}_bold_${r}.tshift \
         pb01.${m}_${p}_bold_${r}.despike+orig
```
- **Aligns slice acquisition times**
- -tzero 0: Align to first slice
- -quintic: 5th order polynomial interpolation (high quality)

#### Step 5: Motion Correction (Line 136-148)
```tcsh
3dvolreg -verbose -zpad 1 \
         -base ${m}_rest-up_bold_1_middle_vol.nii.gz \
         -1Dfile dfile.${m}_${p}_bold_${r}.1D \
         -prefix pb03.${m}_${p}_bold_${r}.volreg.nii.gz \
         -cubic pb02.${m}_${p}_bold_${r}.tshift+orig
```
- **Registers all volumes to reference volume**
- Reference: Middle volume of "up" phase encoding, run 1
- -cubic: Cubic interpolation for high-quality registration
- Outputs: Motion parameters in dfile.*.1D

#### Step 6: Phase Encoding Correction (Line 151-163)
```tcsh
# Only if pe_correct = "yes"
applytopup --imain=pb03.${m}_up_bold_${r}.volreg.nii.gz \
           --topup=${temp_dir}/${m}_bold_${r}_topup_${a} \
           --datain=${acqpth}/acqparams_${a}.txt \
           --method=jac --inindex=1 \
           --out=${temp_dir}/${m}_bold_${r}_rest-pec_up.nii.gz
```
- **Corrects EPI distortion** using FSL TOPUP
- Requires: Up/down phase encoding images (SEEPI files)
- NIH data: Uses acqparams_1_0_0.txt (readout time = 0.028673s)
- UWO data: No correction available

#### Step 7: Spatial Smoothing (Line 178-181)
```tcsh
3dmerge -1blur_fwhm ${blur} -doall \
        -prefix pb04.${m}_bold_${r}_${p}.blur \
        ${temp_dir}/${m}_bold_${r}_rest-pec_${p}.nii.gz
```
- **Spatial Gaussian blur: 1.5mm FWHM**
- CRITICAL DIFFERENCE from humans (typically 4-8mm)
- Marmoset-specific due to small brain size

#### Step 8: Motion Parameter Preparation (Line 183-196)
```tcsh
# Demean motion parameters
1d_tool.py -infile dfile.${m}_${p}_bold_${r}_est.1D \
           -set_nruns 1 -demean \
           -write ${m}_${p}_bold_${r}_motion_demean.1D

# Calculate derivatives
1d_tool.py -infile dfile.${m}_${p}_bold_${r}_est.1D \
           -set_nruns 1 -derivative -demean \
           -write motion_deriv_${m}_${p}_bold_${r}.1D

# Create censor file (>0.5mm motion)
1d_tool.py -infile dfile.${m}_${p}_bold_${r}_est.1D \
           -set_nruns 1 -show_censor_count \
           -censor_prev_TR -censor_motion .5 \
           motion_${m}_${p}_bold_${r}
```
- Prepares 12 motion regressors (6 motion + 6 derivatives)
- Motion threshold: 0.5mm (stricter than human typical 1mm)

#### Step 9: Bandpass Filter Preparation (Line 198-201)
```tcsh
1dBport -nodata ${tr_counts} ${tr} \
        -band 0.01 0.1 -invert -nozero \
        > bandpass_rall_${m}_${p}_bold_${r}.1D
```
- Creates bandpass filter: **0.01 - 0.1 Hz**
- Standard resting-state frequency band
- -invert: Creates regressors for REMOVAL (not retention)

#### Step 10: Regression Analysis (Line 206-238)
```tcsh
3dDeconvolve -input pb04.${m}_bold_${r}_${p}.blur+orig.HEAD \
    -censor motion_${m}_${p}_bold_${r}_censor.1D \
    -ortvec bandpass_rall_${m}_${p}_bold_${r}.1D bandpass \
    -polort 5 \
    -num_stimts 12 \
    -stim_file 1-6 ${m}_${p}_bold_${r}_motion_demean.1D'[0-5]' \
    -stim_file 7-12 motion_deriv_${m}_${p}_bold_${r}.1D'[0-5]' \
    -x1D ${m}_${p}_bold_${r}.X.xmat.1D \
    -errts errts.${m}_${p}_bold_${r}

# Then project out nuisance regressors
3dTproject -polort 0 \
    -input pb04.${m}_bold_${r}_${p}.blur+orig.HEAD \
    -censor motion_${m}_${p}_bold_${r}_censor.1D -cenmode ZERO \
    -ort ${m}_${p}_bold_${r}.X.nocensor.xmat.1D \
    -prefix errts.${m}_${p}_bold_${r}.tproject
```

**Regressors removed:**
1. Motion: 6 parameters (roll, pitch, yaw, dS, dL, dP)
2. Motion derivatives: 6 parameters
3. Bandpass: Frequencies outside 0.01-0.1 Hz
4. Polynomial: 5th order (linear + quadratic + cubic + 4th + 5th)
5. Motion censoring: Volumes with >0.5mm displacement

#### Step 11: Create Mean Image (Line 240-242)
```tcsh
3dTstat -prefix ${output_dir}/${m}_${p}_bold_${r}.mean.nii.gz \
        ${temp_dir}/${m}_bold_${r}_rest-pec_${p}.nii.gz
```
- Mean functional image for registration

### Final Output
```
errts.${subject}_${phase}_bold_${run}.tproject.nii.gz
${subject}_${phase}_bold_${run}.mean.nii.gz
```

---

## 2. Registration Workflow

### Main Script: `registration_MASTER.sh` (original) and `registration_MASTER_UPDATED.sh` (updated)

### Two-Stage Registration Process

#### Stage 1: BOLD → T2 (Same Subject)
**Tool:** FSL FLIRT (linear registration)

```tcsh
# Step 1: Register mean functional to T2
flirt -searchrx -360 360 -searchry -360 360 -searchrz -360 360 \
      -in ${m}_${p}_bold_${r}.mean.nii.gz \
      -ref ${anat_pth}/${m}_InplaneT2.nii.gz \
      -out ${temp_dir}/${m}_${p}_bold_${r}.mean_to_t2.nii.gz \
      -omat ${temp_dir}/${m}_${p}_bold_${r}.mean_to_t2.mat
```
- Full 360° search range (exhaustive search)
- Outputs transformation matrix (.mat file)

```tcsh
# Step 2: Apply transform to preprocessed BOLD
flirt -in errts.${m}_${p}_bold_${r}.tproject.nii.gz \
      -ref ${anat_pth}/${m}_InplaneT2.nii.gz \
      -applyxfm -init ${temp_dir}/${m}_${p}_bold_${r}.mean_to_t2.mat \
      -out ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_t2.nii.gz \
      -interp trilinear
```
- Applies same transform to 4D preprocessed data
- Trilinear interpolation

#### Stage 2: T2 → MBM Template (Cross-Subject)
**Tool:** ANTs SyNQuick (nonlinear registration)

```tcsh
# Step 1: Skull-strip T2
3dcalc -a ${anat_pth}/${m}_InplaneT2.nii.gz \
       -b ${temp_dir}/${m}_mask_to_t2_binary.nii.gz \
       -expr '(a*b)' \
       -prefix ${temp_dir}/${m}_InplaneT2_masked.nii.gz
```

```tcsh
# Step 2: Register T2 to MBM template (0.5mm resolution)
antsRegistrationSyNQuick.sh -d 3 \
    -f ${mskpth}/template_T2w_brain_0.5mm.nii.gz \
    -m ${temp_dir}/${m}_InplaneT2_masked.nii.gz \
    -o ${temp_dir}/${m}_t2_to_template_0.5mm_
```

**Outputs:**
- Affine transform: `*_0GenericAffine.mat`
- Nonlinear warp: `*_1Warp.nii.gz`
- Warped T2: `*_Warped.nii.gz`

**This is the SLOW STEP:** 10-30 minutes per subject

```tcsh
# Step 3: Apply combined transforms to BOLD
antsApplyTransforms -e 3 \
    -i ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_t2.nii.gz \
    -r ${temp_dir}/${m}_t2_to_template_0.5mm_Warped.nii.gz \
    -o ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_template.nii.gz \
    -t ${temp_dir}/${m}_t2_to_template_0.5mm_1Warp.nii.gz \
    -t ${temp_dir}/${m}_t2_to_template_0.5mm_0GenericAffine.mat
```
- Applies warp then affine (order matters!)
- Results in template-space BOLD data

#### Stage 3: Gray Matter Masking
```tcsh
3dcalc -a ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_template.nii.gz \
       -b ${mskpth}/segmentation_three_types_prob_1_gray_0.5mm.nii.gz \
       -expr '(a*b)' \
       -prefix ${corrpth}/${m}_${p}_bold_${r}_to_template_0.5mm_masked_gm.nii.gz
```

#### Stage 4: Nuisance Regressors from Template Space
```tcsh
# White matter regressor
3dmaskave -quiet \
    -mask ${mskpth}/segmentation_three_types_prob_2_white_0.5mm.nii.gz \
    ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_template.nii.gz \
    > ${corrpth}/${m}_${p}_bold_${r}_wm_nui_regressor.1D

# CSF regressor
3dmaskave -quiet \
    -mask ${mskpth}/segmentation_three_types_prob_3_csf_0.5mm.nii.gz \
    ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_template.nii.gz \
    > ${corrpth}/${m}_${p}_bold_${r}_csf_nui_regressor.1D

# Combine
paste ${corrpth}/${m}_${p}_bold_${r}_wm_nui_regressor.1D \
      ${corrpth}/${m}_${p}_bold_${r}_csf_nui_regressor.1D \
      > ${corrpth}/${m}_${p}_bold_${r}_nui_regressors.1D
```

### Templates Used

#### MBM v3.0.1 (Marmoset Brain Mapping)
**Source:** https://marmosetbrainmapping.org/atlas.html#v3

**Original Resolution:** ~0.15mm isotropic
**Downsampled for processing:** 0.5mm isotropic

**Required Files:**
```
template_T2w_brain_0.5mm.nii.gz              # T2 template (skull-stripped)
segmentation_three_types_prob_1_gray_0.5mm.nii.gz   # Gray matter mask
segmentation_three_types_prob_2_white_0.5mm.nii.gz  # White matter mask
segmentation_three_types_prob_3_csf_0.5mm.nii.gz    # CSF mask
atlas_MBM_cortex_vPaxinos.nii.gz             # Cortical parcellation
atlas_MBM_subcortical_beta.nii.gz            # Subcortical structures
```

**Downsampling Command:**
```bash
3dresample -dxyz 0.5 0.5 0.5 \
           -input template_T2w_brain.nii.gz \
           -prefix template_T2w_brain_0.5mm.nii.gz
```

---

## 3. ROI Extraction Methods

### Original Method: Voxel-wise Correlation Maps

**Script:** `correlation_MASTER.sh`

```tcsh
3dTcorrMap -ort ${m}_${p}_${r}_nui_regressors.1D \
           -input ${m}_${p}_${r}_to_template_errts_.5iso_masked_gm.nii.gz \
           -mask ${mskpth}/gray_template_.5.nii \
           -Corrmap ${m}_${p}_${r}_corrmap.nii.gz
```

**Output:** Each voxel becomes a "seed" with its own correlation map
- Results in HUGE file: [n_voxels × n_voxels] correlation matrix
- Requires splitting: `split_volume_MASTER.m` (MATLAB)

### Vocalization Network ROI Approach

**Script:** `STAGE1_create_marmoset_vocalization_ROIs.sh`

#### Neuroanatomical Basis

**Based on marmoset vocalization neuroscience:**
- Takahashi et al. (2015, 2017) - Vocal development
- Eliades & Wang (2008) - Neural substrates
- Miller et al. (2015) - Phee call production
- Petkov & Jarvis (2012) - Cross-species homology

#### ROI Definitions from MBM Atlas

**1. Vocal Motor System**
- Motor cortex (Area 4) - Laryngeal control
- Premotor cortex (Area 6, SMA) - Vocalization planning
- Ventral PFC (Area 45) - Sequencing (homolog to Broca's)

**2. Limbic System**
- Anterior cingulate cortex (ACC) - Call initiation drive
- Amygdala - Emotional valence
- Periaqueductal gray (PAG) - Innate vocalization (if available)
- Nucleus accumbens - Social motivation
- Thalamus (MD, VA) - Cortical relay

**3. Auditory-Vocal Integration**
- Primary auditory cortex (A1)
- Auditory belt regions (R, RT, CM, CL)
- Superior temporal cortex

**4. Basal Ganglia**
- Caudate - Call sequencing
- Putamen - Motor execution
- Pallidum - Timing and gating

#### ROI Extraction Process

```bash
# Example: Extract motor cortex ROI
3dcalc -a ${CORTICAL_ATLAS} \
       -expr 'amongst(a,LABEL1,LABEL2,LABEL3)' \
       -prefix bilateral_motor_cortex.nii.gz
```

**NOTE:** Actual label numbers must be determined from:
- `atlas_MBM_cortex_vPaxinos.txt` (cortical labels)
- `atlas_MBM_subcortical_beta.txt` (subcortical labels)

### Atlas Parcellations Actually Used

**Cortical:** Paxinos parcellation (108 cortical areas)
**Subcortical:** Subcortical beta version (amygdala, thalamus, striatum, etc.)

**No surface-based analysis** - volumetric only

---

## 4. Connectivity/Analysis Pipeline

### Time Series Extraction

**Script:** `STAGE4_extract_ROI_timeseries.py`

```python
def extract_roi_timeseries(bold_file, roi_mask_file):
    bold_data = nib.load(bold_file).get_fdata()  # [x, y, z, time]
    roi_mask = nib.load(roi_mask_file).get_fdata() > 0
    
    # Extract voxels in ROI
    n_timepoints = bold_data.shape[3]
    bold_2d = bold_data.reshape(-1, n_timepoints)
    roi_timeseries = bold_2d[roi_mask.flatten(), :]
    
    # Mean across voxels
    mean_timeseries = np.mean(roi_timeseries, axis=0)
    return mean_timeseries  # [n_timepoints,]
```

**Output per subject:**
```
sub-06_bilateral_motor_cortex.txt     # 1D time series
sub-06_all_rois.txt                   # [timepoints × ROIs] matrix
```

### Connectivity Computation

**Script:** `STAGE5_compute_connectivity.py`

```python
# Pearson correlation between all ROI pairs
corr_matrix = np.corrcoef(timeseries_matrix.T)  # [n_rois, n_rois]

# Fisher Z-transform for statistics
z_matrix = np.arctanh(corr_matrix)
```

**Output per subject:**
```
sub-06_corr.npy         # Correlation matrix
sub-06_fisher_z.npy     # Z-transformed (for stats)
sub-06_corr.csv         # Human-readable
```

### Developmental Analysis

**Script:** `STAGE6_developmental_analysis.py`

**Analyses:**
1. Overall connectivity vs. age correlation
2. Edge-wise development (which connections change?)
3. Developmental phase comparison
4. Network variability across ages

**Statistical Tests:**
- Pearson correlation (connectivity vs. age)
- Linear/logarithmic/exponential model fitting
- Phase-wise ANOVA

### Group-Level Analysis

**Script:** `ttest_MASTER_UWOandNIH_group.sh`

```tcsh
# Group-level connectivity comparison
# (Details minimal in provided code)
```

### Cross-Species Comparison

**Script:** `STAGE7_cross_species_comparison.py`

**Compares:**
- Marmoset vocalization network → Human speech/language network
- Developmental timelines (marmoset months → human years)
- Conserved vs. species-specific connectivity patterns

---

## 5. Marmoset-Specific Considerations

### Brain Size Differences

**Marmoset Brain:**
- Volume: ~7-8 cm³
- Weight: ~8 grams
- Much smaller than human brain (~1350 cm³, ~1400 grams)

**Human Brain:**
- Volume: ~1200-1400 cm³
- Weight: ~1300-1400 grams

**Ratio:** Human brain is ~175× larger by volume

### Template Resolution

**Standard Human fMRI:** 2-3mm isotropic
**Marmoset fMRI:** 0.5mm isotropic (THIS CODEBASE)

**Why 0.5mm?**
- Original MBM template: ~0.15mm
- Downsampled to 0.5mm for computational efficiency
- Still MUCH higher resolution than human standard
- Necessary due to small brain structures

**Voxel Volume Comparison:**
- Human 2mm: 8 mm³
- Marmoset 0.5mm: 0.125 mm³
- Human voxel is 64× larger!

### Special Smoothing Kernels

**Marmoset:** 1.5mm FWHM
**Human:** 4-8mm FWHM (typical)

**Calculation:**
```
Smoothing as % of brain size:
Marmoset: 1.5mm / 30mm diameter ≈ 5%
Human:    6mm / 150mm diameter ≈ 4%
```
Roughly proportional to brain size!

### TR Differences

**NIH Data:** TR = 2s (or up to 6s for some subjects)
**UWO Data:** TR = 1.5s
**Human Standard:** TR = 2-3s

Marmoset TRs are comparable to human, despite smaller brain.

### Motion Thresholds

**Marmoset:** 0.5mm censoring threshold
**Human:** 0.5-1mm censoring threshold

Stricter threshold makes sense given smaller brain (same motion = larger % of brain)

### Phase Encoding Correction

**NIH Data:**
- Up/down phase encoding acquired
- TOPUP distortion correction ATTEMPTED
- Readout time: 0.028673s (from acqparams_1_0_0.txt)
- Configuration: updown.cnf (9-iteration progressive warping)

**UWO Data:**
- Only "up" phase encoding
- No distortion correction available

**Human Standard:**
- Often uses TOPUP or gradient unwarping
- Similar approach but larger FOV

### Coordinate System Issues

**Script:** `coordinate_correction_for_raw_files/MBC_Coordinate_fix.sh`

**Problem:** NIH 7T scanner has non-standard gradient polarities
- Bruker scanner doesn't have sphinx position for NHP
- Requires sform matrix correction

**Fix:** Flip certain axes in NIfTI header
```bash
# Flips srow_x and srow_z signs
arr[0,0]=$(echo $srow|cut -d" " -f19 *-1 | bc)
# ... etc
```

**This is MARMOSET-SPECIFIC** - not needed for human data

---

## 6. Key Parameters Summary

### Preprocessing Parameters (from rs_MASTER.sh)

```tcsh
# UNIVERSAL (same for all subjects of same site)
set pe = (up down)          # NIH has both; UWO only up
set bp_l = (0.1)            # Bandpass high frequency
set bp_h = (0.01)           # Bandpass low frequency
set blur = (1.5)            # Spatial smoothing (mm FWHM)
set n_cpu = (8)             # Parallel processing cores
set pe_correct = (no)       # Distortion correction (usually no)
set acpr = (dummy)          # Placeholder for distortion params

# SUBJECT-SPECIFIC (varies per subject)
set monkey = (m6)           # Subject ID
set run = (1 2 3 4)         # Number of runs (CHECK!)
set tr_counts = (348)       # Volumes per run (from fslinfo)
set reg_vol = (174)         # Middle volume (tr_counts/2)
set tr = (6)                # TR in seconds (from fslinfo)

# PATHS (subject-specific)
set apth = /path/to/raw_bold/${m}
set anat_pth = /path/to/anatomical/${m}
set output_dir = /path/to/preprocessed/${m}
```

### Registration Parameters

```tcsh
# Template path
set mskpth = /path/to/MBM_v3.0.1_0.5mm/

# Required template files
template_T2w_brain_0.5mm.nii.gz
segmentation_three_types_prob_1_gray_0.5mm.nii.gz
segmentation_three_types_prob_2_white_0.5mm.nii.gz
segmentation_three_types_prob_3_csf_0.5mm.nii.gz
```

### How to Get Subject-Specific Parameters

**Helper script:** `get_subject_parameters.sh`

```bash
#!/bin/bash
SUBJECT="m6"
RAW_DIR="/path/to/raw_bold/${SUBJECT}"

# Count runs
N_RUNS=$(ls $RAW_DIR/BOLD_up_*.nii.gz | wc -l)

# Get dimensions
TR_COUNTS=$(fslinfo $RAW_DIR/BOLD_up_1.nii.gz | grep "^dim4" | awk '{print $2}')
TR=$(fslinfo $RAW_DIR/BOLD_up_1.nii.gz | grep "^pixdim4" | awk '{print $2}')
REG_VOL=$((TR_COUNTS / 2))

echo "set run = ($(seq -s ' ' 1 $N_RUNS))"
echo "set tr_counts = ($TR_COUNTS)"
echo "set reg_vol = ($REG_VOL)"
echo "set tr = ($TR)"
```

---

## 7. Differences from Human fMRI Processing

### Key Differences Table

| Aspect | Marmoset (This Code) | Human Standard |
|--------|---------------------|----------------|
| **Template Resolution** | 0.5mm isotropic | 2-3mm isotropic |
| **Smoothing FWHM** | 1.5mm | 4-8mm |
| **Brain Volume** | ~8 cm³ | ~1400 cm³ |
| **Voxel Size** | 0.125 mm³ | 8-27 mm³ |
| **Motion Threshold** | 0.5mm | 0.5-1mm |
| **Template** | MBM v3 (T2-based) | MNI152 (T1-based) |
| **Distortion Correction** | Limited (NIH only) | Common (TOPUP/SDC) |
| **Coordinate System** | Needs fixing (Bruker) | Standard (human scanners) |
| **Relative Smoothing** | ~5% of brain | ~4% of brain |
| **Atlas** | Paxinos (volumetric) | AAL/Harvard-Oxford/DK |
| **Surface Analysis** | Not used | Common (FreeSurfer) |
| **Registration Tool** | ANTs (same) | ANTs or FSL |
| **Bandpass** | 0.01-0.1 Hz (same) | 0.01-0.1 Hz |
| **TR** | 1.5-6s | 2-3s |
| **Despiking** | Yes (critical) | Sometimes |

### Why These Differences Exist

**1. Resolution:**
- Marmoset structures are tiny (e.g., amygdala ~50 mm³ vs. human ~1200 mm³)
- Need higher resolution to resolve structures
- Trade-off: Longer scan times, more data

**2. Smoothing:**
- Must be proportional to brain size
- Too much smoothing = lose anatomical specificity
- 1.5mm is ~5% of marmoset brain diameter (similar % as 6mm for human)

**3. Template:**
- MBM designed specifically for marmoset neuroanatomy
- T2-weighted (better gray/white contrast in marmosets)
- Human: MNI152 is T1-weighted standard

**4. Motion:**
- Same absolute threshold (0.5mm) is more stringent for smaller brain
- 0.5mm in marmoset ≈ 10mm equivalent in human (proportionally)

**5. Distortion Correction:**
- Limited availability in marmoset data
- Smaller FOV = less distortion, but still present
- Original study didn't always acquire necessary data

**6. Coordinate System:**
- Bruker scanners (used for marmosets) have non-standard orientations
- Human scanners follow DICOM standard
- Requires manual correction for marmosets

### Similarities with Human Processing

**These steps are IDENTICAL:**
1. Volume removal (first 10 TRs)
2. Despiking algorithm
3. Slice timing correction approach
4. Motion correction strategy
5. Bandpass filtering frequency range (0.01-0.1 Hz)
6. Nuisance regression (motion + WM + CSF)
7. Polynomial detrending (same order)
8. Censoring approach (high-motion volumes)
9. Registration strategy (2-stage: functional→anatomical→template)
10. Connectivity analysis (Pearson correlation)

**The PIPELINE is the same, but PARAMETERS are scaled for marmoset brain size.**

---

## 8. Complete Workflow Summary

### Original Pipeline Execution Order

```
1. rs_MASTER.sh
   Input:  Raw BOLD (BOLD_up_*.nii.gz, BOLD_down_*.nii.gz)
           T2 anatomical (InplaneT2.nii.gz)
           Brain mask (mask.nii.gz)
   Output: errts.*.tproject.nii.gz (preprocessed BOLD)
           *.mean.nii.gz (mean functional)
   Time:   2-3 hours per subject

2. registration_MASTER.sh
   Input:  Preprocessed BOLD (from step 1)
           T2 anatomical
           MBM template (0.5mm)
   Output: *_to_template_0.5mm_masked_gm.nii.gz (template space)
           *_nui_regressors.1D (WM/CSF regressors)
   Time:   1-2 hours per subject (10-30min for T2→template step)

3. correlation_MASTER.sh
   Input:  Template-space BOLD (from step 2)
           Gray matter mask
           Nuisance regressors
   Output: *_corrmap.nii.gz (huge correlation matrix)
   Time:   Variable (hours to days for large datasets)

4. split_volume_MASTER.m (MATLAB)
   Input:  Correlation map (from step 3)
   Output: Individual seed correlation maps
   Time:   Hours

5. ttest_MASTER_UWOandNIH_group.sh
   Input:  Individual correlation maps
   Output: Group-level statistics
   Time:   Variable
```

### Modern Pipeline (STAGE scripts)

```
STAGE 1: Create ROI masks (ONCE)
         STAGE1_create_marmoset_vocalization_ROIs.sh
         Output: ROI masks from MBM atlas

STAGE 2: Preprocess (use rs_MASTER.sh - per subject)
         Output: Preprocessed BOLD

STAGE 3: Register (use registration_MASTER.sh - per subject)
         STAGE3_register_and_prepare_ROI_data.sh
         Output: Template-space data organized

STAGE 4: Extract time series (ALL subjects)
         STAGE4_extract_ROI_timeseries.py
         Output: ROI time series matrices

STAGE 5: Compute connectivity (ALL subjects)
         STAGE5_compute_connectivity.py
         Output: Connectivity matrices

STAGE 6: Developmental analysis (ALL subjects)
         STAGE6_developmental_analysis.py
         Output: Age correlations, trajectories

STAGE 7: Cross-species comparison
         STAGE7_cross_species_comparison.py
         Output: Marmoset-human comparisons
```

---

## 9. Software Versions

From `software_versions.txt`:

```
Platform: macOS Big Sur 11.0.1
AFNI:     Version AFNI_20.3.02 'Vespasian'
FSL:      6.0.4
ANTs:     2.3.5.dev212-g44225
Connectome Workbench: 1.4.2
Python:   3.9.2
```

**All tools are standard neuroimaging packages**
**No marmoset-specific software required** (just marmoset-specific parameters)

---

## 10. Data Structure

### Expected Input Structure

```
/data02/share/bin-wu/data/marmoset/brain/nih_uwo/nih/NIH-data/
├── m6/
│   ├── BOLD_up_1.nii.gz        # Run 1, up phase encoding
│   ├── BOLD_up_2.nii.gz        # Run 2, up phase encoding
│   ├── BOLD_down_1.nii.gz      # Run 1, down phase encoding
│   ├── BOLD_down_2.nii.gz      # Run 2, down phase encoding
│   ├── SEEPI_up.nii.gz         # For distortion correction
│   ├── SEEPI_down.nii.gz
│   ├── InplaneT2.nii.gz        # Anatomical reference
│   └── mask.nii.gz             # Brain mask
├── m7/
└── ...
```

### Preprocessing Output Structure

```
preprocessed/m6/
├── errts.m6_up_bold_1.tproject.nii.gz      # Clean BOLD data
├── errts.m6_up_bold_2.tproject.nii.gz
├── errts.m6_down_bold_1.tproject.nii.gz
├── errts.m6_down_bold_2.tproject.nii.gz
├── m6_up_bold_1.mean.nii.gz                # Mean images
├── m6_up_bold_2.mean.nii.gz
├── m6_down_bold_1.mean.nii.gz
├── m6_down_bold_2.mean.nii.gz
├── m6_up_bold_1_motion.1D                  # Motion parameters
├── m6_up_bold_1.X.xmat.1D                  # Design matrix
└── ...
```

### Template Space Output

```
correlation/
├── m6_up_bold_1_to_template_0.5mm_masked_gm.nii.gz
├── m6_up_bold_1_nui_regressors.1D
└── ...
```

---

## Conclusion

This marmoset connectivity pipeline is a **well-designed, species-appropriate adaptation** of standard human resting-state fMRI preprocessing.

**Key Strengths:**
1. Proper scaling for marmoset brain size (resolution, smoothing)
2. Appropriate motion thresholds
3. High-quality MBM template registration
4. Comprehensive nuisance regression
5. Well-documented developmental focus

**Marmoset-Specific Features:**
1. 0.5mm template resolution (vs. 2-3mm human)
2. 1.5mm smoothing (vs. 4-8mm human)
3. MBM atlas (vs. MNI/AAL human)
4. Coordinate correction for Bruker scanner
5. Vocalization network ROI definitions

**Similar to Human:**
- Same preprocessing STEPS
- Same frequency bands (0.01-0.1 Hz)
- Same motion regression strategy
- Same connectivity computation (Pearson correlation)
- Same statistical approaches

**The pipeline is SPECIES-APPROPRIATE, not fundamentally different from human fMRI.**

