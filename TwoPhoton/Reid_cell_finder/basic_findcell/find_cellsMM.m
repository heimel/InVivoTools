function [cell_list,params_,labelimg,bw3] = find_cellsMM (in,params_,show_flag,do_manual_correction)
% [cell_list,params_,labelimg,bw3] = find_cellsMM (in,params_,show_flag,do_manual_correction)
% 
% Identify cells in an image using the Reid lab algorithm.
%
% INPUT:
% -NOTE-: if called with no input args, will return [] for all output
% args except params_, which will contain the default param structure.
%
% in: input 2-D image.  Values will be converted to uint8.
%
% params_: A structure containing params for image analysis.  See below
%   for requisite fields.
%   NOTE: enter any non-structure value here to get a default set of
%   parameters.  See code or 4th output arg for what these output params are.
%
% show_flag: (0 or 1) displays images at relevant processing steps (default:0)
%
% do_manual_correction: (0 or 1) whether to run the tool for manually
%   eliminating and adding cells.
%
% Here are the requisite fields of 'params_':
% ------------------------------------------
% min_area: minimum cell area in pixels
% win_size: length in pixels of sides of square neighborhood used for
%   adaptive histogram.
%       suggestion: (cell diameter) * 3
% noise_radius: radius in pixels of image 'speckle'
%       suggestion: 1 for 128x128 or 256x256
%                   2 for 512x512
% junk_radius: radius of bright 'junk' in between cell bodies
%       suggestion: 1 if cell area is any smaller than 100 pixels
% ratio_th: percentage of cell area in 2-D image.
%       suggestion: 0.1 to 0.2 (10% - 20%)
% min_center: minimum disk area in pixels that a cell center must encompass
%       suggestion: (1/2 to 3/4) of min_area 
% con_ratio: minimum concavity ratio {smaller ratio means greater
%   concavity will be allowed in objects}
%   ratio = (radius of bridge between objects)/(radius of smallest object)
%   in general: higher ratios increase breakup 
%       suggestion: 0.5 to 1, lower values if breakup_factor is high
% breakup_factor: # of iterations of bottom hat subtraction preceding
%   breakup based on concavity
%       suggestion: 1 to 5 (greater than 10 will be ignored)
% clear_border: (0 or 1) eliminates all objects at the border of the image
% fast_breakup: (0 or 1) can decrease breakup processing time, but may be
%   slightly less effective.
%
% OUTPUT:
% cell_list: a structure list with one entry for each cell.  The elements
% of the structure are as follows:
%   -pixelinds: the indices of pixels corresponding to the cell (note that
%   these are single-value, not x/y pairs)
%   -xi: the x-axis indices of the cell outline
%   -yi: the y-axis indices of the cell outline
% 
% params_: a structure containing the parameters used for the cell
% identification algorithm.  Useful when default parameters are used, or
% to see the list of required input params.
%
% bw3:(logical) binary image of all of the cell regions
% 
% labelimg:(double) same as bw3, but regions are indexed
%
% CALLING:
% [cell_list,params_,labelimg,bw3] = find_cellsMM (in,params_,show_flag,do_manual_correction)

% 10/24/06 - Modification of find_cellsAK by Mark Mazurek, Fitzpatrick
%   lab.  Very minor modifications involving syntax.
% 9/9/04 - parameters now set by setParamsAK function
% modification of find_cellKO by SY(addition of postprocessing) by AK(addition of more morphophological analysis)
%
% NOTE: this function requires 2 java tools as well as NIH ImageJ (a
% java application) to be in the java path.  The tools are:
%   BinaryDilateNoMerge8AK.class
%   Filter_RankAK.class
% It also requires that you have java enabled in your Matlab session.

if(nargin<2 | ~isa(params_,'struct'))
  % Use default params
  params_ = struct;

  params_.min_area = 100;
  params_.win_size = 35;
  params_.noise_radius = 2;
  params_.junk_radius = 3;
  params_.ratio_th = 0.17;
  params_.min_center = 75;
  params_.con_ratio = 0.8;
  params_.breakup_factor = 3;
  params_.clear_border = 1;
  params_.fast_breakup = 1;

end

if(nargin==0)
  % User only wants the parameter list
  labelimg = [];
  bw3 = [];
  cell_list = [];
  return
