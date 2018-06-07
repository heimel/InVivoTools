function [inf,imagenames] = lifinfo(id,imagename,stored,infname)
%LIFINFO reads metadata of Leica LIF file
%
%  [INF,IMAGENAMES] = LIFINFO(ID,IMAGENAME,STORED,INFNAME)
%       ID is filename
%       IMAGENAME is name of image in series
%       if STORED then use already compute matlab summary data
%
%  Needs location of loci_tools.jar included in javaclasspath
%
% 2011-2014, Alexander Heimel, based on BFOPEN from Bio-Formats
%

if nargin<2
    imagename = '';
end

if nargin<4
    infname = [id ':' imagename '_lifinfo.mat'];
end
if nargin<3
    stored=[];
end
if isempty(stored)
    stored=0;
end

if stored
    if exist(infname,'file')
        imagenames = {};
        load(infname);
        return
    end
end

if ~exist(id,'file')
    error(['File ' id ' not found.']);
end

fid = fopen(id);
buf = fread(fid,5000000);
fclose(fid);
txt = char(buf(14:2:end))';

tag = '<Dimensions>';
ind1 = findstr(txt,tag)+length(tag);
tag = '</Dimensions>';
ind2 = findstr(txt,tag)-1;

if length(ind1)>length(ind2)
    logmsg(['Not read all of header of LIF file ' id]);
end

for i=1:length(ind1)
    txts = txt(ind1(i):ind2(i));
    tag1 = '<DimensionDescription';
    inds1 = findstr(txts,tag1)+length(tag1);
    tag2 = '</DimensionDescription';
    inds2 = findstr(txts,tag2)-2;
    for j=1:length(inds1) % setting dimensions structs
%        m='m'; % for unit
        Pixel = 'Pixel' ; 
        code = txts(inds1(j):inds2(j));
        code = strrep(code,'"m"','''m''');
        code = strrep(code,'""','''''');
        code = [strrep(code,' ',['; dd(' num2str(i) ',' num2str(j) ').'] ) ';'];
        code(code=='"') = '';
        try
            eval(code);
        catch me
            logmsg(['Error evaluating: ' code]);
            rethrow(me);
        end
            
    end
end


autoloadBioFormats = 1;

% load the Bio-Formats library into the MATLAB environment
if autoloadBioFormats
    path = fullfile(fileparts(mfilename('fullpath')), 'loci_tools.jar');
    javaaddpath(path);
end

logmsg(['Loci tools version ' char(loci.formats.FormatTools.VERSION)]);

loci.common.DebugTools.enableLogging('INFO');

r = loci.formats.ChannelFiller();
r = loci.formats.ChannelSeparator(r);
r.setMetadataStore(loci.formats.MetadataTools.createOMEXMLMetadata());
r.setId(id);
numSeries = r.getSeriesCount();
if numSeries>size(dd,1)
   errormsg(['Reported numSeries = ' num2str(numSeries) ', but only read header info for ' num2str(size(dd,1)) ' series. Need to increase read buffer']);
   numSeries = size(dd,1);
end

