function a = loadStructArray(fname,fields,delimiter)
% if no fields, get fields from first line

if nargin<3
    delimiter = '';
end

if isempty(delimiter)
  delimiter=char(9); % tab
end

if nargin<2 
    fields = {};
end


[fid,msg] = fopen(fname, 'rt');
if fid == -1
	disp(['LOADSTRUCTARRAY: ' msg ' for file ' fname]);
	return
end

if isempty(fields)
	s = fgetl(fid);
	s = [delimiter s delimiter];
	pos = findstr(s,delimiter);
	for i=1:length(pos)-1
		fields{i} = s(pos(i)+1:pos(i+1)-1);
	end
end

count = 1;
while 1
	s = fgetl(fid);
	if ~ischar(s)
		break;
	end
	a(count) = char2struct(s,fields,delimiter);
	count = count + 1;
end

fclose(fid);
