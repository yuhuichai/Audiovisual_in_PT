clear;
close all;
dataDir='~/Data/Audiovisual_motion';
xlist={'aud' 'vis' 'audvis'};

cd(dataDir);
subjList = dir('*tina*/exp_logs/aud*.mat');
subjNum = length(subjList);
motionRate = zeros(subjNum,3);
colorRate = zeros(subjNum,3);
motionRT = zeros(subjNum,3);

for subj=1:subjNum
	cd(subjList(subj).folder);

	audFile=dir('aud*.mat');
	aud=load(audFile.name);
	motionRate(subj,1) = aud.expLog.correctRate;
	colorRate(subj,1) = aud.expLog.targetRate;
	motionRT(subj,1) = mean(aud.expLog.audResponseTime,'omitnan');
	dlmwrite('motionRT_aud.txt',aud.expLog.audResponseTime,'delimiter','\t');

	visFile=dir('vis*.mat');
	vis=load(visFile.name);
	motionRate(subj,2) = vis.expLog.correctRate;
	colorRate(subj,2) = vis.expLog.targetRate;
	motionRT(subj,2) = mean(vis.expLog.visResponseTime,'omitnan');
	dlmwrite('motionRT_vis.txt',vis.expLog.visResponseTime,'delimiter','\t');

	mulFile=dir('mul*.mat');
	mul=load(mulFile.name);
	motionRate(subj,3) = mul.expLog.correctRate;
	colorRate(subj,3) = mul.expLog.targetRate;
	motionRT(subj,3) = mean(mul.expLog.avcResponseTime,'omitnan');
	dlmwrite('motionRT_mul.txt',mul.expLog.avcResponseTime,'delimiter','\t');

	dlmwrite('motionRT.txt',motionRT(subj,:),'delimiter','\t');
end

motionRateMean = mean(motionRate);
motionRateSD = std(motionRate)/sqrt(subjNum);
anova1(motionRate);


colorRateMean = mean(colorRate);
colorRateSD = std(colorRate)/sqrt(subjNum);
anova1(colorRate);
[~,p_aud_vis] = ttest(colorRate(:,1),colorRate(:,2));
[~,p_aud_mul] = ttest(colorRate(:,1),colorRate(:,3));
[~,p_vis_mul] = ttest(colorRate(:,2),colorRate(:,3));

figure;
bar(motionRateMean,0.6,'FaceColor',[.5 .5 .5],'EdgeColor',[0.5 0.5 0.5],'LineWidth',2);
hold on; errorbar(motionRateMean,motionRateSD,'x','MarkerEdgeColor','none','LineWidth',3,'Color','k');
ylabel('Motion task performance','fontsize',26,'FontWeight','normal');
set(gca,'xticklabel',xlist);
% xtickangle(0);
% xlim([0.3 4.7]);
% ylim([0 1])
box off
whitebg('white');
set(gcf,'color',[1 1 1]);
set(gca,'linewidth',3,'fontsize',26,'FontWeight','normal','Xcolor',[0 0 0],'Ycolor',[0 0 0]);
% fig_name=replace(outputName,'.mat','_responseTime.png');
% export_fig(fig_name,'-r300');

figure;
bar(colorRateMean,0.6,'FaceColor',[.5 .5 .5],'EdgeColor',[0.5 0.5 0.5],'LineWidth',2);
hold on; errorbar(colorRateMean,colorRateSD,'x','MarkerEdgeColor','none','LineWidth',3,'Color','k');
ylabel('Accuracy of vigilance task','fontsize',26,'FontWeight','normal');
set(gca,'xticklabel',xlist);
% xtickangle(0);
% xlim([0.3 4.7]);
% ylim([0 1])
box off
whitebg('white');
set(gcf,'color',[1 1 1]);
set(gca,'linewidth',3,'fontsize',26,'FontWeight','normal','Xcolor',[0 0 0],'Ycolor',[0 0 0]);
% fig_name=replace(outputName,'.mat','_responseTime.png');
% export_fig(fig_name,'-r300');

motionRTMean = mean(motionRT);
motionRTSD = std(motionRT)/sqrt(subjNum);
anova1(motionRT);

figure;
bar(motionRTMean,0.6,'FaceColor',[.5 .5 .5],'EdgeColor',[0.5 0.5 0.5],'LineWidth',2);
hold on; errorbar(motionRTMean,motionRTSD,'x','MarkerEdgeColor','none','LineWidth',3,'Color','k');
ylabel('Motion task RT','fontsize',26,'FontWeight','normal');
set(gca,'xticklabel',xlist);
% xtickangle(0);
% xlim([0.3 4.7]);
% ylim([0 1])
box off
whitebg('white');
set(gcf,'color',[1 1 1]);
set(gca,'linewidth',3,'fontsize',26,'FontWeight','normal','Xcolor',[0 0 0],'Ycolor',[0 0 0]);
% fig_name=replace(outputName,'.mat','_responseTime.png');
% export_fig(fig_name,'-r300');

