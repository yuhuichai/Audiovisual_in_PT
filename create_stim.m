clear;
close all;
dataDir='~/Data/Audiovisual_motion/200309FRA_CAS.loc/exp_logs';

% %% congruent vs. incongruent
% cd(dataDir);
% TR=3.3;
% stim1File=dir('*run1.mat');
% stim1=load(stim1File.name);
% stim1_congruenttime_dis2TR=stim1.stimLog.stimCongruentBegnTime-TR*2;
% dlmwrite('stimCongruent_dis2TR.txt',stim1_congruenttime_dis2TR','delimiter','\t');
% stim1_incongruenttime_dis2TR=stim1.stimLog.stimInCongruentBegnTime-TR*2;
% dlmwrite('stimInCongruent_dis2TR.txt',stim1_incongruenttime_dis2TR','delimiter','\t');

% stim2File=dir('*run2.mat');
% stim2=load(stim2File.name);
% stim2_congruenttime_dis2TR=stim2.stimLog.stimCongruentBegnTime-TR*2;
% dlmwrite('stimCongruent_dis2TR.txt',stim2_congruenttime_dis2TR','-append','delimiter','\t');
% stim2_incongruenttime_dis2TR=stim2.stimLog.stimInCongruentBegnTime-TR*2;
% dlmwrite('stimInCongruent_dis2TR.txt',stim2_incongruenttime_dis2TR','-append','delimiter','\t');

% movefile('stim*Congruent_dis2TR.txt','../Stim')

% %% audio vs. visual motion
% cd(dataDir);
% stim1File=dir('*run1.mat');
% stim1=load(stim1File.name);
% stim1_Visualtime_dis2TR=stim1.stimLog.stimVisualBegnTime-TR*2;
% dlmwrite('stimVisual_dis2TR.txt',stim1_Visualtime_dis2TR','delimiter','\t');
% stim1_Audiotime_dis2TR=stim1.stimLog.stimAudioBegnTime-TR*2;
% dlmwrite('stimAudio_dis2TR.txt',stim1_Audiotime_dis2TR','delimiter','\t');

% stim2File=dir('*run2.mat');
% stim2=load(stim2File.name);
% stim2_Visualtime_dis2TR=stim2.stimLog.stimVisualBegnTime-TR*2;
% dlmwrite('stimVisual_dis2TR.txt',stim2_Visualtime_dis2TR','-append','delimiter','\t');
% stim2_Audiotime_dis2TR=stim2.stimLog.stimAudioBegnTime-TR*2;
% dlmwrite('stimAudio_dis2TR.txt',stim2_Audiotime_dis2TR','-append','delimiter','\t');

% movefile('stim*_dis2TR.txt','../Stim')

% %% lars stimulation
% cd(dataDir);
% TR=3.3;

% stim1File=dir('*run1.mat');
% stim1=load(stim1File.name);

% audBgnTime_dis2TR=stim1.expLog.audBgnTime-TR*2;
% dlmwrite('audio_dis2TR.txt',audBgnTime_dis2TR','delimiter','\t');

% visBgnTime_dis2TR=stim1.expLog.visBgnTime-TR*2;
% dlmwrite('visual_dis2TR.txt',visBgnTime_dis2TR','delimiter','\t');

% avcBgnTime_dis2TR=stim1.expLog.avcBgnTime-TR*2;
% dlmwrite('audiovisual_dis2TR.txt',avcBgnTime_dis2TR','delimiter','\t');

% stim2File=dir('*run2.mat');
% stim2=load(stim2File.name);

% audBgnTime_dis2TR=stim2.expLog.audBgnTime-TR*2;
% dlmwrite('audio_dis2TR.txt',audBgnTime_dis2TR','-append','delimiter','\t');

% visBgnTime_dis2TR=stim2.expLog.visBgnTime-TR*2;
% dlmwrite('visual_dis2TR.txt',visBgnTime_dis2TR','-append','delimiter','\t');

% avcBgnTime_dis2TR=stim2.expLog.avcBgnTime-TR*2;
% dlmwrite('audiovisual_dis2TR.txt',avcBgnTime_dis2TR','-append','delimiter','\t');


% stim3File=dir('*run3.mat');
% stim3=load(stim3File.name);

% audBgnTime_dis2TR=stim3.expLog.audBgnTime-TR*2;
% dlmwrite('audio_dis2TR.txt',audBgnTime_dis2TR','-append','delimiter','\t');

% visBgnTime_dis2TR=stim3.expLog.visBgnTime-TR*2;
% dlmwrite('visual_dis2TR.txt',visBgnTime_dis2TR','-append','delimiter','\t');

% avcBgnTime_dis2TR=stim3.expLog.avcBgnTime-TR*2;
% dlmwrite('audiovisual_dis2TR.txt',avcBgnTime_dis2TR','-append','delimiter','\t');

% movefile('*_dis2TR.txt','../Stim')

% %% lars attention stimulation
% cd(dataDir);
% TR=3.3;

% stim1File=dir('aud*.mat');
% stim1=load(stim1File.name);

% audBgnTime_dis2TR=stim1.expLog.audBgnTime-TR*2;
% dlmwrite('aud_dis2TR.txt',audBgnTime_dis2TR','delimiter','\t');

% targetRespT1 = stim1.expLog.targetButTime - stim1.expLog.targetEndTime;
% targetT1 = stim1.expLog.targetButTime((targetRespT1>0)&(targetRespT1<3))-TR*2;
% dlmwrite('aud_attention_dis2TR.txt',targetT1','delimiter','\t');

% stim2File=dir('vis*.mat');
% stim2=load(stim2File.name);

% visBgnTime_dis2TR=stim2.expLog.visBgnTime-TR*2;
% dlmwrite('vis_dis2TR.txt',visBgnTime_dis2TR','-append','delimiter','\t');

% targetRespT2 = stim2.expLog.targetButTime - stim2.expLog.targetEndTime;
% targetT2 = stim2.expLog.targetButTime((targetRespT2>0)&(targetRespT2<3))-TR*2;
% dlmwrite('vis_attention_dis2TR.txt',targetT2','delimiter','\t');

% stim3File=dir('mul*.mat');
% stim3=load(stim3File.name);

% avcBgnTime_dis2TR=stim3.expLog.avcBgnTime-TR*2;
% dlmwrite('mul_dis2TR.txt',avcBgnTime_dis2TR','-append','delimiter','\t');

% targetRespT3 = stim3.expLog.targetButTime - stim3.expLog.targetEndTime;
% targetT3 = stim3.expLog.targetButTime((targetRespT3>0)&(targetRespT3<3))-TR*2;
% dlmwrite('mul_attention_dis2TR.txt',targetT3','delimiter','\t');

% movefile('*_dis2TR.txt','../Stim')

%% motion specific stimulation
cd(dataDir);
TR=2.498;

stim1File=dir('audmot*.mat');
stim1=load(stim1File.name);

motBgnTime_dis2TR=stim1.expLog.motBgnTime-TR*2;
dlmwrite('audmot_dis2TR.txt',motBgnTime_dis2TR','delimiter','\t');

staBgnTime_dis2TR=stim1.expLog.staBgnTime-TR*2;
dlmwrite('audsta_dis2TR.txt',staBgnTime_dis2TR','delimiter','\t');

targetRespT1 = stim1.expLog.targetButTime - stim1.expLog.targetEndTime;
targetT1 = stim1.expLog.targetButTime((targetRespT1>0)&(targetRespT1<3))-TR*2;
dlmwrite('aud_attention_dis2TR.txt',targetT1','delimiter','\t');

stim2File=dir('vismot*.mat');
stim2=load(stim2File.name);

motBgnTime_dis2TR=stim2.expLog.motBgnTime-TR*2;
dlmwrite('vismot_dis2TR.txt',motBgnTime_dis2TR','-append','delimiter','\t');

staBgnTime_dis2TR=stim2.expLog.staBgnTime-TR*2;
dlmwrite('vissta_dis2TR.txt',staBgnTime_dis2TR','-append','delimiter','\t');

targetRespT2 = stim2.expLog.targetButTime - stim2.expLog.targetEndTime;
targetT2 = stim2.expLog.targetButTime((targetRespT2>0)&(targetRespT2<3))-TR*2;
dlmwrite('vis_attention_dis2TR.txt',targetT2','delimiter','\t');

movefile('*_dis2TR.txt','../Stim')

