#!/bin/tcsh -xef

# user specifications

set monkey = (m1) #m1 m2...
set run = (1) #1 2...
set tr_counts = (600) #number of volumes
set reg_vol = (300) #volume number for within run registration
set tr = (1.5) #in seconds; UWO data = 1.5s, NIH data = 2s
set bp_l = (.1) #bandpass, .1
set bp_h = (.01) #bandpass, .01
set pe_correct = (no) # phase encoding correction? UWO = no, NIH = yes
set pe = (up) #phase encoding directions, UWO = up, NIH = up down
set acpr = (1_0_0) #phase encoding correction file, NIH = 1_0_0
set blur = (1.5) #spatial blurring, 1.5 mm

set n_cpu = (10) #number of processors for parallel processing

foreach m ( ${monkey} )
foreach r ( ${run})
foreach a ( ${acpr})

set apth = /Users/dschaeff/google_drive/Documents/Manuscripts/open_source_seed_corr/Nature_Neuroscience/code/test_uwo/${m}#path to individual subject BOLD files
set stats_dir = /Users/dschaeff/google_drive/Documents/Manuscripts/open_source_seed_corr/Nature_Neuroscience/code/test_uwo/${m}#path to statistics output
set acqpth = /Users/dschaeff/google_drive/Documents/Manuscripts/open_source_seed_corr/Nature_Neuroscience/code/test_uwo/${m}#acquisition parameter for topup correction, required for PE correction only

set output_dir = ${apth}/${m}_${r}.results
set temp_dir = ${apth}/temp

if ( ! -d ${output_dir} ) then
	mkdir ${output_dir}
endif

if ( ! -d ${temp_dir} ) then
	mkdir ${temp_dir}
endif

cd ${apth}

#phase encoding correction
if( ${pe_correct} == "yes" ) then

if (-f BOLD_up_${r}.nii.gz)then

if (! -f ${temp_dir}/SEEPI_up_mean.nii.gz)then
fslmaths SEEPI_up.nii.gz -Tmean ${temp_dir}/SEEPI_up_mean.nii.gz
fslmaths SEEPI_down.nii.gz -Tmean ${temp_dir}/SEEPI_down_mean.nii.gz
endif

if (! -f ${temp_dir}/BOLD_up_${r}_middle_vol.nii.gz)then
3dcalc -a BOLD_up_${r}.nii.gz"[${reg_vol}]" -expr '(a)' -prefix ${temp_dir}/BOLD_up_${r}_middle_vol.nii.gz
endif

if (! -f ${temp_dir}/merged_${r}.nii.gz)then
fslmerge -t ${temp_dir}/merged_${r}.nii.gz ${temp_dir}/BOLD_up_${r}_middle_vol.nii.gz ${temp_dir}/SEEPI_up_mean.nii.gz ${temp_dir}/SEEPI_down_mean.nii.gz
endif

if (! -f ${temp_dir}/reg_up_down_to_middle_${r}.nii.gz)then
3dvolreg -prefix ${temp_dir}/reg_up_down_to_middle_${r}.nii.gz ${temp_dir}/merged_${r}.nii.gz
endif

if (! -f ${temp_dir}/SEEPI_down_mean_reg_${r}.nii.gz)then
3dcalc -a ${temp_dir}/reg_up_down_to_middle_${r}.nii.gz'[1]' -expr '(a)' -prefix ${temp_dir}/SEEPI_up_mean_reg_${r}.nii.gz
3dcalc -a ${temp_dir}/reg_up_down_to_middle_${r}.nii.gz'[2]' -expr '(a)' -prefix ${temp_dir}/SEEPI_down_mean_reg_${r}.nii.gz
endif

if (! -f ${temp_dir}/SEEPI_merged_reg_${r}.nii.gz)then
fslmerge -t ${temp_dir}/SEEPI_merged_reg_${r}.nii.gz ${temp_dir}/SEEPI_up_mean_reg_${r}.nii.gz ${temp_dir}/SEEPI_down_mean_reg_${r}.nii.gz
endif

cd ${output_dir}

if (! -f ${m}_${r}_topup_${a}_fieldcoef.nii.gz)then
topup --imain=${temp_dir}/SEEPI_merged_reg_${r}.nii.gz --datain=${acqpth}/acqparams_${a}.txt --config=${acqpth}/updown.cnf --out=${temp_dir}/${m}_${r}_topup_${a}
endif

endif
endif

foreach p ( ${pe})

cd ${apth}

if (-f BOLD_${p}_${r}.nii.gz)then

cd ${output_dir}

#volume removal for steady-state stabilization, default is the first 10 volumes
if ( ! -f ${temp_dir}/pb00.${m}_${p}_${r}.tcat+orig.HEAD ) then