motionRateTina = motionRate;
motionRTTina = motionRT;

% clear;
% close all;
dataDir='~/Data/Audiovisual_motion';
xlist={'aud' 'vis' 'audvis'};

cd(dataDir);
subjList = dir('*lars*/exp_logs/Lars_*_run1.mat');
subjNum = length(subjList);
motionRate = zeros(subjNum,3);
motionRT = zeros(subjNum,3);

for subj=1:subjNum
	cd(subjList(subj).folder);

	audRate = zeros(3,1);
	visRate = zeros(3,1);
	mulRate = zeros(3,1);

	run1File=dir('Lars*run1.mat');
	run1=load(run1File.name);
	audRate(1) = run1.expLog.audCorrectRate;
	visRate(1) = run1.expLog.visCorrectRate;
	mulRate(1) = run1.expLog.avcCorrectRate;

	run2File=dir('Lars*run2.mat');
	run2=load(run2File.name);
	audRate(2) = run2.expLog.audCorrectRate;
	visRate(2) = run2.expLog.visCorrectRate;
	mulRate(2) = run2.expLog.avcCorrectRate;

	run3File=dir('Lars*run3.mat');
	run3=load(run3File.name);
	audRate(3) = run3.expLog.audCorrectRate;
	visRate(3) = run3.expLog.visCorrectRate;
	mulRate(3) = run3.expLog.avcCorrectRate;

	motionRate(subj,:) = [mean(audRate) mean(visRate) mean(mulRate)];

	motionRT(subj,1) = mean([run1.expLog.audResponseTime;run2.expLog.audResponseTime;run3.expLog.audResponseTime],'omitnan');
	motionRT(subj,2) = mean([run1.expLog.visResponseTime;run2.expLog.visResponseTime;run3.expLog.visResponseTime],'omitnan');
	motionRT(subj,3) = mean([run1.expLog.avcResponseTime;run2.expLog.avcResponseTime;run3.expLog.avcResponseTime],'omitnan');

	dlmwrite('motionRT_aud.txt',[run1.expLog.audResponseTime;run2.expLog.audResponseTime;run3.expLog.audResponseTime],'delimiter','\t');
	dlmwrite('motionRT_vis.txt',[run1.expLog.visResponseTime;run2.expLog.visResponseTime;run3.expLog.visResponseTime],'delimiter','\t');
	dlmwrite('motionRT_mul.txt',[run1.expLog.avcResponseTime;run2.expLog.avcResponseTime;run3.expLog.avcResponseTime],'delimiter','\t');

	dlmwrite('motionRT.txt',motionRT(subj,:),'delimiter','\t');
end

motionRate = [motionRate;motionRateTina];
motionRT = [motionRT;motionRTTina];
subjNum = length(motionRate);

motionRateMean = mean(motionRate);
motionRateSD = std(motionRate)/sqrt(subjNum);
[p1,t1,stats1] = anova1(motionRate);
c1 = multcompare(stats1); 
c10 = multcompare(stats1,'CType','bonferroni');

figure;
bar(motionRateMean,0.6,'FaceColor',[.5 .5 .5],'EdgeColor',[0.5 0.5 0.5],'LineWidth',2);
hold on; errorbar(motionRateMean,motionRateSD,'x','MarkerEdgeColor','none','LineWidth',3,'Color','k');
ylabel('Accuracy of motion task','fontsize',26,'FontWeight','normal');
set(gca,'xticklabel',xlist);
% xtickangle(0);
% xlim([0.3 4.7]);
% ylim([0 1])
box off
whitebg('white');
set(gcf,'color',[1 1 1]);
set(gca,'linewidth',3,'fontsize',26,'FontWeight','normal','Xcolor',[0 0 0],'Ycolor',[0 0 0]);
% fig_name=replace(outputName,'.mat','_responseTime.png');
% export_fig(fig_name,'-r300');

motionRTMean = mean(motionRT);
motionRTSD = std(motionRT)/sqrt(subjNum);
[p2,t2,stats2] = anova1(motionRT);
c2 = multcompare(stats2);
c20 = multcompare(stats2,'CType','bonferroni');

figure;
bar(motionRTMean,0.6,'FaceColor',[.5 .5 .5],'EdgeColor',[0.5 0.5 0.5],'LineWidth',2);
hold on; errorbar(motionRTMean,motionRTSD,'x','MarkerEdgeColor','none','LineWidth',3,'Color','k');
ylabel('RT of motion task','fontsize',26,'FontWeight','normal');
set(gca,'xticklabel',xlist);
% xtickangle(0);
% xlim([0.3 4.7]);
% ylim([0 1])
box off
whitebg('white');
set(gcf,'color',[1 1 1]);
set(gca,'linewidth',3,'fontsize',26,'FontWeight','normal','Xcolor',[0 0 0],'Ycolor',[0 0 0]);
% fig_name=replace(outputName,'.mat','_responseTime.png');
% export_fig(fig_name,'-r300');


