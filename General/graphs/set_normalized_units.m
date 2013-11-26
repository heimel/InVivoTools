function set_normalized_units( h )
%SET_NORMALIZED_UNITS set units property of all figure's objects to 'normalized'
%
% 2010, Alexander Heimel

if nargin<1
	h=gcf;
end

for hh=h'
	try %#ok<TRYNC>
		c=get(hh,'Children');
		set_normalized_units(c);
	end
	try %#ok<TRYNC>
        set(h,'Units','normalized');
	end
end

