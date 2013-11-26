function g = geteditor(str)

%  Part of the NewStim package
%  G = GETEDITOR(STR)
%
%  Returns the figure number which contains the appropriate editor.  STR 
%
%  See also:  SCRIPTEDITOR STIMEDITOR SCRIPTOBJEDITOR

g = [];

openFigures = findobj(allchild(0),'flat','Visible','on');

j = 1;
for i=1:length(openFigures),
	z = get(openFigures(i),'UserData');
	if isstruct(z),
		if isfield(z,'tag'),
			if strcmp(z.tag,str),
				g(j) = openFigures(i); j = j + 1;
			end;
		end;
	end;
end;
