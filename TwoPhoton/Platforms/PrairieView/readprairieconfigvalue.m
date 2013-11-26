function v = readprairieconfigvalue(filename, fieldname)

%  READPRAIRIECONFIGVALUE - Read a value from a Prairie config file
%
%   VALUE = READPRAIRIECONFIGVALUE(FILENAME, FIELDNAME)
%
%  Reads a value from a Prairie Technologies config file.
%  Returns empty if the parameter value could not be found.
%
%  Note that this function only reads the old .pcf file format.
%
%  Example, filename = 'Image-11-Jan-2006-15-47.pcf',
%  fieldname = 'Dwell time (us)'
%
%  See also:  READPRAIRIECONFIG

f = fopen(filename);

if f<0, error(['Could not open file ' filename '.']); end;

v = [];

while (~feof(f)&isempty(v)),
	s = fgets(f);
	if ~isempty(strfind(s,fieldname)),
		v = sscanf(s,[fieldname '=%f']);
	end;
end;
fclose(f);

