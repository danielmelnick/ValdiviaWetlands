clear
addpath(genpath(pwd))

load Rucaco.mat
load Pichoy.mat
load CORRAL_tidetrag.mat
load HRC_a2.mat
%
years = ELA.tlin;
sea_level=ELA.filt;
vegetation = interp1(HRC.t,HRC.avg,ELA.tlin);
precipitation = interp1(pp.yd,pp.Precipitacion_mm,ELA.tlin);
dis.m=moving(dis.Caudal_m3s,12,'mean');
%discharge = interp1(dis.yd,dis.m,ELA.tlin);
discharge = interp1(dis.yd,dis.Caudal_m3s,ELA.tlin);

% Create data matrix
data = [sea_level, vegetation, discharge, precipitation];
% Pearson correlation
[R_pearson, P_pearson] = corrcoef(data, 'rows', 'complete');
% Spearman correlation (rank-based, more robust to outliers)
[R_spearman, P_spearman] = corr(data, 'type', 'Spearman', 'rows', 'complete');

var_names = {'Sea Level', 'Vegetation', 'Discharge','Precipitation'};
var_units = {'m', 'km²', 'm³/s'};
fprintf('\n=== SIGNIFICANT CORRELATIONS (p < 0.05) ===\n');
sig_count = 0;
for i = 1:size(R_pearson,1)
    for j = i+1:size(R_pearson,2)
        if P_pearson(i,j) < 0.05
            sig_count = sig_count + 1;
            fprintf('%s vs %s: r = %.3f (p = %.4f)\n', ...
                var_names{i}, var_names{j}, R_pearson(i,j), P_pearson(i,j));
        end
    end
end

%%
bo=0.1; w=0.8; h=0.25; gr=.5; fs=10;

figure(2), clf, hold on, axis off
set(gcf,'color','w')

% Veg RSL
ax2 = axes('Position',[bo,4.5*bo+h,w,h]); hold on

yyaxis right
upper_bound = HRC.avgc + HRC.sdc; lower_bound = HRC.avgc - HRC.sdc;
x_patchc = vertcat(HRC.t', flipud(HRC.t'));
y_patchc = vertcat(upper_bound', flipud(lower_bound'));
hp2=fill(x_patchc, y_patchc, 'r', 'EdgeColor', 'none');
alpha(hp2,0.5);
plot(HRC.t,HRC.avgc,'-r','LineWidth',1.2)
xlim([1985,2025])
box off
ylabel('Vegetation area change (%)','FontSize',fs)
a1=[94.43;14.84]; %km;
a2=[60.67;5.4]; 
achange=(a1(1)-a2(1))/(HRC.t(end)-HRC.t(1));
text(2008,1,sprintf('Vegetation area change= %3.1f km^2/yr',achange),'Color','r')

yyaxis left
plot([ELA.tlin],[ELA.filt],'-','Color',[gr gr gr+.3])
plot([ELA.tlin],[ELA.Ulin],'-b','LineWidth',1)
xlim([1985,2025]), ylim([-150 75])
%set(gca,'xtick',[],'tickdir','out'), box off
set(gca,'xaxislocation','top','tickdir','out'), box off
xlabel('Year','FontSize',fs), ylabel('Relative sea level (mm)','FontSize',fs)
text(1995,50,sprintf('Corral tide gauge RSL change= %3.1f mm/yr',ELA.M(2)),'Color','b')

ax1 = axes('Position',[bo,1.8*bo+h,w,h]); hold on
yyaxis left
plot(dis.yd,moving(dis.Caudal_m3s,12,'mean'),'-','Color',[gr gr gr])
%plot(dis.yd,dis.Caudal_m3s,'-','Color',[gr gr gr])
xlim([1985,2025])
xlabel('Year','FontSize',fs), ylabel('Montly mean river discharge (m^3/s)','FontSize',fs)
set(gca,'tickdir','out')
ax = gca; ax.YColor = [gr gr gr];
XY=[]; XY(:,1)=dis.yd; XY(:,2)=dis.Caudal_m3s; 
XY=sortrows(XY,1); [r,p] = corrcoef(XY(:,1),XY(:,2));
[po,so]=polyfit(XY(:,1),XY(:,2),1); [yp,delta]=polyval(po,XY(:,1),so);
h1=plot(XY(:,1),yp,'--','color',[gr gr gr],'LineWidth',1.5); %,XY(:,1),yp+delta,'--r',XY(:,1),yp-delta,'--r')
%text(2010,110,sprintf('Discharge rate change= %3.1f m^3/s/yr',po(1)),'Color',[gr gr gr])

yyaxis right
plot(pp.yd,moving(pp.Precipitacion_mm,12,'mean'),'-k')
xlim([1985,2025])
ylabel('Mean precipitation (mm/month)','FontSize',fs)
ax = gca;  ax.YAxis(2).Color = 'k'; 
XY=[]; XY(:,1)=pp.yd; XY(:,2)=pp.Precipitacion_mm; XY=sortrows(XY,1); [r,p] = corrcoef(XY(:,1),XY(:,2));
[po,so]=polyfit(XY(:,1),XY(:,2),1); [yp,delta]=polyval(po,XY(:,1),so);
h1=plot(XY(:,1),yp,'--k','LineWidth',1.5); %,XY(:,1),yp+delta,'--r',XY(:,1),yp-delta,'--r')

% Correlation heatmap
ax3 = axes('Position',[1.5*bo,bo,w/2.5,h]); hold on

imagesc(R_pearson); axis tight; box on
cb=colorbar; cb.Label.String='Correlation coefficient';
colormap(gca, 'bluewhitered');
caxis([-1 1]);
set(gca, 'XTick', 1:length(var_names), 'XTickLabel', var_names, ...
    'YTick', 1:length(var_names), 'YTickLabel', var_names);
xtickangle(45);
title('Pearson Correlation Matrix');

% Add correlation values to heatmap
for i = 1:size(R_pearson,1)
    for j = 1:size(R_pearson,2)
        text(j, i, sprintf('%.2f', R_pearson(i,j)), ...
            'HorizontalAlignment', 'center', 'FontSize', 10);
    end
end

% corr RSL-Vegetation
ax3 = axes('Position',[1.5*bo+w/2,bo,w/2.5,h]); hold on
row = 2; col = 1;
plot(data(:,col), data(:,row), '.b','MarkerSize',0.1);
xlim([-180 60])
xlabel(var_names{col}); ylabel(var_names{row});
xlabel('Relative sea level (mm)','FontSize',fs); ylabel('Vegetation area change (%)','FontSize',fs)
title(sprintf('r = %.2f', R_pearson(row,col)));
box on
set(gca,'YAxisLocation','right')

% figure panel labels
bo=.02; ho=.98;
tx1 = axes('position',[bo ho .1 .1]); axis off
text(0,0,'a','FontSize',12)
tx2 = axes('position',[bo ho/1.4 .1 .1]); axis off
text(0,0,'b','FontSize',12)
tx3 = axes('position',[bo ho/2.7 .1 .1]); axis off
text(0,0,'c','FontSize',12)
tx4 = axes('position',[bo+0.5 ho/2.7 .1 .1]); axis off
text(0,0,'d','FontSize',12)

rect=[2,4,20,25]; %[xmin ymin width height]
set(gcf,'PaperType','A4','PaperUnits','centimeters','Paperposition',rect);
fout='figs/HRC_Fig11_RSL_discharge.png'; saveas(gca,fout,'png')








