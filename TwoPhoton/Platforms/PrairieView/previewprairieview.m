function im = previewprairieview(dirname, numFrames, firstFrames, channel)

%  PREVIEWPRAIRIEVIEW - Preview PrairieView image data
%
%    IM = PREVIEWPRAIRIEVIEW(DIRNAME, NUMFRAMES, FIRSTFRAMES,CHANNEL)
%
%  Read a few frames to create a preview image.  DIRNAME is the
%  directory name to be opened, and NUMFRAMES is the number of
%  frames to read.  If FIRSTFRAMES is 1, then the first NUMFRAMES
%  frames will be read; otherwise, the frames will be taken
%  randomly from those available.
% 
%  CHANNEL is the channel to be read.  If it is empty, then
%  all channels will be read and third dimension of im will
%  correspond to channel.  For example, im(:,:,1) would be
%  preview image from channel 1.
%
%  DIRNAME will have '-001' appended to it.
%

tpdirname = [dirname '-001'];

if ~exist(tpdirname),
	error(['Directory ' tpdirname ' does not exist.']);
end;

fname=dir([tpdirname filesep '*Cycle001_Ch' int2str(channel) '_000001.tif']);
if isempty(fname), error(['Could not create preview image: ' tpdirname filesep '*Cycle001_Ch' int2str(channel) '_000001.tif does not exist.']); end;
fname=fname(end).name;
fnameprefix = fname(1:strfind(fname,'Cycle')-1);

pcfile = dir([tpdirname filesep '*_Main.pcf']);
if isempty(pcfile), pcfile = dir([tpdirname filesep '*.xml']); end;
pcfile = pcfile(end).name;
params = readprairieconfig([tpdirname filesep pcfile]);

ffile = repmat([0 0],length(params.Image_TimeStamp__us_),1);

initind = 1;
for i=1:params.Main.Total_cycles,
  frames=getfield(getfield(params,['Cycle_' int2str(i)]),'Number_of_images');
  ffile(initind:initind+frames-1,:) = [repmat(i,frames,1) (1:frames)'];
  initind = initind + frames;
end;

if firstFrames,
	n = 1:numFrames;
else,
	N = randperm(length(params.Image_TimeStamp__us_));
	n = N(1:numFrames);
end;

im = [];

for i=1:numFrames,
	im = cat(1,im,reshape(imread(...
		[tpdirname filesep fnameprefix 'Cycle' sprintf('%.3d',ffile(n(i),1)) ...
		'_Ch' int2str(channel) '_' sprintf('%.6d',ffile(n(i),2)) '.tif']),...
		1,params.Main.Lines_per_frame*params.Main.Pixels_per_line));
end;

if size(im,1)>1, im = mean(double(im)); else, im = double(im); end;
im = reshape(im,params.Main.Lines_per_frame,params.Main.Pixels_per_line);
