clear;
close all;
dataDir='/Users/chaiy3/Data/Audiovisual_motion';
cd(dataDir)
bold_list=dir('200124FRA_CAS.tina/*sft/rp*bold*txt');
dant_list=dir('200124FRA_CAS.tina/*sft/rp*dant*txt');
sub_num = length(bold_list);

for index=1:sub_num
	cd(bold_list(index).folder);
	bold = load(bold_list(index).name);
	dant = load(dant_list(index).name);
	bold(:,4:6) = bold(:,4:6)/pi*180;
	dant(:,4:6) = dant(:,4:6)/pi*180;

	color_list = [153,76,0; 76,0,153; 0,153,153; 255,0,0; 0,0,255; 0,255,0]/255;

	vol = 1:length(bold);
	figure;
	p = zeros(6,1);
	for rp = 1:6
		hold on;
		p(rp) = plot(vol,bold(:,rp),'-','LineWidth',2.5,'Color',color_list(rp,:));
		hold on;
		plot(vol,dant(:,rp),':','LineWidth',2.5,'Color',color_list(rp,:));
	end
	legend(p,'x','y','z','pitch','roll','yaw','Location','northwest','Orientation','horizontal');
	xlim([min(vol) max(vol)]);
	ylim([min(min(min(bold,dant))) max(max(max(bold,dant)))+0.07])
	xlabel('Vol','Fontsize',23,'FontWeight','bold');
	ylabel('Motion (mm or deg)','Fontsize',23,'FontWeight','bold');
	box off
	whitebg('white');
	set(gcf,'color',[1 1 1])
	set(gca,'linewidth',2.3,'fontsize',18)
	export_fig([char(extractBefore(bold_list(index).name,'.txt')) '.png'],'-r300');
end
