function [filtx,filtstd,filtstderr,newimage] = prairieviewoptfilter(slowdir, fastdir, channel)

% PRAIRIEVIEWOPTFILTER - Creates an optimal filter for prairieview files
%
%  [FILT,FILTSTD,FILTSTDERR]=PRAIRIEVIEWOPTFILTER(SLOWDIR,FASTDIR,CHANNEL)
%
%  Creates an optimal linear filter for data acquired quickly in
%  PrairieView.  The Prairie two-photon scope has a PMT preamplifier
%  that rings, and this ringing is evident for fast recordings.
%  This function calculates a filter that can help remove the ringing.
%
%  CHANNEL is the channel number to examine.
%  
%
%  Assumes number of frames is not large (memory hungry).

if ~exist([slowdir '-001' filesep 'driftcorrect'])
	disp(['Checking drift in slowly acquired directory.']);
	[drs,ts] = prairieviewdriftcheck(slowdir,[-10:10],[-10:10],slowdir,0,0,3,2,1,1);
end;
if ~exist([fastdir '-001' filesep 'driftcorrect'])
	disp(['Checking drift in fast directory.']);
	[drf,tf] = prairieviewdriftcheck(fastdir,[-10:10],[-10:10],slowdir,[-10:10],[-10:10],5,5,1,1);
end;

im = tppreview(slowdir,2,1,channel);
im_outline = zeros(size(im)); im_outline(10:end-10,10:end-10) = 1;
pixelinds = {find(im_outline==1)};
data = tpreaddata(slowdir,[-Inf Inf],pixelinds,21,channel);
im_base = im(10:end-10,10:end-10);
im_base=reshape(data{1,1},size(im_base,1),size(im_base,1),length(data{1,1})/(size(im_base,1)*size(im_base,2)));

F_base = fft(im_base,[],2);

pcfile = dir([fastdir '-001' filesep '*_Main.pcf']);
if isempty(pcfile), pcfile = dir([fastdir '-001' filesep '*.xml']); end;
pcfile = pcfile(end).name;
params = readprairieconfig([fastdir '-001' filesep pcfile]);

frameTimes = 1e-6*params.Image_TimeStamp__us_;
nFrames = 0;
nLines = 0;
ffsum = zeros(1,size(im_base,1));
ffsumsq = zeros(1,size(im_base,1));

i=1;
while i<length(frameTimes),
	start = i,
	stop = min([i+25 length(frameTimes)]);
	data = tpreaddata(fastdir,frameTimes([start stop]),pixelinds,21,channel);
	myframes=reshape(data{1,1},size(im_base,1),size(im_base,1),length(data{1,1})/(size(im_base,1)*size(im_base,2)));
	for k=1:size(myframes,3),
		F = fft(myframes(150:400,:,k),[],2);
		f = (ifft(F_base(150:400,:)./F,[],2));
		ffsum = ffsum + sum(f);
		ffsumsq = ffsumsq + sum(f.*f);
		nLines = nLines + size(f,2);
	end;
	nFrames = nFrames+stop-start+1;
	i = stop+1;
end;

filtx = fftshift((ffsum/(nLines)));
filtstd = fftshift(sqrt(abs(ffsumsq/nLines - ffsum.*ffsum/(nLines*nLines))));
filtstderr = filtstd / sqrt(nLines);

figure;
plot(abs(filtx),'bo'); hold on;
plot(filtx,'b');
plot(filtx-2*filtstderr,'k');
plot(filtx+2*filtstderr,'k');
imagedisplay(im_base);
imagedisplay(myframes);

FI = fft(fftshift(filtx));
newimage = ifft(fft(myframes,[],2).*repmat(FI,size(myframes,1),1),[],2);
imagedisplay(abs(newimage));