end
  
if(~exist('show_flag','var'))
  show_flag = 0;
end

if(~exist('do_manual_correction'))
  do_manual_correction = 0;
end

% Convert the input image into uint8
%in = uint16(in);
in = uint8(rescale(in,[min(min(in)) max(max(in))],[0 255]));
si = size(in);
savein = in;

% Read out the input parameters
min_area = params_.min_area;
win_size = params_.win_size;
noise_radius = params_.noise_radius;
junk_radius = params_.junk_radius;
ratio_th = params_.ratio_th;
min_center = params_.min_center;
con_ratio = params_.con_ratio;
breakup_factor = params_.breakup_factor;
clear_border = params_.clear_border;
fast_breakup = params_.fast_breakup;


if show_flag>0
    figure;
    imshow(in);
    title('Input');
end

% Preform adaptive histogram equalization 
in = adapthisteqAK(in,win_size);

saveadapt = in;

if show_flag>0
    figure;
    imshow(in);
    title('Hist Equaliztion');
end

% clear small particles
clear_radius = noise_radius -1;
if clear_radius > 0;
    se = strel('disk', clear_radius);
    in = imopen(in, se);
else
    se = strel('disk', 1);
    in = imopen(in, se);
end

% fill holes in cells
se = strel('disk', (noise_radius));
in = imclose(in, se);

if show_flag>0
    figure;
    imshow(in);
    title('Noise Removed');
end

% eliminate medium size 'junk' forming bridges between cells

% REM by AK 9/21/04
%se = strel('disk',round(junk_radius));
%nhood = getnhood(se);
%idx = find(nhood == 1);
%filtwin = size(nhood);
%thresh = 80;
%in = nlfilter(in, filtwin, @adapterodeAK, idx, thresh);

%if show_flag>0
%    figure;
%    imagesc(in);
%    colormap(gray);
%    title('temp');
%end

%in = imdilate(in, se);

se = strel('disk', junk_radius);
in = imopen(in, se);

if show_flag>0
    figure;
    imagesc(in);
    colormap(gray);
    title('Junk Removed');
end

% threshold at relatively low value to capture all regions (cellular area), even if neighboring cells are connected
sorted=sort(reshape(in,si(1)*si(2),1));
th=sorted(round(si(1)*si(2)*(1-ratio_th)),1);
regionmask = (in>=th);

if show_flag>0
    figure;
    imshow(regionmask);
    title('Region Mask');
end


%strong clear border objects
if clear_border==1;
regionmask = imclearborder(regionmask,4);
    if show_flag>0
        figure;
        imshow(regionmask);
        title('Border Constraint');
    end
end

% remove objects less than the minimum cell area
% REMOVED CR 040920 regionmask = bwareaopen(regionmask, min_area);
% Reinstated AK - saves significant processing time

regionmask = bwareaopen(regionmask, min_area);

if show_flag>0
    figure;
    imshow(regionmask);
    title('Area and Border Constraints');
end

shrink = immultiply(in,regionmask);

%subtract bottom hat to enhance small dark features
disp('Preforming bottom hat subtraction...please wait');
if (breakup_factor>10)
    breakup_factor = 10;
end
r = sqrt(min_area/pi);
se = strel('disk', round(r));
for i=1:round(breakup_factor)
bh = imbothat(shrink,se);
shrink = imsubtract(shrink,bh);
end
disp('Bottom hat subtraction complete');

if show_flag>0
    figure;
    imshow(shrink);
    title('-BottomHat Gray');
end

%auto-threshold
level = graythresh(shrink);
shrinkmask = im2bw(shrink,level);

if show_flag>0
    figure;
    imshow(shrinkmask);
    title('-BottomHat Mask');
end


%remove small bright spots that probably represent small pieces of one cell
%shrinkmask = bwareaopen(shrinkmask, round(min_center/2));

% break up bright areas based on concavity and preform no merge dilation
bw3 = concave_breakMM(regionmask,shrinkmask,min_area, fast_breakup, ...
							 con_ratio, show_flag);

if show_flag>0
    figure;
    imshow(bw3);
    title('Breakup');
end

% reapply area constraint
bw3 = bwareaopen(bw3,min_area, 4);

