function [newac,status] = extractdir(ac,ex1,thedir,aqinfo,cksds,instruc);

%  [NEWAC,STATUS]=EXTRACTDIR(AC,THEDIR,ACQ_OUT_INFO,THECKSDIRSTRUCT,INSTRUC)
%
%  Perform extraction operation on the data described by ACQ_OUT_INFO in the
%  given directory (THEDIR) associated with THECKSDIRSTRUCT according to the
%  instructions given in INSTRUC.
%
%  INSTRUC has the following fields:
%     extractincompletedir (0 or 1)      : 1 means attempt to extract data
%                                        :   from directory where data is still
%                                        :   coming in
%
%  STATUS is one of -1 (error), 0 (no error but not operation not complete)
%  1 (operation complete).
%
%  See also:  CKSDIRSTRUCT, INSTRUC

display('Extractdir AC')

status = 1; newac = ac;
return; %  nothing to do ... not a directory based extractor
