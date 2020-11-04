clear;
% close all;
dataDir='~/Data/Audiovisual_motion';
xlist={'CSF' 'WM'};
xlist={'' '' ''};

cd(dataDir);
effect_list = dir('190719COS_TUC.goodlars/*.sft/layerProfile/stats.smXY_sub_d_bold.aud_vis_audvis.pc.layers3D_anteT3Columns.1D');
effect_list = dir('190712COS_TUC.goodlars/*.sft/layerProfile/stats.smXY_sub_d_bold.aud_vis_audvis.pc.layers3D_audioFeedforward.1D');
% % % remove 190719COS_TUC.goodlars for audioFeedforward
effect_list = dir('200120COS_TUC.good1tina/*.sft/layerProfile/stats.sm*_rbold.aud_vis_audvis.pc.layers3D_audioT2.1D');
				% dir('200120COS_TUC.good1tina/*.sft/layerProfile/stats.sm*_sub_d_bold.aud_vis_audvis.pc.layers3D_audioT2.1D')];
% effect_list = dir('190719COS_TUC.goodlars/*.sft/layerProfile/stats.smXY_rbold.aud_vis_audvis.pc.layers3D_visualFeedback.1D');


for index=1:length(effect_list)
	cd(dataDir);
	fprintf('++ Begin analyzing %s \n',effect_list(index).name);
	% no 200120COS_TUC.goodtina for layers3D_audioFeedforward
	subject_list = [dir(['*/*.sft/layerProfile/' effect_list(index).name])];
	subjNum=length(subject_list);

	effect0 = load([effect_list(index).folder '/' effect_list(index).name]);
	[condNum,layerNum] = size(effect0);

	effectAll=zeros(subjNum,condNum,layerNum);
	effectAll_aud_audvis=zeros(subjNum,layerNum);

	for subj=1:subjNum
		fileNM=[subject_list(subj).folder '/' effect_list(index).name];	
		effect0=load(fileNM);
		% effect_norm=(effect0-min(effect0(:)))/(max(effect0(:))-min(effect0(:)));
		% effect_norm=(effect0-0)/(max(effect0(:))-0);
		effect_norm=effect0;
		effect_aud_audvis=effect0(1,:)-effect0(3,:);
		if length(effect_norm)==layerNum-1
			% effect_norm=[effect_norm(:,1) effect_norm];
			effect_norm=[effect_norm effect_norm(:,end)];
		elseif length(effect_norm)==layerNum-2
			% effect_norm=[effect_norm(:,1) effect_norm];
			effect_norm=[effect_norm(:,1) effect_norm effect_norm(:,end)];
		end
		effectAll(subj,:,:)=effect_norm;
		effectAll_aud_audvis(subj,:)=effect_norm(1,:)-effect_norm(3,:);
	end

	effectMean=squeeze(mean(effectAll,1));
	effectSEM=squeeze(std(effectAll,0,1))/sqrt(subjNum);

	effectMean_aud_audvis=squeeze(mean(effectAll_aud_audvis,1));
	effectSEM_aud_audvis=squeeze(std(effectAll_aud_audvis,0,1))/sqrt(subjNum);

	effectMean=fliplr(effectMean);
	effectSEM=fliplr(effectSEM);

	effectMean_aud_audvis=fliplr(effectMean_aud_audvis);
	effectSEM_aud_audvis=fliplr(effectSEM_aud_audvis);

	% effectMean=effectMean(:,1:layerNum-1);
	% effectSEM=effectSEM(:,1:layerNum-1);

	% effectMean_aud_audvis=effectMean_aud_audvis(:,1:layerNum-1);
	% effectSEM_aud_audvis=effectSEM_aud_audvis(:,1:layerNum-1);

	% layerNum=layerNum-1;

	
	effectAll_aud_audvis = fliplr(effectAll_aud_audvis);
	[~,p_sup] = ttest(mean(effectAll_aud_audvis(:,1:6),2));
	[~,p_mid] = ttest(mean(effectAll_aud_audvis(:,7:13),2));
	[~,p_dep] = ttest(mean(effectAll_aud_audvis(:,14:20),2));


	effectAll_vis = squeeze(effectAll(:,2,:));
	[~,p_sup1] = ttest(mean(effectAll_vis(:,1:6),2));
	[~,p_mid1] = ttest(mean(effectAll_vis(:,7:13),2));
	[~,p_dep1] = ttest(mean(effectAll_vis(:,14:20),2));

	mean(effectMean,2)

	% color_list = [255,0,0; 0,0,255; 0,255,0]/255;
	color_list = {'r' 'b' 'g'};
	depth=[1:layerNum]/layerNum;

	cd([dataDir '/group'])
	figure;
	p = zeros(3,1);
	for rp = 1:3
		hold on;	
		p(rp) = plot(depth,effectMean(rp,:),'Color',char(color_list(rp)),'LineWidth',3);
		hold on;
		% errorbar(depth,effectMean(rp,:),effectSEM(rp,:),'x','MarkerEdgeColor','none','LineWidth',1.5,'Color',color_list(rp,:));
		shadedErrorBar(depth,effectMean(rp,:),effectSEM(rp,:),'lineProps',color_list(rp));
	end

	% legend(p,'aud','vis','audvis','Location','northeast','Orientation','horizontal');

	ylabel('Signal change (%)','Fontsize',25,'FontWeight','bold');
	xlabel('','Fontsize',25,'FontWeight','bold');
	xticks([1/layerNum 1/2 1]);
	set(gca,'xticklabel',xlist);,
	% xtickangle(0);
	ylim([min(effectMean(:))-1.5*mean(effectSEM(:)) max(effectMean(:))+1.5*mean(effectSEM(:))])
	xlim([0 1+1/layerNum])
	box off
	whitebg('white');
	set(gcf,'color',[1 1 1])
	set(gca,'linewidth',3,'fontsize',25,'FontWeight','bold','Xcolor',[0 0 0],'Ycolor',[0 0 0])
	fig_name=replace(effect_list(index).name,'1D','png');
	export_fig(fig_name,'-r300');	

	% figure;	
	% plot(depth,effectMean_aud_audvis,'Color','c','LineWidth',3);
	% % legend('visual vs. audiovisual','Location','northeast','Orientation','horizontal');
	% hold on;
	% % errorbar(depth,effectMean_aud_audvis,effectSEM_aud_audvis,'x','MarkerEdgeColor','none','LineWidth',1.5,'Color',[0.5,0,1]);
	% shadedErrorBar(depth,effectMean_aud_audvis,effectSEM_aud_audvis,'lineProps','c');
	% ylabel('Signal change (%)','Fontsize',25,'FontWeight','bold');
	% xlabel('','Fontsize',25,'FontWeight','bold');
	% xticks([1/layerNum 1/2 1]);
	% set(gca,'xticklabel',xlist);,
	% % xtickangle(0);
	% ylim([min(effectMean_aud_audvis(:))-1*mean(effectSEM_aud_audvis(:)) max(effectMean_aud_audvis(:))+1.5*mean(effectSEM_aud_audvis(:))])
	% xlim([0 1+1/layerNum])
	% box off
	% whitebg('white');
	% set(gcf,'color',[1 1 1])
	% set(gca,'linewidth',3,'fontsize',25,'FontWeight','bold','Xcolor',[0 0 0],'Ycolor',[0 0 0])
	% fig_name=replace(effect_list(index).name,'.1D','_aud_audvis.png');
	% export_fig(fig_name,'-r300');	
