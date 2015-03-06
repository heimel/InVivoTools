function h=get_fighandle(name)
%GET_FIGHANDLE gets figure handle by name
%
%  H=GET_FIGHANDLE(NAME)
%     NAME can have '*' as a wild card
%
% 2008-2013, Alexander Heimel
%

h=[];
fighandles=get(0,'children');
name=lower(strtrim(name));
while isempty(h) && ~isempty(fighandles)
	if streq(lower(strtrim(get(fighandles(1),'Name'))),name)==1
		h=fighandles(1);
	else
		fighandles=fighandles(2:end);
	end
end
