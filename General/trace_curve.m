function [x,y]=trace_curve(fig,n)
%TRACE_CURVE traces a given curve by pointing and clicking
%
% [x,y]=trace_curve(fig,n)
%   FIG can be figure handle or image filename
%   N is number of datasets/lines to gather
%
% 2008, Alexander Heimel
%

if isnumeric(fig) % then figurehandle
	figure(fig);
elseif ischar(fig) % filename
	img=imread(fig);
	figure;image(img);axis image;axis off;
end

if nargin<2
	n=1;
end

disp('Click left bottom corner');
[left,bottom]=ginput(1);
disp('Click top right corner');
[right,top]=ginput(1);

prompt={'Left x coordinate:','Right x coordinate:','x is log axis?'...
	'Bottom y coordinate:','Top y coordinate:','y is log axis?'};
name='Input for Peaks function';
numlines=1;
%defaultanswer={'20','hsv'};
answer=inputdlg(prompt,name,numlines);
xl=eval(answer{1});
xr=eval(answer{2});
switch lower(answer{3})
  case {'1','yes','y'}
    xla=1;
    xl=log10(xl);
    xr=log10(xr);
  case {'0','no','n'}
    xla=0;
  otherwise
    disp('did not understand if x-axis is logarithmic. use yes/y or no/n');
end
yb=eval(answer{4});
yt=eval(answer{5});
switch lower(answer{6})
  case {'1','yes','y'}
    yla=1;
    yb=log10(yb);
    yt=log10(yt);
  case {'0','no','n'}
    yla=0;
  otherwise
    disp('did not understand if y-axis is logarithmic. use yes/y or no/n');
end


disp('Click on points, press return when a single set is finished')
for i=1:n
	[x{i},y{i}]=ginput; 
	x{i}=(x{i}-left)/(right-left)*(xr-xl)+xl;
	
	if xla %  log axis
    x{i}=10.^x{i}
	end
		y{i}=(y{i}-bottom)/(top-bottom)*(yt-yb)+yb
	if yla %  log axis
		y{i}=10.^y{i}
	end
end


if n==1 
	x=x{1};
	y=y{1};
end


