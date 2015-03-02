function tinf = tiffinfo_parse_fluoview(tinf)
%TIFFINFO_PARSE_FLUOVIEW used by tiffinfo for Fluoview metadata
%
% TINF = TIFFINFO_PARSE_FLUOVIEW( TINF )
%
% For more info on reading Olympus Fluoview Tiffs check out:
%    http://www.bioimage.ucsb.edu/downloads/BioImage%20Convert
%
% 2012, Alexander Heimel
%
%
% NumberOfChannels
% NumberOfFrames
% x_step
% x_unit
% y_step
% y_unit
% if more than 1 frame
%   third_axis_name
%   third_axis_unit
%   if third_axis_name is t
%     frame_period
%     frame_timestamp
%   if third_axis_name is z
%     z_step
%     z_unit
%     z
% bidirectional (logical)

% multiple channels?
if isfield(tinf(1).ParsedImageDescription,'NumberOfViewsAvailable')
    tinf(1).NumberOfChannels = tinf(1).ParsedImageDescription.NumberOfViewsAvailable;
else
    tinf(1).NumberOfChannels = 1;
end
tinf(1).NumberOfFrames=length(tinf) / tinf(1).NumberOfChannels;

if isfield(tinf(1),'PageName')
    [tinf(1).x_step tinf(1).x_unit tinf(1).y_step tinf(1).y_unit] = get_primary_dimensions( tinf(1).PageName );

    if length(tinf)>tinf(1).NumberOfChannels % i.e. 3-dimensions
        [tinf(1).third_axis_name tinf(1).third_axis_unit] = get_third_axis( tinf );
    else
        tinf(1).third_axis_name = [];
        tinf(1).third_axis_unit = [];
    end
end

if isfield(tinf,'UnknownTags') % for Fluoview
    % get frameperiod
    f=fopen(tinf(1).Filename);
    if isfield(tinf(1).UnknownTags(1),'Offset')
        fseek(f,tinf(1).UnknownTags(1).Offset+64*8,-1);
    elseif isfield(tinf(1).UnknownTags(1),'OffsetPtr')
        fseek(f,tinf(1).UnknownTags(1).OffsetPtr+64*8,-1);
    else
        error('TIFFINFO: Cannot find Offset field in UnknownTags');
    end
    if ~isfield(tinf(1),'third_axis_name') || isempty(tinf(1).third_axis_name)
        return
    end
    switch lower(tinf(1).third_axis_name) 
        case 't'
            tinf(1).frame_period = fread(f,1,'double');
            fclose(f);
            tinf(1).frame_timestamp = [];
            for i=1:tinf(1).NumberOfFrames
                tinf(1).frame_timestamp(i) = get_time( tinf(i).PageName) * tinf(1).frame_period;
            end
        case 'z'
            tinf(1).z_step = fread(f,1,'double');
            tinf(1).z_unit = tinf(1).third_axis_unit;
            fclose(f);
            tinf(1).z = [];
            for i=1:tinf(1).NumberOfFrames
                tinf(1).z(i) = get_z( tinf(i).PageName) * tinf(1).z_step;
            end
    end
            
end

if isfield(tinf(1).ParsedImageDescription,'ScanMode') && ...
    strcmpi(strtrim(tinf(1).ParsedImageDescription.ScanMode),'bidirectional scan')
    tinf(1).bidirectional = true;
else
    tinf(1).bidirectional = false;
end


function [x_step,x_unit,y_step,y_unit] = get_primary_dimensions( pagename )
caption = 'Resolution';
p = findstr( pagename, caption);
if isempty(p)
    warning('TIFFINFO_PARSE_FLUOVIEW:NO_PRIMARY_DIMENSIONS',...
        'TIFFINFO_PARSE_FLUOVIEW: cannot find primary dimensions');
    return
end
pagename = pagename(p+length(caption):end);
xy = eval([ '[' strtrim(pagename( 1:find(pagename==13 | pagename ==10))) ']' ]);
x_step = xy(1);
y_step = xy(2);

caption = 'Units';
p = findstr( pagename, caption);
pagename = strtrim(pagename(p+length(caption):end));
x_unit = strtrim(pagename(1:find(pagename==13|pagename==10|pagename==9,1)-1));
if x_unit(1) == 65461
    x_unit(1) = 'u';
end
pagename = pagename(find(pagename==9)+1:end);
y_unit = strtrim(pagename(1:find(pagename==13|pagename==10|pagename==9,1)-1));
if y_unit(1) == 65461
    y_unit(1) = 'u';
end


function [name,unit] = get_third_axis( inf )
if length(inf)<=inf(1).NumberOfChannels
    name = '';
    unit = '';
    return
end
pagename = inf(1).PageName;
caption = '[Higher Dimensions]'; % go to third dimension
p = strfind( pagename, caption);
pagename = pagename(p+length(caption):end);
caption = 'Name';
p = strfind( pagename, caption);
pagename = pagename(p+length(caption):end);
name = strtrim(pagename(1:find(pagename==13|pagename==10,1)-1));
name = name(1); % only take first character, i.e. T or Z

caption = 'Units';
p = strfind( pagename, caption);
pagename = pagename(p+length(caption):end);
unit = strtrim(pagename(1:find(pagename==13|pagename==10,1)-1));
if unit(1) == 65461
    unit(1) = 'u';
end



function time = get_time( pagename )
time  = NaN;
caption = 'Calibrated Position';
p = findstr( pagename, caption);
if isempty(p)
    warning('TIFFINFO_PARSE_FLUOVIEW:NO_CALIBRATED_TIME',...
        'TIFFINFO_PARSE_FLUOVIEW: cannot find calibrated frame time');
    return
end
pagename = pagename(p+length(caption):end);
time = eval([ '[' strtrim(pagename( 1:find(pagename==13 | pagename ==10))) ']' ]);
%if length(time)==2  %two-channels
time=time(1);
%end


function z = get_z( pagename )
z  = NaN;
caption = 'Calibrated Position';
p = findstr( pagename, caption);
if isempty(p)
    warning('TIFFINFO_PARSE_FLUOVIEW:NO_Z',...
        'cannot find calibrated z position');
    return
end
pagename = pagename(p+length(caption):end);
z = eval([ '[' strtrim(pagename( 1:find(pagename==13 | pagename ==10))) ']' ]);
if length(z)==2  %probably z-stack
    % second is time, first is slice
    z=z(1);
end


