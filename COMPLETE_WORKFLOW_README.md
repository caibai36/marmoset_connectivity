# Complete Marmoset Vocalization Analysis Workflow

## Your Actual Directory Structure

```
/work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/
├── local/fmri/local/                    # ALL SCRIPTS GO HERE
│   ├── setup_directories_and_data.sh    # Step 1: Setup
│   ├── run_preprocessing.sh             # Step 2: Preprocess wrapper
│   ├── run_registration.sh              # Step 3: Registration
│   ├── run_stage1_rois.sh               # Step 4: Create ROIs
│   ├── run_stage4_timeseries.py         # Step 5: Extract timeseries
│   ├── run_stage5_connectivity.py       # Step 6: Connectivity
│   ├── run_stage6_development.py        # Step 7: Development
│   └── run_stage7_comparison.py         # Step 8: Cross-species
│
└── exp/mri/sandbox/marmoset_registration/  # ALL DATA GOES HERE
    ├── config_paths.sh                  # Configuration (auto-created)
    ├── check_status.sh                  # Status checker
    ├── README.txt                       # Instructions
    │
    ├── raw_bold/                        # Linked raw data
    │   ├── m6/
    │   │   ├── BOLD_up_1.nii.gz
    │   │   ├── BOLD_down_1.nii.gz
    │   │   └── ...
    │   ├── m7/
    │   └── ...
    │
    ├── anatomical/                      # Copied anatomical files
    │   ├── m6/
    │   │   ├── InplaneT2.nii.gz
    │   │   └── mask.nii.gz
    │   └── ...
    │
    ├── preprocessed/                    # OUTPUT from Step 2
    │   ├── m6/
    │   │   ├── errts.m6_u_bold_1.tproject.nii.gz
    │   │   ├── m6_u_bold_1.mean.nii.gz
    │   │   └── ...
    │   └── ...
    │
    ├── correlation/                     # OUTPUT from Step 3
    │   ├── m6_u_bold_1_to_template_0.5mm_masked_gm.nii.gz
    │   ├── m6_u_bold_1_nui_regressors.1D
    │   └── ...
    │
    ├── roi_masks/                       # OUTPUT from Step 4
    │   ├── bilateral_motor_cortex.nii.gz
    │   ├── bilateral_auditory.nii.gz
    │   └── ...
    │
    ├── roi_timeseries/                  # OUTPUT from Step 5
    │   └── individual_rois/
    │
    ├── connectivity_matrices/           # OUTPUT from Step 6
    │   └── individual/
    │
    ├── developmental_analysis/          # OUTPUT from Step 7
    │
    ├── cross_species_comparison/        # OUTPUT from Step 8
    │
    ├── logs/                            # All logs
    │   ├── preprocessing_m6.log
    │   ├── registration_m6.log
    │   └── ...
    │
    └── temp/                            # Temporary files
```

---

## Original Data Locations

```
# Raw NIH data
/data02/share/bin-wu/data/marmoset/brain/nih_uwo/nih/NIH-data/
├── m6/
│   ├── BOLD_up_1.nii.gz
│   ├── InplaneT2.nii.gz
│   └── mask.nii.gz
├── m7/
└── ...

# MBM templates (0.5mm downsampled)
/data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1_0.5mm/
├── template_T2w_brain_0.5mm.nii.gz
├── atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz
├── segmentation_three_types_prob_1_gray_0.5mm.nii.gz
└── ...

# Original marmoset_connectivity scripts
/work02/home/bin-wu/workspace/projects/tests/test_fmri/marmoset_connectivity/
├── rs_MASTER.sh
├── registration_MASTER.sh
└── ...
```

---

## Complete Workflow: Step-by-Step

### STEP 0: Initial Setup (One-Time)

```bash
# Go to scripts directory
cd /work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/local/fmri/local

# Copy all scripts from repository
cp /work02/.../marmoset_connectivity/setup_directories_and_data_FINAL.sh ./setup_directories_and_data.sh
cp /work02/.../marmoset_connectivity/run_preprocessing.sh ./
cp /work02/.../marmoset_connectivity/registration_MASTER_UPDATED.sh ./run_registration.sh
# ... etc for all scripts

# Make executable
chmod +x *.sh

# Run setup
bash setup_directories_and_data.sh
```

**This creates:**
- Directory structure in `exp/mri/sandbox/marmoset_registration/`
- Links raw BOLD data
- Copies anatomical files
- Creates `config_paths.sh`

**Check status:**
```bash
cd ../../exp/mri/sandbox/marmoset_registration
bash check_status.sh
```

---

### STEP 1: Preprocess BOLD Data

**Goal:** Convert raw BOLD → preprocessed, motion-corrected, filtered data

**Script location:** `local/fmri/local/`

