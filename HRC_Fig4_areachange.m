clear
addpath(genpath(pwd))

% load landsat area change
load HRC_basins_areachange.mat

% basin areas
DatosHRC=HRCbasinsareachange;
DatosHRC(4,2:end)=DatosHRC(4,2:end)+DatosHRC(10,2:end);
DatosHRC(10,:)=[];
basins=DatosHRC.basin(2:9);

% time
t=table2array(DatosHRC(1,2:end));
HRC_a2=table2array(DatosHRC(2:end-1,2:end));

% Load drainage basins
BA=shaperead("HRC_drainagebasins_GPSuplift_u18S.shp");

% load Sentinel tide-area relations
load('Landsat_tidalcorr.mat')
Landsat_tidecorr=HoraLandsat;

% Format tide corr table
TidecorrLandsat=table2array(HoraLandsat);
% remove dates and tide
TidecorrLandsat(:,1:2)=[];
% remove conf intervals 
TidecorrLandsat(:,9:end)=[];
% transpose
TidecorrLandsat=TidecorrLandsat';
% add tidal corrections
HRCa2cor=HRC_a2+TidecorrLandsat;

%% remove 2015 & 2020 anomalies
HRC_a2(:,21)=[]; HRCa2cor(:,21)=[]; t(21)=[];
HRC_a2(:,7)=[]; HRCa2cor(:,7)=[]; t(7)=[];

% Normalize basin area change
HRCpcorr=100-(HRCa2cor.*100./HRCa2cor(:,1));
HRCp=100-(HRC_a2.*100./HRC_a2(:,1));

% average
HRC.avg=mean(HRCp);
HRC.sd=std(HRCp);
HRC.t=t;
HRC.avgc=mean(HRCpcorr);
HRC.sdc=std(HRCpcorr);
HRC.basins=HRCp;
HRC.basinscorr=HRCpcorr;

% export
save('codes/data/landsat_basinareachange/HRC_a2.mat','HRC')

%% plot tributary basins
figure(1), clf , 

ax1 = axes('Position',[0.1 0.55 0.8 0.4]); hold on
col = parula(numel(basins));
for i=1:numel(basins)    
    plot(t,HRCp(i,:),'color',col(i,:))
end
L=legend(basins,'location','northwest');
L.AutoUpdate = 'off';  % L=Legend
L.Title.String = 'Tributary basin';
ylabel('Vegetation area change (%)')
ylim([0 85]), box on
%xlabel('Year')
line([2004.5,2004.5],[0 85],'color','k','linestyle','-')
x = [0.45 0.49];
y = [0.85 0.79];
str = {'Industrial wastewater','discharge event'};
a=annotation('textarrow',x,y,'String',str);
a.Color = 'red';
a.FontSize = 10;
set(gca,'tickdir','out')

ax2 = axes('Position',[0.1 0.08 0.8 0.4]); hold on
plot(HRC.t,HRC.avg,'-r','LineWidth',1.5)
plot(HRC.t,HRC.avgc,'-b','LineWidth',1.5)
plot(HRC.t,HRC.avg+HRC.sd,'--r')
plot(HRC.t,HRC.avgc+HRC.sdc,'--b')
L=legend('Landsat average','Landsat average + Sentinel tidal correction',...
    'Landsat standard deviation','Landsat standard deviation + Sentinel tidal correction','location','north');
L.AutoUpdate = 'off';  % L=Legend
plot(HRC.t,HRC.avgc-HRC.sdc,'--b')
plot(HRC.t,HRC.avg-HRC.sd,'--r')
ylabel('Vegetation area change (%)')
ylim([0 85]), box on
xlabel('Year')
line([2004.5,2004.5],[0 85],'color','k','linestyle','-')
set(gca,'tickdir','out')

ax3 = axes('Position',[0.12 0.22 0.15 0.15]); hold on
histogram(HRC.avg-HRC.avgc), box on
xlabel('Area change difference (%)'), ylabel('N Landsat scenes')
set(gca,'yaxislocation','right')

bo=.04; ho=.97;
tx1 = axes('position',[bo ho .1 .1]); axis off
text(0,0,'a','FontSize',12)
tx2 = axes('position',[bo ho./2 .1 .1]); axis off
text(0,0,'b','FontSize',12)

rect=[0,0,25,20]; %[xmin ymin width height]
set(gcf,'PaperType','A4','PaperUnits','centimeters','Paperposition',rect);
fout='figs/HRC_Fig4_Pchange_avg.png'; saveas(gca,fout,'png')

%
