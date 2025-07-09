clear
addpath(genpath(pwd))

% Load coseismic uplift from Ho et al.
CO=load('up_1960_ho_xyz.txt');

% crop
CO(CO(:,2)<-41,:)=[];
CO(CO(:,2)>-39,:)=[];
CO(CO(:,1)<-73.7,:)=[];
CO(CO(:,1)>-72.5,:)=[];

% interpolate and grid
x=CO(:,1); y=CO(:,2); v=CO(:,3);
[E,N]=deg2utm18(y,x); 
F = scatteredInterpolant(E,N,v);
dd=100; %grid size in m
[Eq,Nq] = meshgrid(min(E):dd:max(E),min(N):dd:max(N));
F.Method = 'natural';
Uq = F(Eq,Nq);

% creat gridobj
UP = GRIDobj(Eq,Nq,Uq);

% load basins
BAfile='codes/data/basins/HRC_drainagebasins_GPSuplift_u18S.shp';
BA=shaperead(BAfile);

% Crop basin polygons
for i=1:numel(BA)
    mask = polygon2GRIDobj(UP,BA(i));
    D=UP;
    D.Z(mask.Z==0)=NaN;         
    COstack(:,i)=D.Z(:); %stack
    % pdf
    %[f,xi] = ksdensity(BA(i).RO.Z(:));      
    %BA(i).f=f;
    %BA(i).xi=xi; 
    BA(i).comerw=median(D.Z(:),'omitnan');
    BA(i).cop25=prctile(D.Z(:),25);
    BA(i).cop75=prctile(D.Z(:),75);    
    fprintf('...basin %u/%u ready...\n',i,numel(BA))    
end

% add fields to shapefile
shapewrite(BA,BAfile)
fprintf('...%u basins exported...\n',numel(BA))    

% export stack for boxplot
save('codes/data/1960coseismic/coseismic_up_boxplots.mat','COstack',"BA")

