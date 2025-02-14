function [s] = getstimscripttimestruct(cksds,thedir)

%  Part of the NelsonLabTools package
%  
%  [THESTIMSCRIPTTIMESTRUCT] = GETSTIMSCRIPTTIMESTRUCT(MYCKSDIRSTRUCT,THEDIR)
%
%  Gets the stimscript and MTI (timing) record associated with a particular
%  test directory in the form of a stimscripttimestruct.
%
%  See also:  STIMSCRIPTTIMESTRUCT

[ss,mti]=getstimscript(cksds,thedir);

s=stimscripttimestruct(ss,mti);

