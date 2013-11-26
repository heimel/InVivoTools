function i = findag(ag, figure)

%  i = findag - finds which entry in userdata corresponds to ag, -1 if not there

ud = get(figure,'userdata');

i = -1;

if ~isempty(ud)&strcmp(class(ud),'cell'),
  for j=1:length(ud), if ag==ud{j}, i = j; break; end; end;
end;
