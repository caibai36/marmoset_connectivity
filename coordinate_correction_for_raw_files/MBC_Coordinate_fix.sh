#!/bin/bash
# This script will fix coordinate issues for marmoset connectome protocol at NIH 7T
# Because Bruker doesn’t have sphinx position for NHP, and gradient polarities of NIH 7T are non-standard.
# Cecil Chern-Chyi Yen cecil.yen@nih.gov

# 12/13/2021 Initial release
# 12/14/2021 Fix Gzipped NIfTI file does not work with AFNI nifti_tool
# 12/15/2021 Use pigz can speed up processing gz

fname=$1
if [[ $fname =~ \.gz$ ]];then
	if [ -x "$(command -v pigz)" ]; then
		pigz -d $fname
	else
		gzip -d $fname
	fi
	fname=${fname%.*}
fi

srow=$(nifti_tool -disp_hdr -field srow_x -field srow_y -field srow_z -infile $fname)
declare -A arr
arr[0,0]=$(echo `echo $srow|cut -d" " -f19` *-1 | bc)
arr[0,1]=$(echo `echo $srow|cut -d" " -f20` *-1 | bc)
arr[0,2]=$(echo `echo $srow|cut -d" " -f21` *-1 | bc)
arr[0,3]=$(echo `echo $srow|cut -d" " -f22` *-1 | bc)
arr[1,0]=$(echo $srow|cut -d" " -f33)
arr[1,1]=$(echo $srow|cut -d" " -f34)
arr[1,2]=$(echo $srow|cut -d" " -f35)
arr[1,3]=$(echo $srow|cut -d" " -f36)
arr[2,0]=$(echo `echo $srow|cut -d" " -f26` *-1 | bc)
arr[2,1]=$(echo `echo $srow|cut -d" " -f27` *-1 | bc)
arr[2,2]=$(echo `echo $srow|cut -d" " -f28` *-1 | bc)
arr[2,3]=$(echo `echo $srow|cut -d" " -f29` *-1 | bc)

nifti_tool -mod_hdr -mod_field srow_x "${arr[0,0]} ${arr[0,1]} ${arr[0,2]} ${arr[0,3]}" -mod_field srow_y "${arr[1,0]} ${arr[1,1]} ${arr[1,2]} ${arr[1,3]}" -mod_field srow_z "${arr[2,0]} ${arr[2,1]} ${arr[2,2]} ${arr[2,3]}" -overwrite -infile $fname

if [ -x "$(command -v pigz)" ]; then
	pigz $fname &
else
	gzip $fname &
fi
