#!/bin/bash

dataDir=/Users/chaiy3/Data/Audiovisual_motion

cd ${dataDir}
for subj in *tina *lars *loc; do
{
	subjDir=${dataDir}/${subj}
	cd ${subjDir}
	# epi=${subjDir}/anat.sft/denoise.uni.mean.sub_d_dant.masked.nii
	epi=${subjDir}/anat.sft/mean.sub_d_dant.masked.denoised.nii

	if [ -f ${subjDir}/brain_mask_comb_mc.nii ]; then
		epiMask=${subjDir}/brain_mask_comb_mc.nii
	else
		epiMask=${subjDir}/brain_mask_comb.nii
	fi

	# if [ ! -f ${epi} ]; then
	# 	3dcalc -a ${subjDir}/anat.sft/mean.sub_d_dant.nii \
	# 		-b ${epiMask} -expr 'step(b)*a' \
	# 		-prefix ${subjDir}/anat.sft/mean.sub_d_dant.masked.nii \
	# 		-overwrite

		DenoiseImage -d 3 -n Gaussian -i ${subjDir}/anat.sft/mean.sub_d_dant.masked.nii \
			-o ${subjDir}/anat.sft/mean.sub_d_dant.masked.denoised.nii
	# fi

	transformFile=${subjDir}/anat.sft/manual_align.txt
	outDir=${subjDir}/anat.sft

	if [[ "$subj" == *"COS_TUC"* ]]; then
		brainDir=${dataDir}/brain_COS_TUC
	elif [[ "$subj" == *"KAP_PAU"* ]]; then
		brainDir=${dataDir}/brain_KAP_PAU
	elif [[ "$subj" == *"OWU_SAM"* ]]; then
		brainDir=${dataDir}/brain_OWU_SAM
	elif [[ "$subj" == *"DEL_PRI"* ]]; then
		brainDir=${dataDir}/brain_DEL_PRI
	elif [[ "$subj" == *"HAR_CHA"* ]]; then
		brainDir=${dataDir}/brain_HAR_CHA
	elif [[ "$subj" == *"MAR_CEL"* ]]; then
		brainDir=${dataDir}/brain_MAR_CEL
	elif [[ "$subj" == *"COW_SET"* ]]; then
		brainDir=${dataDir}/brain_COW_SET
	elif [[ "$subj" == *"BRA_DON"* ]]; then
		brainDir=${dataDir}/brain_BRA_DON
	elif [[ "$subj" == *"ITU_INA"* ]]; then
		brainDir=${dataDir}/brain_ITU_INA
	elif [[ "$subj" == *"BIN_ARE"* ]]; then
		brainDir=${dataDir}/brain_BIN_ARE
	elif [[ "$subj" == *"MIG_GIN"* ]]; then
		brainDir=${dataDir}/brain_MIG_GIN
	elif [[ "$subj" == *"ABD_SHE"* ]]; then
		brainDir=${dataDir}/brain_ABD_SHE
	elif [[ "$subj" == *"FRA_CAS"* ]]; then
		brainDir=${dataDir}/brain_FRA_CAS
	elif [[ "$subj" == *"KEA_GEO"* ]]; then
		brainDir=${dataDir}/brain_KEA_GEO
	fi
	brain=${brainDir}/brain.nii

	echo "*************** 1st step: manual alignment, save transform file ***************"

	antsApplyTransforms --interpolation BSpline[5] -d 3 -i ${epi} \
		-r ${brain} -t ${transformFile} -o ${outDir}/anat2brain_manual_aligned.nii

	3dAutomask -overwrite -prefix ${outDir}/mask.anat2brain_manual_aligned.nii -dilate 10 ${outDir}/anat2brain_manual_aligned.nii

	brainMask=${subjDir}/anat.sft/mask.anat2brain_manual_aligned.nii

	echo "*************** 2nd step: antsRegistration with manual transform file ***************"

	cd ${outDir}

	echo "***********************************************************************************"
	echo " antsRegister sub_d_dant for ${subj} "
	echo "***********************************************************************************"

	antsRegistration \
		--verbose 1 \
		--dimensionality 3 \
		--float 1 \
		--output [registered_,WarpedDenoise.nii,InverseWarpedDenoise.nii] \
		--interpolation BSpline[5] \
		--use-histogram-matching 1 \
		--winsorize-image-intensities [0.005,0.995] \
		--initial-moving-transform ${transformFile} \
		--transform Rigid[0.05] \
		--metric MI[${brain},${epi},1,32,Regular,0.25] \
	    --convergence [1000x1000x1000x1000,1e-6,10] \
	    --shrink-factors 8x4x2x1 \
	    --smoothing-sigmas 3x2x1x0vox \
	    --masks [${brainMask},${epiMask}] \
		--transform Affine[0.05] \
		--metric MI[${brain},${epi},1,32,Regular,0.25] \
		--convergence [1000x1000x1000x1000,1e-6,10] \
	    --shrink-factors 8x4x2x1 \
	    --smoothing-sigmas 3x2x1x0vox \
		--masks [${brainMask},${epiMask}] \
		--transform SyN[0.1,3,0] \
		--metric CC[${brain},${epi},1,4] \
		--convergence [1000x1000x500x60,1e-6,10] \
		--shrink-factors 8x4x2x1 \
		--smoothing-sigmas 3x2x1x0vox \
		--masks [${brainMask},${epiMask}] \
	# consider a mask for interested region, so the distortion correction will be focusing on the interested region, like visual cortex

	# antsApplyTransforms -d 3 -n BSpline[5] -i ${brain} \
	# 	-o brain2epi.nii -t -t [registered_0GenericAffine.mat,1] -t registered_1InverseWarp.nii.gz -r ${brain}

}
done
wait



