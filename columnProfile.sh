#!/bin/bash

top_dir=/Users/chaiy3/Data/Audiovisual_motion

cd ${top_dir}

for patDir in 200109MIG_GIN.goodtina 20011*.* 20012*.*; do
{
	# cd ${top_dir}/${patDir}/anat.sft
	# 3dresample -master ${layerNii} -rmode NN -overwrite \
	# 	-prefix scaledXYZ_landmark_auditory.nii -input scaledXY_landmark_auditory.nii

	# 3dcalc -a scaledXYZ_landmark_auditory.nii -b ${layerNii} \
	# 	-expr "step(a)*b" -prefix layers3D_auditory_4column.nii -datum short -overwrite

	# 3dcalc -a scaledXYZ_landmark_auditory.nii -expr "amongst(a,1)" \
	# 	-prefix landmark_auditory.nii -overwrite -datum short

	# rm scaledXYZ_landmark_auditory.nii

	# LN_COLUMNAR_DIST -layer_file layers3D_auditory_4column.nii -landmarks landmark_auditory.nii -vinc 200

	# # LN_COLUMNAR_DIST -layer_file layers3D_auditory_4column.nii -landmarks landmark_auditory.nii -vinc 200 -twodim

	if [[ "$patDir" == *"lars"* ]]; then
		cd ${top_dir}/${patDir}/lars.sft
	else
		cd ${top_dir}/${patDir}/aud.sft
	fi

	# pbgn=`cat columnProfile/columns_anterior_posterior.txt | awk '{print $1}'`
	# pend=`cat columnProfile/columns_anterior_posterior.txt | awk '{print $3}'`
	# pmid=`cat columnProfile/columns_anterior_posterior.txt | awk '{print $2}'`

	# abgn=`cat columnProfile/columns_anterior_posterior.txt | awk '{print $4}'`
	# aend=`cat columnProfile/columns_anterior_posterior.txt | awk '{print $6}'`
	# amid=`cat columnProfile/columns_anterior_posterior.txt | awk '{print $5}'`

	# # 3dcalc -a ../anat.sft/${columns} -expr "step(a-($abgn+$amid)/2)*step(($aend+$amid)/2-a)+2*step(a-($pbgn+$pmid)/2)*step(($pend+$pmid)/2-a)" \
	# # 	-prefix ../anat.sft/columns_peak_auditory.nii -overwrite

	# 3dcalc -a ../anat.sft/columns3D_auditory.nii -expr "step(a-$abgn)*step($aend-a)+2*step(a-$pbgn)*step($pend-a)" \
	# 	-prefix ../anat.sft/columns_peak_auditory.nii -overwrite

	# 3dcalc -a ../anat.sft/columns3D_auditory.nii -expr "step(a-$pmid)*step($pend-a)" \
	# 	-prefix ../anat.sft/columns_postPeak_postPT.nii -overwrite

	# 3dcalc -a ../anat.sft/columns3D_auditory.nii -expr "step(a-$pend)*step($abgn-a)" \
	# 	-prefix ../anat.sft/columns_midPT.nii -overwrite

	# if [ -f columnProfile/columnsT3_anter_poster.txt ]; then
	# 	pbgn=`cat columnProfile/columnsT3_anter_poster.txt | awk '{print $1}'`
	# 	pend=`cat columnProfile/columnsT3_anter_poster.txt | awk '{print $3}'`
	# 	pmid=`cat columnProfile/columnsT3_anter_poster.txt | awk '{print $2}'`

	# 	abgn=`cat columnProfile/columnsT3_anter_poster.txt | awk '{print $4}'`
	# 	aend=`cat columnProfile/columnsT3_anter_poster.txt | awk '{print $6}'`
	# 	amid=`cat columnProfile/columnsT3_anter_poster.txt | awk '{print $5}'`

	# 	# 3dcalc -a ../anat.sft/columns3D_T3.nii -expr "step(a-$abgn+1)*step($aend-a+1)+2*step(a-$pbgn+1)*step($pend-a+1)" \
	# 	# 	-prefix ../anat.sft/columns_peak_T3.nii -overwrite

	# 	if [[ "$patDir" == *"1lars"* ]] || [[ "$patDir" == *"1tina"* ]]; then
	# 		layerNii=layers3D_4smooth.nii
	# 	else
	# 		layerNii=layers3D_auditory_premotor_ips_sts_mt.nii
	# 	fi

	# 	3dcalc -a ../anat.sft/columns3D_T3.nii -b ../anat.sft/${layerNii} \
	# 		-expr "step(a-${pmid}+1)*step(${amid}-a+1)*amongst(b,10,11)*a" \
	# 		-prefix ../anat.sft/columns3D_midLayer.nii -overwrite
	# fi

	if [[ "$patDir" == *"lars"* ]]; then
		cd ${top_dir}/${patDir}/lars.sft
	else
		cd ${top_dir}/${patDir}/aud.sft
	fi

	if [[ "$patDir" == *"1lars"* ]] || [[ "$patDir" == *"1tina"* ]]; then
		statsList=stats.smLAY*.nii
		layerNii=layers3D_4smooth.nii
	else
		statsList=stats.smXY*.nii
		layerNii=layers3D_auditory_premotor_ips_sts_mt.nii
	fi

	statsList=stats.smBlurInM*.nii

	# cd ${top_dir}/${patDir}/anat.sft

	# 3dcalc -a columns3D_T3.nii -b ${layerNii} \
	# 	-expr "step(a)*step(b-14.5)*a" -prefix columns3D_T3_sup.nii -overwrite

	# 3dcalc -a columns3D_T3.nii -b ${layerNii} \
	# 	-expr "step(a)*step(14.5-b)*step(b-7.5)*a" -prefix columns3D_T3_mid.nii -overwrite

	# 3dcalc -a columns3D_T3.nii -b ${layerNii} \
	# 	-expr "step(a)*step(7.5-b)*a" -prefix columns3D_T3_dep.nii -overwrite

	
	if [[ "$patDir" == *"lars"* ]]; then
		cd ${top_dir}/${patDir}/lars.sft
		[ ! -d columnProfile ] && mkdir columnProfile

		for columns in columns3D_T3_4COLMSM.nii columns3D_T3.nii; do
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

		for columns in columns3D_T3_4COLMSM.nii columns3D_T3.nii; do
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

