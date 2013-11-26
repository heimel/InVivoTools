function smaller_font(dec, h )
%SMALLER_FONT makes all fonts in figure smaller
%
%  SMALLER_FONT
%  SMALLER_FONT(DEC, H )
%    DEC is decrement in points
%    H is figure handle
%
% 2003, Alexander Heimel (heimel@brandeis.edu)

ver=version;
if ver(1)~='5'
	warning('off', 'MATLAB:legend:changedItemTextFontProperties');
end

if nargin<2
	h=gcf;
end
if nargin<1
	dec=1;
end

for hh=h'
	try
		c=get(hh,'Children');
		smaller_font(dec,c);
	end
	try
		decfont(get(hh,'XLabel'),dec);
		decfont(get(hh,'YLabel'),dec);
	end

	try
		decfont(hh,dec);
	end
end
return


function decfont(h,dec)
set(h,'FontSize',get(h,'FontSize')-dec);