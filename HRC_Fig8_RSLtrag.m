clear

% load
addpath(genpath(pwd))

station='CORRAL'; 
gpsta='NIEB'; 
vlmp='NIEB_IPOC';
load(sprintf('%s_ASLtrag.mat',station));
load(sprintf('%s_tidetrag.mat',station));
load(sprintf('%s_IPOC_TraG.mat',gpsta));
ix=1; gps=gpstrag(ix);

% MLE of uplift rate
nci=2+2*gps.dtr.ncomp;
[fi,xi] = ksdensity(gps.Linpdf.Mb(:,nci));
gps.Linpdf.xi=xi;
gps.Linpdf.fi=fi;
[gps.Linpdf.phat, gps.Linpdf.pci] = mle(gps.Linpdf.xi,'Distribution','Normal');
P=ASL.Linpdf.fi - flip(gps.Linpdf.fi); P(P<0)=0;
S=ASL.Linpdf.xi - gps.Linpdf.xi;

% plot
figure(1), clf, hold on %, axis off
title(station)
plot(ASL.Linpdf.xi,ASL.Linpdf.fi,'-k')
plot(gps.Linpdf.xi,gps.Linpdf.fi,'-g')
plot(ELA.Linpdf.xi,ELA.Linpdf.fi,'-b')
plot(S,P,'-r')

legend('ASL','VLM','tide RSL','RSL=ASL-VLM','location','best')
box on
xlabel('Rate (mm/yr)'), ylabel('pd')

rect=[3,4,10,10]; %[xmin ymin width height]
set(gcf,'PaperType','A4','PaperUnits','centimeters','Paperposition',rect);
fout='figs/HRC_Fig8_RSLtrag.png'; saveas(gca,fout,'png')




