function [stims,filename] = getstimsfile( record )
%GETSTIMSFILE gets tptestdb or ectestdb record a read NewStim stimsfile
%
%  [STIMS,FILENAME] = GETSTIMSFILE( RECORD )
%       returns empty STIMS if file not available
%
% 2010, Alexander Heimel
%

stimsname = 'stims.mat';
switch record.datatype
    case 'tp'
        filename = fullfile( tpdatapath(record),stimsname);
    case {'ec','lfp'}
        filename = fullfile( ecdatapath(record), record.test,stimsname);
end
if exist( filename, 'file')
    stims = load( filename, '-mat');
else
    logmsg(['Stimulus file ' filename ' does not exist.']);
    stims = [];
end
