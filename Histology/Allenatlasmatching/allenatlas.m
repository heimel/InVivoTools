function [intensity,x_mm] = allenatlas(slice_name,separate_figures)
%ALLENATLAS loads and slices Allen Atlas map to compare slice
%
%  [INTENSITY, X_MM] = ALLENATLAS( SLICE_NAME, SEPARATE_FIGURES )
%
%  Allen Atlas nissl maps and annotation files need to be downloaded
%    to folder specified in params.hist_allenmaplocation, set in
%    processparams_local.m file
%  the map file atlasVolume.raw and annotation file 1.json can be found at 
%     http://help.brain-map.org/display/mousebrain/API#API-DownloadAtlas
%     Annotation http://api.brain-map.org/api/v2/structure_graph_download/1.json
%
%  2016-2020, Alexander Heimel, based on Allen Institute loading script

if nargin<1
    slice_name = '';
end
if nargin<2 || isempty(separate_figures)
    separate_figures = false;
end

disp('Loading and slicing Allen Mouse Atlas. See http://help.brain-map.org/display/mousebrain/API#API-DownloadAtlas');
disp('Annotation file: http://api.brain-map.org/api/v2/structure_graph_download/1.json');

screensize = get(0,'ScreenSize');
fig = figure(1234);
set(fig,'keypressfcn',@keypress);
set(fig,'color',[0 0 0 ]);
ud = get(fig,'userdata');
ud.separate_figures = separate_figures;
set(fig,'Position',[20 screensize(4)/2-40 screensize(3)-2*20 screensize(4)/2-2*40]);

params = histprocessparams; % edit processparams_local to set alternate locations for slices and atlas


% load slice
if ~isfield(ud,'slice_name') || (~isempty(slice_name) && ~strcmp(ud.slice_name,slice_name))

    filename = fullfile(params.hist_sliceslocation,[slice_name '.jpg']);
    if ~exist(filename,'file')
        disp('Choose a slice image');
        savedir = pwd;
        if exist(params.hist_sliceslocation,'dir')
            cd(params.hist_sliceslocation);
        else
            logmsg(['Folder ' params.hist_sliceslocation ' des not exist.'])
            logmsg(['Set params.hist_slicelocation in processparams_local.m file to change default search location.']);
        end
        [filename,pathname] = uigetfile({'*.*','All Files (*.*)'},'Choose a slice image');
        cd(savedir);
        if filename==0
            return
        end
        filename = fullfile(pathname,filename);
        if ~exist(filename,'file')
            errormsg([filename ' does not exist.']);
            return
        end
    end
    [~,ud.slice_name] = fileparts(filename);
    
    ud.slice = imread(filename);
end

if ~isfield(ud,'VOL') || ~isfield(ud,'ANO') || isempty(ud.VOL) || isempty(ud.ANO)
    atlasfolder = params.hist_allenmaplocation;
    
    % 25 micron volume size
    blocksize = [528 320 456]; % Anterior-posterior, dorsal-ventral, left-right
    ud.size_ap = blocksize(1);
    ud.size_dv = blocksize(2);
    ud.size_lr = blocksize(3);
    % VOL = 3-D matrix of atlas Nissl volume
    atlasfilename = fullfile(atlasfolder,'atlasVolume.raw');
    if ~exist(atlasfilename,'file')
        disp('Select atlasVolume.raw');
        [atlasfilename,atlasfolder] = uigetfile({'*.raw','Raw Files (*.raw)'},'Locate atlasVolume.raw');
        atlasfilename = fullfile(atlasfolder,atlasfilename);
    end
    fid = fopen(atlasfilename, 'r', 'l' );
    if fid==-1
        disp(['Error opening ' atlasfilename ]);
        return
    end
    ud.VOL = fread( fid, prod(blocksize), 'uint8' );
    fclose( fid );
    ud.VOL = reshape(ud.VOL,blocksize);
    
    % ANO = 3-D matrix of annotation labels
    fid = fopen(fullfile(atlasfolder,'annotation.raw'), 'r', 'l' );
    ud.ANO = fread( fid, prod(blocksize), 'uint32' );
    fclose( fid );
    ud.ANO = reshape(ud.ANO,blocksize);
    
    % make top view where brightness dependents on distance
    levelim = repmat(1:ud.size_dv,[ud.size_ap 1 ud.size_lr]);
    levelim = levelim.*(ud.VOL>1);
    levelim(levelim==0) = NaN;
    ud.topim = -squeeze(min(levelim,[],2));
