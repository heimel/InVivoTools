function [im,fname] = tpreadframe(record,channel,frame,opt,verbose)
%DEZEEUW/TPREADFRAME read frame from multitiff
%
%  [IM, FNAME] = TPREADFRAME( RECORD, CHANNEL, FRAME, OPT )
%
% 2012, Alexander Heimel
%

if length(channel)>1
    error('TPREADFRAME:MULTIPLE_CHANNELS','TPREADFRAME:TPREADFRAME ONLY ACCEPT SINGLE CHANNEL');
end

if nargin<4
    opt = [];
end

persistent readfname images

fname = tpfilename( record, frame, channel, opt);



% check if matlabstored file is present
if strcmp(readfname,tpfilename( record, 1, 1, opt) )==0 % not read in yet
    disp('TPREADFRAME: first time loading this stack. reading all frames');
    iminf = tpreadconfig(record);
    
    if iminf.BitsPerSample~=16
        warning('TPREADFRAME:not_16bits','TPREADFRAME: Bits per samples is unequal to 16');
    end
    images = zeros(iminf.Height,iminf.Width,iminf.NumberOfFrames,iminf.NumberOfChannels,'uint16');
    if exist(fname,'file')
        % i.e. (processed) image file already exists
        for ch = 1:iminf.NumberOfChannels
            for fr = 1:iminf.NumberOfFrames
                fname = tpfilename( record, fr, ch, opt);
                images(:,:,fr,ch)=imread(fname);
            end
        end
    else % i.e. no right processed file exist
        for ch = 1:iminf.NumberOfChannels
            for fr = 1:iminf.NumberOfFrames
                fname = tpfilename( record, fr, ch, []); % no options
                images(:,:,fr,ch)=imread(fname);
            end
        end
        % now do image processing
        images = tp_image_processing( images, opt );
        % save processed file for later use
        disp(['TPREADFRAME: writing processed image stack is not implemented yet for DeZeeuw setup']);
        %         disp(['TPREADFRAME: writing processed image stack as ' fname]);
        %         writepath = fileparts(fname);
        %         if ~exist(writepath,'dir')
        %             mkdir(writepath);
        %         end
        %         fluoviewtiffwrite(images,fname,iminf)
    end
    disp('TPREADFRAME: finished reading')
    readfname = tpfilename( record, 1, 1, opt); % when completely loaded set readfname
else
    % disp(['reading frame ' num2str(frame)]);
end

% return selected images
im=images(:,:,frame,channel);


