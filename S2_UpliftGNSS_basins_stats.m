clear
addpath(genpath(pwd))
inpt.name='HRC';
fout=sprintf('%s_TraG.mat',inpt.name); load(fout)
for i=1:numel(gpstrag)
    du(i,1)=[gpstrag(i).rate.Urate];    
end
inpt.lonlim=[-74,-71];
inpt.latlim=[-41.5,-37.5];                  % Latitude limits

% interpolate 
x=[G.X]'; y=[G.Y]'; v=du;
F = scatteredInterpolant(x,y,v);
dd=0.01;
[xq,yq] = meshgrid(inpt.lonlim(1):dd:inpt.lonlim(2),inpt.latlim(1):dd:inpt.latlim(2));
F.Method = 'natural'; F.ExtrapolationMethod ='none';
vq = F(xq,yq);

% interpolate in utm
[E,N]=deg2utm18(y,x); 
F = scatteredInterpolant(E,N,v);
dd=100; %grid size
[Eq,Nq] = meshgrid(min(E):dd:max(E),min(N):dd:max(N));
F.Method = 'natural'; F.ExtrapolationMethod ='none';
Uq = F(Eq,Nq);
%%
% load basins
BAfile='codes/data/basins/HRC_drainagebasins_GPSuplift_u18S.shp';
BA=shaperead(BAfile);

% creat grid
DEM = GRIDobj(Eq,Nq,Uq);

% Crop polygons
for i=1:numel(BA)
    mask = polygon2GRIDobj(DEM,BA(i));
    D=DEM;
    D.Z(mask.Z==0)=NaN;
    %GRIDobj2geotiff(D,sprintf('out/RO_%u_taco_%s.tif',rw,[S(i).zona]));    
    %BA(i).RO=D;             
    GPSstack(:,i)=D.Z(:); %stack
    % pdf
    %[f,xi] = ksdensity(BA(i).RO.Z(:));      
    %BA(i).f=f;
    %BA(i).xi=xi; 
    BA(i).p50=median(D.Z(:),'omitnan');
    BA(i).p25=prctile(D.Z(:),25);
    BA(i).p75=prctile(D.Z(:),75);
    
    fprintf('...basin %u/%u ready...\n',i,numel(BA))    
end
% export basin stats
shapewrite(BA,BAfile)
% export boxplot stack
save('codes/data/GPSinterseismic/interseismic_up_boxplots.mat','GPSstack')
disp('...basins updated with GPS rates...')

%% plot gridded model
figure(2), clf, cla, clc, axis off
g=0.4;
ax1 = axes('position',[0.15 0.1 0.7 0.85]); hold on
pcolor(xq,yq,vq), shading interp, colormap(ax1,bluewhitered)
cb=colorbar('position',[0.75 0.6 0.02 0.3]);
cb.Label.String = 'Uplift rate (mm/yr)';
%plot([C.X],[C.Y],'-k'), plot([P.X],[P.Y],'-k','linewidth',3), plot([B.X],[B.Y],'-k')
plot(x,y,'sk','markersize',6,'markerfacecolor','k')
for i=1:numel(G)
   text(G(i).X+0.1,G(i).Y+0.1,G(i).station,'fontsize',7) 
end
q1=quiver(x,y,zeros(numel(x),1),du,'color','k','linewidth',1.2,'MaxHeadSize',50/norm(du));
axis equal, box on,
xlim(inpt.lonlim), ylim(inpt.latlim)
title(sprintf('Uplift rate (mm/yr)')) %%4.1f a %4.1f',inpt.remdat(1),inpt.remdat(2)))
xlabel('Longitud'),ylabel('Latitud')

%rect=[2,4,15,18]; %[xmin ymin width height]
%set(gcf,'PaperType','A4','PaperUnits','centimeters','Paperposition',rect);
%fout=sprintf('%s_dispU_interp.pdf',inpt.name); saveas(gca,fout,'pdf')
%fout=sprintf('%s_dispU_interp.png',inpt.name); saveas(gca,fout,'png')
