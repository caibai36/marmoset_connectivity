# Marmoset Affective Vocalization Development Analysis
## Complete Stage-by-Stage Workflow

---

## 📋 Overview

This pipeline analyzes the development of **affective vocalization networks** in marmoset monkeys using resting-state fMRI data, with cross-species comparison to human vocalization systems.

**Dataset:** 32 marmosets, ages 14-115 months (NIH 7T + UWO 9.4T)
**Goal:** Understand how vocalization-related brain connectivity develops
**Comparison:** Map to human infant/child vocalization development

---

## 🗺️ Analysis Pipeline

```
STAGE 1: Define ROIs → STAGE 2: Preprocess → STAGE 3: Register
     ↓                                             ↓
STAGE 7: Compare   ← STAGE 6: Development ← STAGE 5: Connectivity
    Species                                      ↑
                                            STAGE 4: Extract Time Series
```

---

## 📍 STAGE 1: Define Marmoset Vocalization Network ROIs

**Script:** `STAGE1_create_marmoset_vocalization_ROIs.sh`

### Purpose
Create ROI masks for vocalization-related brain regions using MBM v3 atlas

### Vocalization Network Components

1. **Vocal Motor System**
   - Motor cortex (Area 4) - laryngeal control
   - Premotor cortex (Area 6) - vocalization planning
   - Prefrontal areas - motor sequencing

2. **Limbic Vocalization System**
   - Anterior cingulate cortex (ACC) - call initiation
   - Amygdala - emotional valence
   - Thalamus - cortical relay
   - Nucleus accumbens - social motivation

3. **Auditory-Vocal Integration**
   - Primary auditory cortex (A1)
   - Auditory belt regions
   - Auditory feedback processing

4. **Basal Ganglia Vocal Control**
   - Caudate - call sequencing
   - Putamen - motor execution
   - Pallidum - timing/gating

### Execution

```bash
# Step 1: Run preparation script
bash STAGE1_create_marmoset_vocalization_ROIs.sh

# Step 2: Examine atlas labels (printed by script)

# Step 3: Edit STAGE1b script with actual label numbers
nano marmoset_vocalization_ROIs/STAGE1b_extract_vocalization_ROIs.sh

# Step 4: Extract ROIs
bash marmoset_vocalization_ROIs/STAGE1b_extract_vocalization_ROIs.sh
```

### Output
- `marmoset_vocalization_ROIs/*.nii.gz` - ROI masks
- `marmoset_vocalization_homology.txt` - Marmoset-human mapping

---

## 🔬 STAGE 2: Preprocess fMRI Data

**Script:** `STAGE2_preprocessing_master.sh`
**Existing pipeline:** `rs_MASTER.sh` + `registration_MASTER.sh`

### Purpose
Run existing preprocessing pipeline on all 32 subjects

### Processing Steps (from rs_MASTER.sh)

1. **Remove first 10 volumes** - steady-state
2. **Distortion correction** - FSL TOPUP (NIH up/down phase encoding)
3. **Despiking** - remove outliers (3dDespike)
4. **Slice timing correction** - align slices (3dTshift)
5. **Motion correction** - register to reference (3dvolreg)
6. **Spatial smoothing** - 1.5mm FWHM Gaussian
7. **Motion regression** - 12 parameters (6 motion + derivatives)
8. **Bandpass filtering** - 0.01-0.1 Hz
9. **Censoring** - exclude high-motion volumes (>0.5mm)

### Data Structure

```
/data02/share/bin-wu/data/marmoset/brain/nih_uwo/nih/NIH-data/
├── m6/  (sub-06, 71 months)
│   ├── BOLD_up_1.nii.gz      # 512 volumes, TR=2s
│   ├── BOLD_up_2.nii.gz
│   ├── BOLD_down_1.nii.gz
│   ├── SEEPI_up.nii.gz       # For distortion correction
│   ├── SEEPI_down.nii.gz
│   ├── InplaneT2.nii.gz      # Anatomical reference
│   └── mask.nii.gz
├── m7/  (sub-07, 24 months)
└── ...

Metadata: /data02/.../nih_uwo_meta.csv
```

### Execution

```bash
# Review the batch processing script
bash STAGE2_preprocessing_master.sh

# For actual processing, modify existing rs_MASTER.sh to accept arguments:
# Example for subject m6:
cd /path/to/rs_MASTER.sh
# Set: monkey=m6, run=1-8, pe=up down
# Run rs_MASTER.sh

# Then run registration to MBM template:
# Run registration_MASTER.sh
```

### Output (per subject)
- `errts.{monkey}_{pe}_bold_{run}.tproject.nii.gz` - preprocessed BOLD
- `{monkey}_{pe}_bold_{run}_to_template_errts_.5iso_masked_gm.nii.gz` - in template space
- Motion parameters, QC metrics

---

## 🎯 STAGE 3: Register to MBM Template

**Script:** `STAGE3_register_and_prepare_ROI_data.sh`

### Purpose
Verify all data is in common MBM template space for ROI analysis

### Registration Process (from registration_MASTER.sh)

