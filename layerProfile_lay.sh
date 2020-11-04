#!/bin/bash

# set data directories
top_dir=/Users/chaiy3/Data/Audiovisual_motion

cd ${top_dir}

for patDir in *tina* *lars*; do
{
	cd ${top_dir}/${patDir}
	for runDir in lars.sft aud.sft; do
		if [ -d ${top_dir}/${patDir}/${runDir} ] && [ -f ${top_dir}/${patDir}/${runDir}/stats.smLAY_bold_mdant.nii ] ; then
			cd ${top_dir}/${patDir}/${runDir}

			[ ! -d layerProfile ] && mkdir layerProfile

			# 1, audioFeedforward; 2, visualFeedback; 3, hg1; 4, ips; 5, sts; 6, mt

			echo "***************************** extract precise ROIs for layer profile ***************************************"

			if [ -f ${top_dir}/${patDir}/anat.sft/scaledXY_layerMask_profile.nii ]; then
				3dresample -master ../anat.sft/layers3D_4smooth.nii \
					-rmode NN -overwrite -prefix ../anat.sft/LayerMask_profile.nii \
					-input ../anat.sft/scaledXY_layerMask_profile.nii
			fi

			3dcalc -a ../anat.sft/LayerMask_profile.nii -b ../anat.sft/layers3D_4smooth.nii \
				-expr "amongst(a,1)*b" -prefix layers3D_audioFeedforward.nii -overwrite

			3dcalc -a ../anat.sft/LayerMask_profile.nii -b ../anat.sft/layers3D_4smooth.nii \
				-expr "amongst(a,2)*b" -prefix layers3D_visualFeedback.nii -overwrite

			3dcalc -a ../anat.sft/LayerMask_profile.nii -b ../anat.sft/layers3D_4smooth.nii \
				-expr "amongst(a,3)*b" -prefix layers3D_audioT2.nii -overwrite


			echo "*********************** extract auditory columnar ROIs for layer profile *******************************"
			# 3dresample -master ../anat.sft/layers3D_4smooth.nii \
			# 	-rmode NN -overwrite -prefix ../anat.sft/scaledXYZ_landmark_auditory.nii \
			# 	-input ../anat.sft/scaledXY_landmark_auditory.nii

			# # 3dcalc -a ../anat.sft/columns_peak_auditory.nii -b ../anat.sft/layers3D_4smooth.nii \
			# # 	-c ../anat.sft/scaledXYZ_landmark_auditory.nii \
			# # 	-expr "amongst(a,1)*b*step(c)" -prefix layers3D_anteAudColumns.nii -overwrite

			# 3dcalc -a ../anat.sft/columns_peak_auditory.nii -b ../anat.sft/layers3D_4smooth.nii \
			# 	-c ../anat.sft/scaledXYZ_landmark_auditory.nii \
			# 	-expr "amongst(a,2)*b*step(c)" -prefix layers3D_postAudColumns.nii -overwrite



			# 3dresample -master ../anat.sft/layers3D_4smooth.nii \
			# 	-rmode NN -overwrite -prefix ../anat.sft/scaledXYZ_landmark_T3.nii \
			# 	-input ../anat.sft/scaledXY_landmark_T3.nii

			# 3dcalc -a ../anat.sft/columns_peak_T3.nii -b ../anat.sft/layers3D_4smooth.nii \
			# 	-c ../anat.sft/scaledXYZ_landmark_T3.nii \
			# 	-expr "amongst(a,1)*b*step(c)" -prefix layers3D_anteT3Columns.nii -overwrite

			# 3dcalc -a ../anat.sft/columns_peak_T3.nii -b ../anat.sft/layers3D_4smooth.nii \
			# 	-c ../anat.sft/scaledXYZ_landmark_T3.nii \
			# 	-expr "amongst(a,2)*b*step(c)" -prefix layers3D_postT3Columns.nii -overwrite

			if [[ "$patDir" == *"lars"* ]]; then
				for statsLAY in stats.smLAY*.nii; do
				{
					stats=stats.smXY${statsLAY#*smLAY}
					3dresample -master ../anat.sft/layers3D_4smooth.nii \
						-rmode Bk -overwrite -prefix scaled_$stats -input $statsLAY['audio#0_Tstat','visual#0_Tstat','audiovisual#0_Tstat']
				}&
				done
				wait
			fi

			if [[ "$patDir" == *"tina"* ]]; then
				for statsLAY in stats.smLAY*.nii; do
				{
					stats=stats.smXY${statsLAY#*smLAY}
					3dresample -master ../anat.sft/layers3D_4smooth.nii \
						-rmode Bk -overwrite -prefix scaled_aud_$stats -input ../aud.sft/$statsLAY['motion#0_Tstat']
					3dresample -master ../anat.sft/layers3D_4smooth.nii \
						-rmode Bk -overwrite -prefix scaled_vis_$stats -input ../vis.sft/$statsLAY['motion#0_Tstat']
					3dresample -master ../anat.sft/layers3D_4smooth.nii \
						-rmode Bk -overwrite -prefix scaled_mul_$stats -input ../mul.sft/$statsLAY['motion#0_Tstat']
				}
				done
				wait
			fi


			# 3dresample -master ../anat.sft/layers3D_4smooth.nii \
			# 		-rmode Bk -overwrite -prefix ../anat.sft/scaledXYZ_mean.bold_mdant.nii \
			# 		-input ../anat.sft/mean.bold_mdant.nii

			# 3dresample -master ../anat.sft/layers3D_4smooth.nii \
			# 		-rmode Bk -overwrite -prefix ../anat.sft/scaledXYZ_mean.sub_d_dant.nii \
			# 		-input ../anat.sft/mean.sub_d_dant.nii

			for layers in layers3D_audioT2.nii layers3D_audioFeedforward.nii; do
			{
				if [ -f ${layers} ]; then
					layerPre=${layers%.nii}

					echo "*********************************************************************************************"
					echo " extract profile for ${layers} in ${patDir} "
					echo "*********************************************************************************************"
					
					3dROIstats -nomeanout -nzvoxels -quiet -mask ${layers} ${layers} > layerProfile/nzvoxels_${layerPre}.1D

					# 3dROIstats -nomeanout -nzmean -quiet -mask ${layers} ../anat.sft/scaledXYZ_mean.sub_d_dant.nii \
					# 	> layerProfile/mtana.tval.${layerPre}.1D
					# 3dROIstats -nomeanout -nzsigma -quiet -mask ${layers} ../anat.sft/scaledXYZ_mean.sub_d_dant.nii \
					# 	> layerProfile/mtana.tsd.${layerPre}.1D

					# 3dROIstats -nomeanout -nzmean -quiet -mask ${layers} ../anat.sft/scaledXYZ_mean.bold_mdant.nii \
					# 	> layerProfile/mtsub.tval.${layerPre}.1D
					# 3dROIstats -nomeanout -nzsigma -quiet -mask ${layers} ../anat.sft/scaledXYZ_mean.bold_mdant.nii \
					# 	> layerProfile/mtsub.tsd.${layerPre}.1D

					for statsLAY in stats.smLAY*.nii; do
					{
						subj=${stats#stats.}
						subj=${subj%.nii}
						stats=stats.smXY${statsLAY#*smLAY}

						if [[ "$patDir" == *"lars"* ]]; then
							3dROIstats -nomeanout -nzmean -quiet -mask ${layers} scaled_${stats}['audio#0_Tstat','visual#0_Tstat','audiovisual#0_Tstat'] \
								> layerProfile/${stats%.nii}.aud_vis_audvis.tval.${layerPre}.1D
							3dROIstats -nomeanout -nzsigma -quiet -mask ${layers} scaled_${stats}['audio#0_Tstat','visual#0_Tstat','audiovisual#0_Tstat'] \
								> layerProfile/${stats%.nii}.aud_vis_audvis.tsd.${layerPre}.1D
						fi
						if [[ "$patDir" == *"tina"* ]]; then
							3dROIstats -nomeanout -nzmean -quiet -mask ${layers} scaled_aud_${stats}['motion#0_Tstat'] \
								> layerProfile/${stats%.nii}.aud_vis_audvis.tval.${layerPre}.1D
							3dROIstats -nomeanout -nzsigma -quiet -mask ${layers} scaled_aud_${stats}['motion#0_Tstat'] \
								> layerProfile/${stats%.nii}.aud_vis_audvis.tsd.${layerPre}.1D

							3dROIstats -nomeanout -nzmean -quiet -mask ${layers} scaled_vis_${stats}['motion#0_Tstat'] \
								>> layerProfile/${stats%.nii}.aud_vis_audvis.tval.${layerPre}.1D
							3dROIstats -nomeanout -nzsigma -quiet -mask ${layers} scaled_vis_${stats}['motion#0_Tstat'] \
								>> layerProfile/${stats%.nii}.aud_vis_audvis.tsd.${layerPre}.1D

							3dROIstats -nomeanout -nzmean -quiet -mask ${layers} scaled_mul_${stats}['motion#0_Tstat'] \
								>> layerProfile/${stats%.nii}.aud_vis_audvis.tval.${layerPre}.1D
							3dROIstats -nomeanout -nzsigma -quiet -mask ${layers} scaled_mul_${stats}['motion#0_Tstat'] \
								>> layerProfile/${stats%.nii}.aud_vis_audvis.tsd.${layerPre}.1D
						fi
					}&
					done
					wait
				fi
			}&
			done
			wait

			rm scaled_stats*nii
			
		fi
	done
}
done
wait

