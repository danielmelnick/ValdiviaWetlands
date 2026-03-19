clear
addpath(genpath(pwd))

DEM=GRIDobj('HRC_srtmplus_Fig1.tif');

%C=shaperead('GSHHS_h_L1');
% Load coseismic uplift from Ho et al.
CO=load('up_1960_ho_xyz.txt');
x1=-75; x2=-71; y1=-42; y2=-37;
dd=0.01; %grid size in m
[Xq,Yq] = meshgrid(x1:dd:x2,y1:dd:y2);

% crop
CO(CO(:,2)<y1,:)=[]; CO(CO(:,2)>y2,:)=[];
CO(CO(:,1)<x1,:)=[]; CO(CO(:,1)>x2,:)=[];
Dc = crop(DEM,[x1,x2],[y1 y2]); 
GT=contour(Dc, [0 0]);

%% interpolate and grid
FS = scatteredInterpolant(CO(:,1),CO(:,2),CO(:,3));
FS.Method = 'natural';
Sq = FS(Xq,Yq);

% create gridobj
S = GRIDobj(Xq,Yq,Sq);
S.Z=single(S.Z);
S.georef=Dc.georef;
S.wf=Dc.wf;

zmin = min(S.Z(:)); zmax = max(S.Z(:));
clim_abs = max(abs(zmin), abs(zmax));   % symmetric limits → white = 0
n_colors  = 128;
cmap = bluewhitered(n_colors);          % diverging blue-white-red
%%
load("HRC_TraG.mat")
for i=1:numel(gpstrag)
    du(i,1)=[gpstrag(i).rate.Urate];        
end
% interpolate 
x=[G.X]'; y=[G.Y]'; v=du;
F = scatteredInterpolant(x,y,v);
F.Method = 'natural'; F.ExtrapolationMethod ='none';
Uq = F(Xq,Yq);

% creat gridobj
U = GRIDobj(Xq,Yq,Uq);
U.Z=single(U.Z);
U.georef=Dc.georef;
U.wf=Dc.wf;

zmin = nanmin(U.Z(:)); zmax = nanmax(U.Z(:));
clim_absu = max(abs(zmin), abs(zmax));   % symmetric limits → white = 0
%%
f=figure(1); clf
f.Position = [2287 100 800 500];

% Co uplift
hax1 = axes('position',[0.05 .3 .5 .5]); hold on, box on
imageschs(Dc, S, ...
    'colormap',   cmap, ...
    'caxis',      [-clim_abs, clim_abs], ...   % symmetric → white = 0
    'ticklabels', 'nice', ...
    'colorbar',   true);
%plot([C.X],[C.Y],'-k')
geoshow(GT,'DisplayType', 'line', ...
    'Color',       [0 0 0], ...   % RGB triplet (red)
    'LineWidth',   0.5, ...
    'LineStyle',   '-');
hcbm=colorbar; %('position',[0.34 .12 0.015 0.15]);
hcbm.Label.String ='Coseismic land-level change (m)'; 
hcbm.TickDirection='out'; 
ylabel('Latitude'), xlabel('Longitude')
xlim([x1 x2]), ylim([y1 y2]), box on

% GNSS
hax2 = axes('position',[0.5 .3 .5 .5]); hold on, box on
imageschs(Dc, U, ...
    'colormap',   cmap, ...
    'caxis',      [-clim_absu, clim_absu], ...   % symmetric → white = 0
    'ticklabels', 'nice', ...
    'colorbar',   true);
hcbm=colorbar; %('position',[0.34 .12 0.015 0.15]);
hcbm.Label.String ='Interseismic GNSS uplift rate (mm/yr)'; 
hcbm.TickDirection='out'; %hcbm.TickLabels={-5,0,5};
ylabel('Latitude'), xlabel('Longitude')
geoshow(GT,'DisplayType', 'line', ...
    'Color',       [0 0 0], ...   % RGB triplet (red)
    'LineWidth',   0.5, ...
    'LineStyle',   '-');
plot(x,y,'sk','markersize',4,'markerfacecolor','auto')
for i=1:numel(G)
   text(G(i).X+0.08,G(i).Y+0.08,G(i).station,'fontsize',7) 
end
q1=quiver(x,y,zeros(numel(x),1),du,'color','k','linewidth',1.2,'MaxHeadSize',50/norm(du));
xlim([x1 x2]), ylim([y1 y2])

% export
w=30;
h=w * f.Position(4)./f.Position(3);
rect = [0,0,w,h]; 
set(gcf,'PaperType','A4','PaperUnits','centimeters','Paperposition',rect);
fout='figs/HRC_Fig1_landlevels.png'; saveas(gca,fout,'png')