end

disp('Keys:');
disp('a,d     : map turn counter clockwise, clockwise')
disp('/,\     : map tilt forward, backward')
disp('w,s     : map next, previous ');
disp('arrows  : slice move');
disp('pg up,dn: slice scale up, down');
disp('[,]     : slice turn');
disp('q       : quit');
disp('r       : reset slice');
disp('e       : export');
disp('p       : map set phi in degrees');
disp('shift   : to increase step size');

set(fig,'userdata',ud);
set(fig,'Name',ud.slice_name);
set(fig,'NumberTitle','off');
goto_baseposition(fig);
showslice(fig)

if nargout>1
    ud = get(gcf,'userdata');
    [intensity,x_mm] = get_profile(ud);
end


function showslice(fig)

v1_ids = [385, 593, 821, 721, 778, 33,305];
vlat_ids = [409, 421, 973, 573, 613, 74,121];
al_ids = [402 1074 905 1114 233 601 649];
% va_ids = [  669 801 561 913 937 457 497 ];
% am_ids = [394 281 1066 401 433 1046 411];
% pl_ids = [425 750 269 869 902 377 393];
% pm_ids = [533 805 41 501 565 257 469];
vlat_ids = [al_ids vlat_ids];
ud = get(fig,'userdata');

r(1) = -ud.axis_ap/cos(ud.phi);
r(2) = (ud.size_ap-ud.axis_ap)/cos(ud.phi);
r(3) = -ud.axis_lr/sin(ud.phi);
r(4) = (ud.size_lr-ud.axis_lr)/sin(ud.phi);
r = sort(r);
r_lims = r([2 3]);

imano = [];
count = 1;

im = NaN(round(r_lims(2)-r_lims(1)),ud.size_dv);
for r= r_lims(1):(r_lims(2)-1)
    if ud.theta==0
        
        ap = round(ud.axis_ap + r*cos(ud.phi) + 1);
        lr = round(ud.axis_lr + r*sin(ud.phi) + 1);
        if lr>ud.size_lr
            continue
        end
        if ap>ud.size_ap
            continue
        end
        im(count,:)    = ud.VOL(ap,:,lr);
        imano(count,:) = ud.ANO(ap,:,lr);
    else % slow tilted plane. slow and incorrect
        disp('Tilting is not implemented');
        n_z = ceil(abs(ud.size_dv*cos(ud.theta)));
        for z=1:n_z
            ap = round(ud.axis_ap + r*cos(ud.phi) + 1 + z*sin(ud.theta)*sin(ud.phi));
            dv = round(z*cos(ud.theta));
            lr = round(ud.axis_lr + r*sin(ud.phi) + 1+ z*sin(ud.theta)*cos(ud.phi));
            im(count,z)    = ud.VOL(ap,dv,lr);
            imano(count,z) = ud.ANO(ap,dv,lr);
        end
    end
    count = count+1;
end

imv1 = imano;
imv1(imv1>0) = 1;
imv1(1) = 2;
for i=1:length(v1_ids)
    imv1(imano(:)==v1_ids(i))=2;
end

imvlat = imano;
imvlat(imvlat>0) = 1;
imvlat(1) = 2;
for i=1:length(vlat_ids)
    imvlat(imano(:)==vlat_ids(i))=2;
end


xl = [0.5 260.5];
yl = [0.4 310.5];

if ud.separate_figures
    figure
else
    subplot('position',[0.03 0.2 0.1 0.8]);
end

show_topview(ud,r_lims)

if ud.separate_figures
    figure
else
    subplot('position',[0.15 0.15 0.4 0.8]);
end
imagesc(im');
axis image off
set(gca,'xdir','reverse');
colormap(gray);
xlim(xl);
ylim(yl);

% get v1 border
if 1
    imv1 = imgaussfilt(imv1,2);
    outlinev1 = (imv1>1.4);
else
    outlinev1 = imv1>1; %#ok<UNRCH>
end
b{1} = bwboundaries(outlinev1);%,'noholes');

% get hippocampus pyramidal border
im = imgaussfilt(im,2);
imb = (im>100);
b{2} = bwboundaries(imb);%,'noholes');

% get brain border
im = imgaussfilt(im,7);
imb = (im>30);
b{3} = bwboundaries(imb);%,'noholes');
b{3} = b{3}(1);

% get v1at border
if 1
    imvlat = imgaussfilt(imvlat,2);
    outlinevlat = (imvlat>1.4);