if (-f ${apth}/BOLD_${p}_${r}.nii.gz)then
3dTcat -prefix ${temp_dir}/pb00.${m}_${p}_${r}.tcat ${apth}/BOLD_${p}_${r}.nii.gz'[10..$]'
endif
endif

cd ${temp_dir}

# data check: compute outlier fraction for each volume
if ( ! -f outcount.${m}_${p}_${r}.1D) then
touch out.pre_ss_warn.txt
3dToutcount -automask -fraction -polort 5 -legendre pb00.${m}_${p}_${r}.tcat+orig > outcount.${m}_${p}_${r}.1D

# catenate outlier counts into a single time series
cat outcount.${m}_${p}_${r}.1D > outcount.${m}_${p}_${r}_all.1D

endif

# apply 3dDespike to each run
if ( ! -f pb01.${m}_${p}_${r}.despike+orig.HEAD ) then
3dDespike -NEW -nomask -prefix pb01.${m}_${p}_${r}.despike pb00.${m}_${p}_${r}.tcat+orig
endif

# time shift data so all slice timing is the same
if ( ! -f pb02.${m}_${p}_${r}.tshift+orig.HEAD ) then
3dTshift -tzero 0 -quintic -prefix pb02.${m}_${p}_${r}.tshift pb01.${m}_${p}_${r}.despike+orig
endif


# extract volreg registration base

if (! -f ${temp_dir}/BOLD_up_${r}_middle_vol.nii.gz)then
3dcalc -a ${apth}/BOLD_up_${r}.nii.gz"[${reg_vol}]" -expr '(a)' -prefix ${temp_dir}/BOLD_up_${r}_middle_vol.nii.gz
endif


if ( ! -f pb03.${m}_${p}_${r}.volreg.nii.gz ) then

# align each dset to base volume, base volume calculated in pe correction above, ${reg_vol} volume of "UP" before stabilzation volume removal
    # register each volume to the base


3dvolreg -verbose -zpad 1 -base BOLD_up_1_middle_vol.nii.gz \
-1Dfile dfile.${m}_${p}_${r}.1D -prefix pb03.${m}_${p}_${r}.volreg.nii.gz \
-cubic \
pb02.${m}_${p}_${r}.tshift+orig

# make a single file of registration params
cat dfile.${m}_${p}_${r}.1D > dfile.${m}_${p}_${r}_all.1D
endif

## apply PE correction to registered images
if( ${pe_correct} == "yes" ) then
if (-f pb03.${m}_up_${r}.volreg.nii.gz ) then
if (! -f ${temp_dir}/${m}_${r}_BOLD_pec_up.nii.gz)then
applytopup --imain=pb03.${m}_up_${r}.volreg.nii.gz --topup=${temp_dir}/${m}_${r}_topup_${a} --datain=${acqpth}/acqparams_${a}.txt --method=jac --inindex=1 --out=${temp_dir}/${m}_${r}_BOLD_pec_up.nii.gz
endif
endif

if (-f pb03.${m}_down_${r}.volreg.nii.gz ) then
if (! -f ${temp_dir}/${m}_${r}_BOLD_pec_down.nii.gz)then
applytopup --imain=pb03.${m}_down_${r}.volreg.nii.gz --topup=${temp_dir}/${m}_${r}_topup_${a} --datain=${acqpth}/acqparams_${a}.txt --method=jac --inindex=2 --out=${temp_dir}/${m}_${r}_BOLD_pec_down.nii.gz
endif
endif
endif
#estimate motion
if (! -f pb03.${m}_${p}_${r}.volreg.est.nii.gz)then
3dvolreg -verbose -zpad 1 -base ${reg_vol} \
-1Dfile dfile.${m}_${p}_${r}_est.1D -prefix pb03.${m}_${p}_${r}.volreg.est.nii.gz \
-cubic \
pb02.${m}_${p}_${r}.tshift+orig
endif

#rename file if no PE corrected file exists
if (! -f ${temp_dir}/${m}_${r}_BOLD_pec_${p}.nii.gz)then
3dcalc -a pb03.${m}_${p}_${r}.volreg.nii.gz -expr '(a)' -prefix ${temp_dir}/${m}_${r}_BOLD_pec_${p}.nii.gz
endif

# blur each volume of each run
if (! -f pb04.${m}_${r}_${p}.blur.nii.gz)then
3dmerge -1blur_fwhm ${blur} -doall -prefix pb04.${m}_${r}_${p}.blur ${temp_dir}/${m}_${r}_BOLD_pec_${p}.nii.gz
endif

# compute de-meaned motion parameters (for use in regression)
if (! -f ${m}_${p}_${r}_motion_demean.1D)then
1d_tool.py -infile dfile.${m}_${p}_${r}_est.1D -set_nruns 1 -demean -write ${m}_${p}_${r}_motion_demean.1D
endif

