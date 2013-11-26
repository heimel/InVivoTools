function def=tptestrecord_defaults( datatype )
%TPTESTRECORD_DEFAULTS returns cell array with default tptestrecord settings
%
%   DEF=TPTESTRECORD_DEFAULTS
%
%  2010, Alexander Heimel
%
if nargin<1
  datatype='tp';
end

def = {['datatype=' datatype], ['setup=' host], 'ref_epoch=t00001'};

