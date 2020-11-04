# !/bin/bash

# set data directories
dataDir=/Users/chaiy3/Data/Audiovisual_motion
cd ${dataDir}

for patDir in 200309FRA_CAS.loc; do
{
	top_dir=${dataDir}/${patDir}
	echo "*****************************************************************************************************"
	echo ++ start with ${patDir} 
	echo "*****************************************************************************************************"
	for filePre in anat; do
	{
		cd $top_dir/Func
		sl_dsets=($(ls -f ${filePre}*_e00*.nii.gz))
		# sl_dsets=($(ls -f ${filePre}*.nii))
		run_num=${#sl_dsets[@]}

		tr=`3dinfo -tr ${sl_dsets[0]}`
		echo "************** actual TR = ${tr} with 3drefit -TR 3.302600 * ******************"
		trdouble=`bc -l <<< "2*$tr"`
		
		echo "*************** extract bold and dant images ***************"
		run=0
		for img in ${sl_dsets[@]}; do
			let "run+=1"

			nVol=`3dinfo -nv ${img}`

			# 3dTcat -overwrite -prefix ${filePre}_bold${run}.nii ${img}'[2..'`expr $nVol - 3`'(2)]'
			3dTcat -overwrite -prefix ${filePre}_bold${run}.nii ${img}'[2..$(2)]'
			3drefit -TR ${trdouble} ${filePre}_bold${run}.nii

			3dTcat -overwrite -prefix ${filePre}_dant${run}.nii ${img}'[3..$(2)]'
			3drefit -TR ${trdouble} ${filePre}_dant${run}.nii
		done

		cd $top_dir
		[ ! -d ${filePre}.sft ] && mkdir ${filePre}.sft
		for run in `seq 1 ${run_num}`; do
		{
			mv $top_dir/Func/${filePre}_bold${run}.nii ${filePre}.sft/bold${run}.nii
			mv $top_dir/Func/${filePre}_dant${run}.nii ${filePre}.sft/dant${run}.nii
		}&
		done
		wait 

		# *****************************************************************************************************
		cd $top_dir/${filePre}.sft
		# *****************************************************************************************************

		echo "************** create mask for motion correction ******************"
		for img in bold*nii dant*nii; do
		{
		    3drefit -duporigin bold1.nii ${img}
		    3dAutomask -prefix rm.mask_${img} ${img}
		}
		done
		wait
		# create union of inputs, output type is byte
		3dmask_tool -inputs rm.mask_* -union -prefix brain_mask.nii -overwrite
		rm rm.mask*

		# # 3dmask_tool -inputs *sft/brain_mask.nii -union -prefix brain_mask_comb.nii -overwrite

		# echo "******************** do motion correction in spm ******************"
		# echo "******************** check bluring after motion correction ******************"
		# for run in `seq 1 ${run_num}`; do
		# {
		# 	# 3dcalc -a rbold${run}.nii -b rdant${run}.nii \
		# 	# 	-expr "(a-b)/a" -prefix ratio${run}.nii -overwrite

		# 	# 3dTstat -overwrite -mean -prefix mean.ratio${run}.nii ratio${run}.nii
		# 	# rm ratio${run}.nii
		# 	3dTstat -overwrite -mean -prefix mean.bold${run}.nii bold${run}.nii
		# 	3dTstat -overwrite -mean -prefix mean.dant${run}.nii dant${run}.nii
		# }&
		# done
		# wait 


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

		# create censor file motion_${subj}_censor.1D, for censoring motion 
		1d_tool.py -overwrite -infile dfile_rall.bold.1D -set_run_lengths ${run_length} \
		    -show_censor_count -censor_prev_TR \
		    -censor_motion 0.5 motion_bold

		1d_tool.py -overwrite -infile dfile_rall.dant.1D -set_run_lengths ${run_length} \
		    -show_censor_count -censor_prev_TR \
		    -censor_motion 0.5 motion_dant

		# combine multiple censor files
		1deval -overwrite -a motion_bold_censor.1D -b outcount_bold_censor.1D \
			   -c motion_dant_censor.1D -d outcount_dant_censor.1D \
		       -expr "a*b*c*d" > censor_combined.1D

		if [ "$goodrun_num" -eq "2" ]; then
			NumVolCtrl0=`3dinfo -nv rdant1.nii`
			let "NumVolCtrl1=${NumVolCtrl0}-1"
			1dcat censor_combined.1D\' > rm.censor_combined.1D
			1dcat rm.censor_combined.1D"[0..${NumVolCtrl1}]" > rm.censor_combined1.1D
			1dcat rm.censor_combined.1D"[${NumVolCtrl0}..$]" > rm.censor_combined2.1D

			1dcat rm.censor_combined1.1D\' > censor_combined1.1D
			1dcat rm.censor_combined2.1D\' > censor_combined2.1D

			rm rm.censor_combined*.1D
		fi

		1dplot -jpg motion_censor -censor censor_combined.1D motion_*_enorm.1D
	}&
	done
	wait
}&
done
wait

top_dir=/Users/chaiy3/Data/Audiovisual_motion
cd $top_dir

for patDir in 200309FRA_CAS.loc; do
{
	cd ${top_dir}/${patDir}
	for runDir in anat.sft; do # 
	{	
		if [ -d ${top_dir}/${patDir}/${runDir} ]; then
			cd ${top_dir}/${patDir}/${runDir}

			run_dsets=($(ls -f rbold*.nii))
			run_num=${#run_dsets[@]}

			trdouble=`3dinfo -tr rbold1.nii`
			tr=`bc -l <<< "${trdouble}/2"`

			echo "******************** compute all kinds of contrast ***********************"
			for run in `seq 1 ${run_num}`; do 
			{ 	
				NumVolCtrl=`3dinfo -nv rbold${run}.nii`
				NumVolTagd=`3dinfo -nv rdant${run}.nii`

				if [ "$NumVolCtrl" -gt "$NumVolTagd" ]; then
					3dTcat -overwrite -prefix rm.rbold${run}.nii \
						rbold${run}.nii'[0..'`expr $NumVolCtrl - 2`']'
					mv rm.rbold${run}.nii rbold${run}.nii
				elif [ "$NumVolCtrl" -lt "$NumVolTagd" ]; then
					3dTcat -overwrite -prefix rm.rdant${run}.nii \
						rdant${run}.nii'[0..'`expr $NumVolTagd - 2`']'
					mv rm.rdant${run}.nii rdant${run}.nii
				fi
					
				echo "******************** (dant(n)+dant(n+1))/2*bold(n+1) ***********************"
				# 3dcalc -prefix rm.ratio_mdant${run}_1vol.nii \
				# 	-a rbold${run}.nii'[0]' \
				# 	-b rdant${run}.nii'[0]' \
				# 	-expr 'b/a' -float -overwrite

				3dcalc -prefix rm.bold_mdant${run}_1vol.nii \
					-a rbold${run}.nii'[0]' \
					-b rdant${run}.nii'[0]' \
					-expr '(a-b)' -float -overwrite

				3dcalc -prefix rm.sub_d_bold${run}_1vol.nii \
					-a rbold${run}.nii'[0]' \
					-b rdant${run}.nii'[0]' \
					-expr '(a-b)/a' -float -overwrite

				3dcalc -prefix rm.sub_d_dant${run}_1vol.nii \
					-a rbold${run}.nii'[0]' \
					-b rdant${run}.nii'[0]' \
					-expr '(a-b)/b' -float -overwrite

				# Calculate all volumes after the first one
				NumVol=`3dinfo -nv rbold${run}.nii`

				# 3dcalc -prefix rm.ratio_mdant${run}_othervols.nii \
				# 	-a rdant${run}.nii'[0..'`expr $NumVol - 2`']' \
				# 	-b rdant${run}.nii'[1..$]' \
				# 	-c rbold${run}.nii'[1..$]' \
				# 	-expr '((a+b)/2)/c' -float -overwrite	


				3dcalc -prefix rm.bold_mdant${run}_othervols.nii \
					-a rdant${run}.nii'[0..'`expr $NumVol - 2`']' \
					-b rdant${run}.nii'[1..$]' \
					-c rbold${run}.nii'[1..$]' \
					-expr '(c-(a+b)/2)' -float -overwrite

				3dcalc -prefix rm.sub_d_bold${run}_othervols.nii \
					-a rdant${run}.nii'[0..'`expr $NumVol - 2`']' \
					-b rdant${run}.nii'[1..$]' \
					-c rbold${run}.nii'[1..$]' \
					-expr '(c-(a+b)/2)/c' -float -overwrite

				3dcalc -prefix rm.sub_d_dant${run}_othervols.nii \
					-a rdant${run}.nii'[0..'`expr $NumVol - 2`']' \
					-b rdant${run}.nii'[1..$]' \
					-c rbold${run}.nii'[1..$]' \
					-expr '(c-(a+b)/2)/((a+b)/2)' -float -overwrite

				# 3dTcat -overwrite -prefix ratio_mdant$run.nii rm.ratio_mdant${run}_1vol.nii rm.ratio_mdant${run}_othervols.nii
				# 3drefit -TR ${trdouble} ratio_mdant$run.nii

				3dTcat -overwrite -prefix bold_mdant$run.nii rm.bold_mdant${run}_1vol.nii rm.bold_mdant${run}_othervols.nii
				3drefit -TR ${trdouble} bold_mdant$run.nii

				3dTcat -overwrite -prefix sub_d_bold$run.nii rm.sub_d_bold${run}_1vol.nii rm.sub_d_bold${run}_othervols.nii
				3drefit -TR ${trdouble} sub_d_bold$run.nii

				3dTcat -overwrite -prefix sub_d_dant$run.nii rm.sub_d_dant${run}_1vol.nii rm.sub_d_dant${run}_othervols.nii
				3drefit -TR ${trdouble} sub_d_dant$run.nii



			}&
			done
			wait
			rm rm*

			echo "*********************************************************************************************"
			echo " do regression for ${patDir}/${runDir} "
			echo "*********************************************************************************************"
			# note TRs that were not censored
			ktrs=`1d_tool.py -infile censor_combined.1D             \
			                 -show_trs_uncensored encoded`



			# rbold bold_mdant sub_d_bold upsamp.bold_dant upsamp.sub_d_bold
			for subj in  sub_d_dant rbold bold_mdant sub_d_bold; do
			{		



				3dTcat -prefix all_runs.${subj}.nii ${subj}*nii -overwrite
				# if [ -f censor_combined.1D ]; then
				# 	3dTstat -overwrite -cvarinv -prefix TSNR.${subj}.nii all_runs.${subj}.nii"[$ktrs]"
				# else
				# 	3dTstat -overwrite -cvarinv -prefix TSNR.${subj}.nii all_runs.${subj}.nii
				# fi

				3dTstat -overwrite -mean -prefix mean.${subj}.nii all_runs.$subj.nii"[$ktrs]"

				# # 3dcalc -a mean.${subj}.nii -b ../brain_mask_comb_mc.nii -expr "a*step(b)" \
				# # 	-prefix mean.${subj}.masked.nii -overwrite

				# # DenoiseImage -d 3 -n Rician -i mean.${subj}.masked.nii -o mean.${subj}.masked.denoised.nii

				# ================================= normalize ==================================
				# scale each voxel time series to have a mean of 100
				# (be sure no negatives creep in)
				for run in `seq 1 ${run_num}`; do
				{    
				    if [ -f ${subj}${run}.nii ]; then
					    3dTstat -prefix rm.mean.${subj}${run}.nii ${subj}${run}.nii
					    3dcalc -a ${subj}${run}.nii -b rm.mean.${subj}${run}.nii \
					    	   -c brain_mask.nii -expr 'step(c)*(a/b*100)*step(a)*step(b)'         \
					           -prefix norm.${subj}${run}.nii -overwrite
					fi
				}&
				done
				wait


				# ------------------------------
				# run the regression analysis in afni  
				echo "++++++++++++++ input `ls norm.${subj}*nii` for glm .........."
				if [[ "$subj" != *"upsamp"* ]]; then


					if [[ "$runDir" == *"lars"* ]]; then
						3dDeconvolve -input norm.${subj}*nii                   \
							-censor censor_combined.1D                    \
							-mask brain_mask.nii                          \
						    -polort A -float                              \
						    -num_stimts 3                                                       \
						    -stim_times 1 ../Stim/audio_dis2TR.txt 'BLOCK(33,1)'                    \
						    -stim_label 1 audio                                               \
						    -stim_times 2 ../Stim/visual_dis2TR.txt 'BLOCK(33,1)'                    \
						    -stim_label 2 visual                                               \
						    -stim_times 3 ../Stim/audiovisual_dis2TR.txt 'BLOCK(33,1)'                    \
						    -stim_label 3 audiovisual                                               \
						    -jobs 4                                                             \
						    -num_glt 2                                                             \
						    -gltsym 'SYM: visual -audio'      \
						    -glt_label 1 visual-audio                                           \
						    -gltsym 'SYM: audiovisual -0.5*audio -0.5*visual'                                  \
						    -glt_label 2 audiovisual-audio_visual                                         \
						    -tout -nofullf_atall -x1D X.xmat.1D -xjpeg X.jpg                             \
						    -bucket stats.${subj}.nii 												\
						    -overwrite

						3dDeconvolve -input ${subj}*nii                   \
							-censor censor_combined.1D                    \
							-mask brain_mask.nii                          \
						    -polort A -float                              \
						    -num_stimts 3                                                       \
						    -stim_times 1 ../Stim/audio_dis2TR.txt 'BLOCK(33,1)'                    \
						    -stim_label 1 audio                                               \
						    -stim_times 2 ../Stim/visual_dis2TR.txt 'BLOCK(33,1)'                    \
						    -stim_label 2 visual                                               \
						    -stim_times 3 ../Stim/audiovisual_dis2TR.txt 'BLOCK(33,1)'                    \
						    -stim_label 3 audiovisual                                               \
						    -jobs 4                                                             \
						    -num_glt 2                                                             \
						    -gltsym 'SYM: visual -audio'      \
						    -glt_label 1 visual-audio                                           \
						    -gltsym 'SYM: audiovisual -0.5*audio -0.5*visual'                                  \
						    -glt_label 2 audiovisual-audio_visual                                         \
						    -tout -nofullf_atall -x1D X.xmat.1D -xjpeg X.jpg                             \
						    -bucket stats.${subj}.as.nii 												\
						    -overwrite

						# 3dDeconvolve -input norm.${subj}*nii                   \
						# 	-censor censor_combined.1D                    \
						# 	-mask brain_mask.nii                          \
						#     -polort A -float                              \
						#     -num_stimts 3                                                       \
						#     -stim_times 1 ../Stim/audio_dis2TR.txt 'SPMG2(33)'                    \
						#     -stim_label 1 audio                                               \
						#     -stim_times 2 ../Stim/visual_dis2TR.txt 'SPMG2(33)'                    \
						#     -stim_label 2 visual                                               \
						#     -stim_times 3 ../Stim/audiovisual_dis2TR.txt 'SPMG2(33)'                    \
						#     -stim_label 3 audiovisual                                               \
						#     -jobs 4                                                             \
						#     -tout -x1D X.xmat.spmg2.1D -xjpeg X.spmg2.jpg                             \
						#     -bucket stats.${subj}.spmg2.nii 												\
						#     -overwrite
					fi





					if [[ "$runDir" == *"aud"* ]] || [[ "$runDir" == *"vis"* ]] || [[ "$runDir" == *"mul"* ]]; then
						3dDeconvolve -input norm.${subj}*nii                   \
							-censor censor_combined.1D                    \
							-mask brain_mask.nii                          \
						    -polort A -float                              \
						    -num_stimts 2                                                       \
						    -stim_times 1 ../Stim/${runDir%.sft}_dis2TR.txt 'BLOCK(33,1)'                    \
						    -stim_label 1 motion                                               \
						    -stim_times 2 ../Stim/${runDir%.sft}_attention_dis2TR.txt 'GAM'                    \
						    -stim_label 2 attention                                               \
						    -jobs 4                                                             \
						    -tout -nofullf_atall -x1D X.xmat.1D -xjpeg X.jpg                             \
						    -bucket stats.${subj}.nii 												\
						    -overwrite

						3dDeconvolve -input ${subj}*nii                   \
							-censor censor_combined.1D                    \
							-mask brain_mask.nii                          \
						    -polort A -float                              \
						    -num_stimts 2                                                       \
						    -stim_times 1 ../Stim/${runDir%.sft}_dis2TR.txt 'BLOCK(33,1)'                    \
						    -stim_label 1 motion                                               \
						    -stim_times 2 ../Stim/${runDir%.sft}_attention_dis2TR.txt 'GAM'                    \
						    -stim_label 2 attention                                               \
						    -jobs 4                                                             \
						    -tout -nofullf_atall -x1D X.xmat.1D -xjpeg X.jpg                             \
						    -bucket stats.${subj}.as.nii 												\
						    -overwrite
					fi
				fi


				
				rm fitts.${subj}*
				rm noise.${subj}*
				rm norm.${subj}*
				rm rm.mean.${subj}*
			}
			done
			wait
			rm sub_d_bold*.nii
			rm bold_mdant*nii
			rm sub_d_dant*.nii
			rm ratio*.nii
			rm all_runs.*.nii
			rm errts*
		fi
	}&
	done
	wait

}&
done
wait
