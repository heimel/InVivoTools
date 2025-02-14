function a = newassoc(type, owner, data, desc)

% NEWASSOC / Makes a new associate data structure (shorthand)
%
%   ASSOC=NEWASSOC(TYPE, OWNER, DATA, DESC)
%
%  Creates a new associate structure.  This is simply shorthand for
%
%  ASSOC=STRUCT('type',TYPE,'owner',OWNER,'data',DATA,'desc',DESC)
%
%  See also:  MEASUREDDATA/ASSOCIATE
a = struct('type',type,'owner',owner,'data',data,'desc',desc);
