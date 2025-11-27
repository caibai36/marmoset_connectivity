# Next Steps for Subject m6

## Current Status: ✅ Preprocessing Complete!

You have successfully completed preprocessing for m6:
- 8 preprocessed BOLD files in `preprocessed/m6/`
- 4 runs × 2 phase encodings (up/down)

---

## What to Do Next

### STEP 2: Register to MBM Template

**Location:**
```bash
cd /work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/local/fmri/local
```

**Command:**
```bash
# First, copy the registration script if you haven't
cp /work02/home/bin-wu/workspace/projects/tests/test_fmri/marmoset_connectivity/registration_MASTER.sh \
   ./registration_MASTER_m6.sh

# Edit paths in the script (check subject variable, paths to preprocessed/, anatomical/, etc.)
nano registration_MASTER_m6.sh

# Load modules
module load afni fsl ants

# Run registration
tcsh -xef registration_MASTER_m6.sh 2>&1 | tee ../../../exp/mri/sandbox/marmoset_registration/logs/registration_m6.log
```

**Expected time:** ~50 minutes

**What this does:**
1. Registers T2 anatomical → MBM template (ANTs nonlinear)
2. Registers each BOLD run → T2 → template
3. Applies gray matter mask
4. Extracts nuisance regressors (white matter, CSF)

**Expected outputs:**
```
correlation/
├── m6_up_bold_1_to_template_0.5mm_masked_gm.nii.gz
├── m6_up_bold_2_to_template_0.5mm_masked_gm.nii.gz
├── m6_up_bold_3_to_template_0.5mm_masked_gm.nii.gz
├── m6_up_bold_4_to_template_0.5mm_masked_gm.nii.gz
├── m6_down_bold_1_to_template_0.5mm_masked_gm.nii.gz
├── m6_down_bold_2_to_template_0.5mm_masked_gm.nii.gz
├── m6_down_bold_3_to_template_0.5mm_masked_gm.nii.gz
├── m6_down_bold_4_to_template_0.5mm_masked_gm.nii.gz
├── m6_up_bold_1_nui_regressors.1D
├── ... (and more .1D files)
```

**Verify:**
```bash
ls ../../../exp/mri/sandbox/marmoset_registration/correlation/*m6*_to_template_0.5mm_masked_gm.nii.gz | wc -l
# Should be 8
```

---

## After Registration Completes

### Option A: Continue with m6 Only (Test Pipeline)

**Step 3: Create ROI masks** (one-time setup)
```bash
cd /work01/.../local/fmri/local
bash run_stage1_rois.sh
```

This creates vocalization network ROI masks from MBM atlas.

**Step 4: Extract m6 time series**
```bash
python run_stage4_timeseries.py --subject m6
```

**Step 5: Compute m6 connectivity**
```bash
python run_stage5_connectivity.py --subject m6
```

### Option B: Process All Subjects (Full Analysis)

**Repeat preprocessing for all subjects:**
```bash
# Get parameters for each subject
for subj in m7 m8 m9 m10 m11 m12 m14 m15 m16 m17 m18 m19 m20 m21 m22 m23 m24 m25 m26 m27 m28 m29 m30 m31 m32; do
    bash get_subject_parameters.sh $subj > params_${subj}.txt

    # Create subject-specific rs_MASTER script
    cp /work02/.../marmoset_connectivity/rs_MASTER.sh ./rs_MASTER_${subj}.sh

    # Edit rs_MASTER_${subj}.sh with parameters from params_${subj}.txt
    # Then run:
    # tcsh -xef rs_MASTER_${subj}.sh 2>&1 | tee logs/preprocessing_${subj}.log
done
```

**Then registration for all:**
```bash
bash registration_MASTER_UPDATED.sh all
```

---

## Quick Decision Guide

**If you want to:**
- ✅ **Test the full pipeline quickly:** Process just m6 through all steps
- ✅ **Run full analysis:** Process all 27 subjects (recommended to submit as batch jobs)

**My recommendation:**
1. Complete registration for m6 (verify pipeline works end-to-end)
2. Then batch-process remaining subjects
3. This ensures you catch any issues early

---

## Troubleshooting Registration

### Common Issues:

**1. "Template file not found"**
```bash
# Check template path in registration script
# Should be: /data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/...
```

**2. "No preprocessed files found"**
```bash
# Verify preprocessing outputs exist
ls preprocessed/m6/errts.*.nii.gz
```

**3. "ANTS registration fails"**
```bash
# Check that ANTs module is loaded
module load ants/2.3.5
which antsRegistration
```

**4. "Out of memory"**
```bash
# Registration is memory-intensive
# Request more memory if running on cluster: --mem=16G
```

---

## Expected Timeline

| Task | Time | Status |
|------|------|--------|
| Preprocessing m6 | 2-3 hours | ✅ DONE |
| Registration m6 | 50 min | ⏳ NEXT |
| ROI creation | 10 min | ⏸️ Pending |
| Time series m6 | 2 min | ⏸️ Pending |
| Connectivity m6 | 1 min | ⏸️ Pending |

**Total for m6:** ~3-4 hours (mostly preprocessing)

---

## Files to Check Before Running Registration

1. **Preprocessed BOLD exists:**
   ```bash
   ls preprocessed/m6/errts.m6_*_bold_*.tproject.nii.gz
   ```

2. **Mean functional images exist:**
   ```bash
   ls preprocessed/m6/m6_*_bold_*.mean.nii.gz
   ```

3. **Anatomical files exist:**
   ```bash
   ls anatomical/m6/InplaneT2.nii.gz
   ls anatomical/m6/mask.nii.gz
   ```

4. **MBM template exists:**
   ```bash
   ls /data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1_0.5mm/template_T2w_brain_0.5mm.nii.gz
   ```

All these should exist from your setup step!

---

## Summary

**You are ready to proceed!**

Your preprocessing is successful, and you need these results for functional connectivity analysis.

**Next command:**
```bash
cd /work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/local/fmri/local
cp /work02/.../marmoset_connectivity/registration_MASTER.sh ./registration_MASTER_m6.sh
nano registration_MASTER_m6.sh  # Edit paths
module load afni fsl ants
tcsh -xef registration_MASTER_m6.sh 2>&1 | tee ../../../exp/mri/sandbox/marmoset_registration/logs/registration_m6.log
```

After this completes, you'll have m6 ready for ROI time series extraction and connectivity analysis! 🎉
