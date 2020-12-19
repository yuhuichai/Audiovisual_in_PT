#!/bin/bash

# set data directories
top_dir=/Users/chaiy3/Data/Audiovisual_motion

cd ${top_dir}

for patDir in 190530OWU_SAM.goodlars; do
{
	
	echo "*********************************************************************************************"
	echo " start working in ${patDir} "
	echo "*********************************************************************************************"

	cd ${top_dir}/${patDir}/anat.sft

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
		
		cd ${top_dir}/${patDir}
		for runDir in aud*.sft lars.sft vis.sft mul.sft; do
			if [ -d ${top_dir}/${patDir}/${runDir} ]; then
				cd ${top_dir}/${patDir}/${runDir}

				echo "*********************************************************************************************"
				echo " smooth activity map in ${layerPrefix} for ${patDir} "
				echo "*********************************************************************************************"
				for stats in stats.*.nii; do
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

