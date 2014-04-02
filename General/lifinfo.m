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
            errormsg('I am in doubt about the pixel size. Ask Alexander to check this file');
            zoom = 1;
        end
        inf.x_step  =linelength/r.getSizeX/zoom*1e6;
        inf.x_unit = 'um';
        if r.getSizeX~=r.getSizeY
            errormsg('I am in doubt about the pixel size. Ask Alexander to check this file');
        end
        if r.getSizeX~=512 && r.getSizeX~=1024 
            errormsg('I am in doubt about the pixel size. Ask Alexander to check this file');
        end
        inf.y_step  =inf.x_step;
inf.y_unit = inf.x_unit;
    
    if inf.NumberOfFrames > 1
        % more than 1 frame
        if r.getSizeT > 1
            disp('LIFINFO: unknown frame period. Ask Alexander to improve code');
            inf.third_axis_name  = 't';
            inf.third_axis_unit = 'frame'; % i.e. unknown
            inf.frame_period = 1; 
            inf.frame_timestamp = inf.frame_period * (0:(inf.NumberOfFrames-1));
        elseif r.getSizeZ > 1
            errormsg('I am in doubt about the z-step size. Ask Alexander to check this file');
            inf.third_axis_name = 'z';
            stacklength = str2double(r.getSeriesMetadataValue('DimensionDescription|Length'));
            inf.z_step  = stacklength/r.getSizeZ;
            inf.z_unit = 'um';
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
