function allenatlasmatching(slice_name)
%ALLENATLASMATCHING
%
%  Loading and slicing Allen Atlas map
%  http://help.brain-map.org/display/mousebrain/API#API-DownloadAtlas
%
%  Annotation http://api.brain-map.org/api/v2/structure_graph_download/1.json
%
%  2016 Alexander Heimel, based on Allen Institute
%
% DEPRECATED: USE ALLENATLAS INSTEAD

disp('DEPRECATED: Use allenatlas instead');


if nargin<1
    slice_name = '';
end

disp('Loading and slicing Allen Mouse Atlas. See http://help.brain-map.org/display/mousebrain/API#API-DownloadAtlas');
disp('Annotation file: http://api.brain-map.org/api/v2/structure_graph_download/1.json');

screensize = get(0,'ScreenSize');
fig = figure(1234);
set(fig,'keypressfcn',@keypress);
set(fig,'color',[0 0 0 ]);
ud = get(fig,'userdata');
set(fig,'Position',[20 screensize(4)/2-40 screensize(3)-2*20 screensize(4)/2-2*40]);
%set(fig,'PaperOrientation','landscape');

% load slice
if ~isfield(ud,'slice_name') || (~isempty(slice_name) && ~strcmp(ud.slice_name,slice_name))
    if isempty(slice_name)
        slice_name = 'ignace3';
    end
    ud.slice_name = slice_name;
    ud.slice = imread([ud.slice_name '.jpg']);
end

if ~isfield(ud,'VOL') || ~isfield(ud,'ANO') || isempty(ud.VOL) || isempty(ud.ANO)
    atlasfolder = fileparts(mfilename);
    
    % 25 micron volume size
    blocksize = [528 320 456]; % Anterior-posterior, dorsal-ventral, left-right
    ud.size_ap = blocksize(1);
    ud.size_dv = blocksize(2);
    ud.size_lr = blocksize(3);
    % VOL = 3-D matrix of atlas Nissl volume
    atlasfilename = fullfile(atlasfolder,'atlasVolume.raw');
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
disp('left : turn counter clockwise')
disp('right: turn clockwise')
disp('/    : tilt forward')
disp('\    : tilt backward')
disp('up   : next slice');
disp('down : previous slice');
disp('q    : quit');
disp('r    : reset slice');
disp('s    : save');
disp('p    : set phi in degrees');
disp('shift: to increase step size');


set(fig,'userdata',ud);
set(fig,'Name',ud.slice_name);
set(fig,'NumberTitle','off');
goto_baseposition(fig);
showslice(fig)



function showslice(fig)

separate_figures = false;

v1_ids = [385, 593, 821, 721, 778, 33,305];
vlat_ids = [409, 421, 973, 573, 613, 74,121];
 
va_ids = [  669 801 561 913 937 457 497 ];
al_ids = [402 1074 905 1114 233 601 649];
am_ids = [394 281 1066 401 433 1046 411];
pl_ids = [425 750 269 869 902 377 393];
pm_ids = [533 805 41 501 565 257 469];
vlat_ids = [al_ids vlat_ids];
ud = get(fig,'userdata');

r(1) = -ud.axis_ap/cos(ud.phi);
r(2) = (ud.size_ap-ud.axis_ap)/cos(ud.phi);
r(3) = -ud.axis_lr/sin(ud.phi);
r(4) = (ud.size_lr-ud.axis_lr)/sin(ud.phi);
r = sort(r);
r_lims = r([2 3]);

im = [];
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
            try
                ap = round(ud.axis_ap + r*cos(ud.phi) + 1 + z*sin(ud.theta)*sin(ud.phi));
                dv = round(z*cos(ud.theta));
                lr = round(ud.axis_lr + r*sin(ud.phi) + 1+ z*sin(ud.theta)*cos(ud.phi));
                im(count,z)    = ud.VOL(ap,dv,lr);
                imano(count,z) = ud.ANO(ap,dv,lr);
            end
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

aplims = [round(ud.axis_ap + r_lims(1)*cos(ud.phi) + 1) round(ud.axis_ap + (r_lims(2)-1)*cos(ud.phi) + 1)];
lrlims = [round(ud.axis_lr + r_lims(1)*sin(ud.phi) + 1) round(ud.axis_lr + (r_lims(2)-1)*sin(ud.phi) + 1)];