if show_flag>0
    figure;
    imshow(bw3);
    title('Total Area Constraints');
end

% remove objects that do not contain the minimum center disk
[templabel num] = bwlabel(bw3);
r2 = sqrt(min_center/pi);
se = strel('disk',round(r2));
shrinkmask = imerode(bw3,se);

if show_flag>0
    figure;
    imshow(shrinkmask);
    title('Center Area Constraint');
end


for i=1:num
    idx = find(templabel==i);
    if (sum(shrinkmask(idx))==0)
        bw3(idx) = 0;
    end
end

%weak clear border objects
if clear_border==2;
bw3 = imclearborder(bw3,4);
    if show_flag>0
        figure;
        imshow(bw3);
        title('Border Constraint');
    end
end

%find labels
labelimg=bwlabel(bw3,4);

%open original image in ImageJ for inspection
if do_manual_correction == 1
wd = java.lang.System.getProperty('user.dir');
java.lang.System.setProperty('user.dir', 'C:\Program Files\ImageJ');
IJ = ij.ImageJ;
bw3ij = array2ijAK(savein);
bw3ij.show;
end

%select objects to be eliminated
if do_manual_correction == 1
    shadeimg = shadecellsCR(saveadapt, bw3);
    H = figure;
    imshow(shadeimg);
    title('Object Elimination');
    [Y X] = getpts(H);
    for i=1:length(X)
        val = labelimg(round(X(i)),round(Y(i)));
        if val~=0
            idx = find(labelimg==val);
            bw3(idx) = 0;
        end
    end
    close(H);
end


%select positions to add cells

if do_manual_correction == 1
    se = strel('disk',1);
    tempmask = logical(zeros(si(1),si(2)));
    r2 = sqrt(min_area/pi);
    se2 = strel('disk',round(r2));

    shadeimg = shadecellsCR(saveadapt, bw3);
    H = figure;
    imshow(shadeimg);
    title('Object Addition');
    [Y X] = getpts(H);
    for i=1:length(X)
        tempmask(:) = 0;
        dilateorg = imdilate(bw3,se);
        tempmask(round(X(i)),round(Y(i))) = 1;
        tempmask = imdilate(tempmask,se2);
        tempmask = tempmask & ~dilateorg;
        bw3 = bw3 | tempmask;
    end
    close(H);
end


if do_manual_correction == 1
%close ImageJ
bw3ij.hide;
ij.WindowManager.closeAllWindows;
IJ.quit;
java.lang.System.setProperty('user.dir', wd);
end

if show_flag>0
    figure;
    imshow(bw3);
    title('Output');
end

if show_flag>0
    shadeimg = shadecellsCR(saveadapt, bw3);
    figure;
    imshow(shadeimg);
    title('Shaded');
end

%relabel
labelimg=bwlabel(bw3,4);

% save labelimg labelimg;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MM added the following 10/25/06 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate the cell-by-cell data list

q = unique(labelimg(:));
cell_nums = q(q>0);
ncells = length(cell_nums);

pixelinds = cell(ncells,1);
xi = cell(ncells,1);
yi = cell(ncells,1);
for i_cell = 1:ncells
  pixinds = find(labelimg==i_cell);
  pixelinds{i_cell} = pixinds;
  
  % Define cell outline
  bw3_cell = zeros(size(bw3));
  bw3_cell(pixinds) = 1;

  [q] = contourc(bw3_cell,1);
  % Tried several methods of determining the cell outline but contourc
  % gave the best results
  x = q(1,:);
  y = q(2,:);
  
  bad_x = x<1;
  % contourc consistently returns a few junk indices with x~=0, not sure
  % why...just eliminate them.
  x(bad_x) = [];
  y(bad_x) = [];
  
  xi{i_cell} = x;
  yi{i_cell} = y;
  
  if(show_flag)
	 figure(gcf),hold on
	 plot(x,y,'r-','LineWidth',2)
	 ts = sprintf('%d',i_cell);
	 hts = text(mean(x)-5,mean(y),ts);
	 set(hts,'Color','w','FontSize',8,'FontWeight','bold');
  end
end

cell_list = struct('pixelinds',pixelinds,'xi',xi,'yi',yi);