1. **BOLD → InplaneT2** - FSL FLIRT (same geometry)
2. **InplaneT2 → MBM template** - ANTs SyNQuick (nonlinear)
3. **Apply transforms** - bring BOLD to template space
4. **Gray matter masking**

### Execution

```bash
bash STAGE3_register_and_prepare_ROI_data.sh
```

### Output
```
template_space_data/
├── registered_bold/
│   ├── sub-06_*.nii.gz
│   ├── sub-07_*.nii.gz
│   └── ...
├── roi_masks/
│   ├── bilateral_motor_cortex.nii.gz
│   ├── bilateral_auditory.nii.gz
│   └── ...
└── metadata/
    └── subject_manifest.csv
```

---

## ⏱️ STAGE 4: Extract ROI Time Series

**Script:** `STAGE4_extract_ROI_timeseries.py`

### Purpose
Extract mean BOLD time series from each vocalization ROI

### Method
For each subject and each ROI:
1. Load 4D BOLD data in template space
2. Load 3D ROI mask
3. Extract voxels within ROI
4. Compute mean time series across voxels

### Execution

```bash
python STAGE4_extract_ROI_timeseries.py
```

### Output
```
roi_timeseries/
├── individual_rois/
│   ├── sub-06_bilateral_motor_cortex.txt     # [n_timepoints,]
│   ├── sub-06_bilateral_auditory.txt
│   ├── sub-06_all_rois.txt                   # [n_timepoints, n_rois]
│   ├── sub-06_roi_names.txt
│   └── ...
└── summary/
    └── extraction_summary.csv
```

---

## 🔗 STAGE 5: Compute Functional Connectivity

**Script:** `STAGE5_compute_connectivity.py`

### Purpose
Compute ROI-to-ROI connectivity matrices using Pearson correlation

### Method
For each subject:
1. Load ROI time series matrix [n_timepoints, n_rois]
2. Compute Pearson correlation between all ROI pairs
3. Apply Fisher Z-transformation for statistical analysis
4. Visualize connectivity matrix

### Metrics
- **Correlation matrix:** ROI-to-ROI connectivity strength
- **Fisher Z-transformed:** For statistical comparisons
- **Summary stats:** Mean, median, variability

### Execution

```bash
python STAGE5_compute_connectivity.py
```

### Output
```
connectivity_matrices/
├── individual/
│   ├── sub-06_corr.npy              # Correlation matrix [n_rois, n_rois]
│   ├── sub-06_fisher_z.npy          # Z-transformed
│   ├── sub-06_corr.csv              # Human-readable
│   └── ...
├── plots/
│   ├── sub-06_connectivity.png      # Heatmap visualization
│   └── ...
└── summary/
    └── connectivity_summary.csv     # Per-subject statistics
```

---

## 📈 STAGE 6: Developmental Analysis

**Script:** `STAGE6_developmental_analysis.py`

### Purpose
Analyze how vocalization network connectivity changes with age

### Analyses

1. **Overall Trajectory**
   - Connectivity vs. age correlation
   - Linear, logarithmic, exponential models
   - Statistical significance testing

2. **Developmental Phases**
   - Juvenile (<18 months)
   - Young adult (18-48 months)
   - Mature adult (48-84 months)
   - Older adult (>84 months)

3. **Edge-wise Development**
   - Which ROI-ROI connections change with age?
   - Age correlation for each edge

4. **Variability Analysis**
   - Does network variability change with age?

### Execution

```bash
python STAGE6_developmental_analysis.py
```

### Output
```
developmental_analysis/
├── developmental_trajectory.png          # Multi-panel developmental plots
├── edge_development_heatmap.png          # Edge-wise age correlations
├── edge_age_correlations.npy
├── edge_age_pvalues.npy
└── developmental_summary.csv
```

### Key Questions Answered
- Does vocalization network connectivity increase/decrease with age?
- When does the network mature?
- Which connections show strongest developmental changes?

---

## 🔬 STAGE 7: Cross-Species Comparison

**Script:** `STAGE7_cross_species_comparison.py`

### Purpose
Compare marmoset and human vocalization networks

### Comparisons

1. **Structural Homology**
   - Map marmoset ROIs to human brain regions
   - Confidence ratings for each homology

2. **Developmental Timeline**
   - Marmoset milestones vs. human milestones
   - Age scaling (marmoset develops ~4-10x faster)

3. **Connectivity Patterns**
   - Compare marmoset developmental trajectory to human data
   - Identify conserved vs. species-specific patterns

4. **Functional Similarities**
   - Limbic system emotional calls (conserved)
   - Cortical control differences
   - Vocal learning parallels

### Execution

```bash
python STAGE7_cross_species_comparison.py
```

### Output
```
cross_species_comparison/
├── homology_framework.png               # Region mapping table
├── homology_framework.csv
├── developmental_timeline_comparison.csv
└── comparative_analysis.png             # Multi-panel comparison
```

### Key Insights
- **Conserved:** Limbic drive, auditory feedback, basal ganglia timing
- **Different:** Cortical laryngeal control (humans have direct, marmosets indirect)
- **Convergent:** Antiphonal calling ↔ conversational turn-taking
- **Timeline:** Marmoset 6mo ≈ Human 24mo (vocal development)

