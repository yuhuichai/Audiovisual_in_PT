#!/bin/bash

top_dir=/Users/chaiy3/Data/Audiovisual_motion

cd ${top_dir}

for patDir in 190530OWU_SAM.goodlars; do
{
	cd ${top_dir}/${patDir}/anat.sft
	layerNii=layers3D_auditory_premotor_ips_sts_mt.nii

	3dresample -master ${layerNii} -rmode NN -overwrite \
		-prefix scaledXYZ_landmark_auditory.nii -input scaledXY_landmark_auditory.nii

	3dcalc -a scaledXYZ_landmark_auditory.nii -b ${layerNii} \
		-expr "step(a)*b" -prefix layers3D_auditory_4column.nii -datum short -overwrite

	3dcalc -a scaledXYZ_landmark_auditory.nii -expr "amongst(a,1)" \
		-prefix landmark_auditory.nii -overwrite -datum short

	rm scaledXYZ_landmark_auditory.nii

	LN_COLUMNAR_DIST -layer_file layers3D_auditory_4column.nii -landmarks landmark_auditory.nii -vinc 200

	if [[ "$patDir" == *"lars"* ]]; then
		cd ${top_dir}/${patDir}/lars.sft
	else
		cd ${top_dir}/${patDir}/aud.sft
	fi

	statsList=stats.smXY*.nii
	
	if [[ "$patDir" == *"lars"* ]]; then
		cd ${top_dir}/${patDir}/lars.sft
		[ ! -d columnProfile ] && mkdir columnProfile

		for columns in columns3D_T3.nii; do
		{
			if [ -f ${top_dir}/${patDir}/anat.sft/${columns} ]; then
				columnPre=${columns%.nii}

				echo "*********************************************************************************************"
				echo " extract columnar profile for ${columns} in ${patDir} "
				echo "*********************************************************************************************"
				3dROIstats -nomeanout -nzvoxels -quiet -mask ../anat.sft/${columns} ../anat.sft/${columns} \
					> columnProfile/nzvoxels_${columnPre}.1D

				for stats in ${statsList}; do
				{
					subj=${stats#stats.}
					subj=${subj%.nii}

					3dresample -master ../anat.sft/${layerNii} \
						-rmode Bk -overwrite -prefix scaled_$stats -input $stats

					3dROIstats -nomeanout -nzmean -quiet -mask ../anat.sft/${columns} scaled_${stats}['audio#0_Coef','visual#0_Coef','audiovisual#0_Coef'] \
						> columnProfile/${stats%.nii}.aud_vis_audvis.pc.${columnPre}.1D
					3dROIstats -nomeanout -nzsigma -quiet -mask ../anat.sft/${columns} scaled_${stats}['audio#0_Coef','visual#0_Coef','audiovisual#0_Coef'] \
						> columnProfile/${stats%.nii}.aud_vis_audvis.sd.${columnPre}.1D

				}
				done
				wait
			fi
		}&
		done
		wait
		rm scaled_stats*
	fi

	if [[ "$patDir" == *"tina"* ]]; then
		cd ${top_dir}/${patDir}/aud.sft
		[ ! -d columnProfile ] && mkdir columnProfile

		for columns in columns3D_T3.nii; do
		{
			if [ -f ${top_dir}/${patDir}/anat.sft/${columns} ]; then
				columnPre=${columns%.nii}

				echo "*********************************************************************************************"
				echo " extract columnar profile for ${columns} in ${patDir} "
				echo "*********************************************************************************************"
				3dROIstats -nomeanout -nzvoxels -quiet -mask ../anat.sft/${columns} ../anat.sft/${columns} \
					> columnProfile/nzvoxels_${columnPre}.1D

				for stats in ${statsList}; do
				{
					subj=${stats#stats.}
					subj=${subj%.nii}

					3dresample -master ../anat.sft/${layerNii} \
						-rmode Bk -overwrite -prefix scaled_$stats -input $stats
					3dROIstats -nomeanout -nzmean -quiet -mask ../anat.sft/${columns} scaled_${stats}['motion#0_Coef'] \
						> columnProfile/${stats%.nii}.aud_vis_audvis.pc.${columnPre}.1D
					3dROIstats -nomeanout -nzsigma -quiet -mask ../anat.sft/${columns} scaled_${stats}['motion#0_Coef'] \
						> columnProfile/${stats%.nii}.aud_vis_audvis.sd.${columnPre}.1D

					3dresample -master ../anat.sft/${layerNii} \
						-rmode Bk -overwrite -prefix scaled_$stats -input ../vis.sft/$stats
					3dROIstats -nomeanout -nzmean -quiet -mask ../anat.sft/${columns} scaled_${stats}['motion#0_Coef'] \
						>> columnProfile/${stats%.nii}.aud_vis_audvis.pc.${columnPre}.1D
					3dROIstats -nomeanout -nzsigma -quiet -mask ../anat.sft/${columns} scaled_${stats}['motion#0_Coef'] \
						>> columnProfile/${stats%.nii}.aud_vis_audvis.sd.${columnPre}.1D

					3dresample -master ../anat.sft/${layerNii} \
						-rmode Bk -overwrite -prefix scaled_$stats -input ../mul.sft/$stats
					3dROIstats -nomeanout -nzmean -quiet -mask ../anat.sft/${columns} scaled_${stats}['motion#0_Coef'] \
						>> columnProfile/${stats%.nii}.aud_vis_audvis.pc.${columnPre}.1D
					3dROIstats -nomeanout -nzsigma -quiet -mask ../anat.sft/${columns} scaled_${stats}['motion#0_Coef'] \
						>> columnProfile/${stats%.nii}.aud_vis_audvis.sd.${columnPre}.1D

				}
				done
				wait
			fi
		}&
		done
		wait
		rm scaled_stats*
	fi

}
done
wait

