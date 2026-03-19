clear
addpath(genpath(pwd))

DEMf = GRIDobj('COP30_HRC_u18_c.tif');
% read tidal marshes
M = shaperead('tidal_marshes_area');
A = shaperead('area_river_marsh_pre_1960.shp');
%
of=1e3;
mmax=max([M.X]); mmay=max([M.Y]);
mmix=min([M.X]); mmiy=min([M.Y]);
xlm=[mmix-5*of,mmax+2.3*of]; ylm=[mmiy-5*of,mmay+of];

DEM=crop(DEMf,xlm,ylm);

DBS=shaperead('HRC_outlets_basins.shp');
S=shaperead("HRC_outlets_streams.shp");
%%
%DEM.Z(DEM.Z<0.15)=NaN;

figure(1), clf, hold on, box on
imageschs(DEM,'colormap',[.9 .9 .9],'colorbar',false,'ticklabels','nice')
h=mapshow(M,'facecolor','r','EdgeColor','none');
%plot([S.X],[S.Y],'-b')
%mapshow(DBS,'facecolor','none','EdgeColor','r','LineWidth',2);
title('Valdivia estuary tributary basins')
for i=1:numel(DBS)
    plot([DBS(i).X],[DBS(i).Y],'LineWidth',2)
end
for i=1:numel(DBS)
    text(nanmean([DBS(i).X]),nanmean([DBS(i).Y]),...
        DBS(i).layer,'BackgroundColor','w','FontSize',8)
end
%h=mapshow(A,'facecolor','b'); 
%legend(h,'pre-1960 fluvial network','location','northwest')
legend(h,'Tidal marshes','location','northwest')

xlabel('East (m)'), ylabel('North (m)')

rect=[2,4,20,20]; %[xmin ymin width height]
set(gcf,'PaperType','A4','PaperUnits','centimeters','Paperposition',rect);
fout='figs/HRC_Fig2_drainagebasins.png'; saveas(gca,fout,'png')

