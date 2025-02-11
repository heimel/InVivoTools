function [db,filename]=load_testdb( datatype, hostname, create,load_main,verbose)
%LOAD_TESTDB loads test_db
%
%  [DB,FILENAME] = LOAD_TESTDB( DATATYPE, HOSTNAME )
%      where DATATYPE is one of the 4 main datatypes with different record structures:
%       'ec' - electrophysiology
%       'tp' - two-photon and regular microscopy
%       'wc' - webcam data
%       'oi' - intrinsic signal, flavoprotein and gcamp wide field imaging
%       and HOSTNAME is one of the acquistion computers, e.g. jander, daneel or wall-e.
%
%    FILENAME may be cell array of string
%
% See also SAVE_DB, OPEN_DB
%
% 2005-2015, Alexander Heimel
%

if nargin<1 || isempty(datatype)
    datatype = 'oi';
end
if nargin<2 || isempty(hostname)
    hostname = host;
end
if nargin<5 || isempty(verbose)
    verbose = true;
end
if nargin<3 || isempty(create)
    create = [];
end
if nargin<4 || isempty(load_main)
    load_main = [];
end

if exist(datatype,'file') && strcmp(who('-file',datatype,'db'),'db')
    whichdb = datatype;
else
    whichdb = expdatabases( datatype, hostname);
end

[db,filename] = load_expdatabase(whichdb,'network',create,load_main,verbose);
if isempty(db)
    hostname = '*';
    whichdb = expdatabases( datatype, hostname);
    [db,filename] = load_expdatabase(whichdb,'network',create,load_main,verbose); % filename may be cell array
    if iscell(filename) && length(filename)==1
        filename = filename{1};
    end
end


