function [labelimg, bw3] = find_cellsAK (in, s, nf)
% find cells from image
% 
% 9/9/04 - parameters now set by setParamsAK function
%
% in: input 2-D image
% min_area: minimum cell area in pixels
% win_size: length in pixels of sides of square neighborhood used for adaptive histogram.
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
% con_ratio: minimum concavity ratio {smaller ratio means greater concavity will be allowed in objects}
%       ratio = (radius of bridge between objects)/(radius of smallest object)
%       in general: higher ratios increase breakup 
%       suggestion: 0.5 to 1, lower values if breakup_factor is high
% breakup_factor: # of iterations of bottom hat subtraction preceding breakup based on concavity
%       suggestion: 1 to 5 (greater than 10 will be ignored)
% fast_breakup: (0 or 1) can decrease breakup processing time, but may be slightly less effective.
% clear_border: (0 or 1) eliminates all objects at the border of the image
% show_flag: (0 or 1) displays images at relevant processing steps 
%
% bw3:(logical) binary image of all of the cell regions
% labelimg:(double) same as bw3, but regions are indexed
%
% calling:
% [labelimg, bw3] = find_cellsAK (image, 400, 61, 2, 5, 0.15, 200, 0.8, 3, 1, 1)
%
% modification of find_cellKO by SY(addition of postprocessing) by AK(addition of more morphophological analysis)
%

[min_area win_size noise_radius junk_radius ratio_th min_center con_ratio breakup_factor clear_border fast_breakup do_manual show_flag] = setParamsAK(s,nf);

in = uint8(in);
si = size(in);
savein = in;

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
bw3 = concave_breakAK(regionmask,shrinkmask,min_area, fast_breakup, con_ratio);

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
if do_manual == 1
wd = java.lang.System.getProperty('user.dir');
java.lang.System.setProperty('user.dir', 'C:\Program Files\ImageJ');
IJ = ij.ImageJ;
bw3ij = array2ijAK(savein);
bw3ij.show;
end

%select objects to be eliminated
if do_manual == 1
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

if do_manual == 1
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


if do_manual == 1
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
