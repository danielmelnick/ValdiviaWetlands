clear
addpath(genpath(pwd))

% load landsat area change
load('HRC_a2.mat');

% Load drainage basins
BA=shaperead('codes/data/basins/HRC_drainagebasins_GPSuplift_u18S.shp');

% add %area change and net up to shape
for i=1:numel(BA)
    BA(i).pch=HRC.basins(i,end);
    BA(i).pchtcor=HRC.basinscorr(i,end);     
    BA(i).netup=BA(i).comerw+BA(i).p50./1e3.*65;
    BA(i).netASL=2.4./1e3.*65;
    BA(i).netRSL=BA(i).netup-BA(i).netASL;
    basins{i}=BA(i).layer;

end

% plot RSL change with sentinel tidal corr
of=2.5; ofx=0.1; 
Y=[BA.pch];
X=[BA.comerw]+[BA.p50]./1e3.*65;
%%
figure(3), clf
w=0.28; h=0.6; bot=0.25; fz=8;

ax1 = axes('Position',[0.05 bot w h]); hold on

eh1=([BA.p75]-[BA.p25])./2;
xx=[BA.p50];
errorbar([BA.p50],Y,eh1,'sk','horizontal','MarkerFaceColor','auto','CapSize',0)
scatter_labels_nonoverlap(xx, Y, basins, ...
    'MarkerSize', 8, ...
    'MarkerColor', 'k', ...
    'TextColor', 'k', ...
    'FontSize', fz, ...
    'Padding', 0.6, ...
    'ShowLines', false);
%errorbar([BA.p50],Y,eh1,'sk','horizontal','MarkerFaceColor','auto','CapSize',0)

%for i=1:8
%    text(BA(i).p50-5*ofx,Y(i)+1.5*of,BA(i).layer)
%end
ylabel('Vegetation area change (%)')
xlabel('GNSS uplift rate (mm/yr)')
ylim([15 85]), box on, set(gca,'TickDir','out')

ax2 = axes('Position',[0.07+w bot w h]); hold on
eh2=([BA.cop75]-[BA.cop25])./2;
errorbar([BA.comerw],Y,eh2,'dr','horizontal','MarkerFaceColor','auto','CapSize',0)
xx=[BA.comerw];
scatter_labels_nonoverlap(xx, Y, basins, ...
    'MarkerSize', 2, ...
    'MarkerColor', 'r', ...
    'TextColor', 'k', ...
    'FontSize', fz, ...
    'Padding', 0.1, ...
    'ShowLines', false);
%for i=1:8
%    text(BA(i).comerw-ofx/2,Y(i)+of,BA(i).layer)
%end
%errorbar([BA.comerw],Y,eh2,'dr','horizontal','MarkerFaceColor','auto','CapSize',0)
xlabel('Coseismic uplift in 1960 (m)')
ylim([15 85]), box on, set(gca,'TickDir','out','YTickLabel',[])
%
ax3 = axes('Position',[0.09+2*w bot w h]); hold on
eh=sqrt(eh1.^2+eh2.^2)./1e3.*65;
errorbar([BA.comerw]+[BA.p50]./1e3.*65,Y,eh,'ob','horizontal','MarkerFaceColor','auto','CapSize',0)
for i=1:8
    text(BA(i).comerw+BA(i).p50./1e3.*65-ofx/3,Y(i)+of,BA(i).layer,'FontSize',fz)
end

[r,p]=corrcoef([BA.comerw]+[BA.p50]./1e3.*65,Y);
text(-1.65,80,sprintf('r=%2.1f   p-value=%2.2f',r(1,2),p(1,2)))
xlabel('Net uplift 1960-2025 (m)'), ylabel('Vegetation area change (%)')
ylim([15 85]), box on, set(gca,'TickDir','out','YAxisLocation','right')
xlim([-1.75 -1.35])

XY(:,1)=X'; XY(:,2)=Y; XY=sortrows(XY,1);
[r,p] = corrcoef(XY(:,1),XY(:,2)); [po,so]=polyfit(XY(:,1),XY(:,2),1); [yp,delta]=polyval(po,XY(:,1),so);
plot(XY(:,1),yp,'-r',XY(:,1),yp+delta,'--r',XY(:,1),yp-delta,'--r')

% figure panel labels
bo=.06; ho=.82;
tx1 = axes('position',[bo ho .1 .1]); axis off
text(0,0,'a','FontSize',12)
tx2 = axes('position',[0.08+w ho .1 .1]); axis off
text(0,0,'b','FontSize',12)
tx3 = axes('position',[0.1+2*w ho .1 .1]); axis off
text(0,0,'c','FontSize',12)
%
rect=[2,4,20,10]; %[xmin ymin width height]
set(gcf,'PaperType','A4','PaperUnits','centimeters','Paperposition',rect);
fout='figs/HRC_Fig10_a2_netup_basins.png'; saveas(gca,fout,'png')
fout='figs/HRC_Fig10_a2_netup_basins.pdf';
opts.Resolution = 150;
opts.BackgroundColor = 'none';
opts.ContentType='vector';
exportPlotToPDF_Advanced(gcf, fout, rect, opts);

