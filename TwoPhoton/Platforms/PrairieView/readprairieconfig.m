function v = readprairieconfig(filename)

%  READPRAIRIECONFIG - Read all values from Prairie config file
%
%   VALUES = READPRAIRIECONFIG(FILENAME)
%
%  Reads values from a Prairie Technologies config file.
%  Returns a struct with fieldnames equal to each parameter.
%  Differnet categories (e.g., 'Main') are included as
%  substructures.
%
%  With version 2.2 of the PrairieView software, parameter
%  files became large XML documents that contain a lot of
%  information.  Therefore, this function only retrieves 
%  a subset of parameters from XML files.  They are
%  params.Main.Total_cycles  (total number of cycles)
%  params.Main.Scanline_period__us_  (scanline period, in us)
%  params.Main.Dwell_time__us_  (pixel dwell time, in us)
%  params.Main.Frame_period__us_  (frame period, in us)
%  params.Main.Lines_per_frame (lines per frame)
%  params.Main.Pixels_per_line  (number of pixels per line)
%  params.Image_TimeStamp__us_  (list of all frame timestamps)
%  params.Cycle_N.Number_of_images (num. of images in Cycle N)
%
%
%  For older config files (.pcf files), all fields are read in.  
%  Note that spaces and parentheses are invalid for fieldnames
%  so the fieldnames in VALUES will have have these characters
%  replaced with underscores.
%
%  Example, filename = 'Image-11-Jan-2006-15-47.pcf'.
%
%  See also:  PRAIRIEVIEWREADXML, READPRAIRIECONFIGVALUE 

if strcmp(filename(end-2:end),'xml'),
	v=readprairieviewxml(fixtilde(filename));
	return;
end;

f = fopen(filename);

if f<0, error(['Could not open file ' filename '.']); end;

v = [];

filetype = '';

while ~feof(f),
	s = fgets(f);
	ind = strfind(s,'[');
	if ~isempty(ind),
		if strfind(s,'[Image TimeStamp (us)]'), % next fields are frames
			ImageTimeStamps = [];
			for i=1:v.Main.Total_images, % Total_images should be field by now
				fv = fgets(f);
				f_ind = strfind(fv,'=');
				ImageTimeStamps(end+1) = str2num(fv(f_ind+1:end));
			end;
			v = setfield(v,'Image_TimeStamp__us_',ImageTimeStamps);
		else, % is a subfield
			endind = strfind(s,']');
			subfield = [];
			subname = s(ind+1:endind-1);
			subname(find(subname==' '))='_';
			subname(find(subname=='('))='_';
			subname(find(subname==')'))='_';
			
			while ~isempty(s)&~feof(f),
				s = fgets(f);
				if length(s)==2,
					if double(s(1))==13, s = ''; end;
				end;
				ind = strfind(s,'=');
				if length(ind)>1,
					error(['Found more than one equal sign per line in config ' ...
					'file ' filename '...don''t know how to process.']);
				end;
				if ~isempty(ind),
					field = s(1:ind-1);
					field(find(field==' '))='_';
					field(find(field=='('))='_';
					field(find(field==')'))='_';
					val = str2num(s(ind+1:end)); % see if it's number or string
					if isempty(val), val = s(ind+1:end); end;
					subfield = setfield(subfield, field, val);
					if strcmp(field,'Acquisition_type'),
						filetype = val;
					end;
				end;
			end;
			v = setfield(v,subname,subfield);
		end;
	end;
end;
fclose(f);

