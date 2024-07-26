function [newexop,status] = extractdir(exop,thedir,aqinfo,cksds,instruc);

%  [NEWEXOP,STATUS]=EXTRACTDIR(EXOP,THEDIR,ACQ_OUT_INFO,THECKSDIRSTRUCT,INSTRUC)
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

newexop = exop;

disp(['Extracting ' ...
	aqinfo.name ':' int2str(aqinfo.ref) ' in directory ' thedir '.']);

status = 1;
