
clear;
% close all;
dataDir='~/Data/Audiovisual_motion';
xlist={' ' ' '};

cd(dataDir);


subjList = dir('*.good*/*.sft/columnProfile/stats.smBlurInM_rbold.aud_vis_audvis.pc.columns3D_T3.1D');

subjNum = length(subjList);
columnIndex = -20:0.2:180;

scProfile = zeros(subjNum,3,length(columnIndex));

figure;
for subj = 1:subjNum
	sc = load([subjList(subj).folder '/' subjList(subj).name]);
	columnPeaks = load([subjList(subj).folder '/columnsT3_anter_poster.txt']);
	columnPeaks = round([mean(columnPeaks(1:3)) mean(columnPeaks(4:6))]);
	column = 1:length(sc);

	if subj == 1
		marker = columnPeaks;
		columnNorm = column;
	else
		columnNorm = (column-columnPeaks(1))/(columnPeaks(2)-columnPeaks(1))*(marker(2)-marker(1))+marker(1);
		% columnPeaksNorm = (columnPeaks-columnPeaks(1))/(columnPeaks(2)-columnPeaks(1))*(marker(2)-marker(1))+marker(1);
	end

	tsin = timeseries(sc,columnNorm);
	
	tsout = resample(tsin,columnIndex);
	scNorm = squeeze(tsout.Data);
	scProfile(subj,:,:) = scNorm;

	hold on;
	plot(columnIndex,scNorm(2,:),'LineWidth',1);
end
ylabel('Signal change (%)','Fontsize',25,'FontWeight','bold');
xlabel('Columnar distance','Fontsize',25,'FontWeight','bold');
box off
whitebg('white');
set(gcf,'color',[1 1 1])
set(gca,'linewidth',3,'Fontsize',25,'FontWeight','bold','Xcolor',[0 0 0],'Ycolor',[0 0 0])


scProfileMean = squeeze(nanmean(scProfile,1));
scProfileSD = squeeze(nanstd(scProfile,0,1));
columnIndexOK = columnIndex;
subjsNaN=sum(isnan(squeeze(scProfile(:,1,:))));

figure;
plot(columnIndex,subjsNaN,'LineWidth',2);
ylabel('Subjs of NaN','Fontsize',25,'FontWeight','bold');
xlabel('Column index','Fontsize',25,'FontWeight','bold');
box off
whitebg('white');
set(gcf,'color',[1 1 1])
set(gca,'linewidth',3,'Fontsize',25,'FontWeight','bold','Xcolor',[0 0 0],'Ycolor',[0 0 0])


color_list = {'r' 'b' 'g'};
figure;
p = zeros(3,1);
for rp = 1:3
	hold on;	
	p(rp) = plot(columnIndex,scProfileMean(rp,:),'Color',char(color_list(rp)),'LineWidth',2);
	hold on;
	shadedErrorBar(columnIndex,scProfileMean(rp,:),scProfileSD(rp,:)./sqrt(subjNum),'lineProps',color_list(rp));
end

% legend(p,'audio','visual','audiovisual','Location','northwest','Orientation','horizontal');
% legend('boxoff');

ylabel('Signal change (%)','Fontsize',25,'FontWeight','bold');
xlabel(' ','Fontsize',25,'FontWeight','bold');
xlim([2 110]);
% ylim([-1.4 9]); % bold_mdant
% ylim([-0.5 4]); % bold
% ylim([-1 5]); % sub_d_bold
% ylim([min(scProfileMean(:))-0.5 max(scProfileMean(:))+0.5]);
xticks([min(columnIndexOK) max(columnIndexOK)]);
set(gca,'xticklabel',xlist);,
box off
whitebg('white');
set(gcf,'color',[1 1 1])
set(gca,'linewidth',3,'Fontsize',25,'FontWeight','bold','Xcolor',[0 0 0],'Ycolor',[0 0 0])
% fig_name=replace(effect_list(index).name,'1D','png');
% export_fig(fig_name,'-r300');





