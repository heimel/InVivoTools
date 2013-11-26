function cleanfig(fignum, units)

%  CLEANFIG - Cleans a figure for saving in guide
%
%  CLEANFIG(FIGNUM, UNITS)
%
%  Cleans all string entries from 'edit' and 'popup' uitools,
%  and sets units of all uitools to UNITS.
%
%  Useful for saving a figure after editing it.

c = get(fignum,'children');

for i=1:length(c),
  try, set(c(i),'units',units); end;
  try, if strcmp(get(c(i),'style'),'edit'), set(c(i),'String',''); end; end;
  try, if strcmp(get(c(i),'style'),'popup'), set(c(i),'String',''); end; end;
end;
