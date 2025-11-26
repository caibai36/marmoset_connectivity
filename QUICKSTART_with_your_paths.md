# Quick Start Guide - Your Actual Paths

## ✅ What You Have

- **Downsampled MBM templates (0.5mm):** `/data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1_0.5mm/`
- **Raw NIH data:** `/data02/share/bin-wu/data/marmoset/brain/nih_uwo/nih/NIH-data/`
- **Working directory:** `/work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration`

## 🚀 Quick Start (3 Steps)

### Step 1: Setup Directories and Copy Data

```bash
# Run the automated setup
cd /path/to/marmoset_connectivity
bash setup_directories_and_data.sh
```

This will:
- Create directory structure in `/work01/.../marmoset_registration/`
- Copy all anatomical files (InplaneT2.nii.gz, mask.nii.gz) for 27 subjects
- Verify template files exist
- Create README and status checker

### Step 2: Add Preprocessed BOLD Data

You need to run `rs_MASTER.sh` first (if not done) and place outputs in:
```
/work01/.../marmoset_registration/preprocessed/
```

Required files for each subject/run:
```
preprocessed/errts.m6_u_bold_1.tproject.nii.gz    # Preprocessed 4D BOLD
preprocessed/m6_u_bold_1.mean.nii.gz              # Mean functional
preprocessed/errts.m6_d_bold_1.tproject.nii.gz    # Down phase encoding
preprocessed/m6_d_bold_1.mean.nii.gz
... (all runs for all subjects)
```

### Step 3: Run Registration

```bash
# Copy the updated registration script
cd /work01/.../marmoset_registration
cp /path/to/marmoset_connectivity/registration_MASTER_UPDATED.sh ./

# Edit if needed (paths are already set for your data)
nano registration_MASTER_UPDATED.sh

# Run registration
tcsh -xef registration_MASTER_UPDATED.sh 2>&1 | tee logs/registration.log
```

---

## 📋 Detailed File Paths Reference

### Template Files (0.5mm downsampled)
```bash
BASE: /data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1_0.5mm/

# Main template
template_T2w_brain_0.5mm.nii.gz

# Tissue masks
segmentation_three_types_prob_1_gray_0.5mm.nii.gz    # Gray matter
segmentation_three_types_prob_2_white_0.5mm.nii.gz   # White matter
segmentation_three_types_prob_3_csf_0.5mm.nii.gz     # CSF

# Atlases (for ROI extraction)
atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz               # Cortical parcellation
atlas_MBM_subcortical_beta_0.5mm.nii.gz              # Subcortical structures
```

### Working Directory Structure
```bash
/work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration/
├── preprocessed/          # INPUT: From rs_MASTER.sh
│   ├── errts.m6_u_bold_1.tproject.nii.gz
│   ├── m6_u_bold_1.mean.nii.gz
│   └── ...
├── anatomical/            # READY: Copied by setup script
│   ├── m6/
│   │   ├── InplaneT2.nii.gz
│   │   └── mask.nii.gz
│   ├── m7/
│   └── ...
├── template_space/        # OUTPUT: Intermediate files
├── correlation/           # OUTPUT: Final connectivity-ready files
│   ├── m6_u_bold_1_to_template_0.5mm_masked_gm.nii.gz
│   ├── m6_u_bold_1_nui_regressors.1D
│   └── ...
├── temp/                  # OUTPUT: Temporary (can be deleted)
├── roi_masks/             # OUTPUT: From STAGE1
└── logs/                  # Logs
```

---

## 🔧 Configuration in Scripts

### registration_MASTER_UPDATED.sh

Key variables (already set):
```tcsh
set monkey = (m6)  # Test with one, then expand to all
set run = (1 2 3 4 5 6 7 8)
set pe = (u d)

set raw_data_dir = /data02/share/bin-wu/data/marmoset/brain/nih_uwo/nih/NIH-data
set mskpth = /data02/.../MBM_v3.0.1_0.5mm
set work_base = /work01/.../marmoset_registration
```

### File Naming Convention

**Input (preprocessed):**
- `errts.{monkey}_{pe}_bold_{run}.tproject.nii.gz`
- `{monkey}_{pe}_bold_{run}.mean.nii.gz`

**Output (template space):**
- `{monkey}_{pe}_bold_{run}_to_template_0.5mm_masked_gm.nii.gz`
- `{monkey}_{pe}_bold_{run}_nui_regressors.1D`

**Example:**
- Input: `errts.m6_u_bold_1.tproject.nii.gz`
- Output: `m6_u_bold_1_to_template_0.5mm_masked_gm.nii.gz`

---

## 📊 NIH Subjects (27 total)

