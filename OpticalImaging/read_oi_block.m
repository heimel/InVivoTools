function [frames, compression, fileinfo]=read_oi_block(fname,n_block,...
    max_n_images,compression,show)
%READ_OI_BLOCK reads a block of a Imager3001 optical imaging file into MATLAB
%
%  [FRAMES, COMPRESSION, FILEINFO]=
%        READ_OI_BLOCK(FNAME)
%
%  [FRAMES, COMPRESSION, FILEINFO]=
%        READ_OI_BLOCK(FNAME,N_BLOCK,MAX_N_IMAGES,COMPRESSION,SHOW)
%
%    COMPRESSION is the number of pixels to skip on each horizontal line
%    and will be decreased until a number is found that divides the size
%    of a line. The final COMPRESSION factor is returned. The whole file
%    consists of as many blocks as COMPRESSION, with block 1 starting at
%    the first pixel of each line. This construction is used but in case
%    memory is limited and to get a quick first impression of the data.
%
%    N_BLOCK is the number of the block to read, if N_BLOCK=0 
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
%
% Alexander Heimel (heimel@brandeis.edu) April 2003 
%


if nargin<5
  show=1
end
if nargin<4
  compression=20;
end
if nargin<3
  max_n_images=1000;
end
if nargin<2
  n_block=1;
end

global frames % for debugging
frames=ones(0,0,0);

fileinfo=imagefile_info(fname);
if fileinfo.n_images==-1
  return
end

% pick compression factor that divides the pixel in one line
while mod(fileinfo.xsize,compression)
  compression=compression-1;
end
compression=round(compression); % temporary

n_images=min( max_n_images, fileinfo.n_images);

if n_block==0 
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
    


disp('Reading file...');
[fid,message] = fopen(fname,'r');

%skip header
[header, count] = fread(fid,1716,'char');
  
% skip other blocks 
status = fseek(fid,(n_block-1)*fileinfo.n_bytes_per_pixel,'cof');

% read file
[frames, count] = ...
    fread(fid,fileinfo.xsize*fileinfo.ysize*n_images/compression,...
	  fileinfo.datatype,(compression-1)*fileinfo.n_bytes_per_pixel);
disp([num2str(count) ' read'])
fclose(fid);

disp('Reshaping file');    
frames=reshape(frames,fileinfo.xsize/compression,fileinfo.ysize,n_images);
frames=frames(2:end-1,:,:); % to kill empty pixel on left and right of image

if show
  plot_oi_frames(frames);
end
