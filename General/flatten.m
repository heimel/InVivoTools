function nl=flatten( l )
%FLATTEN returns flattened array of cell list
%
% 2014, Alexander Heimel
%

nl=[];

if ~iscell(l)
	nl = l(:);
	return
end

for i=1:numel(l)
	nl = [nl;flatten(l{i})]; %#ok<AGROW>
end