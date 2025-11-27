# Registration Workflow for M6
## Following Original `registration_MASTER.sh` Exactly

---

## Your Actual Data Structure

```bash
Raw anatomical data:
/data02/share/bin-wu/data/marmoset/brain/nih_uwo/nih/NIH-data/m6/
├── InplaneT2.nii.gz      # T2 anatomical
├── mask.nii.gz           # Brain mask
├── BOLD_up_1.nii.gz      # Raw BOLD (4 runs × 2 PE)
├── BOLD_up_2.nii.gz
├── BOLD_up_3.nii.gz
├── BOLD_up_4.nii.gz
├── BOLD_down_1.nii.gz
├── BOLD_down_2.nii.gz
├── BOLD_down_3.nii.gz
├── BOLD_down_4.nii.gz
├── SEEPI_up.nii.gz       # Phase encoding correction (if needed)
└── SEEPI_down.nii.gz

Preprocessed BOLD data (from previous work):
/work01/.../marmoset_registration/preprocessed/m6/
├── errts.m6_up_bold_1.tproject.nii.gz    # 8 preprocessed files
├── errts.m6_up_bold_2.tproject.nii.gz
├── errts.m6_up_bold_3.nii.gz
├── errts.m6_up_bold_4.tproject.nii.gz
├── errts.m6_down_bold_1.tproject.nii.gz
├── errts.m6_down_bold_2.tproject.nii.gz
├── errts.m6_down_bold_3.tproject.nii.gz
└── errts.m6_down_bold_4.tproject.nii.gz
```

---

## Registration Pipeline (Following Original Code)

### **Script 1: BOLD → Template Registration**
**File:** `register_m6_to_template.sh`

**What it does (following `registration_MASTER.sh`):**

1. **BOLD → T2** (FLIRT linear registration)
   - Registers mean BOLD to subject's InplaneT2
   - Full 360° search range
   - Creates transform matrix

2. **T2 → MBM Template** (ANTs nonlinear)
   - Skull-strips T2 using mask
   - Registers to MBM v3.0.1 template (0.5mm)
   - **SLOW: 10-30 minutes**
   - Creates: Affine (.mat) + Warp (.nii.gz)

3. **Apply Transforms to BOLD**
   - Combines both transforms
   - Warps preprocessed BOLD to template space
   - Results in template-space BOLD (0.5mm)

4. **Gray Matter Masking**
   - Masks with MBM gray matter
   - Final output for connectivity analysis

5. **Extract Nuisance Regressors**
   - WM and CSF time series
   - From template space

**Run it:**
```bash
cd /home/user/marmoset_connectivity

# Load modules
module load afni fsl ants

# Run registration
tcsh register_m6_to_template.sh |& tee registration_m6.log
```

**Expected outputs:**
```
correlation/
├── m6_up_bold_1_to_template_0.5mm_masked_gm.nii.gz    # 8 files
├── m6_up_bold_2_to_template_0.5mm_masked_gm.nii.gz
├── m6_up_bold_3_to_template_0.5mm_masked_gm.nii.gz
├── m6_up_bold_4_to_template_0.5mm_masked_gm.nii.gz
├── m6_down_bold_1_to_template_0.5mm_masked_gm.nii.gz
├── m6_down_bold_2_to_template_0.5mm_masked_gm.nii.gz
├── m6_down_bold_3_to_template_0.5mm_masked_gm.nii.gz
├── m6_down_bold_4_to_template_0.5mm_masked_gm.nii.gz
├── m6_up_bold_1_nui_regressors.1D                     # 8 regressor files
└── ...

temp/
├── m6_t2_to_template_0.5mm_0GenericAffine.mat         # Transform files
├── m6_t2_to_template_0.5mm_1Warp.nii.gz
└── m6_t2_to_template_0.5mm_1InverseWarp.nii.gz
```

---

### **Script 2: Template → Native Space** (Optional)
**File:** `template_to_native_m6.sh`

**What it does (following `template_to_native.sh`):**

Uses **inverse transforms** to bring template-space data back to m6's native T2 space.

