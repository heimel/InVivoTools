function im = tppreview(record, selFrames, firstFrames, channel,opt, mode, verbose)
%  TPPREVIEW - Preview twophoton image data
%
%    IM = TPPREVIEW(RECORD, SELFRAMES, FIRSTFRAMES,CHANNEL, OPT, MODE, VERBOSE)
%
%  Read a few frames to create a preview image.  DIRNAME is the
%  directory name to be opened, and NUMFRAMES is the number of
%  frames to read.  If FIRSTFRAMES is 1, then the first SELFRAMES
%  frames will be read; If FIRSTFRAMES is 0, the frames will be taken
%  randomly from those available.
%
%  CHANNEL is the channel to be read.  If it is empty, then
%  all channels will be read and third dimension of im will
%  correspond to channel.  For example, im(:,:,1) would be
%  preview image from channel 1.
%
%  If MODE is 1 (default) than frames are averaged. If MODE is 2 then a
%  maximum projection is used. For MODE is 3 an maximum projection across
%  the X-axis is taken, for MODE 4 the same through the Y-axis
%
%  2008, Steve Van Hooser, 2010-2015 adapted by Alexander Heimel
%

if nargin<7; verbose = []; end
if nargin<6; mode = []; end
if nargin<5; opt = []; end
if nargin<4; channel = []; end
if nargin<3; firstFrames = []; end
if nargin<2; selFrames = [];end

if isempty(verbose)
    verbose = true;
end
if isempty(firstFrames)
    firstFrames = 1;
end
if isempty(selFrames)
    selFrames = 100;
end

fname=tpfilename(record);
if ~exist(fname,'file')
    errormsg(['File ' fname ' does not exist.']);
    im = [];
    return
end

inf=tpreadconfig(record);

if isfield(inf,'third_axis_name') && ~isempty(inf.third_axis_name) && lower(inf.third_axis_name(1))=='z'
    zstack = true;
else
    zstack = false;
end

if isempty(mode)
    switch record.experiment
        case '12.98'  % Rogier
            mode = 2; % maximum projection
        otherwise
            if zstack
                mode = 2; % maximum projection
            else
                mode = 1; % average
            end
    end
end

if isempty(channel)
    channel = 1:inf.NumberOfChannels;
end

total_nFrames=inf.NumberOfFrames;
numFrames = round(min(max(selFrames), total_nFrames));
if length(selFrames) == 2
    first = round(max(min(selFrames),1));
else
    first = 1;
end

switch firstFrames,
    case 0
        N = randperm(total_nFrames);
        frame_selection = sort(N(1:numFrames));
    case 1
        frame_selection = first:numFrames;
end;

warning('ON','TPREADFRAME:MEM');

switch mode
    case 1 % average through Z/T axis
        im = zeros( inf.Height,inf.Width,inf.NumberOfChannels);
        if verbose
            hwait = waitbar(0,'Loading preview');
        end
        for c=channel
            im(:,:,c) = double( tpreadframe(record,c,frame_selection(1),opt,verbose) );
            for f=frame_selection(2:end)
                im(:,:,c) = im(:,:,c) + double(tpreadframe(record,c,f,opt,verbose));
                if verbose
                    waitbar(((c-1)*length(frame_selection)+f)/length(channel)/length(frame_selection));
                end
            end;
        end
        if verbose
            close(hwait);
        end
        im=im/length(frame_selection);
    case 2 % maximum projection through Z/T axis
        im = zeros( inf.Height,inf.Width,inf.NumberOfChannels);
        if verbose
            hwait = waitbar(0,'Loading preview');
        end
        for c=channel
            im(:,:,c) = double( tpreadframe(record,c,frame_selection(1),opt,verbose) );
            for f=frame_selection(2:end)
                im(:,:,c) = max(im(:,:,c), double(tpreadframe(record,c,f,opt,verbose)));
                if verbose
                    waitbar(((c-1)*length(frame_selection)+f)/length(channel)/length(frame_selection));
                end
            end;
        end
        if verbose
            close(hwait);
        end
    case {3,4} % maximum projection through X or Y axis, respectively
        % takes memory
        im4d = zeros( inf.Height,inf.Width,total_nFrames,inf.NumberOfChannels);
        for c=channel
            for f = 1:total_nFrames
                im4d(:,:,f,c) = double( tpreadframe(record,c,f,opt,verbose) );
            end
        end
        im(:,:,c) = max(im4d(:,:,:,c),[],mode-2);
end