else
    outlinevlat = imvlat>1; %#ok<UNRCH>
end
b{4} = bwboundaries(outlinevlat);%,'noholes');

ud.borders = b;

plot_borders(b)

if ud.separate_figures
    figure
    set(gcf,'color','none');
    plot_borders(b)
    axis image off
    set(gca,'ydir','reverse')
end

% show slice
if ud.separate_figures
    figure
    set(gcf,'color',[0 0 0]);
    set(gca,'color',[0 0 0]);
else
    subplot('position',[0.575 0.15 0.4 0.8],'color',[0 0 0]);
    set(gcf,'color',[0 0 0]);
    set(gca,'color',[0 0 0]);
end
imslice = ud.slice;
if ud.slice_angle~=0
    imslice = imrotate(imslice,ud.slice_angle);
end
if ud.slice_scale~=1
    imslice = imresize(imslice,ud.slice_scale);
end
if any(ud.slice_shift~=0)
    imslice = imtranslate(imslice,ud.slice_shift);
end

if ndims(imslice)==3 % rgb
    imslice = double(imslice(:,:,2)); % take green channel
else
    imslice = double(imslice);
end

imslice = imslice - min(imslice(:));
imslice = imslice / prctile(imslice(:),ud.slice_prctile) * 64;

imslice = imslice.^ud.slice_gamma;
image(imslice);
ud.imslice = imslice;

colormap gray;
axis image off
set(gca,'xdir','reverse');
plot_borders(b)
xlim(xl);
ylim(yl);
hold on

if ud.separate_figures
    figure
else
    subplot('position',[0 0.05 1 0.1]);
end
axis off
txt=['AP = ' num2str(round(ud.axis_ap)) ...
    ', LR = ' num2str(round(ud.axis_lr) ) ...
    ', phi = ' num2str(round(ud.phi*180/pi)) ' deg' ...
    ', theta = ' num2str(round(ud.theta*180/pi)) ' deg' ...
    ', shift = ' num2str(round(ud.slice_shift )) ...
    ', angle = ' num2str(round(ud.slice_angle )) ' deg' ...
    ', scale = ' num2str(ud.slice_scale)  ...
    ];
if isfield(ud,'text')
    delete(ud.text);
    ud.text =  text(0.1,0.1,txt,'color',[1 1 1]);
else
    ud.text =  text(0.1,0.1,txt,'color',[1 1 1]);
end
set(fig,'userdata',ud);
drawnow

% if ud.phi<0
%     disp('Note that left and right hemisphere may be reversed for negative angle phi');
% end


function [intensity,x_mm] = get_profile(ud)
b = ud.borders;
imslice = ud.imslice;

% get orthogonal projection
m1 = min(b{1}{1}(:,1));
m2 = min(b{1}{2}(:,1));
if m2<m1
    bv1 = b{1}{2};
else
    bv1 = b{1}{1};
end
[~,ind_rightmost] = min(bv1(:,1));
[~,ind_bottommost] = max(bv1(:,2));

btop = [ bv1(ind_rightmost,1),bv1(ind_rightmost,2)];
bbot = [bv1(ind_bottommost,1),bv1(ind_bottommost,2)];

bbotval = imslice(bbot(2),bbot(1));
imslice(bbot(2),bbot(1)) = NaN;
imslice(bbot(2)+1,bbot(1)) = NaN;

ang = angle( -(btop(1)-bbot(1)) - 1i*(btop(2)-bbot(2)));

imslice(imslice<ud.slice_threshold) = 0;
imslice = imrotate(imslice,-90+ang/pi*180);

[indi,indj] = find(isnan(imslice),1);
imslice(indi,indj) = bbotval;

% remove dii tracks
for i=1:size(ud.slice_diis,1)
    [x,y] = meshgrid( (1:size(imslice,2)) - ud.slice_diis(i,1),(1:size(imslice,1)) - ud.slice_diis(i,2));
    d = sqrt(x.^2 + y.^2);
    d = (d<ud.slice_diis(i,3));
    imslice(d) = ud.slice_base; % will become NaN
end
figure('Name',['Profile ' ud.slice_name],'NumberTitle','off');
imagesc(imslice);

imslice(imslice==0) = NaN;
topslice = imslice(1:(indi+40),:);

intensity = nanmean(topslice,1);
intensity = intensity-ud.slice_base;
intensity = intensity/max(intensity);