**Transforms:**
- MBM atlases → m6 native space
- Tissue segmentations → m6 native space
- Vocalization network ROIs → m6 native space
- Template T2 → m6 space (for QC)

**Why you might need this:**
- Visualize ROIs on subject's own anatomy
- Extract anatomical volumes in native space
- Quality check registration accuracy

**Run it:**
```bash
# After registration is complete
tcsh template_to_native_m6.sh |& tee template_to_native_m6.log
```

**Expected outputs:**
```
native_space/m6/
├── atlas_MBM_cortex_vPaxinos_native.nii.gz    # Atlases in m6 space
├── atlas_RikenBMA_cortex_native.nii.gz
├── atlas_MBM_subcortical_native.nii.gz
├── gray_matter_mask_native.nii.gz             # Tissue masks in m6 space
├── white_matter_mask_native.nii.gz
├── csf_mask_native.nii.gz
├── network_1_vocal_motor_native.nii.gz        # ROI networks in m6 space
├── network_2_limbic_native.nii.gz
├── network_3_auditory_native.nii.gz
├── network_4_temporal_native.nii.gz
└── template_T2w_in_native_space.nii.gz       # Template warped to m6 (QC)
```

---

## Key Differences from Original Code

### ✅ **What Matches Original:**
- Uses FSL FLIRT for BOLD→T2 (with full 360° search)
- Uses ANTs SyNQuick for T2→Template
- Same transform order: Warp then Affine
- Same gray matter masking
- Same WM/CSF regressor extraction
- Same 0.5mm template resolution

### 📝 **What's Updated:**
- Uses your actual data paths
- Works with your preprocessed data location
- Creates mean BOLD automatically if needed
- Better error checking
- More verbose logging
- Organized output directories

---

## Step-by-Step Execution

### **Prerequisites:**
```bash
# Check you have modules
module load afni fsl ants

# Verify your data exists
ls /data02/share/bin-wu/data/marmoset/brain/nih_uwo/nih/NIH-data/m6/
ls /work01/.../marmoset_registration/preprocessed/m6/

# Verify MBM template exists
ls /data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1_0.5mm/
```

### **Step 1: Register to Template**
```bash
cd /home/user/marmoset_connectivity
module load afni fsl ants

# Run registration (will take ~1-2 hours for m6)
# Most time is ANTs registration (10-30 min per run)
tcsh register_m6_to_template.sh |& tee logs/registration_m6_$(date +%Y%m%d_%H%M%S).log
```

**Monitor progress:**
- Stage 1 (BOLD→T2): ~1 min per run
- Stage 2 (T2→Template): **10-30 minutes** (only once!)
- Stage 3 (Apply to BOLD): ~2-3 min per run
- Stage 4 (Gray matter mask): ~30 sec per run
- Stage 5 (Regressors): ~30 sec per run

**Total time:** ~1-2 hours for all 8 BOLD runs

### **Step 2: Verify Outputs**
```bash
# Check template-space BOLD (should be 8 files)
ls -lh /work01/.../correlation/*m6*_to_template_0.5mm_masked_gm.nii.gz | wc -l

# Check regressors (should be 8 files)
ls -lh /work01/.../correlation/*m6*_nui_regressors.1D | wc -l

# Check transform files exist
ls -lh /work01/.../temp/m6_t2_to_template_0.5mm_*
```

### **Step 3: Extract ROIs (Template Space)**
```bash
# First, extract vocalization network ROIs from MBM atlas
bash extract_vocalization_ROIs_actual_labels.sh

# Then extract time series from template-space BOLD
# (This is for functional connectivity analysis)
```

### **Step 4: Transform to Native Space (Optional)**
```bash
# If you want ROIs in m6's own anatomy
tcsh template_to_native_m6.sh |& tee logs/template_to_native_m6.log
```

---

## Quality Control

### **Check Registration Quality:**