#### Option A: Use Original rs_MASTER.sh (RECOMMENDED)

```bash
cd /work01/.../riken_mri_s0/local/fmri/local

# Copy rs_MASTER.sh for subject m6
cp /work02/.../marmoset_connectivity/rs_MASTER.sh ./rs_MASTER_m6.sh

# Edit the script
nano rs_MASTER_m6.sh
```

**Edit these lines:**
```tcsh
set monkey = (m6)
set run = (1 2 3 4 5 6 7 8)
set pe = (u d)

set apth = /work01/.../marmoset_registration/raw_bold
set anat_pth = /work01/.../marmoset_registration/anatomical
set output_dir = /work01/.../marmoset_registration/preprocessed
```

**Run:**
```bash
module load afni fsl
tcsh -xef rs_MASTER_m6.sh 2>&1 | tee ../../../exp/mri/sandbox/marmoset_registration/logs/preprocessing_m6.log
```

**Time:** ~2-3 hours per subject

**Repeat for all subjects (m6-m32)**

#### Option B: Simplified Version

See `HOW_TO_PREPROCESS_BOLD.md` for a simplified preprocessing script.

**Output:**
```
preprocessed/m6/
├── errts.m6_u_bold_1.tproject.nii.gz  ← Main output
├── errts.m6_u_bold_2.tproject.nii.gz
...
├── m6_u_bold_1.mean.nii.gz            ← For registration
├── m6_u_bold_2.mean.nii.gz
...
```

**Verify:**
```bash
ls preprocessed/m6/errts.*.nii.gz | wc -l
# Should be 16 files (8 runs × 2 phase encodings)
```

---

### STEP 2: Register to Template

**Goal:** Bring all data into common MBM template space

**Script:** `local/fmri/local/run_registration.sh`

```bash
cd /work01/.../riken_mri_s0/local/fmri/local

# Test with one subject
bash run_registration.sh m6

# If successful, run all
bash run_registration.sh all
```

**What it does:**
1. BOLD → T2 (FSL FLIRT)
2. T2 → MBM template (ANTs nonlinear)
3. Apply transforms to BOLD
4. Mask with gray matter
5. Extract nuisance regressors (WM, CSF)

**Time:** ~50 min per subject (20 min for T2→template, 30 min for BOLD transforms)

**Output:**
```
correlation/
├── m6_u_bold_1_to_template_0.5mm_masked_gm.nii.gz  ← Ready for ROI analysis!
├── m6_u_bold_1_nui_regressors.1D
...
```

**Verify:**
```bash
ls correlation/*_to_template_0.5mm_masked_gm.nii.gz | wc -l
# Should be 432 files (27 subjects × 16 runs)
```

---

### STEP 3: Create Vocalization Network ROIs

**Goal:** Extract brain regions for vocalization network

**Script:** `local/fmri/local/run_stage1_rois.sh`

```bash
cd /work01/.../riken_mri_s0/local/fmri/local

bash run_stage1_rois.sh
```

**This will:**
1. Check atlas files
2. Print available labels
3. Create template ROI extraction script

**Then you need to:**
1. Examine atlas labels in MBM_v3.0.1/atlas_MBM_cortex_vPaxinos.txt
2. Edit `roi_masks/STAGE1b_extract_vocalization_ROIs.sh`
3. Replace XXX with actual label numbers
4. Run the edited script

**Output:**
```
roi_masks/
├── bilateral_motor_cortex.nii.gz
├── bilateral_prefrontal.nii.gz
├── bilateral_auditory.nii.gz
├── bilateral_cingulate.nii.gz
├── bilateral_amygdala.nii.gz
├── bilateral_thalamus.nii.gz
├── bilateral_caudate.nii.gz
├── bilateral_putamen.nii.gz
└── bilateral_pallidum.nii.gz
```

---

### STEP 4: Extract ROI Time Series

**Goal:** Get mean BOLD signal from each ROI for each subject

**Script:** `local/fmri/local/run_stage4_timeseries.py`

```bash
cd /work01/.../riken_mri_s0/local/fmri/local

python run_stage4_timeseries.py
```

**Output:**
```
roi_timeseries/
├── individual_rois/
│   ├── sub-06_bilateral_motor_cortex.txt
│   ├── sub-06_all_rois.txt  ← All ROIs combined
│   └── ...
└── summary/
    └── extraction_summary.csv
```

---

### STEP 5: Compute Connectivity Matrices

**Goal:** ROI-to-ROI correlation matrices

**Script:** `local/fmri/local/run_stage5_connectivity.py`

```bash
python run_stage5_connectivity.py
```

**Output:**
```
connectivity_matrices/
├── individual/
│   ├── sub-06_corr.npy
│   ├── sub-06_fisher_z.npy
│   └── sub-06_corr.csv
├── plots/
│   └── sub-06_connectivity.png
└── summary/
    └── connectivity_summary.csv
```

