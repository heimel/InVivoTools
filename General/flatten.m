function nl=flatten( l )
%FLATTEN returns flattened array of cell list
%
% ??
%

nl=[];

if ~iscell(l)
	nl=l(:);
	return
end

for i=1:length(l)
	nl=[nl;flatten(l{i})];
end