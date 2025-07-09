clear
addpath(genpath(pwd))

% load trajectory model
station='CORRAL'; 
load(sprintf('%s_ASLtrag.mat',station));
load SOID.mat

% plot
xx=[ASL.t(1),ASL.t(end)]; 
g=0.8; bo=0.10; h=0.25; w=0.8; 

figure(1), clf, hold on, axis off

ax1 = axes('position',[bo 2*bo+2*h w h]); hold on
plot(ASL.t,ASL.h,'.','color',[g g g],'markersize',1)
plot(ASL.tlin,ASL.DHATlin,'-r','linewidth',1.5)
yx=get(gca,'ylim');
title(sprintf('%s Satellite Altimetry',station)), box on
ylim(yx), xlim(xx)
ylabel('Absolute sea-level elevation (mm)')
legend('Data','Trajectory model','location','southeast')
text(ASL.t(1)+1,min(ASL.h),sprintf('ASL change rate= %2.1f +/- %3.2f mm/yr',ASL.Linpdf.phat(1),ASL.Linpdf.phat(2))) %ylim([-100 100])

ax2 = axes('position',[bo 1.4*bo+h w h]); hold on
xlabel('Year')
plot(ASL.t,(ASL.M(1)+ASL.M(2).*(ASL.t-ASL.t(1)))-mean(ASL.M(1)+ASL.M(2).*(ASL.t-ASL.t(1))),'-k','linewidth',1)
plot(soi.t,soi.h.*ASL.M(end),'-b','linewidth',0.5)
xlim(xx), box on, ylabel('Elevation (mm)')
legend('Linear','SOI','location','best'), title('Model Components')

ax3 = axes('position',[1.5*bo bo/2 w/2-bo h]); hold on
histfit(ASL.h-ASL.DHAT,30,'normal')
xlabel('Model residual (mm)'), box on, ylabel('n')
title(sprintf('SD=%4.1f mm',std(ASL.h-ASL.DHAT)),'FontSize',10)

ax4 = axes('position',[1.6*bo+w/2 bo/2 w/2-bo h]); hold on
plot(ASL.Linpdf.xi,ASL.Linpdf.fi,'-k')
yx=get(gca,'ylim');
line([ASL.Linpdf.phat(1) ASL.Linpdf.phat(1)],[yx(1), yx(2)])
xlabel('ASL change rate (mm/yr)'), box on, ylabel('PD')
title(sprintf('ML=%3.1f ± %3.1f mm/yr',ASL.Linpdf.phat(1),ASL.Linpdf.phat(2)),'FontSize',10)

rect=[3,4,16,22]; %[xmin ymin width height]
set(gcf,'PaperType','A4','PaperUnits','centimeters','Paperposition',rect);
fout='figs/HRC_Fig6_ASL_trag.png'; saveas(gca,fout,'png')



