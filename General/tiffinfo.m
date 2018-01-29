function inf=tiffinfo(imgname,stored,infname)
%TIFFINFO parses image description information from multitiff
%
% INF=TIFFINFO( FNAME )
% INF=TIFFINFO( FNAME,STORED)
%   INF is the result of matlab function IMFINFO and a struct field
%       ParsedImageDescription
%   if STORED = 1 then store info data and read from IMGNAME_INFO.MAT
%   because IMFINFO for multitiffs is slow
%   by default STORED = 0
%
% INF is a struct with the fields:
%  Height
%  Width
%  BitsPerSample
%
%  NumberOfFrames contains number of frames
%  NumberOfChannels contains number of channels
%  x_step
%  x_unit
%  y_step
%  y_unit
%  if more than 1 frame
%    third_axis_name
%    third_axis_unit
%    if third_axis_name is t
%      frame_period
%      frame_timestamp
%    if third_axis_name is z
%      z_step
%      z_unit
%      z
%
%  Should read Olympus Fluoview Tiffs, ImageJ Tiffs
%
% 2009-2012, Alexander Heimel
%


if nargin<3
    infname = [imgname '_tiffinfo.mat'];
end

if nargin<2
    stored=[];
end
if isempty(stored)
    stored=0;
end

if stored
    if exist(infname,'file')
        load(infname);
        return
    end
end

if ~exist(imgname,'file')
    disp(['TIFFINFO: ' imgname ' does not exist.']);
    inf = [];
    return
end

try
    inf=imfinfo(imgname);
catch me % some multitiffs cause an error in a mexfile of imfinfo
    disp(['TIFFINFO: Caught error in getting info from ' imgname '. Possibly multitiff bug in imfinfo mexfile.']);
    me.message
    tempim = imread( imgname, 1); % read one frame to get dimensions
    inf.Width = size(tempim,2);
    inf.Height = size(tempim,1);
    switch(class(tempim))
        case 'uint8'
            inf.BitDepth = 8;
            inf.BitsPerSample = 8;
        case 'uint16'
            inf.BitDepth = 16;
            inf.BitsPerSample = 16;
    end
    if length(size(tempim))==2
        inf.ColorType = 'grayscale';
    else
        disp('TIFFINFO: do not know colortype');
    end
    page = 1;
    step = 1000;
    ready = false;
    while ~ready
        try
            imread(imgname,page);
            page = page + step;
        catch
            page = page - step; % back to previous frame
            if step==1
                inf.NumberOfFrames = page;
                ready = true;
            else
                step = ceil(step/2);
                page = page + step;
            end
        end
    end
end % catch


if ~isfield(inf(1),'ImageDescription')
    inf(1).ImageDescription='';
end

inf(1).ParsedImageDescription = parse_imagedescription(inf(1).ImageDescription);

% only use first image info
if isfield(inf(1).ParsedImageDescription,'ImageJ')
    inf = tiffinfo_parse_imagej(inf);    % imagej
elseif isfield(inf(1).ParsedImageDescription,'FLUOVIEW_Version')
    inf = tiffinfo_parse_fluoview(inf);    % fluoview
elseif isfield(inf(1).ParsedImageDescription,'scan')
    inf = tiffinfo_parse_lohmann(inf);    % lohmann tiff
elseif isfield(inf(1),'Make') && strcmpi(strtrim(inf(1).Make),'imspector')
    inf = tiffinfo_parse_imspector(inf);    % imspector tiff 
elseif isfield(inf(1).ParsedImageDescription,'state_configName')
    inf = tiffinfo_parse_scanimage(inf);  % scanimage tiff
elseif strcmp(strtrim(inf(1).ImageDescription),'Andor SOLIS')
    inf = tiffinfo_parse_andorsolis(inf);
end

% set some defaults
if ~isfield(inf,'NumberOfFrames')
    inf(1).NumberOfFrames=length(inf);
end
if ~isfield(inf,'NumberOfChannels')
    inf(1).NumberOfChannels = 1;
end

% only use first image info
inf=inf(1);

if stored
    save(infname,'inf','-v7');
end
return



function pid=parse_imagedescription(id)
if isempty(id)
    pid = [];
    return
end

start = strtrim(id(1:10));
if strcmp(start(1:5),'<?xml') % xml file
    pid.domnode = xmlparse( id );
    return
end

% otherwise interpret as FIELD=VALUE and make struct
id(id==13)=10; % change all CR to LF
id(end+1)=10;
p=find(id==10,1);
pid=[];
while ~isempty(p)
    idline=strtrim(id(1:p-1));
    p_is=find(idline=='=',1);
    if ~isempty(p_is)
        field=subst_specialchars(strtrim(idline(1:p_is-1)));
        arg=strtrim(idline(p_is+1:end));
        if ~isempty(arg)
            if arg(1)=='"' && arg(end)=='"' % assume string
                arg=arg(2:end-1);
            end
        end
        switch field
            case {'Date','Time'}
                % do nothing
            otherwise
                try % try if it is a numeric
                    % first remove all non-numeric characters for safety
                    carg = arg;
                    carg(carg>57 | carg<43)=' ';
                    arg=eval(carg);
                end
        end
        pid.(field)=arg;
    end  % goto next line
    id=id(p+1:end);
    p=find(id==10,1);
end


function inf = tiffinfo_parse_andorsolis(inf)
inf(1).third_axis_name = 't' ;
inf(1).third_axis_unit = 's';
inf(1).NumberOfFrames = length(inf);
inf(1).frame_period = inf(1).UnknownTags(18).Value;
inf(1).frame_timestamp = [];
for i=1:inf(1).NumberOfFrames
    inf(1).frame_timestamp(i) = (i-1) * inf(1).frame_period;
end


    
    
