# !/bin/bash

# set data directories
dataDir=/Users/chaiy3/Data/Audiovisual_motion # replace with your own data directory
cd ${dataDir}

for patDir in 190530OWU_SAM.goodlars; do
{
	cd ${top_dir}/${patDir}
	for runDir in lars.sft; do # 
	{	
		if [ -d ${top_dir}/${patDir}/${runDir} ]; then
			cd ${top_dir}/${patDir}/${runDir}

			run_dsets=($(ls -f rbold*.nii))
			run_num=${#run_dsets[@]}


			echo "*********************************************************************************************"
			echo " do regression for ${patDir}/${runDir} "
			echo "*********************************************************************************************"
			# note TRs that were not censored
			ktrs=`1d_tool.py -infile censor_combined.1D             \
			                 -show_trs_uncensored encoded`


			# rbold bold_mdant sub_d_bold upsamp.bold_dant upsamp.sub_d_bold
			for subj in rbold bold_mdant sub_d_bold; do
			{		

				3dTcat -prefix all_runs.${subj}.nii ${subj}*nii -overwrite


				3dTstat -overwrite -mean -prefix mean.${subj}.nii all_runs.$subj.nii"[$ktrs]"


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
