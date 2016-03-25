function [stims,filename] = getstimsfile( record )
%GETSTIMSFILE gets tptestdb or ectestdb record a read NewStim stimsfile
%
%  [STIMS,FILENAME] = GETSTIMSFILE( RECORD )
%       returns empty STIMS if file not available
%
% 2010, Alexander Heimel
%

stimsname = 'stims.mat';
filename = fullfile( experimentpath(record),stimsname);
if exist( filename, 'file')
    try 
        stims = load( filename, '-mat');
    catch me
        errormsg(me.message);
        stims = [];
    end
else
    logmsg(['Stimulus file ' filename ' does not exist.']);
    stims = [];
end
