function [ds] = dirstruct(pathname)

%  [DS] = SDIRSTRUCT(PATHNAME)
%
%  Returns a DIRSTRUCT object.  This class is intended to manage experimental data
%  The data are organized into separate test directories, with each directory
%  containing one epoch of recording.  Each such directory has a file called
%  'reference.txt' that contains information about the signals that were acquired
%  during that epoch.  The user can query the DIRSTRUCT object to see what type
%  of signals were recorded and to load data.
%
%  The file 'reference.txt' describes one signal on each line with a name and
%  reference number pair and a record type.  For example, if one were to record
%  from two single electrodes, one in lgn and one in cortex, and this was the first
%  spot visited in cortex and the second spot visited in lgn, one might use the
%  following as the reference.txt file (spaces are tabs, include field title line):
%
%  name    ref    type
%  lgn     2      singleEC
%  ctx     1      singleEC
%
%  See also:  METHODS('DIRSTRUCT') 
%

pathname = fixpath(pathname); % add a '/' if necessary

if exist(pathname)~=7, error(['''' pathname ''' does not exist.']); end;
   % build list
  % create some empty structs
nameref_str = struct('name','','ref',0,'listofdirs',{});
dir_str     = struct('dirname','','listofnamerefs',{});
dir_list    = {};
nameref_list= struct('name',{},'ref',{}); % create empty
extractor_list = struct('name',{},'ref',{},'extractor1','','extractor2','');
autoextractor_list = struct('type',{},'extractor1',{},'extractor2',{});

S = struct('pathname',pathname);
S.nameref_str = nameref_str;
S.dir_str = dir_str;
S.nameref_list = nameref_list;
S.dir_list = dir_list;
S.extractor_list = extractor_list;
S.autoextractor_list = autoextractor_list;
S.active_dir_list={};
ds = class(S,'dirstruct');

ds = update(ds);
