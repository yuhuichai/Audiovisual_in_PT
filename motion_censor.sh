# !/bin/bash

# set data directories
dataDir=/Users/chaiy3/Data/Audiovisual_motion # replace with your own data directory
cd ${dataDir}

for patDir in 190530OWU_SAM.goodlars; do # replace with your own patient name
{
	top_dir=${dataDir}/${patDir}
	echo "*****************************************************************************************************"
	echo ++ start with ${patDir} 
	echo "*****************************************************************************************************"
	for filePre in anat lars; do
	{
		cd $top_dir/Func
		sl_dsets=($(ls -f *${filePre}*e00*.nii*)) # nii in short while nii.gz in float
		run_num=${#sl_dsets[@]}

		tr=`3dinfo -tr ${sl_dsets[0]}`
		echo "************** actual TR = ${tr}, changing with 3drefit -TR 3.302600 * ******************"
		trdouble=`bc -l <<< "2*$tr"`


		# *****************************************************************************************************
		cd $top_dir/${filePre}.sft
		# *****************************************************************************************************

		3drefit -TR ${trdouble} rbold*.nii
		3drefit -TR ${trdouble} rdant*.nii

		3drefit -space ORIG *.nii

		echo "******************** outcount and motion censor ***********************"
		for run in `seq 1 ${run_num}`; do
		{
		    if [ -f rbold${run}.nii ]; then
			    3dToutcount -mask brain_mask.nii -fraction -polort 4 -legendre \
			                rbold${run}.nii > outcount.bold.r$run.1D

			    3dToutcount -mask brain_mask.nii -fraction -polort 4 -legendre \
			                rdant${run}.nii > outcount.dant.r$run.1D

			    # - censor when more than 0.1 of automask voxels are outliers
			    # - step() defines which TRs to remove via censoring
			    1deval -a outcount.bold.r$run.1D -expr "1-step(a-0.1)" > rm.out.cen.bold.r$run.1D
			    1deval -a outcount.dant.r$run.1D -expr "1-step(a-0.1)" > rm.out.cen.dant.r$run.1D
			fi
		}&
		done
		wait
		# catenate outlier censor files into a single time series
		cat rm.out.cen.bold.r*.1D > outcount_bold_censor.1D
		cat rm.out.cen.dant.r*.1D > outcount_dant_censor.1D
		rm rm.out.cen*

		cat rp_bold*.txt > dfile_rall.bold.1D
		cat rp_dant*.txt > dfile_rall.dant.1D

		run_dsets=($(ls -f rbold*.nii))
		goodrun_num=${#run_dsets[@]}
		run_length=`3dinfo -nv rdant*.nii`
		# compute de-meaned motion parameters (for use in regression)
		1d_tool.py -overwrite -infile dfile_rall.bold.1D -set_run_lengths ${run_length} \
		           -demean -write motion_demean.bold.1D
		1d_tool.py -overwrite -infile dfile_rall.dant.1D -set_run_lengths ${run_length} \
		           -demean -write motion_demean.dant.1D

		# compute motion parameter derivatives (for use in regression)
		1d_tool.py -overwrite -infile dfile_rall.bold.1D -set_run_lengths ${run_length} \
		           -derivative -demean -write motion_deriv.bold.1D
		1d_tool.py -overwrite -infile dfile_rall.dant.1D -set_run_lengths ${run_length} \
		           -derivative -demean -write motion_deriv.dant.1D

		# create censor file motion_${subj}_censor.1D, for censoring motion 
		1d_tool.py -overwrite -infile dfile_rall.bold.1D -set_run_lengths ${run_length} \
		    -show_censor_count -censor_prev_TR \
		    -censor_motion 0.4 motion_bold

		1d_tool.py -overwrite -infile dfile_rall.dant.1D -set_run_lengths ${run_length} \
		    -show_censor_count -censor_prev_TR \
		    -censor_motion 0.4 motion_dant

		# combine multiple censor files
		1deval -overwrite -a motion_bold_censor.1D -b outcount_bold_censor.1D \
			   -c motion_dant_censor.1D -d outcount_dant_censor.1D \
		       -expr "a*b*c*d" > censor_combined.1D

		1dplot -jpg motion_censor -censor censor_combined.1D motion_*_enorm.1D

		3dcalc -a motion_demean.bold.1D\' -b motion_demean.dant.1D\' \
			-expr "(a+b)/2" -prefix rm.motion_demean.bold_dant.1D -overwrite
		1dcat rm.motion_demean.bold_dant.1D\' > motion_demean.bold_dant.1D -overwrite
		rm rm.motion_demean.bold_dant.1D

		3dcalc -a motion_deriv.bold.1D\' -b motion_deriv.dant.1D\' \
			-expr "(a+b)/2" -prefix rm.motion_deriv.bold_dant.1D -overwrite
		1dcat rm.motion_deriv.bold_dant.1D\' > motion_deriv.bold_dant.1D -overwrite
		rm rm.motion_deriv.bold_dant.1D
	}&
	done
	wait
}&
done
wait

