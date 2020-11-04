#!/bin/bash

# set data directories
top_dir=/Users/chaiy3/Data/Audiovisual_motion

cd ${top_dir}

for patDir in 20*.goodtina; do
{
	
	echo "*********************************************************************************************"
	echo " start working in ${patDir} "
	echo "*********************************************************************************************"

	if [[ "$patDir" == *"COS_TUC"* ]]; then
		sumaDir=${top_dir}/brain_COS_TUC/SUMA
	elif [[ "$patDir" == *"KAP_PAU"* ]]; then
		sumaDir=${top_dir}/brain_KAP_PAU/SUMA
	elif [[ "$patDir" == *"OWU_SAM"* ]]; then
		sumaDir=${top_dir}/brain_OWU_SAM/SUMA
	elif [[ "$patDir" == *"DEL_PRI"* ]]; then
		sumaDir=${top_dir}/brain_DEL_PRI/SUMA
	elif [[ "$patDir" == *"HAR_CHA"* ]]; then
		sumaDir=${top_dir}/brain_HAR_CHA/SUMA
	elif [[ "$patDir" == *"MAR_CEL"* ]]; then
		sumaDir=${top_dir}/brain_MAR_CEL/SUMA
	elif [[ "$patDir" == *"COW_SET"* ]]; then
		sumaDir=${top_dir}/brain_COW_SET/SUMA
	elif [[ "$patDir" == *"BRA_DON"* ]]; then
		sumaDir=${top_dir}/brain_BRA_DON/SUMA
	elif [[ "$patDir" == *"ITU_INA"* ]]; then
		sumaDir=${top_dir}/brain_ITU_INA/SUMA
	elif [[ "$patDir" == *"ARE_BIN"* ]]; then
		sumaDir=${top_dir}/brain_ARE_BIN/SUMA
	elif [[ "$patDir" == *"MIG_GIN"* ]]; then
		sumaDir=${top_dir}/brain_MIG_GIN/SUMA
	elif [[ "$patDir" == *"FRA_CAS"* ]]; then
		sumaDir=${top_dir}/brain_FRA_CAS/SUMA
	elif [[ "$patDir" == *"KEA_GEO"* ]]; then
		sumaDir=${top_dir}/brain_KEA_GEO/SUMA
	fi


	cd ${top_dir}/${patDir}/anat.sft

	# echo "++ isolate the interest layer mask ..."
	# 3dcalc -a rawLayerMask_auditory.nii -expr "amongst(a,3)" -prefix rm.rawLayerMask_auditory.3.nii -overwrite
	# 3dmask_tool -dilate_inputs 1 -prefix rm.rawLayerMask_auditory.3.d1.nii -overwrite -inputs rm.rawLayerMask_auditory.3.nii
	# 3dcalc -a rm.rawLayerMask_auditory.3.d1.nii -b rawLayerMask_auditory.nii \
	# 	-expr "step(a)*b" -prefix LayerMask_auditory.nii -overwrite
	# rm rm.rawLayerMask_auditory.3.*nii

	# echo "++ please correct the interest layer mask mannually ..."

	# echo "++ upscale layerMask in slice direction ..."
	# 3dresample -master LayerMask4smooth.nii -rmode NN -overwrite -prefix LayerMask_auditory_mc.nii \
	# 	-input scaledXY_layerMask_auditory.nii
	# 3dresample -master LayerMask4smooth.nii -rmode NN -overwrite -prefix scaledXYZ_layerMask_sts_mt_premotor_ips.nii \
	# 	-input scaledXY_layerMask_sts_mt_premotor_ips.nii

	# 3dresample -master scaledXY_mean.sub_d_bold.masked.nii -rmode NN -overwrite -prefix scaledXY_layerMask_auditory_mc.nii -input LayerMask_auditory_mc.nii
	# 3dcalc -a scaledXY_layerMask_auditory_mc.nii -b scaledXY_layerMask_sts_mt_premotor_ips.nii -expr "a+b" -prefix scaledXY_layerMask_auditory_premotor_ips_sts_mt.nii

	if [ -f scaledXY_layerMask_auditory_premotor_ips_sts_mt.nii ]; then
		3dresample -master LayerMask4smooth.nii -rmode NN -overwrite -prefix LayerMask_auditory_premotor_ips_sts_mt.nii \
			-input scaledXY_layerMask_auditory_premotor_ips_sts_mt.nii
	fi


	for layerMask in LayerMask_auditory_premotor_ips_sts_mt.nii; do

		layerPrefix=${layerMask#LayerMask_}
		layerPrefix=${layerPrefix%.nii}

		cd ${top_dir}/${patDir}/anat.sft

		echo "************** grow cortical layers for ${layerMask} ******************"
		3dcalc -a ${layerMask} -expr a -datum short -overwrite -prefix sht_${layerMask}

		LN_GROW_LAYERS -rim sht_${layerMask} -threeD
		mv layers.nii layers3D${layerMask#LayerMask}
		rm sht_${layerMask}

		layers=${top_dir}/${patDir}/anat.sft/layers3D${layerMask#LayerMask}

		# if [ -f LayerMask_ROI.nii ]; then
		# 	# 3dresample -master LayerMask4smooth.nii -rmode NN -overwrite -prefix scaledXYZ_layerMask_ROI.nii \
		# 	# 	-input LayerMask_ROI.nii

		# 	# 3dcalc -a ${layers} -b layers3D_4smooth.nii -c scaledXYZ_layerMask_ROI.nii \
		# 	# 	-expr "a+b*step(c)*iszero(a)" -prefix layers3D_allROIs.nii -overwrite

		# 	# rm scaledXYZ_layerMask_ROI.nii

		# 	layers=${top_dir}/${patDir}/anat.sft/layers3D_allROIs.nii
		# fi

		# echo "************** grow columns for ${layerMask} ******************"
		# LN_COLUMNAR_DIST -layer_file layers3D${layerMask#LayerMask} -landmarks landmark_${layerPrefix}.nii -verbose
		
		cd ${top_dir}/${patDir}
		for runDir in aud*.sft lars.sft congruent*sft vis.sft mul.sft; do
			if [ -d ${top_dir}/${patDir}/${runDir} ]; then
				cd ${top_dir}/${patDir}/${runDir}

				echo "*********************************************************************************************"
				echo " smooth activity map in ${layerPrefix} for ${patDir} "
				echo "*********************************************************************************************"
				for stats in stats.bold_mdant.nii; do
				{
						statsPre=${stats%.nii}
						3dresample -master ${layers} -rmode NN -overwrite -prefix scaled_${statsPre} -input $stats
						nVol=`3dinfo -nv $stats`
						let "nVol1=${nVol}-1"

						# for vol in `seq 0 ${nVol1}`; do # ignore the F map
						for vol in `seq 0 1`; do
						{

							if [ ${#vol} = 1 ]; then
								volIdx=0${vol}
							else
								volIdx=${vol}
							fi

							3dcalc -a scaled_${statsPre}+orig.[$vol] -expr "a" -prefix scaled_${statsPre}_${volIdx}.nii -overwrite

							echo "++ smoothing stats $vol in cortical layers ......................"
							LN_LAYER_SMOOTH -mask -layer_file ${layers} -input scaled_${statsPre}_${volIdx}.nii -FWHM 1 -sulctouch

						}&
						done
						wait

						3dbucket -overwrite -prefix smoothed_sulctouch_${layerPrefix}_${statsPre}.nii smoothed_scaled_${statsPre}_*.nii
						rm smoothed_scaled_${statsPre}_*.nii

				}
				done
				wait

				rm scaled_stats*
				rm *stats*orig*
			fi
		done
	done
}
done
wait

