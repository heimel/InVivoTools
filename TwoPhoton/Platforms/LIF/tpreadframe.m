function [im,fname]=tpreadframe(record,channel,frame,opt)
%TPREADFRAME read frame from liff (Leica Image Format File)
%
%  [IM, FNAME] = TPREADFRAME( RECORD, CHANNEL, FRAME )
%
%
% 2011, Alexander Heimel
%

if length(channel)>1
    warning('TPREADFRAME:MULTIPLE_CHANNELS','TPREADFRAME:TPREADFRAME WILL IN FUTURE ONLY ACCEPT SINGLE CHANNEL');
end
    
    
if nargin<4
    opt = [];
end

persistent readfname images


fname = tpfilename( record, frame, channel, opt);


% check if matlabstored file is present
if strcmp(readfname,fname)==0 % not read in yet
    disp('TPREADFRAME: first time loading this stack. reading all frames');
    org_fname = tpfilename( record, frame, channel); % no options
    iminf = tpreadconfig(record);
    
    if iminf.BitsPerSample~=16
        warning('TPREADFRAME:not_16bits','TPREADFRAME: Bits per samples is unequal to 16');
    end
    images = zeros(iminf.Height,iminf.Width,iminf.NumberOfFrames,iminf.NumberOfChannels,'uint16');
    if exist(fname,'file') && strcmp(fname(end-2:end),'tif')
        % i.e. (processed) image file already exists
        for ch = 1:iminf.NumberOfChannels
            for fr = 1:iminf.NumberOfFrames
                
                % a programming error makes imread slow in matlab version before 2009b
                images(:,:,fr,ch)=imread(fname,(ch-1)*iminf.NumberOfFrames+fr);
                % tiffread2(fname,fr) is an alternative but it doesn't work on the
                % compressed tiffs of Friederike
            end
        end
    else % i.e. no right processed file exist
        %images(:,:,fr,ch)
        
        data = bfopen(org_fname); % only use first=last? session
        for ch = 1:iminf.NumberOfChannels
            for fr = 1:iminf.NumberOfFrames
                
                images(:,:,fr,ch) = data{1,1}{ (fr-1)*iminf.NumberOfChannels + ch,1};
            end
        end
        
        % now do image processing
        images = tp_image_processing( images, opt );
        % save processed file for later use
        disp(['TPREADFRAME: writing processed image stack as ' fname]);
        writepath = fileparts(fname);
        if ~exist(writepath,'dir')
            mkdir(writepath);
        end
        fluoviewtiffwrite(images,fname,iminf)
    end
    disp('TPREADFRAME: finished reading')
    readfname=fname; % when completely loaded set readfname
else
    % disp(['reading frame ' num2str(frame)]);
end

% return selected images
im=images(:,:,frame,channel);
%im = zeros([size(images,1) size(images,2) length(frame) size(images,4)],class(images));
%im(:,:,:,channel)=images(:,:,frame,channel);

mlock
return


