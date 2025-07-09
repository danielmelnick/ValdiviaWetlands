clear
addpath(genpath(pwd))

% load trajectory model
load CORRAL_tidetrag.mat

xx=[ELA.t(1),ELA.t(end)]; 
g=0.8; bo=0.10; h=0.25; w=0.8; 

figure(2), clf, hold on, axis off
ax1 = axes('position',[bo 2*bo+2*h w h]); hold on
plot(ELA.t,ELA.h,'.','color',[g g g],'markersize',0.5)
plot(ELA.tlin,ELA.DHATlin,'-r','linewidth',1.5)
yx=get(gca,'ylim');
if numel(inpt.t_jumps)>0
    for i=1:numel(inpt.t_jumps)
        line([inpt.t_jumps(i) inpt.t_jumps(i)],yx,'color','g','linewidth',1.5)
    end
end
title(sprintf('%s tide gauge',inpt.station)), box on
ylim(yx), xlim(xx)
ylabel('Residual tide (mm)')
legend('Data','Trajectory model','Heaviside jump','location','northwest')
text(ELA.t(1)+1,min(yx)+100,sprintf('RSL change rate= %2.1f ± %2.2f mm/yr',ELA.M(2),ELA.Me(2))) %ylim([-100 100])

ax2 = axes('position',[bo 1.4*bo+h w h]); hold on
plot(ELA.tlin,ELA.Ulin-mean(ELA.Ulin),'-k','linewidth',1)
plot(inpt.soi.t,inpt.soi.h.*ELA.M(end),'-b','linewidth',0.5)
plot(ELA.tlin,ELA.Uht,'-g','linewidth',1)
if numel(inpt.tlt)>0
    plot(ELA.tlin,ELA.Ulg,'-r','linewidth',1)
end
xlim(xx), box on
ylabel('Elevation (mm)')
legend('Linear','SOI','Heaviside','Log','location','northwest')
title('Model components')
xlabel('Year')

ax3 = axes('position',[1.5*bo bo/2 w/2-bo h]); hold on
histfit(ELA.h-ELA.DHAT,30,'normal')
%title(sprintf('Mean=%3.2f ± %4.1f mm',mean(ELA.h-ELA.DHAT),std(ELA.h-ELA.DHAT)),'FontSize',10)
title(sprintf('SD=%4.1f mm',std(ELA.h-ELA.DHAT)),'FontSize',10)
xlabel('Model residual (mm)'), box on, ylabel('n')

ax4 = axes('position',[1.5*bo+w/2 bo/2 w/2-bo h]); hold on
plot(ELA.Linpdf.xi,ELA.Linpdf.fi,'-k')
title(sprintf('ML=%3.1f ± %3.1f mm/yr',ELA.Linpdf.phat(1),ELA.Linpdf.phat(2)),'FontSize',10)
xlabel('RSL change rate (mm/yr)'), box on, ylabel('PD')
yx=get(gca,'ylim');
line([ELA.Linpdf.phat(1) ELA.Linpdf.phat(1)],[yx(1), yx(2)])

rect=[3,4,16,22]; %[xmin ymin width height]
set(gcf,'PaperType','A4','PaperUnits','centimeters','Paperposition',rect);
fout='figs/HRC_Fig7_Tidegauge.png'; saveas(gca,fout,'png')