```bash
# Visualize in AFNI
afni &

# Load:
# 1. Underlay: /data02/.../m6/InplaneT2.nii.gz (native anatomy)
# 2. Overlay: native_space/m6/template_T2w_in_native_space.nii.gz
# Should align well!

# Or in template space:
# 1. Underlay: MBM template_T2w_brain_0.5mm.nii.gz
# 2. Overlay: correlation/m6_up_bold_1_to_template_0.5mm_masked_gm.nii.gz
# Should match template boundaries
```

### **Check Transform Files:**

```bash
# ANTs outputs (critical!)
ls -lh temp/m6_t2_to_template_0.5mm_*

# Should see:
# - *_0GenericAffine.mat        (linear component)
# - *_1Warp.nii.gz              (nonlinear forward)
# - *_1InverseWarp.nii.gz       (nonlinear inverse)
# - *_Warped.nii.gz             (registered T2)
```

### **Verify BOLD Dimensions:**

```bash
# Template-space BOLD should be 0.5mm isotropic
3dinfo correlation/m6_up_bold_1_to_template_0.5mm_masked_gm.nii.gz

# Should show:
# - Voxel dimensions: 0.5 × 0.5 × 0.5 mm
# - Matrix size: ~340 × 200 × 180 (similar to template)
# - Time points: 338 (348 original - 10 removed)
```

---

## Troubleshooting

### **Problem: ANTs registration fails**
```bash
# Check memory
free -h  # Need at least 8-16 GB free

# Check T2 is skull-stripped
3dinfo temp/m6_InplaneT2_masked.nii.gz

# Check template exists
ls /data02/.../MBM_v3.0.1_0.5mm/template_T2w_brain_0.5mm.nii.gz
```

### **Problem: BOLD→T2 alignment poor**
```bash
# Check mean BOLD was created correctly
3dinfo preprocessed/m6/m6_up_bold_1.mean.nii.gz

# Visualize alignment
afni -niml &
# Load: InplaneT2.nii.gz and mean BOLD
```

### **Problem: Output files missing**
```bash
# Check for errors in log
grep -i error logs/registration_m6*.log

# Check disk space
df -h /work01

# Check temp directory
ls -lh temp/
```

---

## Next Steps After Registration

### **For Functional Connectivity Analysis:**
1. Extract time series from template-space BOLD
2. Use ROI masks to get mean signal per region
3. Compute ROI-to-ROI correlations
4. Analyze connectivity matrices

### **For Anatomical Volume Analysis:**
1. Transform atlas to native space (template_to_native)
2. Extract ROI volumes from native T2
3. Measure region sizes
4. Compare with other subjects

### **For Developmental Analysis:**
1. Repeat registration for all subjects (m6-m32)
2. Extract same measures for all ages
3. Plot volume or connectivity vs age
4. Compare marmoset vs human trajectories

---

## Files to Keep vs Delete

### **Keep (Critical):**
- `correlation/*_to_template_0.5mm_masked_gm.nii.gz` (final BOLD)
- `correlation/*_nui_regressors.1D` (nuisance regressors)
- `temp/m6_t2_to_template_0.5mm_*` (transforms - needed for template_to_native)

### **Can Delete After QC:**
- `temp/errts*_to_t2.nii.gz` (intermediate BOLD→T2)
- `temp/errts*_to_template.nii.gz` (pre-masking template BOLD)
- `temp/*mean_to_t2*` (intermediate registration files)
- `temp/*_mask_to_t2*` (intermediate masks)

---

## Summary

**You now have two scripts that follow the original workflow:**

1. **`register_m6_to_template.sh`** - Forward (BOLD → Template)
   - Follows `registration_MASTER.sh` exactly
   - Uses your actual data paths
   - Ready to run

2. **`template_to_native_m6.sh`** - Reverse (Template → Native)
   - Follows `template_to_native.sh` workflow
   - Brings ROIs back to subject space
   - Optional, for visualization/QC

**Both scripts:**
- ✅ Use marmoset-specific parameters (0.5mm template)
- ✅ Follow original code structure
- ✅ Work with your actual data
- ✅ Create proper outputs for connectivity analysis

**Run them when you're ready!** The registration will take 1-2 hours for m6.
