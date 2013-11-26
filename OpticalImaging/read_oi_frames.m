function [frames, compression, fileinfo]=read_oi_frames(fname,start,...
    max_n_images,compression,show)
%READ_OI_FRAMES reads consequtive frames of a Imager3001 file (DEPRECATED)
%
%
%  DEPRECATED use READ_OI_COMPRESSED instead
%
%
%  [FRAMES, COMPRESSION, FILEINFO]=
%        READ_OI_FRAMES(FNAME)
%
%  [FRAMES, COMPRESSION, FILEINFO]=
%        READ_OI_BLOCK(FNAME,START,MAX_N_FRAMES,COMPRESSION,SHOW)
%
%    COMPRESSION is the number of pixels to skip on each horizontal line
%    and will be decreased until a number is found that divides the size
%    of a line. The final COMPRESSION factor is returned. The whole file
%    consists of as many blocks as COMPRESSION, with block 1 starting at
%    the first pixel of each line. This construction is used but in case
%    memory is limited and to get a quick first impression of the data.
%
%    START is the number of the frame to start on (from 1).  If START is 0,
%    then nothing is read, but COMPRESSION and FILEINFO are computed
%    and returned.
%
%    MAX_N_IMAGES is maximum number of frames to read. Default is 1000.
%   
%    if SHOW is 1, the function PLOT_OI_FRAMES is called, showing the first
%    and last read frame and their difference. By default SHOW=0.
%
%    FRAMES( FILEINFO.XSIZE, FILEINFO.YSIZE, number of frames) will 
%    contain the data if succesful.  
%
%    FILEINFO contains a struct with information about the imaging file 
%    as returned by the function IMAGEFILE_INFO. (see HELP IMAGEFILE_INFO)
%
%    if file FNAME could not be opened, FILEINFO.N_IMAGES=-1
%
%   Note: compression feature not tested for this file.
%   See also: READ_OI_BLOCK
%
% Alexander Heimel and Steve Van Hooser, 2003 
%
%

%disp(['Start frame: ' num2str(start)]);

if nargin<5
  show=1
end
if nargin<4
  compression=[];
end
if nargin<3
  max_n_images=1000;
end
if nargin<2
  start=1;
end

global frames % for debugging
frames=ones(0,0,0);

fileinfo=imagefile_info(fname);
if fileinfo.n_images==-1
  return
end


if isempty(compression)
  compression=1;
end

% pick compression factor that divides the pixel in one line
while mod(fileinfo.xsize,compression)
  compression=compression-1;
end
compression=round(compression); % temporary

n_images=min( max_n_images, fileinfo.n_images);

if start==0 
  disp(['Name:      ' fileinfo.name]);
  disp(['Date:      ' fileinfo.date]);
  disp(['Cameraframes per frame: ' num2str(fileinfo.cameraframes_per_frame) ]);
  disp(['Xsize: ' num2str(fileinfo.xsize,3) ]);
  disp(['Ysize: ' num2str(fileinfo.ysize,3) ]);
  disp(['Compression: ' num2str(compression,2) ]);
  disp(['Number of images in file: ' num2str(fileinfo.n_images) ]); 
  disp([' suggested maximum number of frames: ' num2str( max_n_images)]);
  disp([' loading ' num2str(n_images) ' frames']);
  
  return; % don't do anything, just report
end
    


%disp('Reading file...');
[fid,message] = fopen(fname,'r');

%skip header
[header, count] = fread(fid,1716,'char');

% skip to starting frame
status=fseek(fid,(start-1)*fileinfo.xsize*fileinfo.ysize*fileinfo.n_bytes_per_pixel,'cof');





% read file
[frames, count] = ...
    fread(fid,fileinfo.xsize*fileinfo.ysize*n_images/compression,...
	  fileinfo.datatype,(compression-1)*fileinfo.n_bytes_per_pixel);
%disp([num2str(count) ' read'])
fclose(fid);

%disp('Reshaping file');    
frames=reshape(frames,fileinfo.xsize/compression,fileinfo.ysize,n_images);

if show
  plot_oi_frames(frames);
end
