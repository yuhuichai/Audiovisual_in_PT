#!/bin/bash

# set data directories
top_dir=/Users/chaiy3/Data/Audiovisual_motion

cd ${top_dir}

for patDir in *.lars; do # *.tina
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


	echo "++ transform freesurfer generated layer mask into epi space ..."

	# cd ${sumaDir}
	# 3dcalc -a aparc+aseg_REN_gm.nii.gz -expr "step(a)*1000" \
	# 	-prefix gm_boosted.nii -overwrite
	# 3dcalc -a aparc+aseg_REN_wmat.nii.gz -expr "step(a)*1000" \
	# 	-prefix wm_boosted.nii -overwrite
	# 3dcalc -a aparc+aseg_REN_all.nii.gz -expr "step(a)*1000" \
	# 	-prefix all_boosted.nii -overwrite


	cd ${top_dir}/${patDir}/anat.sft

	# # # IPS.wang2015atlas.nii BA6_exvivo.thresh.nii MT_exvivo.thresh.nii
	# # for roi in wang2015atlas.IPS1_IPS2.nii wang2015atlas.IPS3_IPS4.nii wang2015atlas.IPS5.nii wang2015atlas.SPL1.nii; do # 
	# # {
		
	# # 	3dcalc -a ${sumaDir}/../${roi} -expr "step(a)*1000" \
	# # 		-prefix rm.boosted.${roi} -overwrite

	# # 	antsApplyTransforms -d 3 -n BSpline[5] \
	# # 		-i rm.boosted.${roi} \
	# # 		-o ${roi} -t [registered_0GenericAffine.mat,1] -t registered_1InverseWarp.nii.gz \
	# # 		-r scaledXYZ_mean.sub_d_dant.masked.nii

	# # 	# 3dcalc -a rm.${roi} -expr "step(a-100)" -prefix ${roi} -overwrite -datum short -nscale

	# # 	rm rm.*${roi}
	# # }&
	# # done
	# # wait

	# # 3dcalc -a wang2015atlas.IPS1_IPS2.nii -b wang2015atlas.IPS3_IPS4.nii -c wang2015atlas.IPS5.nii -d wang2015atlas.SPL1.nii \
	# # 	-expr "step(a-100)*step(100-b)+step(b-100)*step(100-c)*2+step(c-100)*3+step(d-100)*step(100-c)*4" \
	# # 	-prefix wang2015atlas.IPS.nii -overwrite

	# antsApplyTransforms -d 3 -n BSpline[5] \
	# 	-i ${sumaDir}/gm_boosted.nii \
	# 	-o gm_upsamp.nii -t [registered_0GenericAffine.mat,1] -t registered_1InverseWarp.nii.gz \
	# 	-r scaledXYZ_mean.sub_d_dant.masked.nii

	# antsApplyTransforms -d 3 -n BSpline[5] \
	# 	-i ${sumaDir}/wm_boosted.nii \
	# 	-o wm_upsamp.nii -t [registered_0GenericAffine.mat,1] -t registered_1InverseWarp.nii.gz \
	# 	-r scaledXYZ_mean.sub_d_dant.masked.nii

	# antsApplyTransforms -d 3 -n BSpline[5] \
	# 	-i ${sumaDir}/all_boosted.nii \
	# 	-o all_upsamp.nii -t [registered_0GenericAffine.mat,1] -t registered_1InverseWarp.nii.gz \
	# 	-r scaledXYZ_mean.sub_d_dant.masked.nii

	# 3dcalc -a wm_upsamp.nii -expr "step(a-500)" \
	# 	-prefix wm_upsamp_thr.nii -overwrite
	# 3dcalc -a all_upsamp.nii -expr "step(a-500)" \
	# 	-prefix all_upsamp_thr.nii -overwrite

	# 3dAutomask -overwrite -prefix brain_mask_anat.nii scaledXYZ_mean.sub_d_dant.masked.nii

	# 3dcalc -a gm_upsamp.nii -b brain_mask_anat.nii -expr "step(a-200)*step(b)" \
	# 	-prefix gm_upsamp_thr.nii -overwrite

	# # extract white matter edge
	# 3dmask_tool -dilate_inputs -1 -prefix wm_upsamp_thr_e1.nii -overwrite -inputs wm_upsamp_thr.nii
	# 3dcalc -a wm_upsamp_thr.nii -b wm_upsamp_thr_e1.nii  -c brain_mask_anat.nii -expr '(step(a)-step(b))*step(c)' \
	# 	-prefix wm_upsamp_edge.nii -overwrite

	# # extract csf edge
	# 3dmask_tool -dilate_inputs 1 -prefix all_upsamp_thr_d1.nii -overwrite -inputs all_upsamp_thr.nii
	# 3dcalc -a all_upsamp_thr.nii -b all_upsamp_thr_d1.nii -c brain_mask_anat.nii -expr '(step(b)-step(a))*step(c)' \
	# 	-prefix all_upsamp_edge.nii -overwrite

	# # generate cortical layermask
	# 3dcalc -a all_upsamp_edge.nii -b wm_upsamp_edge.nii -c gm_upsamp_thr.nii \
	# 	-expr "(step(a)+2*step(b)+3*step(c)*iszero(a+b))" \
	# 	-prefix LayerMask4smooth.nii -overwrite

	# # generate csf layermask
	# 3dmask_tool -dilate_inputs 1 -prefix all_upsamp_thr_d1.nii -overwrite -inputs all_upsamp_thr.nii
	# 3dmask_tool -dilate_inputs 2 -prefix all_upsamp_thr_d2.nii -overwrite -inputs all_upsamp_thr.nii
	# 3dcalc -a all_upsamp_thr_d2.nii -b all_upsamp_thr_d1.nii -c brain_mask_anat.nii -expr "(step(a)-step(b))*step(c)" \
	# 	-prefix csfMask_edge2.nii -overwrite

	# 3dmask_tool -dilate_inputs 5 -prefix all_upsamp_thr_d5.nii -overwrite -inputs all_upsamp_thr.nii
	# 3dcalc -a all_upsamp_thr_d5.nii -b all_upsamp_thr_d2.nii -c brain_mask_anat.nii -expr "(step(a)-step(b))*step(c)" \
	# 	-prefix csfMask.nii -overwrite

	# 3dmask_tool -dilate_inputs 6 -prefix all_upsamp_thr_d6.nii -overwrite -inputs all_upsamp_thr.nii
	# 3dcalc -a all_upsamp_thr_d6.nii -b all_upsamp_thr_d5.nii -c brain_mask_anat.nii -expr "(step(a)-step(b))*step(c)" \
	# 	-prefix csfMask_edge1.nii -overwrite

	# 3dcalc -a csfMask_edge1.nii -b csfMask_edge2.nii -c csfMask.nii -d LayerMask4smooth.nii \
	# 	-expr "(step(a)+2*step(b)+3*step(c)*iszero(a+b))*iszero(d)" \
	# 	-prefix csfMask4smooth.nii -overwrite

	# # generate wm layermask
	# 3dmask_tool -dilate_inputs -1 -prefix wm_upsamp_thr_e1.nii -overwrite -inputs wm_upsamp_thr.nii
	# 3dmask_tool -dilate_inputs -2 -prefix wm_upsamp_thr_e2.nii -overwrite -inputs wm_upsamp_thr.nii
	# 3dmask_tool -dilate_inputs -4 -prefix wm_upsamp_thr_e4.nii -overwrite -inputs wm_upsamp_thr.nii
	# 3dmask_tool -dilate_inputs -5 -prefix wm_upsamp_thr_e5.nii -overwrite -inputs wm_upsamp_thr.nii

	# 3dcalc -a wm_upsamp_thr_e4.nii -b wm_upsamp_thr_e2.nii -c brain_mask_anat.nii -expr "(step(b)-step(a))*step(c)" \
	# 	-prefix wmMask.nii -overwrite

	# 3dcalc -a wm_upsamp_thr_e5.nii -b wm_upsamp_thr_e4.nii -c brain_mask_anat.nii -expr "(step(b)-step(a))*step(c)" \
	# 	-prefix wmMask_edge2.nii -overwrite

	# 3dcalc -a wm_upsamp_thr_e2.nii -b wm_upsamp_thr_e1.nii -c brain_mask_anat.nii -expr "(step(b)-step(a))*step(c)" \
	# 	-prefix wmMask_edge1.nii -overwrite

	# 3dcalc -a wmMask_edge1.nii -b wmMask_edge2.nii -c wmMask.nii -d LayerMask4smooth.nii \
	# 	-expr "(step(a)+2*step(b)+3*step(c)*iszero(a+b))*iszero(d)" \
	# 	-prefix wmMask4smooth.nii -overwrite

	# rm *thr_d* *thr_e* csfMask.nii wmMask.nii *edge1.nii *edge2.nii *_upsamp.nii *_upsamp_thr.nii 

	# 3dcalc -a all_upsamp_edge.nii -b wm_upsamp_edge.nii -expr "step(a)+2*step(b)" \
	# 	-prefix all_wm_upsamp_edge.nii -overwrite
	# rm all_upsamp_edge.nii wm_upsamp_edge.nii


	# echo "************** grow cortical layers with RENZO's program ******************"
	# 3dcalc -a LayerMask4smooth.nii -expr a -datum short -overwrite -prefix sht_LayerMask4smooth.nii

	# # # input for LN_GROW_LAYERS always needs to be in datatype SHORT
	# # LN_GROW_LAYERS -rim sht_LayerMask4smooth.nii
	# # mv layers.nii layers2D_4smooth.nii
	# # sleep 1

	# LN_GROW_LAYERS -rim sht_LayerMask4smooth.nii -threeD
	# mv layers.nii layers3D_4smooth.nii
	# rm sht_LayerMask4smooth.nii

	# 3dresample -master scaledXY_mean.sub_d_dant.masked.nii \
	# 	-rmode NN -overwrite -prefix layers2D_4smooth.nii \
	# 	-input layers3D_4smooth.nii

	echo "************** grow wm and csf layers with RENZO's program ******************"
	3dcalc -a csfMask4smooth.nii -expr a -datum short -overwrite -prefix sht_csfMask4smooth.nii
	LN_GROW_LAYERS -N 7 -rim sht_csfMask4smooth.nii -threeD
	mv layers.nii csf3D_4smooth.nii
	rm sht_csfMask4smooth.nii

	3dcalc -a wmMask4smooth.nii -expr a -datum short -overwrite -prefix sht_wmMask4smooth.nii
	LN_GROW_LAYERS -N 6 -rim sht_wmMask4smooth.nii -threeD
	mv layers.nii wm3D_4smooth.nii
	rm sht_wmMask4smooth.nii

	echo "************** combine cortical layers, wm and csf ******************"
	3dcalc -a wm3D_4smooth.nii -b layers3D_4smooth.nii -c csf3D_4smooth.nii \
		-expr "a+(b+step(b)*6)+(c+step(c)*26)" -prefix all3D_4smooth.nii -overwrite

	3dresample -master scaledXY_mean.sub_d_dant.masked.nii \
		-rmode NN -overwrite -prefix all2D_4smooth.nii \
		-input all3D_4smooth.nii


	# layers=${top_dir}/${patDir}/anat.sft/layers3D_4smooth.nii
	# # csflayers=${top_dir}/${patDir}/anat.sft/csf3D_4smooth.nii
	# # wmlayers=${top_dir}/${patDir}/anat.sft/wm3D_4smooth.nii
	# alllayers=${top_dir}/${patDir}/anat.sft/all3D_4smooth.nii
	# # alllayers=${top_dir}/${patDir}/anat.sft/column.nii


	# cd ${top_dir}/${patDir}
	# for runDir in aud*.sft lars.sft congruent*sft vis.sft mul.sft; do
	# {
	# 	if [ -d ${top_dir}/${patDir}/${runDir} ]; then
	# 		cd ${top_dir}/${patDir}/${runDir}

	# 		# mv ../anat.sft/scaledXYZ_InverseWarped.nii ./
	# 		3dcopy -overwrite ${layers} layers3D_4smooth.nii
	# 		3dcopy -overwrite ${top_dir}/${patDir}/anat.sft/scaledXYZ_mean.sub_d_dant.masked.nii scaledXYZ_mean.sub_d_dant.masked.nii
						
	# 		echo "*********************************************************************************************"
	# 		echo " smooth activity map in ${layers} for ${patDir} "
	# 		echo "*********************************************************************************************"
	# 		for stats in stats.bold_mdant.nii; do #stats.rbold.nii  stats.sub_d_bold.nii stats.bold_mdant.nii
	# 		{
	# 			# if [ ! -f smoothedALL_scaled_${stats} ]; then
	# 				statsPre=${stats%.nii}
	# 				3dresample -master ${layers} -rmode NN -overwrite -prefix scaled_${statsPre} -input $stats
	# 				# nVol=`3dinfo -nv $stats`
	# 				# let "nVol1=${nVol}-1"
	# 				if [[ "$patDir" == *"lars"* ]]; then
	# 					nVol1=5
	# 				fi
	# 				if [[ "$patDir" == *"tina"* ]]; then
	# 					nVol1=1
	# 				fi


	# 				for vol in `seq 0 ${nVol1}`; do # only smooth percent signal change 2 2 
	# 				{

	# 					if [ ${#vol} = 1 ]; then
	# 						volIdx=0${vol}
	# 					else
	# 						volIdx=${vol}
	# 					fi

	# 					3dcalc -a scaled_${statsPre}+orig.[$vol] -expr "a" -prefix scaled_${statsPre}_${volIdx}.nii -overwrite

	# 					# echo "++ smoothing stats $vol in wm, gm and csf layers ......................"
	# 					# LN_LAYER_SMOOTH -mask -layer_file ${alllayers} -input scaled_${statsPre}_${volIdx}.nii -FWHM 1
	# 					# mv smoothed_scaled_${statsPre}_${volIdx}.nii smoothed2_scaled_${statsPre}_${volIdx}.nii

	# 					# echo "++ smoothing stats $vol in cortical layers ......................"
	# 					# LN_LAYER_SMOOTH -mask -layer_file ${layers} -input scaled_${statsPre}_${volIdx}.nii -FWHM 1

	# 					echo "++ smoothing stats $vol in wm, gm and csf layers ......................"
	# 					LN_LAYER_SMOOTH -mask -layer_file ${alllayers} -input scaled_${statsPre}_${volIdx}.nii -FWHM 1

	# 				}&
	# 				done
	# 				wait

	# 				# 3dbucket -prefix smoothed_scaled_${statsPre}.nii smoothed_scaled_${statsPre}_*.nii
	# 				# rm smoothed_scaled_${statsPre}_*.nii

	# 				# 3dbucket -overwrite -prefix smoothed2_scaled_${statsPre}.nii smoothed2_scaled_${statsPre}_*.nii
	# 				# rm smoothed2_scaled_${statsPre}_*.nii

	# 				# if [[ "$runDir" == *"lars"* ]]; then
	# 				# 	3dbucket -overwrite -prefix smoothedALL_scaled_${statsPre}.nii \
	# 				# 		smoothed1_scaled_${statsPre}.nii[0] smoothed2_scaled_${statsPre}.nii[0] \
	# 				# 		smoothed1_scaled_${statsPre}.nii[1] smoothed2_scaled_${statsPre}.nii[1] \
	# 				# 		smoothed1_scaled_${statsPre}.nii[2] smoothed2_scaled_${statsPre}.nii[2] \
	# 				# 		smoothed1_scaled_${statsPre}.nii[3] smoothed2_scaled_${statsPre}.nii[3] \
	# 				# 		smoothed1_scaled_${statsPre}.nii[4] smoothed2_scaled_${statsPre}.nii[4] \
	# 				# 		smoothed1_scaled_${statsPre}.nii[5] smoothed2_scaled_${statsPre}.nii[5] \
	# 				# 		smoothed1_scaled_${statsPre}.nii[6] smoothed2_scaled_${statsPre}.nii[6]
	# 				# else
	# 				# 	3dbucket -overwrite -prefix smoothedALL_scaled_${statsPre}.nii \
	# 				# 		smoothed1_scaled_${statsPre}.nii[0] smoothed2_scaled_${statsPre}.nii[0] \
	# 				# 		smoothed1_scaled_${statsPre}.nii[1] smoothed2_scaled_${statsPre}.nii[1] \
	# 				# 		smoothed1_scaled_${statsPre}.nii[2] smoothed2_scaled_${statsPre}.nii[2] \
	# 				# 		smoothed1_scaled_${statsPre}.nii[3] smoothed2_scaled_${statsPre}.nii[3]
	# 				# fi

	# 				3dbucket -overwrite -prefix smoothedALL_scaled_${statsPre}.nii smoothed_scaled_${statsPre}_*.nii
	# 				# 3dbucket -overwrite -prefix smoothedCol_scaled_${statsPre}.nii smoothed_scaled_${statsPre}_*.nii
	# 				rm smoothed_scaled_${statsPre}_*.nii
	# 			# fi

	# 		}
	# 		done
	# 		wait

	# 		rm scaled_stats*
	# 		rm *stats*orig*
	# 		rm layers3D_4smooth.nii

	# 		# if [[ "$patDir" == *"lars"* ]]; then
	# 		# 	for smNII in smoothed*nii; do
	# 		# 		3dbucket -overwrite -prefix rm.${smNII} ${smNII}"[0..5]"
	# 		# 		mv rm.${smNII} ${smNII}
	# 		# 	done
	# 		# fi
	# 		# if [[ "$patDir" == *"tina"* ]]; then
	# 		# 	for smNII in smoothed*nii; do
	# 		# 		3dbucket -overwrite -prefix rm.${smNII} ${smNII}"[0..1]"
	# 		# 		mv rm.${smNII} ${smNII}
	# 		# 	done
	# 		# fi
	# 	fi
	# }&
	# done
	# wait


}&
done
wait

