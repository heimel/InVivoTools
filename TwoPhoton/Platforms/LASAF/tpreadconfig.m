function params=tpreadconfig( tpdirname )
%TPREADCONFIG read twophoton experiment config file
%
%
% PARAMS. = 
%  params.Main.Total_cycles  (total number of cycles)
%  params.Main.Scanline_period__us_  (scanline period, in us)
%  params.Main.Dwell_time__us_  (pixel dwell time, in us)
%  params.Main.Frame_period__us_  (frame period, in us)
%  params.Main.Lines_per_frame (lines per frame)
%  params.Main.Pixels_per_line  (number of pixels per line)
%  params.Image_TimeStamp__us_  (list of all frame timestamps)
%  params.Cycle_N.Number_of_images (num. of images in Cycle N)
%
%   params.Image_TimeStamp__s_   = params.Image_TimeStamp__us_ * 1E-6
%
% LAS AF version
%
% 2009, Stephen Van Hooser
%


fnames = dir([tpdirname filesep '*.xml']);

if ~isempty(fnames),
	fname = fnames(end).name;
else,
	error(['no parameter files found in directory ' tpdirname '.']);
end;

fname=fullfile(tpdirname,fname);

fid = fopen(fname,'rt');
if fid<0, error(['Could not open file ' tpdirname filesep fname '.']); end;

filestr = char(fread(fid,Inf,'char'))';
fclose(fid);

stc = xml2struct(filestr);

%dims = [stc.Data{1}.Image{1}.ImageDescription{1}.Dimensions{1}.DimensionDescription{:}];
%
%[dummy,inds] = sort([dims.BytesInc]);
%dims = dims(inds);

ScanSettings = [stc.Data{1}.Image{1}.Attachment{2}.HardwareSetting{1}.ScannerSetting{1}.ScannerSettingRecord{:}];

[dummy,ind] = intersect({ScanSettings.Identifier},'nFormatInDimension');
params.Main.Pixels_per_line = ScanSettings(ind).Variant;
[dummy,ind] = intersect({ScanSettings.Identifier},'nFormatOutDimension');
params.Main.Lines_per_frame = ScanSettings(ind).Variant;
[dummy,ind] = intersect({ScanSettings.Identifier},'nFormatInDimension');
params.Main.Total_cycles = 1;
[dummy,ind] = intersect({ScanSettings.Identifier},'nRepeatActions');
params.Cycle_1.Number_of_images=ScanSettings(ind).Variant;


ts=[stc.Data{1}.Image{1}.Attachment{5}.RootNode{1}.RelativeTime{1}.RelTimeStamp{:}];
params.Image_TimeStamp__s_    = [ts.Time];
params.Image_TimeStamp__us_   = params.Image_TimeStamp__s_ * 1E6; % list of all frame timestamps in s

 % this scanner doesn't tell us the time of each line and pixel, so we have to make it up

[dummy,ind] = intersect({ScanSettings.Identifier},'nDelayTime_ms');
delayTime = ScanSettings(ind).Variant * 1e3; % in us

meantimespentscanning = mean(diff(params.Image_TimeStamp__us_)) - delayTime;

timeperpixel = meantimespentscanning / (params.Main.Pixels_per_line * params.Main.Lines_per_frame);

params.Main.Scanline_period__s_ = (params.Main.Pixels_per_line * timeperpixel)*1e-6;
params.Main.Scanline_period__us_= params.Main.Scanline_period__s_ *1e6; %scanline period in us

params.Main.Dwell_time__s_ = params.Main.Scanline_period__s_ / params.Main.Pixels_per_line; % pixel dwell time in us
params.Main.Dwell_time__us_ =  params.Main.Dwell_time__s_*1e6;

params.Main.Frame_period__s_ = params.Main.Lines_per_frame * params.Main.Scanline_period__s_; % frame period in s
params.Main.Frame_period__us_ = params.Main.Frame_period__s_ * 1e6; % frame period in us

 % functions below are not used, in favor of xml2struct

return;

str = findmystr(text,prefix,postfix);

eqstr = findstr(str,'=');
spstr = findstr(str,' ');

for i=1:length(eqstr),
	prevspace = spstr(find(spstr<eqstr(i)));
	if isempty(prevspace), prevspace = 0; else, prevspace = prevspace(end); end;
	nextspace = spstr(find(spstr>eqstr(i)));
	if isempty(nextspace), nextspace = length(str)+1; else, nextspace = nextspace(end); end;

	myparams = setfield(myparams,str(prevspace+1:eqstr(i)-1),str(eqstr(i)+1:nextspace-1));
end;

function str = findmystr(text,prefix,postfix)
 % finds text between two strings, looks in increments of chunksize
str = '';

indspre = strfind(text,prefix);

if ~isempty(indspre),
	indspost = strfind(text,postfix);
	indspost = indspost(find(indspost>indspre(1)));
	str = text(indspre(1)+length(prefix):indspost(1)-1);
end;




