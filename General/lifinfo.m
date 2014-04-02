function inf = lifinfo(id,stored,infname)
%
%  Needs location of loci_tools.jar included in javaclasspath
%
% 2011, Alexander Heimel, based on BFOPEN from Bio-Formats
%

if nargin<3
    infname = [id '_lifinfo.mat'];
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

if ~exist(id,'file')
    error(['File ' id ' not found.']);
end

fid = fopen(id);
buf = fread(fid,30000);
fclose(fid);
txt = char(buf(14:2:end))';
% tag = '</LMSDataContainerHeader>';
% ind = findstr(txt,tag);
% xml = txt(1:ind(end)+length(tag)-1);
% xmls = xml2struct(xml);
% xmls = xmls.Children(1).Children(4).Children.Children(1).Children.Children(2).Children(2);
%</LMSDataContainerHeader>

tag = '<Dimensions>';
ind1 = findstr(txt,tag)+length(tag);
tag = '</Dimensions>';
ind2 = findstr(txt,tag)-1;
txt = txt(ind1:ind2);

tag1 = '<DimensionDescription';
ind1 = findstr(txt,tag1)+length(tag1);
tag2 = '</DimensionDescription';
ind2 = findstr(txt,tag2)-2;

for i=1:length(ind1)
   m='m'; % for unit
   code = [strrep(txt(ind1(i):ind2(i)),' ',['; dd(' num2str(i) ').'] ) ';'];
   code(code=='"') = ''; 
   eval(code);
end



autoloadBioFormats = 1;

% Toggle the stitchFiles flag to control grouping of similarly
% named files into a single dataset based on file numbering.
stitchFiles = 0;

% To work with compressed Evotec Flex, fill in your LuraWave license code.
%lurawaveLicense = 'xxxxxx-xxxxxxx';

% -- Main function - no need to edit anything past this point --

% load the Bio-Formats library into the MATLAB environment
if autoloadBioFormats
    path = fullfile(fileparts(mfilename('fullpath')), 'loci_tools.jar');
    javaaddpath(path);
end

% set LuraWave license code, if available
if exist('lurawaveLicense')
    path = fullfile(fileparts(mfilename('fullpath')), 'lwf_jsdk2.6.jar');
    javaaddpath(path);
    java.lang.System.setProperty('lurawave.license', lurawaveLicense);
end

% check MATLAB version, since typecast function requires MATLAB 7.1+
canTypecast = versionCheck(version, 7, 1);

% check Bio-Formats version, since makeDataArray2D function requires trunk
bioFormatsVersion = char(loci.formats.FormatTools.VERSION);
isBioFormatsTrunk = versionCheck(bioFormatsVersion, 5, 0);

% initialize logging
loci.common.DebugTools.enableLogging('INFO');

r = loci.formats.ChannelFiller();
r = loci.formats.ChannelSeparator(r);
if stitchFiles
    r = loci.formats.FileStitcher(r);
end


r.setMetadataStore(loci.formats.MetadataTools.createOMEXMLMetadata());
r.setId(id);
numSeries = r.getSeriesCount();
result = cell(numSeries);
for s = 1:numSeries
    fprintf('Reading series #%d', s);
    r.setSeries(s - 1);
    
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
        % check methods(r) for more info

        linelength = str2double(r.getSeriesMetadataValue('DimensionDescription|Length'));
        zoom = str2double(r.getSeriesMetadataValue('ATLConfocalSettingDefinition|Zoom'));
        if isnan(zoom)
            zoom = 1;
        end
        if ~strcmp(dd(1).Unit,'m')
            errormsg(['Unknown unit ' dd(1).Unit ]);
        end
        inf.x_step  = dd(1).Length/dd(1).NumberOfElements*1e6;
        inf.x_unit = 'um';
        if ~strcmp(dd(2).Unit,'m')
            errormsg(['Unknown unit ' dd(2).Unit ]);
        end
        inf.y_step  = dd(2).Length/dd(2).NumberOfElements*1e6;
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
            if ~strcmp(dd(3).Unit,'m')
                errormsg(['Unknown unit ' dd(3).Unit ]);
            end
            inf.z_step  = dd(3).Length/dd(3).NumberOfElements*1e6;
            inf.z_unit = 'um';

            inf.third_axis_name = 'z';
        end
    end

    end
    
    

    result{s} = inf;
end

r.close();

inf = result; % to comply with tiffinfo 
if stored
    save(infname,'inf','-mat');
end

return

% -- Helper functions --

function [result] = versionCheck(v, maj, min)

tokens = regexp(v, '[^\d]*(\d+)[^\d]+(\d+).*', 'tokens');
majToken = tokens{1}(1);
minToken = tokens{1}(2);
major = str2num(majToken{1});
minor = str2num(minToken{1});
result = major > maj || (major == maj && minor >= min);
