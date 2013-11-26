function [labelimg, mask, adapt] = fix_cellsAK (original, mask, s, varargin)
% Manually remove and add objects to a cell mask
% 
% original: (variable datatype 2D array) intensity image
% mask: (logical 2D array) region mask to be fixed
% s: file list structure
% nf: number of image in list  (optional if s is a single struct, not an array).
%
% output
% mask: (logical 2D array) fixed cell mask
% labelimg: (double 2D label matrix) labeled cell mask
%
% Aaron Kerlin (kerlin@fas.harvard.edu) 9/23/04
if length(varargin) == 0
   if length(s) > 1
       error('parameter nf not sent to setparamsAK and s is NOT a single structure but an array (ask Clay or Aaron)');
   end
   nf = 1;
end
if length(varargin) > 0
    nf = cell2mat(varargin(1));
end
if length(varargin) > 1
    adapt = cell2mat(varargin(2));
end

original = double(original);
original=uint8(255*original/(max(original(:))));
si = size(original);

% get settings from setParamsAK
[min_area win_size noise_radius junk_radius ratio_th min_center con_ratio breakup_factor clear_border fast_breakup do_manual show_flag] = setParamsAK(s,nf);   

% get equalized image if not already passed to function
if ~(exist('adapt','var'))
adapt = adapthisteqAK(original,win_size);
end

% Open original image in ImageJ for inspection
% set the Java user directory to the ImageJ root so that ImageJ can load standard plugins and macros
disp('Initializing ImageJ for inspection of original image'); 
wd = java.lang.System.getProperty('user.dir');
java.lang.System.setProperty('user.dir', 'C:\Program Files\ImageJ');
% create an instance of ImageJ 
IJ = ij.ImageJ;
% convert the original image array to ImagePlus object and display it  
originalij = array2ijAK(original);
originalij.show;
    
% Select objects to eliminate
% show the current mask in Matlab    
BW = figure;
imshow(mask);
title('Current Mask');
% display equalized image with cell regions shaded for selection
shadeimg = shadecellsCR(adapt, mask);
H = figure;
imshow(shadeimg);
title('Elimination - Shaded');
disp('Select objects to eliminate by right-clicking ''Elimination - Shaded'' then press Enter');
[Y X] = getpts(H);
% delete regions that were selected
[labelimg num] = bwlabel(mask,4);
for i=1:length(X)
    val = labelimg(round(X(i)),round(Y(i)));
    if val~=0
        idx = find(labelimg==val);
        mask(idx) = 0;
    end
end
close(H);
close(BW);
disp('Elimination complete');

% Select positions to add cells
% show the current mask in Matlab    
BW = figure;
imshow(mask);
title('Current Mask');
% calculate disk radius based on min cell center
r2 = floor(sqrt(min_area/pi))+1;
% request new radius from user
defans = {num2str(r2)};
answer = inputdlg('Radius of disks (in pixels) to add. Default radius is derived from minimum cell center.' ,'Set disk size',1,defans);
r2 = str2num(cell2mat(answer));
if r2<1
    r2 = 1;
end
se2 = strel('disk',floor(r2));
% show shaded image and get new cell coordinates
shadeimg = shadecellsCR(adapt, mask);
H = figure;
imshow(shadeimg);
title('Addition - Shaded');
disp('Select positions to add disks by right-clicking ''Addition - Shaded'' then press Enter');
[Y X] = getpts(H);
    
% Add disks to mask. Ensure new and old objects don't merge by subtrating a 1 pixel 'buffer region' around old objects.  
se = strel('disk',1);
tempmask = logical(zeros(si(1),si(2)));
for i=1:length(X)
    tempmask(:) = 0;
    dilateorg = imdilate(mask,se);
    tempmask(round(X(i)),round(Y(i))) = 1;
    tempmask = imdilate(tempmask,se2);
    tempmask = tempmask & ~dilateorg;
    mask = mask | tempmask;
end
close(H);
close(BW);
disp('Addition complete');

% Close ImageJ
originalij.hide;
ij.WindowManager.closeAllWindows;
IJ.quit;
% reset java user directory to original value
java.lang.System.setProperty('user.dir', wd);

% relabel
labelimg=bwlabel(mask,4);
