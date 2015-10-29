function tpstackinfo( record )
%TPSTACKINFO returns an overview with image data
%
%    TPSTACKINFO ( RECORD )
%
% 2013, Alexander Heimel
%

inf = tpreadconfig( record );
if isempty(inf)
    errormsg('No image information found.');
    return;
end

disp(inf);

if isfield(inf,'third_axis_name') && ~isempty(inf.third_axis_name) && lower(inf.third_axis_name(1))=='z'
    zstack = true;
else
    zstack = false;
end

if zstack 
    image_processing.unmixing = 1;
    image_processing.spatial_filter = 1;
else
    image_processing.unmixing = 0;
    image_processing.spatial_filter = 0;
end

% position figure snugly into TP database and record set
h_tp = get_fighandle('TP database*');
ud = get(h_tp,'userdata');
record_pos = get(ud.record_form,'position');

figure ('Name',['Stack info: ' record.mouse filesep record.date filesep record.epoch ],...
    'Position',[record_pos(1)+record_pos(3) record_pos(2)+record_pos(4)-425 806 425],...
    'NumberTitle','off');

axis off;

[y,x]=printtext(tpfilename(record));
try
    imgdate=[ inf(1).ParsedImageDescription.Date,', ', inf(1).ParsedImageDescription.Time];
catch
    imgdate='';
end
[y,x]=printtext(['Date & Time: ' imgdate],y);
[y,x]=printtext(['Width & Height: ' num2str(inf(1).Width),' x ',num2str(inf(1).Height)],y);
if isfield(inf(1),'x_step') && isfield(inf(1),'x_unit') && isfield(inf(1),'y_step')
    [y,x]=printtext(['X,Y Resolution: ' num2str(inf(1).x_step) ' ' inf(1).x_unit ', ' ...
        num2str(inf(1).y_step) ' ' inf(1).y_unit ],y);
end
[y,x]=printtext(['Bits per Sample: ' num2str(inf(1).BitsPerSample)],y);
try
    [y,x]=printtext(['Max-Min Value: ' num2str(inf(1).MaxSampleValue),' - ',num2str(inf(1).MinSampleValue)],y);
end
try
    [y,x]=printtext(['Display, Scan & Start Mode: ' num2str(inf(1).ParsedImageDescription.DisplayMode),', ',num2str(inf(1).ParsedImageDescription.ScanMode),', ',num2str(inf(1).ParsedImageDescription.Scan_Start_Mode)],y);
end

try
    [y,x]=printtext(['Magnification & Zoom: ' num2str(inf.ParsedImageDescription.Magnification),'x, ',num2str(inf.ParsedImageDescription.Zoom_Size) 'x'],y);
    [y,x]=printtext(['Scan Speed (Sec/Line): ' num2str(inf.ParsedImageDescription.Scan_Speed),' (',num2str(inf.ParsedImageDescription.SecondsPerScanLine),')'],y);
    [y,x]=printtext(['PMT1,Gain,Offset: ' num2str(inf.ParsedImageDescription.PMT_Voltage_Ch1),'V, ',num2str(inf.ParsedImageDescription.Gain_Ch1),'x, ',num2str(inf.ParsedImageDescription.Offset_Ch1) '%'],y);
    [y,x]=printtext(['PMT2,Gain,Offset: ' num2str(inf.ParsedImageDescription.PMT_Voltage_Ch2),'V, ',num2str(inf.ParsedImageDescription.Gain_Ch2),'x, ',num2str(inf.ParsedImageDescription.Offset_Ch2) '%'],y);
    [y,x]=printtext(['Gamma 0 & 1: ' num2str(inf.ParsedImageDescription.Gamma_0),' & ',num2str(inf.ParsedImageDescription.Gamma_1)],y);
end
if inf.NumberOfFrames > 1
    switch lower(inf.third_axis_name)
        case 'z'
            [y,x]=printtext(['XYZ: ' num2str(inf.z_step) ' '  inf.third_axis_unit ],y);
        case 't'
            [y,x]=printtext(['XYT: ' num2str(inf.frame_period) ' '  inf.third_axis_unit ],y);
    end
end

try
    [y,x]=printtext(['3D: ' inf.info_3d.name ' ' num2str(inf.info_3d.resolution) ' ' inf.info_3d.unit ],y);
end


if isfield(record.ROIs,'celllist')
    celllist = record.ROIs.celllist;
    header = 'idx,     type,p,neu,int_av,int_mx,  x,  y,  z';
    disp(header);
    for i=1:length(celllist)
        roi = celllist(i);
        row = '';
        if isfield(roi,'index'), row = [row num2str(roi.index,'%03d')];end
        if isfield(roi,'type'), row = [row ',' sprintf('%9s',roi.type)];end
        if isfield(roi,'present'), row = [row ',' num2str(roi.present)];end
        if isfield(roi,'neurite'), row = [row ',' num2str(roi.neurite(1),'%03d')  ];end
        if isfield(roi,'intensity_mean'), row = [row ',  ' sprintf('%4s',num2str(fix(roi.intensity_mean(1))))];end
        if isfield(roi,'intensity_max'), row = [row ',  ' sprintf('%4s',num2str(fix(roi.intensity_max(1))))];end
        if isfield(roi,'xi'), row = [row ',' num2str(fix(mean(roi.xi)),'%03d')  ];end
        if isfield(roi,'yi'), row = [row ',' num2str(fix(mean(roi.yi)),'%03d')  ];end
        if isfield(roi,'zi'), row = [row ',' num2str(fix(mean(roi.zi)),'%03d')  ];end
        
        
        disp( row );
    end
    disp(header);
end