# compute motion parameter derivatives (for use in regression)
if (! -f motion_deriv_${m}_${p}_${r}.1D)then
1d_tool.py -infile dfile.${m}_${p}_${r}_est.1D -set_nruns 1 -derivative -demean -write motion_deriv_${m}_${p}_${r}.1D
endif

#  create censor file, for censoring motion
if (! -f motion_${m}_${p}_${r}_enorm.1D)then
1d_tool.py -infile dfile.${m}_${p}_${r}_est.1D -set_nruns 1 -show_censor_count -censor_prev_TR -censor_motion .5 motion_${m}_${p}_${r}
endif

# create bandpass regressors
if (! -f bandpass_rall_${m}_${p}_${r}.1D)then
1dBport -nodata ${tr_counts} ${tr} -band 0.01 0.1 -invert -nozero > bandpass_rall_${m}_${p}_${r}.1D
endif

set ktrs = `1d_tool.py -infile motion_${m}_${p}_${r}_censor.1D -show_trs_uncensored encoded`

# run the regression analysis
if (! -f ${output_dir}/errts.${m}_${p}_${r}.tproject.nii.gz)then
3dDeconvolve -input ${temp_dir}/pb04.${m}_${r}_${p}.blur+orig.HEAD                          \
-censor motion_${m}_${p}_${r}_censor.1D                                       \
-ortvec bandpass_rall_${m}_${p}_${r}.1D bandpass                                      \
-polort 5                                                              \
-num_stimts 12                                                         \
-stim_file 1 ${m}_${p}_${r}_motion_demean.1D'[0]' -stim_base 1 -stim_label 1 roll_01  \
-stim_file 2 ${m}_${p}_${r}_motion_demean.1D'[1]' -stim_base 2 -stim_label 2 pitch_01 \
-stim_file 3 ${m}_${p}_${r}_motion_demean.1D'[2]' -stim_base 3 -stim_label 3 yaw_01   \
-stim_file 4 ${m}_${p}_${r}_motion_demean.1D'[3]' -stim_base 4 -stim_label 4 dS_01    \
-stim_file 5 ${m}_${p}_${r}_motion_demean.1D'[4]' -stim_base 5 -stim_label 5 dL_01    \
-stim_file 6 ${m}_${p}_${r}_motion_demean.1D'[5]' -stim_base 6 -stim_label 6 dP_01    \
-stim_file 7 motion_deriv_${m}_${p}_${r}.1D'[0]' -stim_base 7 -stim_label 7 roll_02   \
-stim_file 8 motion_deriv_${m}_${p}_${r}.1D'[1]' -stim_base 8 -stim_label 8 pitch_02  \
-stim_file 9 motion_deriv_${m}_${p}_${r}.1D'[2]' -stim_base 9 -stim_label 9 yaw_02    \
-stim_file 10 motion_deriv_${m}_${p}_${r}.1D'[3]' -stim_base 10 -stim_label 10 dS_02  \
-stim_file 11 motion_deriv_${m}_${p}_${r}.1D'[4]' -stim_base 11 -stim_label 11 dL_02  \
-stim_file 12 motion_deriv_${m}_${p}_${r}.1D'[5]' -stim_base 12 -stim_label 12 dP_02  \
-fout -tout -x1D ${m}_${p}_${r}.X.xmat.1D -xjpeg ${m}_${p}_${r}.X.jpg                                \
-x1D_uncensored ${m}_${p}_${r}.X.nocensor.xmat.1D                                     \
-fitts fitts.${m}_${p}_${r}                                                    \
-errts errts.${m}_${p}_${r}                                                  \
-x1D_stop                                                              \
-bucket stats.${m}_${p}_${r} \
-jobs ${n_cpu}

# 3dTproject to project out regression matrix
3dTproject -polort 0 -input pb04.${m}_${r}_${p}.blur+orig.HEAD                   \
-censor motion_${m}_${p}_${r}_censor.1D -cenmode ZERO                  \
-ort ${m}_${p}_${r}.X.nocensor.xmat.1D -prefix errts.${m}_${p}_${r}.tproject

3dcalc -a errts.${m}_${p}_${r}.tproject+orig. -expr '(a)' -prefix ${output_dir}/errts.${m}_${p}_${r}.tproject.nii.gz
endif

if (! -f ${output_dir}/${m}_${p}_${r}.mean.nii.gz )then
3dTstat -prefix ${output_dir}/${m}_${p}_${r}.mean.nii.gz ${temp_dir}/${m}_${r}_BOLD_pec_${p}.nii.gz
endif


endif
endif

end
end
end
end


foreach m ( ${monkey} )
foreach r ( ${run})
foreach a ( ${acpr})

if (-f ${output_dir}/errts.${m}_${p}_${r}.tproject.nii.gz)then
rm ${temp_dir}/*
endif

end
end
end
