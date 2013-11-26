function def=ectestrecord_defaults( datatype )
%ECTESTRECORD_DEFAULTS returns cell array with default ectestrecord settings
%
%   DEF=ECTESTRECORD_DEFAULTS
%
%  2007, Alexander Heimel
%
if nargin<1
  datatype=[];
end


def = {['datatype=' datatype],['setup=' host]};


switch datatype
  case 'ec'
		def{end+1}='amplification=5000';
    def{end+1}='filter=[300 10000]';
  case 'lfp'
		def{end+1}='amplification=1000';
    def{end+1}='filter=[0 3000]';
end
