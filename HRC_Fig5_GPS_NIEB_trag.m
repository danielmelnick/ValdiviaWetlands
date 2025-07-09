clear
addpath(genpath(pwd))

% load Trajectory model
gpsta='NIEB'; 
vlmp='NIEB_IPOC';
load(sprintf('%s_TraG.mat',vlmp));
ix=1; gps=gpstrag(ix);
nci=2+2*gps.dtr.ncomp;
[fi,xi] = ksdensity(gps.Linpdf.Mb(:,nci));
gps.Linpdf.xi=xi; gps.Linpdf.fi=fi;
[gps.Linpdf.phat, gps.Linpdf.pci] = mle(gps.Linpdf.xi); %,'Distribution','Normal');

% plot VLM
xx=[gps.gps.t(1),gps.gps.t(end)]; 
g=0.8; bo=0.10; h=0.25; w=0.8; 

figure(3), clf, hold on, axis off

ax1 = axes('position',[bo 2*bo+2*h w h]); hold on
plot(gps.gps.t,gps.gps.U,'.','color',[g g g],'markersize',0.5)
plot(gps.gps.tlin,gps.gps.trajUi,'-r','linewidth',2)
yx=get(gca,'ylim');
if numel(gps.gps.eqs.t_jumps)>0
    for i=1:numel(gps.gps.eqs.t_jumps)
        line([gps.gps.eqs.t_jumps(i) gps.gps.eqs.t_jumps(i)],yx,'color','g','linewidth',1)
    end
end
title(sprintf('%s GNSS station',gpsta)), box on
ylim(yx), xlim(xx)
ylabel('Elevation (mm)')
legend('Data','Trajectory model','Heaviside jump','location','northwest')
text(gps.gps.t(1)+1,min(yx)+5,sprintf('VLM rate= %2.1f ± %2.2f mm/yr',gps.rate.Urate,gps.rate.Urater)) %ylim([-100 100])

ax2 = axes('position',[bo 1.4*bo+h w h]); hold on
plot(gps.dtr.t,gps.dtr.ltren.U,'-k') %,'markersize',msz,
plot(gps.dtr.t,gps.dtr.htren.U,'-g') %,'markersize',msz,
plot(gps.gps.t,gps.dtr.stren.U,'-r') %,'markersize',msz,
plot(gps.dtr.t,gps.dtr.lgtren.U,'-b') %,'markersize',msz,
xlim(xx), box on
ylabel('Elevation (mm)')
legend('Linear','Heaviside','Seasonal','Log','location','northwest')
title('Model components')
xlabel('Year')

ax3 = axes('position',[1.5*bo bo/2 w/2-bo h]); hold on
histfit(gps.gps.U-gps.gps.trajU,30,'normal')
title(sprintf('SD=%4.1f mm',std(gps.gps.U-gps.gps.trajU)))
xlabel('Model residual (mm)'), box on, ylabel('n')

ax4 = axes('position',[1.6*bo+w/2 bo/2 w/2-bo h]); hold on
plot(gps.Linpdf.xi,gps.Linpdf.fi,'-k')
title(sprintf('ML=%2.2f ± %2.2f mm/yr',gps.Linpdf.phat(1),gps.Linpdf.phat(2)))
xlabel('VLM rate (mm/yr)'), box on, ylabel('PD')
yx=get(gca,'ylim');
line([gps.Linpdf.phat(1) gps.Linpdf.phat(1)],[yx(1), yx(2)])

rect=[3,4,16,22]; %[xmin ymin width height]
set(gcf,'PaperType','A4','PaperUnits','centimeters','Paperposition',rect);
fout='figs/HRC_Fig5_GPS_NIEB_rag.png'; saveas(gca,fout,'png')




