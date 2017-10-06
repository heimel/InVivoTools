function tpresample_fluoviewtiff( record)
% TPRESAMPLE_FLUOVIEWTIFF squeezes a z-stack by average two consecutive frames 
%
% 2017, Alexander Heimel
%

if nargin<1 || isempty(record)
    experiment('examples');
    host('wall-e')
    db = load_testdb('tp');
    record = db(1);
end

iminf = tpreadconfig(record);

if ~strcmp(iminf.third_axis_name,'Z')
    logmsg('Not a Z-stack');
    return
end

im = tpreadframe(record,[],[],[],[],[],3);

orgclass = class(im);

im = double(im); % to allow averaging
if mod(iminf.number_of_frames,2)==1 % i.e. odd
    % duplicate last frame
    iminf.number_of_frames = iminf.number_of_frames +1;
    iminf.NumberOfFrames = iminf.NumberOfFrames +1;
    iminf.z(end+1) = iminf.z(end)+iminf.z_step;
    iminf.frame_timestamp(end+1) = iminf.frame_timestamp(end)+iminf.frame_period;
    iminf.frame_timestamp__us(end+1) = iminf.frame_timestamp__us(end)+iminf.frame_period__us;
    im(:,:,end+1,:) = im(:,:,end,:); 
end

% average two consecutive frames
squeezed_im = im(:,:,1:2:end,:);
squeezed_im = squeezed_im + im(:,:,2:2:end,:);
squeezed_im = squeezed_im /2 ;

% recast in original class
eval(['squeezed_im = ' orgclass '(squeezed_im);']);
im = squeezed_im;

iminf.number_of_frames = iminf.number_of_frames/2;
iminf.NumberOfFrames = iminf.NumberOfFrames/2;
iminf.z = (iminf.z(1:2:end)+iminf.z(2:2:end))/2;
iminf.z_step = iminf.z_step*2; 
iminf.frame_timestamp = (iminf.frame_timestamp(1:2:end)+iminf.frame_timestamp(2:2:end))/2;
iminf.frame_timestamp__us = (iminf.frame_timestamp__us(1:2:end)+iminf.frame_timestamp__us(2:2:end))/2;

fname = tpfilename(record);
[pathstr,fname,ext] = fileparts(fname);

fname = [fname '_squeezed'];
fname = fullfile(pathstr,[fname ext]);

fluoviewtiffwrite(im,fname,iminf)
logmsg(['Wrote squeezed file ' fname]);