x = (1:size(imslice,2)) - indj;
x_mm = x * 0.025; % in mm

figure;
subplot(2,1,1);
image(topslice);

subplot(2,1,2);
plot(x_mm,intensity);
xlim([min(x_mm) max(x_mm)]);

function plot_borders(b)
clr = 'gbry';
hold on
for i=[1 2 3 4] %[1 2 3]
    for k = 1:length(b{i})
        boundary = b{i}{k} ;
        plot(boundary(:,1),boundary(:,2) ,  [':' clr(i)], 'LineWidth', 2)
    end
end
hold off


function goto_baseposition(fig)
ud = get(fig,'userdata');

ud = get_baseposition(ud);

set(fig,'userdata',ud);

function keypress(fig,event)
ud = get(fig,'userdata');
if ismember(event.Modifier,'shift')
    step = 3;
else
    step = 1;
end

switch event.Key
    case 'a'  % turn counter clockwise
        ud.phi = ud.phi + 0.01 * step;
    case 'd' % turn clockwise
        ud.phi = ud.phi - 0.01 * step;
    case 'slash'
        ud.theta = ud.theta + 0.01 * step;
    case 'backslash'
        ud.theta = ud.theta - 0.01 * step;
    case 'w' % next slice
        ud.axis_ap = ud.axis_ap - step*sin(ud.phi);
        ud.axis_lr = ud.axis_lr + step* cos(ud.phi);
    case 's' % previous slice
        ud.axis_ap = ud.axis_ap + step*sin(ud.phi);
        ud.axis_lr = ud.axis_lr - step* cos(ud.phi);
    case 'r'% reset
        goto_baseposition(fig);
        ud = get(fig,'userdata');
    case 'q' % quit
        close(fig);
        return
    case 'e' % export
        filename = ['slice_' ud.slice_name '_ap' num2str(round(ud.axis_ap)) ...
            '_lr' num2str(round(ud.axis_lr)) ...
            '_phi' num2str(round(ud.phi/pi*180)) ];
        saveas(fig,filename,'png');
        saveas(fig,filename,'tif');
        disp(['Saved as ' fullfile(pwd,filename)]);
    case 'p'
        phi_deg = input('Set phi to (deg): ');
        if isnumeric(phi_deg) && ~isempty(phi_deg)
            ud.phi = phi_deg /180 *pi;
        else
            disp('Please enter number in degrees next time');
        end
        
        % moving experimental slice
    case 'leftbracket'
        ud.slice_angle = ud.slice_angle - 0.5 * step;
    case 'rightbracket'
        ud.slice_angle = ud.slice_angle + 0.5 * step;
        disp(['slice_angle = ' num2str(ud.slice_angle)]);
    case 'uparrow'
        ud.slice_shift(2) = ud.slice_shift(2)  - step;
    case 'downarrow'
        ud.slice_shift(2) = ud.slice_shift(2)  + step;
    case 'leftarrow'
        ud.slice_shift(1) = ud.slice_shift(1)  + step;
    case 'rightarrow'
        ud.slice_shift(1) = ud.slice_shift(1)  - step;
    case 'pageup'
        ud.slice_scale(1) = ud.slice_scale(1)  + 0.02 * step;
    case 'pagedown'
        ud.slice_scale(1) = ud.slice_scale(1)  - 0.02 * step;
end
set(fig,'userdata',ud);
showslice(fig);


function show_topview(ud,r_lims)
persistent Model %#ok<PSET>
if isempty(Model)
    load('AllenBrainTopView.mat','-mat','Model');
end
aplims = [round(ud.axis_ap + r_lims(1)*cos(ud.phi) + 1) round(ud.axis_ap + (r_lims(2)-1)*cos(ud.phi) + 1)];
lrlims = [round(ud.axis_lr + r_lims(1)*sin(ud.phi) + 1) round(ud.axis_lr + (r_lims(2)-1)*sin(ud.phi) + 1)];

imagesc(ud.topim);
colormap gray;
axis image off
hold on
line(lrlims,aplims,'color','r','linewidth',2);
if ud.phi>0
    set(gca,'xdir','reverse');
else
    set(gca,'xdir','normal');
end
set(gca,'ydir','normal');

s = 0.59;
for i=1:length(Model.Boundaries)
    for j=1:length(Model.Boundaries{i})
        plot(s*Model.Boundaries{i}{j}(:,2),s*Model.Boundaries{i}{j}(:,1)-10,'k');
    end
end
hold off
