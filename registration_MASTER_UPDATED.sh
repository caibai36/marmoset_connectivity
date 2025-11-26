#!/bin/tcsh -xef

# ==========================================
# MARMOSET VOCALIZATION DEVELOPMENT ANALYSIS
# Registration to MBM Template Space
# ==========================================
# Updated for actual data paths and 0.5mm downsampled templates
# ==========================================

# ==========================================
# USER SPECIFICATIONS - EDIT THESE
# ==========================================

# Subject IDs (directory names: m6, m7, m8, etc.)
# Start with one subject for testing, then add more
set monkey = (m6)  # Add more: m7 m8 m9 m10 m11 m12 m14 m15 m16 m17 m18 m19 m20 m21 m22 m23 m24 m25 m26 m27 m28 m29 m30 m31 m32

# Run numbers (how many BOLD runs per subject)
# For NIH data, typically 8 runs
set run = (1 2 3 4 5 6 7 8)

# Phase encoding directions
# NIH: up (u) and down (d)
# UWO: only up (u)
set pe = (u d)  # u=up, d=down

# ==========================================
# DIRECTORY PATHS - VERIFIED PATHS
# ==========================================

# Raw data location
set raw_data_dir = /data02/share/bin-wu/data/marmoset/brain/nih_uwo/nih/NIH-data

# MBM template directory (0.5mm downsampled versions)
set mskpth = /data02/share/bin-wu/data/marmoset/brain/nih_uwo/marmoset_brain_mapping_v3/Marmoset_Brain_Mappping_v3.0.1/MBM_v3.0.1_0.5mm

# Working directory for all outputs
set work_base = /work01/home/bin-wu/workspace/projects/clib/egs/riken/riken_mri_s0/exp/mri/sandbox/marmoset_registration

# Subdirectories (will be created if they don't exist)
set apth = ${work_base}/preprocessed           # Preprocessed BOLD input
set anat_pth = ${work_base}/anatomical         # Anatomical files per subject
set output_dir = ${work_base}/template_space   # Registered data output
set corrpth = ${work_base}/correlation         # Final connectivity-ready files
set temp_dir = ${work_base}/temp               # Temporary files (cleaned up)

# ==========================================
# SETUP - Create directories
# ==========================================

if ( ! -d ${work_base} ) then
    echo "Creating base working directory: ${work_base}"
    mkdir -p ${work_base}
endif

cd ${output_dir}

if ( ! -d ${temp_dir} ) then
    mkdir -p ${temp_dir}
endif

if ( ! -d ${corrpth} ) then
    mkdir -p ${corrpth}
endif

# ==========================================
# MAIN PROCESSING LOOP
# ==========================================

