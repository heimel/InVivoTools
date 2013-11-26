function [inds] = getpsstiminds(ps,paramlist,valuelist)

% GETPSSTIMINDS - Get stimulus indicies for periodicscript object
%
% INDS = GETPSSTIMINDS(PS, PARAMLIST, VALUELIST)
%
% Returns a list of stimuli that have parameter values in the cell string
% list PARAMLIST with values in VALUELIST.  For example, if
% PARAMLIST={'contrast'}, and valuelist = {1}, then the function would return
% the indicies of all stimuli for which contrast is 1.

inds = [];
addit=1;
for i=1:numStims(ps),
	p = getparameters(get(ps,i));
	addit=1;
	for j=1:length(paramlist),
		if ~eqlen(getfield(p,paramlist{j}),valuelist{j}), addit=0; break; end;
	end;
	if addit, inds(end+1) = i; end;
end;
