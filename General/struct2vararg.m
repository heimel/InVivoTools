function vararg = struct2vararg( s )
%STRUCT2VARARG transforms struct to cell list with field and value alternating
%
% VARARG = STRUCT2VARARG( S )
%
% 2010, Alexander Heimel
%

f = fieldnames( s );
v = struct2cell( s );
vararg = {};
for i = 1:length(f)
	vararg{end+1} = f{i};
	vararg{end+1} = v{i};
end
