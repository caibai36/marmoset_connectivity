#!/bin/tcsh -xef

# user specifications

set monkey = () #m1 m2...
set run = () #1 2...
set pe = (up down) #phase encoding directions, UWO = up, NIH = up down


foreach m ( ${monkey} )
foreach r ( ${run})
foreach p ( ${pe})


set apth = #data directory
set output_dir = #output directory
set corrpth = #directory containing correlation files
set mskpth = #directory containing mask fo anatomical image
set temp_dir = # temporary directory, to be deleted after processing

cd ${output_dir}

if ( ! -d ${temp_dir} ) then
	mkdir ${temp_dir}
endif

if ( ! -d ${corrpth} ) then
	mkdir ${corrpth}
endif

## flirt mean functional to t2 with skull
if(! -f ${temp_dir}/${m}_${p}_${r}.mean_to_t2.nii.gz)then
flirt -searchrx -360 360 -searchry -360 360 -searchrz -360 360 -in ${m}_${p}_${r}.mean.nii.gz -ref ${apth}/InplaneT2.nii.gz -out ${temp_dir}/${m}_${p}_${r}.mean_to_t2.nii.gz -omat ${temp_dir}/${m}_${p}_${r}.mean_to_t2.mat
endif

if(! -f ${temp_dir}/errts.${m}_${p}_${r}.tproject_to_t2.nii.gz)then
flirt -in errts.${m}_${p}_${r}.tproject.nii.gz -ref ${apth}/InplaneT2.nii.gz -applyxfm -init ${temp_dir}/${m}_${p}_${r}.mean_to_t2.mat -out ${temp_dir}/errts.${m}_${p}_${r}.tproject_to_t2.nii.gz -interp trilinear
endif

if(! -f ${temp_dir}/mask_to_t2.nii.gz)then
flirt -searchrx -360 360 -searchry -360 360 -searchrz -360 360 -in ${apth}/mask.nii.gz -ref ${apth}/InplaneT2.nii.gz -out ${temp_dir}/mask_to_t2.nii.gz
endif

if(! -f ${temp_dir}/mask_to_t2_binary.nii.gz)then
3dcalc -a ${temp_dir}/mask_to_t2.nii.gz -expr 'ispositive(a)' -prefix ${temp_dir}/mask_to_t2_binary.nii.gz
endif

if(! -f ${temp_dir}/InplaneT2_masked.nii.gz)then
3dcalc -a ${apth}/InplaneT2.nii.gz -b ${temp_dir}/mask_to_t2_binary.nii.gz -expr '(a*b)' -prefix ${temp_dir}/InplaneT2_masked.nii.gz
endif

## register t2, no skull, to Template
if(! -f ${temp_dir}/${m}_t2_to_template_.5iso_Warped.nii.gz)then
antsRegistrationSyNQuick.sh -d 3 -f ${mskpth}/template_T2w_brain_.5iso.nii.gz -m ${temp_dir}/InplaneT2_masked.nii.gz -o ${temp_dir}/${m}_t2_to_template_.5iso_
endif

if(! -f ${temp_dir}/errts.${m}_${p}_${r}.tproject_to_template.nii.gz)then
antsApplyTransforms -e 3 -i ${temp_dir}/errts.${m}_${p}_${r}.tproject_to_t2.nii.gz -r ${temp_dir}/${m}_t2_to_template_.5iso_Warped.nii.gz -o ${temp_dir}/errts.${m}_${p}_${r}.tproject_to_template.nii.gz -t ${temp_dir}/${m}_t2_to_template_.5iso_0GenericAffine.mat -t ${temp_dir}/${m}_t2_to_template_.5iso_1Warp.nii.gz
endif

# #mask resdiual file with gray matter only
if(! -f ${corrpth}/${m}_${p}_${r}_to_template_errts_.5iso_masked_gm.nii.gz)then
3dcalc -a ${temp_dir}/errts.${m}_${p}_${r}.tproject_to_template.nii.gz -b ${mskpth}/gray_template_.5.nii -expr '(a*b)' -prefix ${corrpth}/${m}_${p}_${r}_to_template_errts_.5iso_masked_gm.nii.gz
endif

# #create nuisance regressors
if(! -f ${corrpth}/${m}_${p}_${r}_wm_nui_regressor.1D)then
3dmaskave -quiet -mask ${mskpth}/white_matter_.5.nii ${temp_dir}/errts.${m}_${p}_${r}.tproject_to_template.nii.gz > ${corrpth}/${m}_${p}_${r}_wm_nui_regressor.1D
endif
#
if(! -f ${corrpth}/${m}_${p}_${r}_csf_nui_regressor.1D)then
3dmaskave -quiet -mask ${mskpth}/csf_.5.nii ${temp_dir}/errts.${m}_${p}_${r}.tproject_to_template.nii.gz > ${corrpth}/${m}_${p}_${r}_csf_nui_regressor.1D
endif
#
if(! -f ${corrpth}/${m}_${p}_${r}_nui_regressors.1D)then
paste ${corrpth}/${m}_${p}_${r}_wm_nui_regressor.1D ${corrpth}/${m}_${p}_${r}_csf_nui_regressor.1D > ${corrpth}/${m}_${p}_${r}_nui_regressors.1D
endif

rm ${corrpth}/${m}_${p}_${r}_wm_nui_regressor.1D
rm ${corrpth}/${m}_${p}_${r}_csf_nui_regressor.1D

end
end
end

foreach m ( ${monkey} )
cd ${temp_dir}
rm *
end
