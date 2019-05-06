function [frames,fileinfo]=read_oi_compressed(fname,start,...
    max_n_images,...
    n_part,compression,show,fileinfo)
%READ_OI_COMPRESSED reads a part of a Imager3001 optical imaging file into MATLAB
%
%    [FRAMES, FILEINFO]=READ_OI_COMPRESSED(FNAME,START,...
%                                    MAX_N_IMAGES,...
%                                    N_PART,COMPRESSION,SHOW)
%
%          FMAME = filename van block file
%          START = first frame (starting at 1)
%          MAX_N_IMAGES = maximum number of images to load from START
%          N_PART  = is part number (1:compression^2)
%                    first part (top left pixel) is 1.
%                    if n_part==0, returns only fileinfo
%          SHOW = {0,1}, plot first and last frame if 1
%
% 2003-2019, Alexander Heimel
%

if nargin<7
    fileinfo = imagefile_info(fname);
end
if nargin<6
    show = 1;
end
if nargin<5
    compression = 5;
end
if nargin<4
    n_part = 1;
end
if nargin<3
    max_n_images = 10000;
end
if nargin<2
    start = 1;
end

%global frames % for debugging
frames = ones(0,0,0);

if fileinfo.n_images==-1
    return
end

n_images = min( max_n_images, fileinfo.n_total_images-start+1);

if n_part==0
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

n_rows = floor(fileinfo.ysize/compression); % lines in file
n_cols = floor(fileinfo.xsize/compression); % cols in file
n_remainder_cols = fileinfo.xsize-n_cols*compression;
n_remainder_rows = fileinfo.ysize-n_rows*compression;

frames = zeros( n_cols,n_rows,n_images);

fid = fopen(fname,'r');
if fid==-1
    error(['Failed to open ' fname]);
end

%calculate starting line and starting column
%  compression=2
% 1 | 2    line 0
% --+--
% 3 | 4    line 1
%
% col col
% 0    1

startline = floor( (n_part-1)/compression );
startcol= mod( n_part-1, compression);

% skip to starting frame
status=fseek(fid,(start-1)*fileinfo.xsize*fileinfo.ysize*fileinfo.n_bytes_per_pixel+1716,'bof');

if status==-1
    disp('Error finding starting frame');
    frames=[];
    fclose(fid);
    return;
end

% separate compresssion=1 from compression>1
% for increasing speed

if compression==1
    [frames , count] = ...
        fread(fid,fileinfo.xsize*fileinfo.ysize*n_images,...
        fileinfo.datatype,0);
    
    if count<fileinfo.xsize*fileinfo.ysize*n_images
        frames=[];
        fclose(fid);
        errormsg(['Read too few frames from ' fileinfo.name]);
        return
    end
    
    if isempty(frames)
        logmsg(['No frames to be read in ' fileinfo.name ]);
        return
    end
    
    frames=reshape( frames,fileinfo.xsize,fileinfo.ysize,n_images);
else  % compressed
    logmsg('DEPRECATED READING USING COMPRESSION');
    % skip other parts
    fseek(fid,(startline*fileinfo.xsize+startcol)*...
        fileinfo.n_bytes_per_pixel,'cof');
    
    % read file
    fprintf('Reading image: 0000');
    for i=1:n_images
        for j=1:n_rows
            [frames(:,j,i) , count] = ...
                fread(fid,floor(fileinfo.xsize/compression),...
                fileinfo.datatype,(compression-1)* ...
                fileinfo.n_bytes_per_pixel);
            if count~=floor(fileinfo.xsize/compression)
                errormsg(['File ' fname ' too short']);
                return
            end
            %skip remainder of line
            fseek(fid,n_remainder_cols*fileinfo.n_bytes_per_pixel,'cof');
            %skip couple of rows
            fseek(fid,fileinfo.xsize*(compression-1)*...
                fileinfo.n_bytes_per_pixel,'cof');
        end
        % skip remainder rows
        fseek(fid,n_remainder_rows*fileinfo.xsize*...
            fileinfo.n_bytes_per_pixel,'cof');
    end
end
fclose(fid);

if show
    plot_oi_frames(frames);
end
