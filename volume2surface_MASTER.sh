#!/bin/bash

# user specifications

template_dir=
zdir=
sdir=

for i in `seq  1 59` ;do
for j in `seq  1 80` ;do
for k in `seq  1 54` ;do


if [ -e ${zdir}/group_${k}_${j}_${i}_Z.nii.gz ]; then

input=${zdir}/group_${k}_${j}_${i}_Z.nii.gz

## average values between pial and white surface
if [ ! -f ${sdir}/group_${k}_${j}_${i}_Z.R.func.gii ]; then
wb_command -volume-to-surface-mapping ${input} ${template_dir}/surfFS.rh.graymid.surf.gii ${sdir}/group_${k}_${j}_${i}_Z.R.func.gii -ribbon-constrained ${template_dir}/surfFS.rh.white.surf.gii ${template_dir}/surfFS.rh.pial.surf.gii
fi

fi
done
done
done
