#!/bin/tcsh -xef

# user specifications

set m = ( ) #sub-01 sub-02...

set group_space_file = ( )  #group_38_67_34_Z... any funcitonal file in template space


## First, establish the registration of the template space image to the individual's T2 (no skull for either). Uses downsampled (.5mm isotropic)template space.
if(! -f ${m}_template_to_t2_.5iso_Warped.nii.gz)then
antsRegistrationSyNQuick.sh -d 3 -f ${m}_InplaneT2_masked.nii.gz -m template_T2w_brain_.5iso.nii.gz -o ${m}_template_to_t2_.5iso_
endif


# Next, apply the transform to the map of interest (e.g.,group_38_67_34_Z.nii.gz )
if(! -f ${group_space_file}_to_${m}_t2.nii.gz)then

antsApplyTransforms -e 3 -i ${group_space_file}.nii.gz -r ${m}_InplaneT2_masked.nii.gz -o ${group_space_file}_to_${m}_t2.nii.gz -t ${m}_template_to_t2_.5iso_0GenericAffine.mat -t ${m}_template_to_t2_.5iso_1Warp.nii.gz

endif
