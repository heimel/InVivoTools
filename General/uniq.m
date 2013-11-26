function y = uniq(x)
% uniq - find the unique elements in a vector
%
% y = uniq (x) returns a vector shorter than x with all sequential
% occurances but the first of the same element eliminated.
%
% cf. the unix uniq command.  Also see SORT.

if isempty(x)
  y=[];
  return;
end

if ~iscell(x)
  y(1) = x(1);
  j = 2;
  
  for i = 2:max(size(x))
    if x(i) ~= x(i-1)
      y(j) = x(i);
      j = j+1;
    end
  end
else
  
  y{1} = x{1};
  j = 2;
  
  for i = 2:length(x)
    equal=0;
    if isstr(x{i})
      if strcmp(x{i},x{i-1})==1 
	equal=1;
      end
    else
      if x{i}==x{i-1}
	equal=1;
      end
    end
    if ~equal
      y{j} = x{i};
      j = j+1;
    end
  end
end
