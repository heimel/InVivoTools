function [im,iminf] = tpresample_fluoviewtiff( fname,method,writeresult)
% TPRESAMPLE_FLUOVIEWTIFF squeezes a z-stack by average two consecutive frames
%
%  TPRESAMPLE_FLUOVIEWTIFF( FNAME, METHOD, WRITERESULT=true )
%             
%     METHOD = 
%         'average', averages frames 1 and 2 to 1.5, 2 and 3 to 2.5, etc
%         'squeeze', averages frames 1 and 2 to 1.5, 3 and 4 to 3.5, etc
%         'copy', does nothing just rewrite a new tiff
%     WRITERESULT, if true writes new tiff file.
%
% 2017, Alexander Heimel
%

if nargin<2 || isempty(method)
    method = 'average';
end

if nargin<3 || isempty(writeresult)
    writeresult = true;
end

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

logmsg(['Original size ' num2str(size(im))]);

for ch = 1:iminf.NumberOfChannels
    for fr = 1:iminf.NumberOfFrames
        im(:,:,fr,ch)=imread(fname,(ch-1)*iminf.NumberOfFrames+fr);
    end
end

orgclass = class(im);

im = double(im); % to allow averaging

switch method
    case 'squeeze'
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
        im = squeezed_im;
        
        iminf.NumberOfFrames = iminf.NumberOfFrames/2;
        iminf.z = (iminf.z(1:2:end)+iminf.z(2:2:end))/2;
        iminf.z_step = iminf.z_step*2;
        
    case 'average'
        im = (im(:,:,1:end-1,:) + im(:,:,2:end,:))/2;
        iminf.NumberOfFrames = iminf.NumberOfFrames-1;
        iminf.z = (iminf.z(1:end-1)+iminf.z(2:end))/2;
        
    case 'copy'
        % do nothing, just test and rewrite tiff-file
end

% recast in original class
eval(['im = ' orgclass '(im);']);

[pathstr,fname,ext] = fileparts(fname);

fname = [fname '_'  method 'd'];
fname = fullfile(pathstr,[fname ext]);

if writeresult
    fluoviewtiffwrite(im,fname,iminf)
    logmsg(['Wrote ' method 'd file ' fname]);
end

logmsg(['Final size ' num2str(size(im))]);
