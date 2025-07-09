clear
addpath(genpath(pwd))

load coseismic_up_boxplots.mat
load interseismic_up_boxplots.mat
label={BA.layer};

figure(2), clf
subplot(121)
boxplot(COstack,label,'PlotStyle','traditional','symbol','.','OutlierSize',0.00001)
ylabel('Coseismic uplift in 1960 (m)'), xlabel('Tributary basin')

subplot(122)
boxplot(GPSstack,label,'PlotStyle','traditional','symbol','.','OutlierSize',0.00001)
ylabel('Interseismic GPS uplift rate (mm/yr)'), xlabel('Tributary basin')
set(gca,'YAxisLocation','right')
%
rect=[2,4,20,10]; %[xmin ymin width height]
set(gcf,'PaperType','A4','PaperUnits','centimeters','Paperposition',rect);
fout='figs/HRC_Fig3_boxplots.png'; saveas(gca,fout,'png')