end

% clear;
% close all;
% dataDir='~/Data/Audiovisual_motion';
% xlist={'CSF' 'WM'};
% xlist={'' '' ''};

% cd(dataDir);
% effect_list = dir('190719COS_TUC.goodlars/lars.sft/layerProfile/mtana.pc.layers3D_audioFeedforward.1D');
% effect_list = dir('190719COS_TUC.goodlars/lars.sft/layerProfile/mtana.pc.layers3D_postAudColumns.1D');

% for index=1:length(effect_list)
% 	cd(dataDir);
% 	fprintf('++ Begin analyzing %s \n',effect_list(index).name);
% 	subject_list = dir(['*.good*/*sft/layerProfile/' effect_list(index).name]);
% 	subjNum=length(subject_list);

% 	effect0 = load([effect_list(index).folder '/' effect_list(index).name]);
% 	[condNum,layerNum] = size(effect0);

% 	effectAll=zeros(subjNum,layerNum);
% 	effectDiffAll=zeros(subjNum,layerNum);

% 	for subj=1:subjNum
% 		fileNM=[subject_list(subj).folder '/' effect_list(index).name];	
% 		effect0=load(fileNM);
% 		effect_norm=(effect0-min(effect0(:)))/(max(effect0(:))-min(effect0(:)));
% 		if length(effect_norm)==layerNum-1
% 			effect_norm=[effect_norm(:,1) effect_norm];
% 		end
% 		effectAll(subj,:)=effect_norm;

