#!/bin/tcsh -xef

# ==========================================
# TEMPLATE → NATIVE SPACE TRANSFORMATION
# ==========================================
# Following template_to_native.sh workflow
# Transforms template-space ROIs/results back to individual m6 anatomy
# ==========================================

# Subject
set monkey = (m6)

# Paths
set raw_data = /data02/share/bin-wu/data/marmoset/brain/nih_uwo/nih/NIH-data
set temp_dir = /work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration/temp
set output_dir = /work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration/native_space

# MBM template path
set mskpth = /data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1_0.5mm

# ROI masks path (if you've extracted them)
set roi_dir = /work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration/roi_masks

# Create output directory
if ( ! -d ${output_dir} ) then
    mkdir -p ${output_dir}
endif

if ( ! -d ${output_dir}/${monkey} ) then
    mkdir -p ${output_dir}/${monkey}
endif

foreach m ( ${monkey} )

echo "=========================================="
echo "Transforming template data to ${m} native space"
echo "=========================================="
echo ""

# Check if transforms exist
if ( ! -f ${temp_dir}/${m}_t2_to_template_0.5mm_1Warp.nii.gz ) then
    echo "ERROR: Transform files not found!"
    echo "Need to run registration first: register_m6_to_template.sh"
    exit 1
endif

# ==========================================
# TRANSFORM TEMPLATE ATLASES TO NATIVE SPACE
# ==========================================

echo "Transforming MBM atlases to ${m} native T2 space..."

# Paxinos cortical atlas → native space
if ( ! -f ${output_dir}/${m}/atlas_MBM_cortex_vPaxinos_native.nii.gz ) then
    echo "  Transforming Paxinos cortical atlas..."
    antsApplyTransforms -d 3 \
        -i ${mskpth}/atlas_MBM_cortex_vPaxinos_0.5mm.nii.gz \
        -r ${raw_data}/${m}/InplaneT2.nii.gz \
        -o ${output_dir}/${m}/atlas_MBM_cortex_vPaxinos_native.nii.gz \
        -n NearestNeighbor \
        -t [${temp_dir}/${m}_t2_to_template_0.5mm_0GenericAffine.mat,1] \
        -t ${temp_dir}/${m}_t2_to_template_0.5mm_1InverseWarp.nii.gz

    echo "  ✓ Paxinos atlas in native space"
endif

# RIKEN cortical atlas → native space
if ( ! -f ${output_dir}/${m}/atlas_RikenBMA_cortex_native.nii.gz ) then
    echo "  Transforming RIKEN cortical atlas..."
    antsApplyTransforms -d 3 \
        -i ${mskpth}/atlas_RikenBMA_cortex_0.5mm.nii.gz \
        -r ${raw_data}/${m}/InplaneT2.nii.gz \
        -o ${output_dir}/${m}/atlas_RikenBMA_cortex_native.nii.gz \
        -n NearestNeighbor \
        -t [${temp_dir}/${m}_t2_to_template_0.5mm_0GenericAffine.mat,1] \
        -t ${temp_dir}/${m}_t2_to_template_0.5mm_1InverseWarp.nii.gz

    echo "  ✓ RIKEN atlas in native space"
endif

# Subcortical atlas → native space
if ( ! -f ${output_dir}/${m}/atlas_MBM_subcortical_native.nii.gz ) then
    echo "  Transforming subcortical atlas..."
    antsApplyTransforms -d 3 \
        -i ${mskpth}/atlas_MBM_subcortical_beta_0.5mm.nii.gz \
        -r ${raw_data}/${m}/InplaneT2.nii.gz \
        -o ${output_dir}/${m}/atlas_MBM_subcortical_native.nii.gz \
        -n NearestNeighbor \
        -t [${temp_dir}/${m}_t2_to_template_0.5mm_0GenericAffine.mat,1] \
        -t ${temp_dir}/${m}_t2_to_template_0.5mm_1InverseWarp.nii.gz

    echo "  ✓ Subcortical atlas in native space"
endif

echo ""

# ==========================================
# TRANSFORM TISSUE SEGMENTATIONS TO NATIVE
# ==========================================

echo "Transforming tissue segmentations to native space..."

# Gray matter mask
if ( ! -f ${output_dir}/${m}/gray_matter_mask_native.nii.gz ) then
    echo "  Transforming gray matter mask..."
    antsApplyTransforms -d 3 \
        -i ${mskpth}/segmentation_three_types_prob_1_gray_0.5mm.nii.gz \
        -r ${raw_data}/${m}/InplaneT2.nii.gz \
        -o ${output_dir}/${m}/gray_matter_mask_native.nii.gz \
        -n Linear \
        -t [${temp_dir}/${m}_t2_to_template_0.5mm_0GenericAffine.mat,1] \
        -t ${temp_dir}/${m}_t2_to_template_0.5mm_1InverseWarp.nii.gz
endif