---

## 📊 Expected Results Summary

### Sample Findings (Hypothetical)

| Age Group | N | Mean Connectivity | Development |
|-----------|---|-------------------|-------------|
| Juvenile (<18mo) | 3 | 0.35 ± 0.08 | Maturing |
| Young Adult (18-48mo) | 12 | 0.42 ± 0.06 | Stabilizing |
| Mature Adult (48-84mo) | 13 | 0.45 ± 0.05 | Stable |
| Older Adult (>84mo) | 4 | 0.43 ± 0.07 | Slight decline? |

### Interpretation Framework

**Strong positive age correlation (r > 0.5, p < 0.05):**
→ Network strengthens with age (maturation)

**Weak/no correlation (r < 0.3, p > 0.05):**
→ Network stable across development (mature by 14 months)

**Negative correlation (r < -0.3, p < 0.05):**
→ Network pruning/reorganization

### Cross-Species Timeline

```
MARMOSET          HUMAN EQUIVALENT      MILESTONE
--------          ----------------      ---------
0-2 months    →   0-6 months           Reflexive vocalizations
2-6 months    →   6-24 months          Vocal babbling/learning
6-12 months   →   24-48 months         Adult-like repertoire
12-18 months  →   48-216 months        Network refinement
```

---

## 🚀 Quick Start Guide

### Minimum Steps to Run Full Analysis

```bash
# 1. Define ROIs (Stage 1)
bash STAGE1_create_marmoset_vocalization_ROIs.sh
# Edit STAGE1b with atlas labels
bash marmoset_vocalization_ROIs/STAGE1b_extract_vocalization_ROIs.sh

# 2. Preprocess data (Stage 2) - use existing pipeline
# Run rs_MASTER.sh and registration_MASTER.sh for each subject

# 3. Organize template space data (Stage 3)
bash STAGE3_register_and_prepare_ROI_data.sh

# 4. Extract time series (Stage 4)
python STAGE4_extract_ROI_timeseries.py

# 5. Compute connectivity (Stage 5)
python STAGE5_compute_connectivity.py

# 6. Analyze development (Stage 6)
python STAGE6_developmental_analysis.py

# 7. Cross-species comparison (Stage 7)
python STAGE7_cross_species_comparison.py
```

### Dependencies

```bash
# Neuroimaging tools
- AFNI (3dcalc, 3dROIstats, etc.)
- FSL (fslinfo, flirt, etc.)
- ANTs (antsRegistrationSyNQuick.sh, antsApplyTransforms)

# Python packages
pip install nibabel numpy pandas scipy matplotlib seaborn
```

---

## 📚 References

### Marmoset Vocalization
- **Takahashi et al. (2015)** - "The developmental origins of phonology"
- **Eliades & Wang (2008)** - "Neural substrates of primate vocalization"
- **Miller et al. (2015)** - "Marmoset vocal development"

### Primate Brain Atlases
- **Liu et al. (2018)** - Marmoset Brain Mapping (MBM) v3
- **Paxinos et al. (2012)** - Marmoset stereotaxic atlas

### Human-Marmoset Comparison
- **Petkov & Jarvis (2012)** - "Birds, primates, and language evolution"
- **Takahashi et al. (2017)** - "Sequence learning in marmosets"

---

## 💡 Tips & Troubleshooting

### Common Issues

**Issue:** ROI extraction returns empty masks
**Solution:** Check atlas label numbers, verify dimensions match

**Issue:** Preprocessing fails for some runs
**Solution:** Check motion parameters, may need to exclude high-motion runs

**Issue:** Connectivity matrices have NaN values
**Solution:** ROI may have no voxels or constant time series, check preprocessing

**Issue:** No significant age effects
**Solution:** May be normal! Network might mature early in marmosets

### Quality Control

1. **Visual inspection:** Check registration quality
2. **Motion thresholds:** Exclude runs with >0.5mm mean FD
3. **ROI coverage:** Verify ROIs cover expected anatomy
4. **Time series plots:** Check for artifacts/outliers

---

## 📝 Citation

If you use this pipeline, please cite:

- Marmoset Brain Mapping atlas (Liu et al. 2018)
- Original data sources (NIH/UWO datasets)
- Relevant vocalization papers (Takahashi, Eliades, etc.)

---

## 🔬 Research Questions This Pipeline Addresses

1. **When does the vocalization network mature in marmosets?**
2. **Which connections show strongest developmental changes?**
3. **How do marmoset patterns compare to human vocal development?**
4. **Is there sexual dimorphism in vocalization connectivity?**
5. **Do network patterns predict vocal learning ability?**

---

## Contact & Support

For questions about this pipeline, consult:
- MBM atlas documentation: https://marmosetbrainmapping.org
- AFNI tutorials: https://afni.nimh.nih.gov
- Existing marmoset fMRI papers

---

**Last Updated:** 2025-11-26
**Pipeline Version:** 1.0
**Dataset:** NIH/UWO marmoset RS-fMRI (N=32, ages 14-115 months)
