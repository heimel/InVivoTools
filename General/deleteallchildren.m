function deleteallchildren(h)

% DELETEALLCHILDREN
%
%  DELETEALLCHILDREN(H)
% 
% Loops over the children of H and, if they are valid handles, deletes them.
%

 
if ishandle(h), g = get(h,'children');
  for i=1:length(g), if ishandle(g(i)), delete(g(i)); end; end;
end;

