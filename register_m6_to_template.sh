#!/bin/tcsh -xef

# ==========================================
# REGISTRATION WORKFLOW FOR M6
# ==========================================
# Following registration_MASTER.sh exactly
# Using actual data paths
# ==========================================

# Subject
set monkey = (m6)
set run = (1 2 3 4)
set pe = (up down)

# Paths (YOUR ACTUAL DATA)
set raw_data = /data02/share/bin-wu/data/marmoset/brain/nih_uwo/nih/NIH-data
set preprocessed_dir = /work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration/preprocessed
set output_dir = /work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration/correlation
set temp_dir = /work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration/temp

# MBM template path
set mskpth = /data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1_0.5mm

# Create directories
if ( ! -d ${output_dir} ) then
    mkdir -p ${output_dir}
endif

if ( ! -d ${temp_dir} ) then
    mkdir -p ${temp_dir}
endif

foreach m ( ${monkey} )
foreach r ( ${run})
foreach p ( ${pe})

echo "=========================================="
echo "Processing: ${m} run ${r} phase ${p}"
echo "=========================================="

# ==========================================
# STAGE 1: BOLD → T2 (FLIRT Linear Registration)
# ==========================================

echo "Stage 1: Registering BOLD mean to T2..."

# Check if mean BOLD exists (from preprocessing)
if ( ! -f ${preprocessed_dir}/${m}/${m}_${p}_bold_${r}.mean.nii.gz ) then
    echo "ERROR: Mean BOLD not found!"
    echo "Expected: ${preprocessed_dir}/${m}/${m}_${p}_bold_${r}.mean.nii.gz"
    echo "Need to create mean from preprocessed data first"

    # Create mean from preprocessed BOLD
    if ( -f ${preprocessed_dir}/${m}/errts.${m}_${p}_bold_${r}.tproject.nii.gz ) then
        echo "Creating mean from preprocessed BOLD..."
        3dTstat -mean \
            -prefix ${preprocessed_dir}/${m}/${m}_${p}_bold_${r}.mean.nii.gz \
            ${preprocessed_dir}/${m}/errts.${m}_${p}_bold_${r}.tproject.nii.gz
    else
        echo "ERROR: Preprocessed BOLD not found!"
        echo "Expected: ${preprocessed_dir}/${m}/errts.${m}_${p}_bold_${r}.tproject.nii.gz"
        exit 1
    endif
endif

# Register BOLD mean to T2 (FLIRT with full search)
if(! -f ${temp_dir}/${m}_${p}_bold_${r}.mean_to_t2.nii.gz)then
    echo "  Running FLIRT: BOLD mean → T2..."
    flirt -searchrx -360 360 -searchry -360 360 -searchrz -360 360 \
        -in ${preprocessed_dir}/${m}/${m}_${p}_bold_${r}.mean.nii.gz \
        -ref ${raw_data}/${m}/InplaneT2.nii.gz \
        -out ${temp_dir}/${m}_${p}_bold_${r}.mean_to_t2.nii.gz \
        -omat ${temp_dir}/${m}_${p}_bold_${r}.mean_to_t2.mat
endif

# Apply transform to preprocessed BOLD
if(! -f ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_t2.nii.gz)then
    echo "  Applying transform to preprocessed BOLD..."
    flirt -in ${preprocessed_dir}/${m}/errts.${m}_${p}_bold_${r}.tproject.nii.gz \
        -ref ${raw_data}/${m}/InplaneT2.nii.gz \
        -applyxfm -init ${temp_dir}/${m}_${p}_bold_${r}.mean_to_t2.mat \
        -out ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_t2.nii.gz \
        -interp trilinear
endif

# ==========================================
# STAGE 2: T2 → MBM TEMPLATE (ANTs Nonlinear)
# ==========================================

echo "Stage 2: Registering T2 to MBM template..."

# Register mask to T2 (for skull-stripping)
if(! -f ${temp_dir}/${m}_mask_to_t2.nii.gz)then
    echo "  Registering mask to T2..."
    flirt -searchrx -360 360 -searchry -360 360 -searchrz -360 360 \
        -in ${raw_data}/${m}/mask.nii.gz \
        -ref ${raw_data}/${m}/InplaneT2.nii.gz \
        -out ${temp_dir}/${m}_mask_to_t2.nii.gz
endif

# Binarize mask
if(! -f ${temp_dir}/${m}_mask_to_t2_binary.nii.gz)then
    echo "  Binarizing mask..."
    3dcalc -a ${temp_dir}/${m}_mask_to_t2.nii.gz \
        -expr 'ispositive(a)' \
        -prefix ${temp_dir}/${m}_mask_to_t2_binary.nii.gz
endif

# Skull-strip T2
if(! -f ${temp_dir}/${m}_InplaneT2_masked.nii.gz)then
    echo "  Skull-stripping T2..."
    3dcalc -a ${raw_data}/${m}/InplaneT2.nii.gz \
        -b ${temp_dir}/${m}_mask_to_t2_binary.nii.gz \
        -expr '(a*b)' \
        -prefix ${temp_dir}/${m}_InplaneT2_masked.nii.gz
