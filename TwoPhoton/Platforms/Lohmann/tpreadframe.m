function [im,fname]=tpreadframe(record,channel,frame,opt)
%TPREADFRAME
%  read frame from multitiff
%
% 2008, Alexander Heimel
%

% opt are ignored here

%disp(['reading frame: ' num2str(frame)]);
fname = tpfilename( record, frame, channel);
im = imread(fname,frame);

return


 
persistent readfname images

fname = tpfilename( record, frame, channel);

% check if matlabstored file is present
if strcmp(readfname,fname)==0 % not read in yet
  readfname=fname;
  disp('first time. reading all frames');
  iminf = tiffinfo(fname,1, tpscratchfilename(record,[],'tiffinfo') );
  disp('read tiffinfo');
  if iminf.BitsPerSample~=16
      warning('TPREADFRAME: Bits per samples is unequal to 16');
  end
  images=zeros(iminf.Height,iminf.Width,iminf.NumberOfFrames,'uint16');
  whos images
  for fr=1:iminf.NumberOfFrames
    % a programming error makes imread slow in matlab version before 2009b
    images(:,:,fr)=imread(fname,fr);
   % tiffread2(fname,fr) is an alternative but it doesn't work on the
   % compressed tiffs of Friederike
  end
  disp('done reading')
else
  disp(['reading frame ' num2str(frame)]);
end

im=images(:,:,frame);



