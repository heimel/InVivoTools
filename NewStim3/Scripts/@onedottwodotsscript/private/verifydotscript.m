function [good, errormsg] = verifydotscript(params)
%
% 2010-2014, Alexander Heimel
%

good = 0;
errormsg = '';
stim = onedottwodots( params );  % will give error if there is a problem
if ~isempty(stim)
	good = 1;
end