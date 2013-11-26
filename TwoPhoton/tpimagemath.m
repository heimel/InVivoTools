function [result,im1,im2] = tpimagemath(record, channel, stimcode1, stimcode2, op,plotit,name)

%  TPIMAGEMATH - Simple image math
%
%  RESULT = TPIMAGEMATH(DIRNAME,CHANNEL,STIMCODE1,STIMCODE2,OP,PLOTIT,NAME)
%
%    Computes simple image math for Prairieview images.
%
%  DIRNAME is the name of a two-photon directory.  It should not include
%  the string '-001' that PrairieView adds to its directory names.
%
%  CHANNEL is the channel to read.
%  
%  STIMCODE1 and STIMCODE2 are stimulus numbers.  OP is a string and it
%  can be '+', '-', '*', or '/'.  If PLOIT is 1 then data are plotted.
%
%  RESULT is the result of the opertion.  It is the same size as the
%  images in DIRNAME.
%
%  If PLOTIT is 1, then the data is plotted as an image with title
%  NAME.
 
%interval = [];
%spinterval = [];

stims = getstimsfile( record );
if isempty(stims) 
    % create stims file
    stiminterview(record);
    stims = getstimsfile( record );
end;
s.stimscript = stims.saveScript; s.mti = stims.MTI2;
[s.mti,starttime] = tpcorrectmti(s.mti,record);
do = getDisplayOrder(s.stimscript); 
stims1 = find(do==stimcode1); stims2=find(do==stimcode2);
interval1 = []; interval2 = []; spinterval1 = []; spinterval2 = [];
for i=1:length(stims1),
	interval1(i,:) = [ s.mti{stims1(i)}.frameTimes(1) s.mti{stims1(i)}.startStopTimes(3)];
    spinterval1(i,:) = [s.mti{stims1(i)}.frameTimes(1)-3 s.mti{stims1(i)}.frameTimes(1)];
end;
for i=1:length(stims2),
	interval2(i,:) = [ s.mti{stims2(i)}.frameTimes(1) s.mti{stims2(i)}.startStopTimes(3)];
	spinterval2(i,:) = [ s.mti{stims2(i)}.frameTimes(1)-3 s.mti{stims2(i)}.frameTimes(1)];
end;

im = tppreview(record,2,1,channel);

im_outline = zeros(size(im)); im_outline(10:end-10,10:end-10) = 1;

data = tpreaddata(record, [interval1; spinterval1; interval2; spinterval2]-starttime,{find(im_outline==1)},0,channel);

im_outline = 0*im_outline(10:end-10,10:end-10);
im1 = im_outline; im2 = im1;
im1_ = im1; im2_ = im1;

num = 0;
for i=1:size(interval1,1),
    if ~isempty(data{i,1}),
        num=num+1;
        im1 = nansum(cat(3,im1,nanmean(reshape(data{i,1},size(im_outline,1),size(im_outline,2),length(data{i,1})/(size(im_outline,1)*size(im_outline,2))),3)),3);
    end;    
end;
im1 = im1 ./ num;

num=0;
for i=(size(interval1,1)+1):(2*size(interval1,1)),
    if ~isempty(data{i,1}),
        num=num+1;
    	im1_ = nansum(cat(3,im1,nanmean(reshape(data{i,1},size(im_outline,1),size(im_outline,2),length(data{i,1})/(size(im_outline,1)*size(im_outline,2))),3)),3);
    end; 
end;
im1_ = im1_ ./ num;

num=0;
for i=(2*size(interval1,1)+1):(2*size(interval1,1)+size(interval2,1)),
    if ~isempty(data{i,1}),
        num=num+1;
    	im2 = nansum(cat(3,im2,nanmean(reshape(data{i,1},size(im_outline,1),size(im_outline,2),length(data{i,1})/(size(im_outline,1)*size(im_outline,2))),3)),3);
    end;
end;
im2 = im2 ./ num;

num = 0;
for i=(2*size(interval1,1)+size(interval2,1)+1):(2*size(interval1,1)+2*size(interval2,1)),
    if ~isempty(data{i,1}),
        num=num+1;
    	im2_ = nansum(cat(3,im2,nanmean(reshape(data{i,1},size(im_outline,1),size(im_outline,2),length(data{i,1})/(size(im_outline,1)*size(im_outline,2))),3)),3);
    end;
end;
im2_ = im2_ ./ num;

im1 = (im1 - im1_); im2 = (im2 - im2_);

if op=='+',
	result = im1 + im2;
elseif op=='-',
	result = im1 - im2;
elseif op=='*',
	result = im1.*im2;
elseif op=='/',
	result = im1./im2;
end;

result = conv2(result,ones(5)/sum(sum(ones(5))),'same');

if plotit==1,
	imagedisplay(result,'Title',name);
    axis image
end;
