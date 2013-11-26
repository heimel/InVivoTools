function [newexop,status] = cleanupextract(exop,pexop,nameref,cksds,instruc);

%  [NEWEXOP,STATUS]=CLEANUPEXTRACT(EXOP,PEXOP,NAMEREF,THECKSDIRSTRUCT,INSTRUC)
%
%  Perform cleanup for extraction operation on the data described by NAMEREF in
%  the directorys associated with THECKSDIRSTRUCT according to the instructions
%  given in INSTRUC.
%
%  INSTRUC has the following fields:
%     extractincompletedir (0 or 1)      : 1 means will attempt to extract data
%                                        :   from directory where data is still
%                                        :   coming in
%
%  STATUS is one of -1 (error), 0 (no error but not operation not complete)
%  1 (operation complete).
%
%  See also:  CKSDIRSTRUCT, INSTRUC

newexop = exop;

disp(['Cleaning up extraction of ' nameref.name ':' int2str(nameref.ref) '.']);

status = 1;