# White matter mask
if ( ! -f ${output_dir}/${m}/white_matter_mask_native.nii.gz ) then
    echo "  Transforming white matter mask..."
    antsApplyTransforms -d 3 \
        -i ${mskpth}/segmentation_three_types_prob_2_white_0.5mm.nii.gz \
        -r ${raw_data}/${m}/InplaneT2.nii.gz \
        -o ${output_dir}/${m}/white_matter_mask_native.nii.gz \
        -n Linear \
        -t [${temp_dir}/${m}_t2_to_template_0.5mm_0GenericAffine.mat,1] \
        -t ${temp_dir}/${m}_t2_to_template_0.5mm_1InverseWarp.nii.gz
endif

# CSF mask
if ( ! -f ${output_dir}/${m}/csf_mask_native.nii.gz ) then
    echo "  Transforming CSF mask..."
    antsApplyTransforms -d 3 \
        -i ${mskpth}/segmentation_three_types_prob_3_csf_0.5mm.nii.gz \
        -r ${raw_data}/${m}/InplaneT2.nii.gz \
        -o ${output_dir}/${m}/csf_mask_native.nii.gz \
        -n Linear \
        -t [${temp_dir}/${m}_t2_to_template_0.5mm_0GenericAffine.mat,1] \
        -t ${temp_dir}/${m}_t2_to_template_0.5mm_1InverseWarp.nii.gz
endif

echo ""

# ==========================================
# TRANSFORM VOCALIZATION ROIs TO NATIVE
# ==========================================

echo "Transforming vocalization network ROIs to native space..."

# Check if ROI masks exist
if ( -d ${roi_dir} ) then
    echo "  Found ROI masks directory"

    # Transform each network to native space
    foreach network (network_1_vocal_motor network_2_limbic network_3_auditory network_4_temporal)
        if ( -f ${roi_dir}/${network}.nii.gz ) then
            echo "  Transforming ${network}..."
            antsApplyTransforms -d 3 \
                -i ${roi_dir}/${network}.nii.gz \
                -r ${raw_data}/${m}/InplaneT2.nii.gz \
                -o ${output_dir}/${m}/${network}_native.nii.gz \
                -n NearestNeighbor \
                -t [${temp_dir}/${m}_t2_to_template_0.5mm_0GenericAffine.mat,1] \
                -t ${temp_dir}/${m}_t2_to_template_0.5mm_1InverseWarp.nii.gz
        endif
    end

    echo "  ✓ Network ROIs transformed to native space"
else
    echo "  WARNING: ROI masks directory not found"
    echo "  Run: bash extract_vocalization_ROIs_actual_labels.sh first"
endif

echo ""

# ==========================================
# OPTIONAL: TRANSFORM TEMPLATE T2 TO NATIVE
# ==========================================

echo "Transforming template T2 to native space (for visualization)..."

if ( ! -f ${output_dir}/${m}/template_T2w_in_native_space.nii.gz ) then
    echo "  Warping template to ${m} anatomy..."
    antsApplyTransforms -d 3 \
        -i ${mskpth}/template_T2w_brain_0.5mm.nii.gz \
        -r ${raw_data}/${m}/InplaneT2.nii.gz \
        -o ${output_dir}/${m}/template_T2w_in_native_space.nii.gz \
        -n Linear \
        -t [${temp_dir}/${m}_t2_to_template_0.5mm_0GenericAffine.mat,1] \
        -t ${temp_dir}/${m}_t2_to_template_0.5mm_1InverseWarp.nii.gz

    echo "  ✓ Template T2 warped to native space"
endif

echo ""

end

# ==========================================
# SUMMARY
# ==========================================

echo "=========================================="
echo "TEMPLATE→NATIVE TRANSFORMATION COMPLETE"
echo "=========================================="
echo ""
echo "Native-space files created in: ${output_dir}/${monkey}/"
echo ""
echo "Atlases in native space:"
ls -lh ${output_dir}/${monkey}/atlas_*_native.nii.gz
echo ""
echo "Tissue masks in native space:"
ls -lh ${output_dir}/${monkey}/*_mask_native.nii.gz
echo ""
echo "Network ROIs in native space (if available):"
ls -lh ${output_dir}/${monkey}/network_*_native.nii.gz 2>/dev/null
echo ""
echo "Usage:"
echo "  1. Visualize ROIs on subject's own anatomy:"
echo "     afni &"
echo "     # Underlay: ${raw_data}/${monkey}/InplaneT2.nii.gz"
echo "     # Overlay: ${output_dir}/${monkey}/network_*_native.nii.gz"
echo ""
echo "  2. Extract ROI volumes in native space:"
echo "     3dROIstats -mask ${output_dir}/${monkey}/atlas_*_native.nii.gz ..."
echo ""
echo "  3. Check registration quality:"
echo "     Compare template_T2w_in_native_space.nii.gz with InplaneT2.nii.gz"
echo ""
