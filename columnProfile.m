
clear;
close all;
dataDir='~/Data/Audiovisual_motion';
xlist={' ' ' ' ' '};

cd(dataDir);
effect_list = dir('200113MAR_CEL.goodtina/*.sft/columnProfile/stats.smXY_rbold.aud_vis_audvis.pc.columns3D_T3.1D');
columnPeaks = zeros(length(effect_list),6);

for index=1:length(effect_list)
	fprintf('++ Begin analyzing %s in %s\n',effect_list(index).name,effect_list(index).folder);
	cd(effect_list(index).folder);
	effect_pc=load(effect_list(index).name);
	effect_sd=load(replace(effect_list(index).name,'pc','sd'));

	nvoxelsFile=['nzvoxels_columns' char(extractAfter(effect_list(index).name,'columns'))];
	nvoxels=load(nvoxelsFile);

	use_ind=(nvoxels>mean(nvoxels)-2*std(nvoxels));
	fprintf('++ Originally %d columns, remains %d columns after threshold \n',length(nvoxels),sum(use_ind));
	effect_pc=effect_pc(:,use_ind);
	effect_sd=effect_sd(:,use_ind);
	nvoxels=nvoxels(use_ind);

	color_list = {'r' 'b' 'g'}; %[255,0,0; 0,0,255; 0,255,0]/255;
	column=[1:length(nvoxels)];

	% columnPeaks = load('columnsT3_anter_poster.txt');
	% signalPeaks2 = effect_pc(2,columnPeaks(1:3));
	% signalPeaks1 = effect_pc(1,columnPeaks(4:6));

	figure;
	p = zeros(3,1);
	for rp = 1:3
		hold on;	
		p(rp) = plot(column,effect_pc(rp,:),'Color',char(color_list(rp)),'LineWidth',2.5);
		% hold on;
		% % errorbar(column,effect_pc(rp,:),effect_sd(rp,:)./sqrt(nvoxels),'x','MarkerEdgeColor','none','LineWidth',1,'Color',color_list(rp,:));
		% shadedErrorBar(column,effect_pc(rp,:),effect_sd(rp,:)./sqrt(nvoxels),'lineProps',color_list(rp));
		% if rp==1
		% 	hold on; plot(columnPeaks(4:6),signalPeaks1,'*','LineWidth',3,'Color',char(color_list(rp)));
		% end
		% if rp==2
		% 	hold on; plot(columnPeaks(1:3),signalPeaks2,'*','LineWidth',3,'Color',char(color_list(rp)));
		% end
	end

	% legend(p,'aud','vis','audvis','Location','northeast','Orientation','horizontal');

	ylabel('Signal change (%)','Fontsize',25,'FontWeight','bold');
	xlabel(' ','Fontsize',25,'FontWeight','bold');
	% xlim([0 102]);
	% xlim([32 130]);
	% ylim([min(effect_pc(:))+0.1 max(effect_pc(:))+0.4]);
	% ylim([-1 4]);
	xticks([0 0.5 1]);
	set(gca,'xticklabel',xlist);,
	box off
	whitebg('white');
	set(gcf,'color',[1 1 1])
	set(gca,'linewidth',3,'Fontsize',25,'FontWeight','bold','Xcolor',[0 0 0],'Ycolor',[0 0 0])
	fig_name=replace(effect_list(index).name,'1D','png');
	% export_fig(fig_name,'-r300');

end

% figure
% plot(column,nvoxels,'LineWidth',2);
% ylabel('# of voxels','Fontsize',25,'FontWeight','bold');
% xlabel('Column','Fontsize',25,'FontWeight','bold');
% xlim([1 max(column)]);
% box off
% whitebg('white');
% set(gcf,'color',[1 1 1])
% set(gca,'linewidth',3,'Fontsize',25,'FontWeight','bold','Xcolor',[0 0 0],'Ycolor',[0 0 0])
% export_fig('nvoxels.png','-r300');



