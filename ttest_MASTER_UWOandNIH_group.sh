#!/bin/bash
# user specifications

corrpth=
tdir=
zdir=
mskpth=
sourcehd=

for i in `seq  1 59` ;do
for j in `seq  1 80` ;do
for k in `seq  1 54` ;do

if [ -e ${tdir}/m1/group_${k}_${j}_${i}.nii.gz ]; then

3dttest++ \
-mask ${mskpth}/gray_template_.5.nii \
-toz \
-setA \
${tdir}/sub-01/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-02/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-03/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-04/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-05/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-06/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-07/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-08/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-09/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-10/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-11/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-12/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-14/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-15/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-16/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-17/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-18/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-19/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-20/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-21/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-22/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-23/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-24/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-25/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-26/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-27/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-28/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-29/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-30/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-31/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/sub-32/group_${k}_${j}_${i}.nii.gz'[0]' \
-prefix ${tdir}/group/group_${k}_${j}_${i}.nii.gz

3dcalc -a ${tdir}/group/group_${k}_${j}_${i}.nii.gz'[1]' -expr '(a)' -prefix ${zdir}/zmap/group_${k}_${j}_${i}_Z.nii.gz
fslcpgeom ${sourcehd} ${zdir}/zmap/group_${k}_${j}_${i}_Z.nii.gz
fi &

done
done
done