endif

# Register T2 to template (ANTs SyNQuick - SLOW STEP!)
if(! -f ${temp_dir}/${m}_t2_to_template_0.5mm_Warped.nii.gz)then
    echo "  Running ANTs registration (this will take 10-30 minutes)..."
    antsRegistrationSyNQuick.sh -d 3 \
        -f ${mskpth}/template_T2w_brain_0.5mm.nii.gz \
        -m ${temp_dir}/${m}_InplaneT2_masked.nii.gz \
        -o ${temp_dir}/${m}_t2_to_template_0.5mm_

    echo "  ANTs registration complete!"
endif

# ==========================================
# STAGE 3: APPLY TRANSFORMS TO BOLD
# ==========================================

echo "Stage 3: Applying transforms to BOLD..."

# Apply combined transforms (Warp + Affine) to BOLD
if(! -f ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_template.nii.gz)then
    echo "  Warping BOLD to template space..."
    antsApplyTransforms -e 3 \
        -i ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_t2.nii.gz \
        -r ${temp_dir}/${m}_t2_to_template_0.5mm_Warped.nii.gz \
        -o ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_template.nii.gz \
        -t ${temp_dir}/${m}_t2_to_template_0.5mm_1Warp.nii.gz \
        -t ${temp_dir}/${m}_t2_to_template_0.5mm_0GenericAffine.mat
endif

# ==========================================
# STAGE 4: GRAY MATTER MASKING
# ==========================================

echo "Stage 4: Applying gray matter mask..."

# Mask with gray matter (final output)
if(! -f ${output_dir}/${m}_${p}_bold_${r}_to_template_0.5mm_masked_gm.nii.gz)then
    echo "  Creating gray matter masked BOLD..."
    3dcalc -a ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_template.nii.gz \
        -b ${mskpth}/segmentation_three_types_prob_1_gray_0.5mm.nii.gz \
        -expr '(a*b)' \
        -prefix ${output_dir}/${m}_${p}_bold_${r}_to_template_0.5mm_masked_gm.nii.gz

    echo "  ✓ Final output created!"
endif

# ==========================================
# STAGE 5: EXTRACT NUISANCE REGRESSORS
# ==========================================

echo "Stage 5: Extracting nuisance regressors..."

# White matter regressor
if(! -f ${output_dir}/${m}_${p}_bold_${r}_wm_nui_regressor.1D)then
    echo "  Extracting WM regressor..."
    3dmaskave -quiet \
        -mask ${mskpth}/segmentation_three_types_prob_2_white_0.5mm.nii.gz \
        ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_template.nii.gz \
        > ${output_dir}/${m}_${p}_bold_${r}_wm_nui_regressor.1D
endif

# CSF regressor
if(! -f ${output_dir}/${m}_${p}_bold_${r}_csf_nui_regressor.1D)then
    echo "  Extracting CSF regressor..."
    3dmaskave -quiet \
        -mask ${mskpth}/segmentation_three_types_prob_3_csf_0.5mm.nii.gz \
        ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_template.nii.gz \
        > ${output_dir}/${m}_${p}_bold_${r}_csf_nui_regressor.1D
endif

# Combine WM and CSF regressors
if(! -f ${output_dir}/${m}_${p}_bold_${r}_nui_regressors.1D)then
    echo "  Combining regressors..."
    paste ${output_dir}/${m}_${p}_bold_${r}_wm_nui_regressor.1D \
          ${output_dir}/${m}_${p}_bold_${r}_csf_nui_regressor.1D \
          > ${output_dir}/${m}_${p}_bold_${r}_nui_regressors.1D

    # Clean up individual files
    rm ${output_dir}/${m}_${p}_bold_${r}_wm_nui_regressor.1D
    rm ${output_dir}/${m}_${p}_bold_${r}_csf_nui_regressor.1D
endif

echo "✓ Complete: ${m} run ${r} phase ${p}"
echo ""

end
end
end

# ==========================================
# SUMMARY
# ==========================================

echo "=========================================="
echo "REGISTRATION COMPLETE FOR ${monkey}"
echo "=========================================="
echo ""
echo "Output files created in: ${output_dir}"
echo ""
echo "Expected outputs (8 files for m6):"
ls -lh ${output_dir}/*${monkey}*_to_template_0.5mm_masked_gm.nii.gz
echo ""
echo "Nuisance regressors:"
ls -lh ${output_dir}/*${monkey}*_nui_regressors.1D
echo ""
echo "Transform files saved in: ${temp_dir}"
echo "  - ${monkey}_t2_to_template_0.5mm_0GenericAffine.mat"
echo "  - ${monkey}_t2_to_template_0.5mm_1Warp.nii.gz"
echo ""
echo "Next steps:"
echo "  1. Extract ROI time series from template-space BOLD"
echo "  2. Compute connectivity matrices"
echo "  3. Or: Transform template ROIs back to native space"
echo ""
