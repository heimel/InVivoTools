function r=sfcurve(sf,lowsfwidth,highsfwidth,lowheight,shifthigh)
if nargin<5
  shifthigh=0;
end
if nargin<4
	lowheight=1;
end

r=exp(-(sf-shifthigh).^2/highsfwidth^2)-lowheight*exp(-sf.^2/lowsfwidth^2);
r=r/max(r);