---

### STEP 6: Developmental Analysis

**Goal:** How does connectivity change with age?

**Script:** `local/fmri/local/run_stage6_development.py`

```bash
python run_stage6_development.py
```

**Analyzes:**
- Connectivity vs. age correlation
- Developmental phases (juvenile, young adult, mature, older)
- Edge-wise development (which connections change most)

**Output:**
```
developmental_analysis/
├── developmental_trajectory.png
├── edge_development_heatmap.png
└── developmental_summary.csv
```

---

### STEP 7: Cross-Species Comparison

**Goal:** Compare marmoset and human vocalization networks

**Script:** `local/fmri/local/run_stage7_comparison.py`

```bash
python run_stage7_comparison.py
```

**Output:**
```
cross_species_comparison/
├── homology_framework.png
├── developmental_timeline_comparison.csv
└── comparative_analysis.png
```

---

## Key Files You Need to Copy to local/fmri/local/

From the repository `/work02/.../marmoset_connectivity/`:

1. **Setup & Config:**
   - `setup_directories_and_data_FINAL.sh` → `setup_directories_and_data.sh`

2. **Preprocessing:**
   - `run_preprocessing.sh` (wrapper - needs adaptation)
   - `HOW_TO_PREPROCESS_BOLD.md` (instructions)
   - `PREPROCESSING_GUIDE.md` (technical details)

3. **Registration:**
   - `registration_MASTER_UPDATED.sh` → `run_registration.sh`

4. **Analysis Stages:**
   - `STAGE1_create_marmoset_vocalization_ROIs_UPDATED.sh` → `run_stage1_rois.sh`
   - `STAGE4_extract_ROI_timeseries.py` → `run_stage4_timeseries.py`
   - `STAGE5_compute_connectivity.py` → `run_stage5_connectivity.py`
   - `STAGE6_developmental_analysis.py` → `run_stage6_development.py`
   - `STAGE7_cross_species_comparison.py` → `run_stage7_comparison.py`

5. **Documentation:**
   - `MASTER_WORKFLOW_GUIDE.md`
   - `QUICKSTART_with_your_paths.md`
   - This file: `COMPLETE_WORKFLOW_README.md`

---

## Quick Command Reference

```bash
# Check status anytime
cd /work01/.../exp/mri/sandbox/marmoset_registration
bash check_status.sh

# View configuration
cat config_paths.sh

# Check logs
tail -f logs/preprocessing_m6.log
tail -f logs/registration_m6.log

# Disk usage
du -sh /work01/.../marmoset_registration
```

---

## Estimated Total Time

| Step | Time per Subject | Total (27 subjects) |
|------|------------------|---------------------|
| Preprocessing | 2-3 hours | 54-81 hours |
| Registration | 50 min | 22 hours |
| ROI extraction | 10 min (one-time) | 10 min |
| Time series extraction | 5 min | 2 hours |
| Connectivity | 2 min | 1 hour |
| Development | 5 min (one-time) | 5 min |
| Comparison | 2 min (one-time) | 2 min |
| **TOTAL** | **~3-4 hours** | **~80-105 hours** |

**Recommendation:** Run on cluster with parallel jobs → can complete in 1-2 days

---

## Software Requirements

**On your system, you need:**

```bash
module load afni/20.3.02
module load fsl/6.0.4
module load ants/2.3.5

# Python packages
pip install nibabel numpy pandas scipy matplotlib seaborn
```

---

## Troubleshooting

### Problem: "Config file not found"
**Solution:** Run `setup_directories_and_data.sh` first

### Problem: "No preprocessed files found"
**Solution:** Complete preprocessing step first (rs_MASTER.sh)

### Problem: "Template file not found"
**Solution:** Check paths in `config_paths.sh`, verify templates exist

### Problem: "Permission denied"
**Solution:** Check directory ownership, make scripts executable with `chmod +x`

---

## Getting Help

1. **Check logs:** `logs/` directory
2. **Status:** `bash check_status.sh`
3. **Documentation:** All .md files in scripts directory

---

## Summary Checklist

- [ ] Step 0: Setup complete (`setup_directories_and_data.sh`)
- [ ] Step 1: BOLD preprocessed (432 files in `preprocessed/`)
- [ ] Step 2: Registered to template (432 files in `correlation/`)
- [ ] Step 3: ROIs created (9 files in `roi_masks/`)
- [ ] Step 4: Time series extracted
- [ ] Step 5: Connectivity computed
- [ ] Step 6: Development analyzed
- [ ] Step 7: Cross-species comparison done

**Final output:** Developmental trajectories of marmoset vocalization network connectivity with comparison to human systems!
