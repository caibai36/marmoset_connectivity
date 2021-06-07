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
${tdir}/m1/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m2/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m3/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m4/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m5/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m6/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m7/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m8/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m9/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m10/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m11/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m12/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m14/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m15/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m16/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m17/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m18/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m19/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m20/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m21/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m22/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m23/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m24/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m25/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m26/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m27/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m28/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m29/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m30/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m31/group_${k}_${j}_${i}.nii.gz'[0]' \
${tdir}/m32/group_${k}_${j}_${i}.nii.gz'[0]' \
-prefix ${tdir}/group/group_${k}_${j}_${i}.nii.gz

3dcalc -a ${tdir}/group/group_${k}_${j}_${i}.nii.gz'[1]' -expr '(a)' -prefix ${zdir}/zmap/group_${k}_${j}_${i}_Z.nii.gz
fslcpgeom ${sourcehd} ${zdir}/zmap/group_${k}_${j}_${i}_Z.nii.gz
fi &

done
done
done