```
m6  (sub-06, 71mo)    m17 (sub-17, 36mo)    m27 (sub-27, 115mo)
m7  (sub-07, 24mo)    m18 (sub-18, 44mo)    m28 (sub-28, 75mo)
m8  (sub-08, 41mo)    m19 (sub-19, 49mo)    m29 (sub-29, 78mo)
m9  (sub-09, 77mo)    m20 (sub-20, 40mo)    m30 (sub-30, 36mo)
m10 (sub-10, 23mo)    m21 (sub-21, 95mo)    m31 (sub-31, 77mo)
m11 (sub-11, 32mo)    m22 (sub-22, 36mo)    m32 (sub-32, 78mo)
m12 (sub-12, 27mo)    m23 (sub-23, 22mo)
m14 (sub-14, 65mo)    m24 (sub-24, 35mo)
m15 (sub-15, 31mo)    m25 (sub-25, 63mo)
m16 (sub-16, 59mo)    m26 (sub-26, 40mo)
```

**Note:** sub-13 (m13) is missing from the dataset

---

## ⚡ Fast Track (If You Already Have Preprocessed Data)

```bash
# 1. Setup (one-time)
bash setup_directories_and_data.sh

# 2. Copy your preprocessed data
cp /path/to/your/preprocessed/errts.*.nii.gz /work01/.../marmoset_registration/preprocessed/
cp /path/to/your/preprocessed/*mean.nii.gz /work01/.../marmoset_registration/preprocessed/

# 3. Test with one subject
cd /work01/.../marmoset_registration
# Edit registration_MASTER_UPDATED.sh: set monkey = (m6)
tcsh -xef registration_MASTER_UPDATED.sh

# 4. Verify output
ls -lh correlation/m6_*_to_template_0.5mm_masked_gm.nii.gz

# 5. If successful, run all subjects
# Edit: set monkey = (m6 m7 m8 ... m32)
tcsh -xef registration_MASTER_UPDATED.sh 2>&1 | tee logs/registration_all.log
```

---

## 🐛 Troubleshooting

### Check Status
```bash
cd /work01/.../marmoset_registration
bash check_status.sh
```

### Common Issues

**Issue:** "Preprocessed BOLD not found"
```bash
# Check file naming
ls preprocessed/errts.m6_*.nii.gz
ls preprocessed/m6_*mean.nii.gz

# Files must match exact naming pattern
# Should be: errts.m6_u_bold_1.tproject.nii.gz (NOT errts_m6_u_bold_1.nii.gz)
```

**Issue:** "Template file not found"
```bash
# Verify template directory
ls -lh /data02/.../MBM_v3.0.1_0.5mm/template_T2w_brain_0.5mm.nii.gz
ls -lh /data02/.../MBM_v3.0.1_0.5mm/segmentation_three_types_prob_*.nii.gz
```

**Issue:** "Cannot write to directory"
```bash
# Check permissions
ls -ld /work01/.../marmoset_registration
# Make sure you own the directory
```

---

## 📈 Expected Processing Time

Per subject (8 runs × 2 phase encodings = 16 files):
- **BOLD → T2:** ~2 min per run = ~32 min
- **T2 → Template (ANTs):** ~20 min (once per subject)
- **Total:** ~50 min per subject

**All 27 subjects:** ~22 hours

**Recommendation:** Run on compute cluster with parallel jobs

---

## 📁 Final Output

After successful registration, you'll have:

```bash
correlation/
├── m6_u_bold_1_to_template_0.5mm_masked_gm.nii.gz  # Ready for ROI analysis
├── m6_u_bold_1_nui_regressors.1D
├── m6_u_bold_2_to_template_0.5mm_masked_gm.nii.gz
├── m6_u_bold_2_nui_regressors.1D
...
├── m32_d_bold_8_to_template_0.5mm_masked_gm.nii.gz
└── m32_d_bold_8_nui_regressors.1D
```

**Total expected:** 27 subjects × 16 files = 432 files

These files are ready for **STAGE 3** (ROI analysis)!

---

## 🎯 Next Steps After Registration

1. **Create Vocalization ROIs:**
   ```bash
   bash STAGE1_create_marmoset_vocalization_ROIs_UPDATED.sh
   # Then edit STAGE1b script with atlas labels
   ```

2. **Extract ROI Time Series:**
   ```bash
   python STAGE4_extract_ROI_timeseries.py
   ```

3. **Compute Connectivity:**
   ```bash
   python STAGE5_compute_connectivity.py
   ```

4. **Developmental Analysis:**
   ```bash
   python STAGE6_developmental_analysis.py
   ```

5. **Cross-Species Comparison:**
   ```bash
   python STAGE7_cross_species_comparison.py
   ```

---

**All scripts are ready with your actual paths!** 🎉