% 		effect_norm=fliplr(effect_norm);
% 		effect_diff_norm=effect_norm(2:end)-effect_norm(1:end-1);
% 		effect_diff_norm=[0 effect_diff_norm];
% 		effectDiffAll(subj,:)=effect_diff_norm;
% 	end

% 	effectMean=squeeze(mean(effectAll,1));
% 	effectSEM=squeeze(std(effectAll,0,1))/sqrt(subjNum);

% 	effectDiffMean=squeeze(mean(effectDiffAll,1));
% 	effectDiffSEM=squeeze(std(effectDiffAll,0,1))/sqrt(subjNum);


% 	effectMean=fliplr(effectMean);
% 	effectSEM=fliplr(effectSEM);


% 	effectMean=effectMean(:,1:layerNum-2);
% 	effectSEM=effectSEM(:,1:layerNum-2);

% 	effectDiffMean=effectDiffMean(:,1:layerNum-2);
% 	effectDiffSEM=effectDiffSEM(:,1:layerNum-2);


% 	layerNum=layerNum-2;

% 	color_list = [255,0,0; 0,0,255; 0,255,0]/255;
% 	depth=[1:layerNum]/layerNum;

% 	cd([dataDir '/group'])
% 	figure;	
% 	plot(depth,effectMean,'Color',color_list(1,:),'LineWidth',3);
% 	hold on;
% 	errorbar(depth,effectMean,effectSEM,'x','MarkerEdgeColor','none','LineWidth',1.5,'Color',color_list(1,:));
% 	ylabel('Normalized signal intensity','Fontsize',25,'FontWeight','bold');
% 	xlabel('','Fontsize',25,'FontWeight','bold');
% 	xticks([1/layerNum 1/2 1]);
% 	set(gca,'xticklabel',xlist);,
% 	% xtickangle(0);
% 	ylim([min(effectMean(:))-1.5*mean(effectSEM(:)) max(effectMean(:))+1.5*mean(effectSEM(:))])
% 	xlim([0 1+1/layerNum])
% 	box off
% 	whitebg('white');
% 	set(gcf,'color',[1 1 1])
% 	set(gca,'linewidth',3,'fontsize',25,'FontWeight','bold','Xcolor',[0 0 0],'Ycolor',[0 0 0])
% 	fig_name=replace(effect_list(index).name,'1D','png');
% 	export_fig(fig_name,'-r300');

% 	figure;	
% 	plot(depth,effectDiffMean,'Color',color_list(1,:),'LineWidth',3);
% 	hold on;
% 	errorbar(depth,effectDiffMean,effectDiffSEM,'x','MarkerEdgeColor','none','LineWidth',1.5,'Color',color_list(1,:));
% 	ylabel('Normalized signal derivative','Fontsize',25,'FontWeight','bold');
% 	xlabel('','Fontsize',25,'FontWeight','bold');
% 	xticks([1/layerNum 1/2 1]);
% 	set(gca,'xticklabel',xlist);,
% 	% xtickangle(0);
% 	xlim([0 1+1/layerNum])
% 	box off
% 	whitebg('white');
% 	set(gcf,'color',[1 1 1])
% 	set(gca,'linewidth',3,'fontsize',25,'FontWeight','bold','Xcolor',[0 0 0],'Ycolor',[0 0 0])
% 	fig_name=replace(effect_list(index).name,'.1D','_derivative.png');
% 	export_fig(fig_name,'-r300');	

% end




