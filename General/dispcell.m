function dispcell( x )
%DISPCELL displays contents of cell list of arrays
%
% 2014, Alexander Heimel
%

cellfun(@(x) disp([ num2str(x,'%g,')]),x,'uniformoutput',false);