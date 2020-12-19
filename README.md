These codes were used in the article of "Topographical and Laminar Distribution of Audiovisual Processing within Human Planum Temporale".

(1) Script used to create and present the task stimuli: https://github.com/yuhuichai/Audiovisual_in_PT/blob/main/Lars_AV.m for Experiment 1 and https://github.com/yuhuichai/Audiovisual_in_PT/blob/main/Lars_AV_attention.m for Experiment 2. This script read the audio motion files (Afro 20 sounds left.wav and Afro 20 sounds right.wav) and the checkerboard pictures (checker.jpg and checker_invert.jpg), which are in this same directory. This script depends on Psychophysics Toolbox 3 (tested with version 3.0.15) and runs in MATLAB (tested in MATLAB R2016b). The run time depends on the block length and trial numbers specified in the script.

(2) Script used to split original time series into even (CTRL, can be treated as BOLD signal) and odd (DANTE-prepared images in functional runs, or MT-prepared in anatomical run) time points and create mask for motion correction: https://github.com/yuhuichai/Audiovisual_in_PT/blob/main/split_ctrl_dant.sh 
This script read the nifti images of all runs. It is writen in bash shell and depends on AFNI program (tested in AFNI_19.3.13). The run time is around several minutes.

(3) Script used for motion correction: https://github.com/yuhuichai/Audiovisual_in_PT/blob/main/mc_run.m
This script read the all functional and anatomical runs, and replace the input in mc_job.m with these nifti names. It runs in MATLAB (tested in MATLAB R2016b) and depends on the SPM12 and REST (http://restfmri.net/forum/, tested with REST_V1.8_130615) package. The run time can be up to 2 hours or even more.

(4) Script used to censor time points whenever the Euclidean norm of the motion derivatives exceeded 0.4 mm or when at least 10% of image voxels were seen as outliers from the trend: https://github.com/yuhuichai/Audiovisual_in_PT/blob/main/motion_censor.sh
It reads the motion parameters estimated by SPM12 in step 3, and runs AFNI programs as in bash shell. The run time is around 10 mins.

(5) 

colomnProfile.sh/m extracts columnar profile, layerProfile extracts laminar profile

layerSmooth.sh generates cortical layers and does laminar smoothing

correctRate.m computes the response time and detection accuracy of vigilance task
