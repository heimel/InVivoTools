function [good, errormsg] = verifyscript(params)
%
% 2010, Alexander Heimel
%

good = 0;
stim = hupestim( params );  % will give error if there is a problem
if ~isempty(stim)
	good = 1;
end
