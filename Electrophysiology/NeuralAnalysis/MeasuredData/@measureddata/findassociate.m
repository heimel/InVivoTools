function [a,i] = findassociate(md,type,owner,description)
%  [A,I] = FINDASSOCIATE(MD,TYPE,OWNER,DESCRIPTION)
%
%     Finds associates of MEASUREDDATA object MD which match all of the
%  criteria above.  It will only return in A associates which match all of the
%  criteria.  To indicate that a field is not to be searched, set the value to
%  empty.  I returns the indicies of the associates.
%
%  See also: MEASUREDDATA, ASSOCIATE

  % fix to allow full wildcards

if ~isempty(type)&~strcmp(class(type),'char'),error('type must be string.');end;
if ~isempty(description)&~strcmp(class(description),'char'),
	error('description must be string.');
end;
if ~isempty(owner)&~strcmp(class(owner),'char'),
	error('owner must be string.');
end;


i = [];
for j=1:numassociates(md),
  a = getassociate(md,j);
  if ( (isempty(type))|(strcmp(type,a.type)) ) &...
     ( (isempty(description))|(strcmp(description,a.desc)) ) &...
     ( (isempty(owner))|(strcmp(owner,a.owner)) ),
     i(length(i)+1) = j;
  end; 
end;

a = getassociate(md,i);

return;

if 0, % surprisingly, this is not faster for searching
i= 1:numassociates(md);
if ~isempty(type)&~isempty(i), [c,i,ib]=intersect({md.associates(i).type},type); end;
if ~isempty(owner)&~isempty(i), [c,i,ib]=intersect({md.associates(i).owner},owner); end;
if ~isempty(description)&~isempty(i), [c,i,ib]=intersect({md.associates(i).description},description); end;
 a = getassociate(md,i);
return;
end;
