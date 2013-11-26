function imag = read_oi_image(fname,theimage)

% READ_OI_IMAGE - Read one image from an Imager3001 optical imaging file
%
%   IMAGEDATA = READ_OI_IMAGE(FILENAME, THEIMAGE)
%
%  Reads one image of data from an Imager3001 optical imaging file.
%  IMAGEDATA is XxYxnframes, where X is the width, Y is the height,
%  and nframes is the number of frames.  FILENAME is the filename of the
%  file to read from, and THEIMAGE is the image number to read from.
%
%  See also: IMAGEFILE_INFO

[info,header]=imagefile_info(fname);

bgin=info.headersize+info.n_bytes_per_pixel*info.xsize*info.ysize*(theimage-1);

f = fopen(fname);
if f<0,error(['Could not open file ' fname '.']); end;

imag = zeros(info.xsize,info.ysize,info.cameraframes_per_frame);
for i=1:(info.cameraframes_per_frame/2)
	imag(:,:,i)=reshape(fread(f,info.xsize*info.ysize,'int32'),info.xsize,info.ysize);
end;

fclose(f);