xl = [0.5 260.5];
yl = [0.4 310.5];

if separate_figures
    figure
else
    subplot('position',[0.03 0.2 0.1 0.8]);
end
imagesc(ud.topim);
colormap gray;
axis image off
hold on
line(lrlims,aplims,'color','r','linewidth',2);
if ud.phi<0
    set(gca,'xdir','reverse');
end
hold off

if separate_figures
    figure
else
    subplot('position',[0.15 0.15 0.4 0.8]);
end
imagesc(im');
axis image off
colormap(gray);
xlim(xl);
ylim(yl);

% get v1 border
if 1
    imv1 = imgaussfilt(imv1,2);
    outlinev1 = (imv1>1.4);
else
    outlinev1 = imv1>1;
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
    outlinevlat = imvlat>1;
end
b{4} = bwboundaries(outlinevlat);%,'noholes');

plot_borders(b)

if separate_figures
    figure
    set(gcf,'color','none');
    plot_borders(b)
    axis image off
    set(gca,'ydir','reverse')
end

% show slice
if separate_figures
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
imslice = double(imslice(:,:,1));
imslice = imslice.^ud.slice_gamma;
image(imslice);
colormap gray;
axis image off
plot_borders(b)
xlim(xl);
ylim(yl);


if separate_figures
    figure
else
    subplot('position',[0 0.05 1 0.1]);
end
axis off
txt=['AP = ' num2str(round(ud.axis_ap)) ...
    ', LR = ' num2str(round(ud.axis_lr) ) ...
    ', phi = ' num2str(round(ud.phi*180/pi)) ' deg' ...
    ', theta = ' num2str(round(ud.theta*180/pi)) ' deg'];
if isfield(ud,'text')
    delete(ud.text);
    ud.text =  text(0.1,0.1,txt,'color',[1 1 1]);
else
    ud.text =  text(0.1,0.1,txt,'color',[1 1 1]);
end
set(fig,'userdata',ud);
drawnow

if ud.phi<0
    disp('Note that left and right hemisphere may be reversed for negative angle phi');
end


function plot_borders(b)
clr = 'gbry';
hold on
for i=[1 3 4]
    for k = 1:length(b{i})
        boundary = b{i}{k} ;
        plot(boundary(:,1),boundary(:,2) ,  [':' clr(i)], 'LineWidth', 2)
    end
end
hold off


function goto_baseposition(fig)
ud = get(fig,'userdata');
ud.phi = -98/180*pi; % angle in AP-LR plane (radii) sagittal =0 ; coronal = pi/2;
ud.axis_ap = 315;
ud.axis_lr = 112;
ud.theta = 0; % angle to DV axis (radii) vertical = 0; horizontal = pi/2
ud.slice_angle = 0; % in degrees
ud.slice_scale = 1;
ud.slice_shift = [0 0];
ud.slice_gamma = 1;

set(fig,'userdata',ud);

function keypress(fig,event)
ud = get(fig,'userdata');
if ismember(event.Modifier,'shift')
    step = 3;
else
    step = 1;
end

switch event.Key
    case 'leftarrow'  % turn counter clockwise
        ud.phi = ud.phi + 0.01 * step;
    case 'rightarrow' % turn clockwise
        ud.phi = ud.phi - 0.01 * step;
    case 'slash'
        ud.theta = ud.theta + 0.01 * step;
    case 'backslash'
        ud.theta = ud.theta - 0.01 * step;
    case 'uparrow' % next slice
        ud.axis_ap = ud.axis_ap - step*sin(ud.phi);
        ud.axis_lr = ud.axis_lr + step* cos(ud.phi);
    case 'downarrow' % previous slice
        ud.axis_ap = ud.axis_ap + step*sin(ud.phi);
        ud.axis_lr = ud.axis_lr - step* cos(ud.phi);
    case 'r'% reset
        disp('jkj');
        goto_baseposition(fig);
        ud = get(fig,'userdata');
    case 'q' % quit
        close(fig);
        return
    case 's' % save
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
        
end
set(fig,'userdata',ud);
showslice(fig);

