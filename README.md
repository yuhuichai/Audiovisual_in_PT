These codes were used in the article of "Topographical and Laminar Distribution of Audiovisual Processing within Human Planum Temporale". 

(1) Script used to create and present the task stimuli: https://github.com/yuhuichai/Audiovisual_in_PT/blob/main/Lars_AV.m for Experiment 1 and https://github.com/yuhuichai/Audiovisual_in_PT/blob/main/Lars_AV_attention.m for Experiment 2. This script read the audio motion files (Afro 20 sounds left.wav and Afro 20 sounds right.wav) and the checkerboard pictures (checker.jpg and checker_invert.jpg), which are in this same directory. This script depends on Psychophysics Toolbox 3 (tested with version 3.0.15) and runs in MATLAB (tested in MATLAB R2016b).

spm_feat.sh is used to split original time series into control and dante-prepared, generate mask for motion correction, compute motion cencor, generate the time series of VAPER contrast and perform regressional analysis.

mc_run.m motion correction

colomnProfile.sh/m extracts columnar profile, layerProfile extracts laminar profile

layerSmooth.sh generates cortical layers and does laminar smoothing

correctRate.m computes the response time and detection accuracy of vigilance task
