#!/bin/tcsh -xef

# user specifications

set monkey = () #sub-01 sub-02...
set run = () #1 2...
set pe = (up down) #phase encoding directions, UWO = up, NIH = up down

foreach m ( ${monkey} )
foreach r (${run})
foreach p (${pe})


set corrpth = #correlation path
set mskpth = #path to mask
cd ${corrpth}

if (-f ${m}_${p}_${r}_to_template_errts_.5iso_masked_gm.nii.gz)then

#create output directory if it doesn't already exist
if (! -d ${corrpth}/${m}_${p}_${r}_split/)then
mkdir ${corrpth}/${m}_${p}_${r}_split/
endif

#calculate the correlation between each voxel and every other voxel, output is each voxel (seed) and resultant connectivity as a volume (ordered by coordinate)
if (-f ${m}_${p}_${r}_nui_regressors.1D)then
if(! -f ${m}_${p}_${r}_corrmap.nii.gz)then
3dTcorrMap -ort ${m}_${p}_${r}_nui_regressors.1D -input ${m}_${p}_${r}_to_template_errts_.5iso_masked_gm.nii.gz -mask ${mskpth}/gray_template_.5.nii -Corrmap ${m}_${p}_${r}_corrmap.nii.gz
endif
endif

endif

endif

end
end
end
