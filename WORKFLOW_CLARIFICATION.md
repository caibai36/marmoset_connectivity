# Workflow Clarification: Functional vs Anatomical Analysis

## Your Question Answered

**Q: "Do we not need those [preprocessing] results in order to do ROI analysis?"**

**A: It depends on WHICH type of ROI analysis:**

---

## Two Different Analyses in Your Study

### 1. FUNCTIONAL CONNECTIVITY ANALYSIS (Primary - Needs Preprocessing!)

**Goal:** Study how brain regions communicate during rest, and how this changes with development

**Pipeline:**
```
Raw BOLD data (348 volumes)
    ↓
[✓ STEP 1: Preprocessing] ← YOU ARE HERE (m6 complete!)
    - Motion correction
    - Temporal filtering
    - Spatial smoothing
    - Nuisance regression
    ↓
Preprocessed BOLD (errts.*.tproject.nii.gz)
    ↓
[STEP 2: Registration to MBM template]
    - BOLD → T2 (FLIRT)
    - T2 → Template (ANTs)
    - Apply transforms
    ↓
Template-space BOLD (*_to_template_0.5mm_masked_gm.nii.gz)
    ↓
[STEP 3: Extract ROI time series]
    - Use MBM atlas ROI masks
    - Average BOLD signal in each ROI
    ↓
ROI time series (N_timepoints × N_ROIs matrix)
    ↓
[STEP 4: Compute connectivity]
    - ROI-to-ROI correlations
    ↓
Connectivity matrix (N_ROIs × N_ROIs)
    ↓
[STEP 5: Developmental analysis]
    - Correlate connectivity with age
    - Compare with human developmental data
```

**For this workflow:**
- ✅ **YES, you NEED preprocessing results!**
- ✅ You need registration (next step)
- ✅ Segmentation from MBM atlas (no surfaces needed)
- ✅ This is your main analysis goal

---

### 2. ANATOMICAL ROI ANALYSIS (Supplementary - Independent!)

**Goal:** Compare brain region volumes between marmosets and humans

**Pipeline:**
```
T2 anatomical image
    ↓
Register T2 → MBM template (ANTs)
    ↓
Extract ROI masks from MBM atlas
    ↓
Calculate volumes of vocalization-related regions
    ↓
Compare with human FreeSurfer volumes
```

**For this workflow:**
- ❌ **NO preprocessing needed** (uses T2 directly)
- ✅ Need T2 registration to template (part of registration_MASTER.sh)
- ✅ Need segmentation only (no surfaces)
- ℹ️ This is supplementary/optional

---

## Segmentation vs Surfaces: What Do You Need?

### For Functional Connectivity Analysis:
**Segmentation: YES** (Required)
- MBM atlas provides ROI labels
- Used to define masks for time series extraction
- Example: "Motor cortex" = voxels with label 42 in atlas

**Surfaces: NO** (Not required, but helpful for visualization)
- Can create pretty brain surface plots
- Not needed for connectivity calculations
- Optional for figures

### For Anatomical Volume Comparison:
**Segmentation: YES** (Required)
- Calculate volume of each ROI
- Example: Motor cortex volume in m6 vs human infant

**Surfaces: NO** (Not required)
- FreeSurfer creates surfaces for humans
- Marmosets: MBM provides volumetric segmentation
- Can compare volumes without surfaces

---

## Comparison with Human T1 Results

Your reference script shows human analysis using:
- **FreeSurfer segmentation** (Desikan-Killiany atlas)
- **Binary ROI masks** for vocalization networks
- **Volumetric analysis** (not surface-based)

For marmosets, equivalent approach:
- **MBM atlas segmentation** (Paxinos parcellation)
- **Binary ROI masks** extracted from atlas
- **Volumetric analysis**

### You Can Compare:
1. **ROI volumes** (marmoset vs human)
2. **Connectivity patterns** (marmoset vs human)
3. **Developmental trajectories** (marmoset vs human)

### You DON'T Need:
- Surface reconstructions for marmosets
- Surface-based analysis
- Cortical thickness (unless you want to add this)

---

## What You Should Do Next

### Immediate Next Steps:

**STEP 1 (✓ COMPLETE for m6):** Preprocessing
- You have: `preprocessed/m6/errts.*.tproject.nii.gz`

**STEP 2 (NEXT):** Registration
```bash
cd /work01/.../local/fmri/local

# Run registration for m6
bash registration_MASTER_UPDATED.sh m6
```

This will create:
- `correlation/m6_up_bold_1_to_template_0.5mm_masked_gm.nii.gz` (and 7 more files)
- These are your preprocessed BOLD in template space
- Ready for ROI time series extraction

**STEP 3:** ROI extraction
- Use MBM atlas to create vocalization network ROI masks
- Extract time series from each ROI

**STEP 4:** Connectivity analysis
- Compute ROI-to-ROI correlations

**STEP 5:** Developmental analysis
- Correlate connectivity with age

---

## Complete Subject Processing Order

For each subject, you need:

1. ✅ **Preprocessing** (rs_MASTER.sh)
   - Input: Raw BOLD
   - Output: Preprocessed BOLD

2. **Registration** (registration_MASTER.sh)
   - Input: Preprocessed BOLD + T2
   - Output: Template-space BOLD + nuisance regressors

3. **ROI time series extraction** (once all subjects registered)
   - Input: Template-space BOLD + ROI masks
   - Output: Time series matrix

4. **Connectivity** (once time series extracted)
   - Input: Time series
   - Output: Connectivity matrices

5. **Development** (once all connectivity computed)
   - Input: Connectivity matrices + age metadata
   - Output: Developmental trajectories

---

## Summary

**Your preprocessing IS successful!**

**You NEED preprocessing results for:**
- ✅ Functional connectivity analysis (your main goal)
- ✅ Studying developmental changes in brain networks

**You DON'T need preprocessing for:**
- ❌ Anatomical volume analysis (optional, uses T2 directly)

**For marmoset-human comparison:**
- ✅ Segmentation is sufficient (MBM atlas for marmosets, FreeSurfer for humans)
- ❌ Surfaces are optional (nice for visualization, not required)

**Next step:** Run registration for m6!

```bash
cd /work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/local/fmri/local
bash registration_MASTER_UPDATED.sh m6
```

This will register your preprocessed BOLD to the MBM template, preparing it for ROI analysis.