result = cell(numSeries,1);
for s = 1:numSeries
    inf = [];
    fprintf('Reading series #%d', s);
    r.setSeries(s - 1);
    inf.Series = s;
    
    inf.Width = r.getSizeX();
    inf.Height = r.getSizeY();
    
    inf.NumberOfChannels = r.getSizeC();
    inf.NumberOfFrames = r.getImageCount() / inf.NumberOfChannels;
    
    pixelType = r.getPixelType();
    inf.FloatingPoint = loci.formats.FormatTools.isFloatingPoint(pixelType);
    inf.Signed =  loci.formats.FormatTools.isSigned(pixelType);
    inf.LittleEndian = r.isLittleEndian();
    inf.BitsPerSample = 8 * loci.formats.FormatTools.getBytesPerPixel(pixelType);
    
    % check methods(r) for what else we can get out of r
    if ismethod(r,'getMetadata') % old loci version before 5.0
        metadata = r.getMetadata.char;
        metadata = split(metadata,',');
        series = metadata{1};
        p = find(series==' ',1);
        series = series(2:p-1);
        try
            xline = metadata{strmatch([' ' series ' HardwareSetting|ScannerSettingRecord|dblVoxelX'],metadata)};
        catch
            xline = metadata{strmatch(['{' series ' HardwareSetting|ScannerSettingRecord|dblVoxelX'],metadata)};
        end
        yline = metadata{strmatch([' ' series ' HardwareSetting|ScannerSettingRecord|dblVoxelY'],metadata)};
        zline = metadata{strmatch([' ' series ' HardwareSetting|ScannerSettingRecord|dblVoxelZ'],metadata)};
        disp('LIFINFO: unknown x and y steps');
        inf.x_step  = str2double(xline(find(xline=='=')+1:end))*1e6;
        inf.x_unit = 'um'; % i.e. unknown, hidden in the metadata
        inf.y_step  = str2double(yline(find(yline=='=')+1:end))*1e6;
        inf.y_unit = 'um' ;% i.e. unknown, hidden in the metadata
        if inf.NumberOfFrames > 1
            % more than 1 frame
            if r.getSizeT > 1
                disp('LIFINFO: unknown frame period. Ask Alexander to improve code');
                inf.third_axis_name  = 't';
                inf.third_axis_unit = 'frame'; % i.e. unknown
                inf.frame_period = 1;
                inf.frame_timestamp = inf.frame_period * (0:(inf.NumberOfFrames-1));
            elseif r.getSizeZ > 1
                inf.third_axis_name = 'z';
                inf.z_step  = str2double(zline(find(zline=='=')+1:end))*1e6;
                inf.z_unit = 'um';
            end
        end
    else % > loci 5.0
        inf.image_name = r.getSeriesMetadataValue('Image name');
        zoom = str2double(r.getSeriesMetadataValue('ATLConfocalSettingDefinition|Zoom'));
        if isnan(zoom)
            zoom = 1;
        end
        if ~strcmp(dd(s,1).Unit,'m')
            errormsg(['Unknown unit ' dd(s,1).Unit ]);
        end
        inf.x_step  = dd(s,1).Length/dd(s,1).NumberOfElements*1e6;
        inf.x_unit = 'um';
        if ~strcmp(dd(2).Unit,'m')
            errormsg(['Unknown unit ' dd(s,2).Unit ]);
        end
        inf.y_step  = dd(s,2).Length/dd(s,2).NumberOfElements*1e6;
        inf.y_unit = 'um';
        
        if inf.NumberOfFrames > 1
            % more than 1 frame
            if r.getSizeT > 1
                disp('LIFINFO: unknown frame period. Ask Alexander to improve code');
                inf.third_axis_name  = 't';
                inf.third_axis_unit = 'frame'; % i.e. unknown
                inf.frame_period = 1;
                inf.frame_timestamp = inf.frame_period * (0:(inf.NumberOfFrames-1));
            elseif r.getSizeZ > 1
                if ~strcmp(dd(s,3).Unit,'m')
                    errormsg(['Unknown unit ' dd(s,3).Unit ]);
                end
                inf.z_step  = dd(s,3).Length/dd(s,3).NumberOfElements*1e6;
                inf.z_unit = 'um';
                inf.third_axis_name = 'z';
            end
        end
    end
    result{s} = inf;
end % series s
r.close();

inf = result; % to comply with tiffinfo
imagenames = cellfun(@(x) x.image_name,inf,'uniformoutput',0);
if isempty(imagename)
    logmsg(['LIF file contains ' num2str(length(inf)) ' images:']);
    disp(imagenames);
else
    p = strmatch(imagename,imagenames);
    if isempty(p)
        logmsg(['LIF file contains ' num2str(length(inf)) ' images:']);
        disp(imagenames);
        logmsg(['Could not find ' imagename ' among image names in the file.']);
    else
        inf = inf{p};
    end
end
if stored
    save(infname,'inf','imagenames','-v7');
end

return
