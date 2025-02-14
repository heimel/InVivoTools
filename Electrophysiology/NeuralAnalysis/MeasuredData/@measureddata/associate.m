function nmd = associate(md,typeorstruct,owner,data,description)

%  ASSOCIATE
%
%  NEWMD = ASSOCIATE(MEASUREDDATAOBJ,TYPE,OWNER,DATA,DESCRIPTION) or
%  NEWMD = ASSOCIATE(MEASUREDDATAOBJ,ASSOCSTRUCT)
%
%  Associates some data with the MEASUREDDATA object MEASUREDDATAOBJ and returns
%  the new object in NEWMD.  TYPE should be a string describing the DATA
%  stored, OWNER should be a string describing the author of inserted data,
%  DATA is the data to be associated, and DESCRIPTION is a human-readable
%  description of DATA.
% 
%  The ASSOCSTRUCT can be used provided it is a structure with the four fields
%  above.
%
%  Duplicates in type, owner, and description are not allowed.  No error will
%  be given, but the new association will replace the old.
%
%  See also:  MEASUREDATA,GETASSOCIATE,FINDASSOCIATE,NUMASSOCIATES,DISASSOCIATE

if nargin==2,
  type=typeorstruct.type;description=typeorstruct.desc;
  owner=typeorstruct.owner; data = typeorstruct.data;
else,
  type = typeorstruct;
end;

if ~strcmp(class(type),'char'),error('type must be string.');end;
if ~strcmp(class(description),'char'),error('description must be string.');end;
if ~strcmp(class(owner),'char'),error('owner must be string.');end;

n.type=type;n.owner=owner;n.data=data;n.desc=description;
l = length(md.associates);
[a,i]=findassociate(md,type,owner,description);
if ~isempty(a),
  md.associates(i) = n;
else,
  md.associates(l+1) = n;
end;
nmd =md;
