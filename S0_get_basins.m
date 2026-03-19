clear
addpath(genpath(pwd))

% read COP30 DEM
DEMf = GRIDobj('COP30_HRC_u18_c.tif');
% read tidal marshes
M = shaperead('tidal_marshes_area.shp');

% Set bounding box around tidal marshes to get basins
of=1e3;
mmax=max([M.X]); mmay=max([M.Y]);
mmix=min([M.X]); mmiy=min([M.Y]);
xlm=[mmix-5*of,mmax+2.3*of]; ylm=[mmiy-5*of,mmay+of];
DEM=crop(DEMf,xlm,ylm);

% get flow
FD  = FLOWobj(DEM,'preprocess','fill');
S   = STREAMobj(FD,'minarea',1e4);
St= klargestconncomps(S);

% read outlets and snap to streams
sites=shaperead("HRC_outlets_pts.shp");
[x,y] = snap2stream(S,[sites.X],[sites.Y]);
DB   = drainagebasins(FD,x,y);
sitesnap=sites; 
for i=1:numel(sitesnap)
    sitesnap(i).X=x(i); 
    sitesnap(i).Y=y(i);
end
shapewrite(sitesnap,'codes/data/basins/HRC_outlets_snap.shp')

% remove basins w/o tidal marshes
DB.Z(DB.Z==11)=0;
DB.Z(DB.Z==10)=0;
% merge cutipay and estancilla
DB.Z(DB.Z==7)=6;
DBS = GRIDobj2polygon(DB,'geometry','Polygon');

% Add names
layer={'Cayumapu','Cruces','Cutipay','Domingo','Maria','Pichoy','Punucapa','Tambillo'};
ix=[5,6,1,8,7,3,4,2];
for i=1:numel(ix)    
    DBS(i).ID=(ix(i));
    DBS(i).layer=layer{ix(i)};
end
% sort
[B,index]=sort(ix);
DBS=DBS(index);
DB.Z(DB.Z==min(DB.Z(:)))=NaN;

MS = STREAMobj2mapstruct(S);
shapewrite(MS,"codes/data/basins/HRC_outlets_streams.shp")
shapewrite(DBS,'codes/data/basins/HRC_outlets_basins.shp')

%% plot
figure(1), clf, hold on, box on
imageschs(DEM,'colormap',[.9 .9 .9],'colorbar',false,'ticklabels','nice')
h=mapshow(M,'facecolor','r','EdgeColor','none');
title('Valdivia estuary tributary basins')
for i=1:numel(DBS)
    plot([DBS(i).X],[DBS(i).Y],'LineWidth',2)
end
for i=1:numel(DBS)
    text(nanmean([DBS(i).X]),nanmean([DBS(i).Y]),...
        DBS(i).layer,'BackgroundColor','w','FontSize',8)
end
legend(h,'Tidal marshes','location','northwest')
xlabel('East (m)'), ylabel('North (m)')

%%
figure(2), clf, hold on
imageschs(DEM,DB,'colorbar',false)
for i=1:numel(DBS)
    text(mean([DBS(i).X]),mean([DBS(i).Y]),...    
    sprintf('%u',i),'BackgroundColor','w')
end
