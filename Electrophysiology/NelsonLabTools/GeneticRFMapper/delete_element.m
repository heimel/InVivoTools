function newlist = delete_element( list, n)
%DELETE_ELEMENT deletes element from cell list or array
%
%  NEWLIST = DELETE_ELEMENT( LIST, N)
%  deletes N'th element from LIST

if n>length(list) | n<1
  disp('Warning: element is not in list');
elseif length(list)==1
  if iscell(list)
    newlist = {};
  else
    newlist = [];
  end
elseif n==1
  newlist = list(2:end);
elseif n==length(list)
  newlist = list(1:end-1);
else
  newlist = list([ (1:n-1) (n+1:end) ]);
end
