function base=localpathbase
%LOCALPATHBASE return base of local data path
%
% BASE = LOCALPATHBASE
%
%  LEVELTLAB dependent, returns path to levelt storage share 
%
% 2012, Alexander Heimel
%

switch computer
    case 'MACI64'
            base = '/Volumes/MVP/Common/InVivo';
    case 'MACI' 
        base = '/Users/user/Dropbox/Data';
    case {'GLNX86','GLNXA64'}
        base = '/home/data/InVivo';
    case {'PCWIN','PCWIN64'}
        base = 'D:\Data\InVivo';
        if ~exist(base,'dir')
            base = 'C:\Data\InVivo';
        end
    otherwise
            error(['LOCALPATHBASE: Unknown computer type ' computer ]);
end
    
if ~exist(base,'dir')
    disp(['LOCALPATHBASE: Folder ' base ' does not exist.']);
end

  