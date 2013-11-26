function a = char2struct(s,fields,delimiter)
if nargin<3
  delimiter=char(9);
end

a = [];
str = [delimiter s delimiter];
pos = findstr(str,delimiter);

for i=1:length(fields)
	t = str(pos(i)+1:pos(i+1)-1);
	u = str2num(t);
	if ~isempty(u)
		a = setfield(a,fields{i},u);
	else
		a = setfield(a,fields{i},t);
	end
end
