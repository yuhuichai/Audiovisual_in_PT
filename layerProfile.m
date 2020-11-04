

clear;
% close all;
dataDir='~/Data/Audiovisual_motion';
xlist={'CSF' 'WM'};
xlist={'CSF' 'mid-GM' 'WM'};

cd(dataDir);

effect_list = [dir('200109MIG_GIN.goodtina/*.sft/layerProfile/stats.sm*_rbold.aud_vis_audvis.pc.layers3D_postT3Columns.1D'); ...
	           dir('200109MIG_GIN.goodtina/*.sft/layerProfile/stats.sm*_sub_d_bold.aud_vis_audvis.pc.layers3D_postT3Columns.1D')];


for index=1:length(effect_list)
	fprintf('++ Begin analyzing %s in %s\n',effect_list(index).name,effect_list(index).folder);
	cd(effect_list(index).folder);
	effect_pc=load(effect_list(index).name);
	effect_sd=load(replace(effect_list(index).name,'pc','sd'));

	nvoxelsFile=['nzvoxels_layers' char(extractAfter(effect_list(index).name,'layers'))];
	nvoxels=load(nvoxelsFile);

	effect_pc=fliplr(effect_pc);
	effect_sd=fliplr(effect_sd);
	nvoxels=fliplr(nvoxels);

	% effect_pc=effect_pc(:,1:19);
	% effect_sd=effect_sd(:,1:19);
	% nvoxels=nvoxels(1:19);

	use_ind=(nvoxels>mean(nvoxels)-std(nvoxels));
	effect_pc=effect_pc(:,use_ind);
	effect_sd=effect_sd(:,use_ind);
	nvoxels=nvoxels(use_ind);

	fprintf('++ Cortical depth of %d \n',length(nvoxels));
	color_list = [255,0,0; 0,0,255; 0,255,0]/255;
	depth=[1:length(nvoxels)]/length(nvoxels);

	figure;
	p = zeros(3,1);
	for rp = 1:3
		hold on;	
		p(rp) = plot(depth,effect_pc(rp,:),'Color',color_list(rp,:),'LineWidth',4);
		hold on;
		errorbar(depth,effect_pc(rp,:),effect_sd(rp,:)./sqrt(nvoxels),'x','MarkerEdgeColor','none','LineWidth',2,'Color',color_list(rp,:));
	end

	legend(p,'aud','vis','audvis','Location','northeast','Orientation','horizontal');

	ylabel('Signal change','Fontsize',30,'FontWeight','bold');
	xlabel('','Fontsize',30,'FontWeight','bold');
	xticks([1/length(nvoxels) 0.5 1]);
	set(gca,'xticklabel',xlist);,
	% xtickangle(0);
	ylim([(min(effect_pc(:))-0.2*abs(min(effect_pc(:)))) max(effect_pc(:))*1.2]);
	xlim([0 1+1/length(nvoxels)])
	box off
	whitebg('white');
	set(gcf,'color',[1 1 1])
	set(gca,'linewidth',3,'fontsize',30,'FontWeight','bold','Xcolor',[0 0 0],'Ycolor',[0 0 0])
	fig_name=replace(effect_list(index).name,'1D','png');
	% export_fig(fig_name,'-r300');		
end

% figure
% bar(depth,nvoxels);
% ylabel('# of voxels','Fontsize',30,'FontWeight','bold');
% xlabel('','Fontsize',30,'FontWeight','bold');
% xticks([1/length(nvoxels) 0.5 1]);
% set(gca,'xticklabel',xlist);,
% xlim([0 1+1/length(nvoxels)])
% box off
% whitebg('white');
% set(gcf,'color',[1 1 1])
% set(gca,'linewidth',3,'fontsize',30,'FontWeight','bold','Xcolor',[0 0 0],'Ycolor',[0 0 0])
% export_fig('nvoxels.png','-r300');



