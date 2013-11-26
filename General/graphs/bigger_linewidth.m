function bigger_linewidth(inc, h )
%BIGGER_LINEWIDTH makes all fonts in figure smaller
%

% 2003, Alexander Heimel (heimel@brandeis.edu)

if nargin<2
	h=gcf;
end
if nargin<1
	inc=1;
end

for hh=h'
	try
		c=get(hh,'Children');
		bigger_linewidth(inc,c);
	end
	try
		inclinewidth(hh,inc);
	end
end

return


function inclinewidth(h,inc)
set(h,'LineWidth',get(h,'LineWidth')+inc);