foreach m ( ${monkey} )
    echo "=========================================="
    echo "Processing subject: ${m}"
    echo "=========================================="

    foreach r ( ${run} )
        foreach p ( ${pe} )

            echo ""
            echo "  Run ${r}, phase encoding: ${p}"
            echo ""

            # Check if preprocessed input exists
            if (! -f ${apth}/errts.${m}_${p}_bold_${r}.tproject.nii.gz) then
                echo "  WARNING: Preprocessed BOLD not found: errts.${m}_${p}_bold_${r}.tproject.nii.gz"
                echo "  Skipping this run..."
                continue
            endif

            # ==========================================
            # STEP 1: Register mean functional to T2
            # ==========================================

            if(! -f ${temp_dir}/${m}_${p}_bold_${r}.mean_to_t2.nii.gz) then
                echo "  [1/7] Registering mean BOLD to T2..."
                flirt -searchrx -360 360 -searchry -360 360 -searchrz -360 360 \
                      -in ${apth}/${m}_${p}_bold_${r}.mean.nii.gz \
                      -ref ${anat_pth}/${m}/InplaneT2.nii.gz \
                      -out ${temp_dir}/${m}_${p}_bold_${r}.mean_to_t2.nii.gz \
                      -omat ${temp_dir}/${m}_${p}_bold_${r}.mean_to_t2.mat
            else
                echo "  [1/7] Mean BOLD to T2 registration exists, skipping..."
            endif

            # ==========================================
            # STEP 2: Apply transform to preprocessed BOLD
            # ==========================================

            if(! -f ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_t2.nii.gz) then
                echo "  [2/7] Applying transform to preprocessed BOLD..."
                flirt -in ${apth}/errts.${m}_${p}_bold_${r}.tproject.nii.gz \
                      -ref ${anat_pth}/${m}/InplaneT2.nii.gz \
                      -applyxfm \
                      -init ${temp_dir}/${m}_${p}_bold_${r}.mean_to_t2.mat \
                      -out ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_t2.nii.gz \
                      -interp trilinear
            else
                echo "  [2/7] BOLD to T2 transform exists, skipping..."
            endif

            # ==========================================
            # STEP 3: Register mask to T2
            # ==========================================

            if(! -f ${temp_dir}/${m}_mask_to_t2.nii.gz) then
                echo "  [3/7] Registering mask to T2..."
                flirt -searchrx -360 360 -searchry -360 360 -searchrz -360 360 \
                      -in ${anat_pth}/${m}/mask.nii.gz \
                      -ref ${anat_pth}/${m}/InplaneT2.nii.gz \
                      -out ${temp_dir}/${m}_mask_to_t2.nii.gz
            else
                echo "  [3/7] Mask to T2 registration exists, skipping..."
            endif

            # ==========================================
            # STEP 4: Binarize mask
            # ==========================================

            if(! -f ${temp_dir}/${m}_mask_to_t2_binary.nii.gz) then
                echo "  [4/7] Binarizing mask..."
                3dcalc -a ${temp_dir}/${m}_mask_to_t2.nii.gz \
                       -expr 'ispositive(a)' \
                       -prefix ${temp_dir}/${m}_mask_to_t2_binary.nii.gz
            else
                echo "  [4/7] Binary mask exists, skipping..."
            endif

            # ==========================================
            # STEP 5: Create skull-stripped T2
            # ==========================================

            if(! -f ${temp_dir}/${m}_InplaneT2_masked.nii.gz) then
                echo "  [5/7] Creating skull-stripped T2..."
                3dcalc -a ${anat_pth}/${m}/InplaneT2.nii.gz \
                       -b ${temp_dir}/${m}_mask_to_t2_binary.nii.gz \
                       -expr '(a*b)' \
                       -prefix ${temp_dir}/${m}_InplaneT2_masked.nii.gz
            else
                echo "  [5/7] Skull-stripped T2 exists, skipping..."
            endif

            # ==========================================
            # STEP 6: Register T2 to MBM template (SLOW STEP!)
            # ==========================================

            if(! -f ${temp_dir}/${m}_t2_to_template_0.5mm_Warped.nii.gz) then
                echo "  [6/7] Registering T2 to MBM template (this may take 10-30 minutes)..."
                antsRegistrationSyNQuick.sh -d 3 \
                    -f ${mskpth}/template_T2w_brain_0.5mm.nii.gz \
                    -m ${temp_dir}/${m}_InplaneT2_masked.nii.gz \
                    -o ${temp_dir}/${m}_t2_to_template_0.5mm_
            else
                echo "  [6/7] T2 to template registration exists, skipping..."
            endif

            # ==========================================
            # STEP 7: Apply transforms to BOLD data
            # ==========================================

            if(! -f ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_template.nii.gz) then
                echo "  [7/7] Applying transforms to BOLD data..."
                antsApplyTransforms -e 3 \
                    -i ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_t2.nii.gz \
                    -r ${temp_dir}/${m}_t2_to_template_0.5mm_Warped.nii.gz \
                    -o ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_template.nii.gz \
                    -t ${temp_dir}/${m}_t2_to_template_0.5mm_1Warp.nii.gz \
                    -t ${temp_dir}/${m}_t2_to_template_0.5mm_0GenericAffine.mat
            else
                echo "  [7/7] BOLD to template transform exists, skipping..."
            endif

            # ==========================================
            # FINAL OUTPUTS: Mask and create regressors
            # ==========================================

            # Mask with gray matter
            if(! -f ${corrpth}/${m}_${p}_bold_${r}_to_template_0.5mm_masked_gm.nii.gz) then
                echo "  Creating gray matter masked output..."
                3dcalc -a ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_template.nii.gz \
                       -b ${mskpth}/segmentation_three_types_prob_1_gray_0.5mm.nii.gz \
                       -expr '(a*b)' \
                       -prefix ${corrpth}/${m}_${p}_bold_${r}_to_template_0.5mm_masked_gm.nii.gz
            else
                echo "  Gray matter masked output exists, skipping..."
            endif

            # Create white matter nuisance regressor
            if(! -f ${corrpth}/${m}_${p}_bold_${r}_wm_nui_regressor.1D) then
                echo "  Extracting white matter nuisance regressor..."
                3dmaskave -quiet \
                    -mask ${mskpth}/segmentation_three_types_prob_2_white_0.5mm.nii.gz \
                    ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_template.nii.gz \
                    > ${corrpth}/${m}_${p}_bold_${r}_wm_nui_regressor.1D
            else
                echo "  White matter regressor exists, skipping..."
            endif

            # Create CSF nuisance regressor
            if(! -f ${corrpth}/${m}_${p}_bold_${r}_csf_nui_regressor.1D) then
                echo "  Extracting CSF nuisance regressor..."
                3dmaskave -quiet \
                    -mask ${mskpth}/segmentation_three_types_prob_3_csf_0.5mm.nii.gz \
                    ${temp_dir}/errts.${m}_${p}_bold_${r}.tproject_to_template.nii.gz \
                    > ${corrpth}/${m}_${p}_bold_${r}_csf_nui_regressor.1D
            else
                echo "  CSF regressor exists, skipping..."
            endif

            # Combine nuisance regressors
            if(! -f ${corrpth}/${m}_${p}_bold_${r}_nui_regressors.1D) then
                echo "  Combining nuisance regressors..."
                paste ${corrpth}/${m}_${p}_bold_${r}_wm_nui_regressor.1D \
                      ${corrpth}/${m}_${p}_bold_${r}_csf_nui_regressor.1D \
                      > ${corrpth}/${m}_${p}_bold_${r}_nui_regressors.1D

                # Clean up individual regressor files
                rm ${corrpth}/${m}_${p}_bold_${r}_wm_nui_regressor.1D
                rm ${corrpth}/${m}_${p}_bold_${r}_csf_nui_regressor.1D
            else
                echo "  Combined nuisance regressors exist, skipping..."
            endif

            echo "  [COMPLETE] Run ${r}, phase encoding ${p}"
            echo ""

        end  # end phase encoding loop
    end  # end run loop

    echo "=========================================="
    echo "Subject ${m} processing complete!"
    echo "=========================================="
    echo ""

end  # end monkey loop

# ==========================================
# CLEANUP (optional - comment out to keep temp files)
# ==========================================

echo "Cleaning up temporary files..."
foreach m ( ${monkey} )
    # Only remove temp files, keep important registration outputs
    # Uncomment the line below if you want to clean temp directory
    # rm ${temp_dir}/${m}_*.nii.gz
end

echo ""
echo "=========================================="
echo "ALL PROCESSING COMPLETE!"
echo "=========================================="
echo ""
echo "Output files in: ${corrpth}/"
echo ""
echo "Files ready for ROI analysis:"
ls -lh ${corrpth}/*_to_template_0.5mm_masked_gm.nii.gz | head -10
echo ""
echo "Next step: Run STAGE3 to organize data for ROI extraction"
