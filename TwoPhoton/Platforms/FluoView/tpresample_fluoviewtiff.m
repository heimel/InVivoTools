function tpresample_fluoviewtiff( fname)
% TPRESAMPLE_FLUOVIEWTIFF squeezes a z-stack by average two consecutive frames
%
% 2017, Alexander Heimel
%

if nargin<1 
    experiment('examples');
    host('wall-e')
    db = load_testdb('tp');
    record = db(2);
    fname = tpfilename(record);
end

iminf = tiffinfo(fname );

if ~strcmp(iminf.third_axis_name,'Z')
    logmsg('Not a Z-stack');
    return
end

im = zeros(iminf.Height,iminf.Width,iminf.NumberOfFrames,iminf.NumberOfChannels,'uint16');

for ch = 1:iminf.NumberOfChannels
    for fr = 1:iminf.NumberOfFrames
        im(:,:,fr,ch)=imread(fname,(ch-1)*iminf.NumberOfFrames+fr);
    end
end


orgclass = class(im);

im = double(im); % to allow averaging
if mod(iminf.NumberOfFrames,2)==1 % i.e. odd
    % duplicate last frame
    iminf.NumberOfFrames = iminf.NumberOfFrames +1;
    iminf.z(end+1) = iminf.z(end)+iminf.z_step;
    im(:,:,end+1,:) = im(:,:,end,:);
end

% average two consecutive frames
squeezed_im = im(:,:,1:2:end,:);
squeezed_im = squeezed_im + im(:,:,2:2:end,:);
squeezed_im = squeezed_im /2 ;

% recast in original class
eval(['squeezed_im = ' orgclass '(squeezed_im);']);
im = squeezed_im;

iminf.NumberOfFrames = iminf.NumberOfFrames/2;
iminf.z = (iminf.z(1:2:end)+iminf.z(2:2:end))/2;
iminf.z_step = iminf.z_step*2;

[pathstr,fname,ext] = fileparts(fname);

fname = [fname '_squeezed'];
fname = fullfile(pathstr,[fname ext]);

fluoviewtiffwrite(im,fname,iminf)
logmsg(['Wrote squeezed file ' fname]);

