function record  = analyse_lstestrecord( record )
% tp_analyze_linescan
%    analyze one two photon linescan
%
%  RECORD = ANALYSE_LSTESTRECORD( RECORD )
%
% 2010-2011, Alexander Heimel
%

disp('ANALYSE_LSTESTRECORD: started');

% use default processparams
record.process_params = tpprocessparams( 'event_detection' );

% run precommands
eval( record.precommands);

% expand epoch range to comma separated list
p = find(record.epoch=='-');
if length(p) == 1
    first = str2double(record.epoch(1:p-1));
    last = str2double(record.epoch(p+1:end));
    record.epoch = num2str(first,'%02d');
    for i = first+1:last
        record.epoch = [record.epoch ',' num2str(i,'%02d')];
    end
end

epochs = split(record.epoch,',');

data = [];
for i=1:length(epochs)
    single_record = record;
    single_record.epoch = epochs{i};
    [datapath,basename] = fileparts( tpfilename(single_record) ) ;
    matfile = fullfile( datapath, [ basename '_compressed_' num2str(single_record.compression) 'x.mat']);
    if exist(matfile,'file')
        single_record_data = load(matfile,'-mat');
    else
        opwd = pwd;
        cd(  tpdatapath(single_record) );
        convert_linescan2mat( tpfilename(single_record), single_record.linescan_period, single_record.compression);
        single_record_data = load(matfile,'-mat');
        cd(opwd);
    end
    if isempty(data)
        data = single_record_data;
    else
        data.full_image = [data.full_image; single_record_data.full_image];
    end
end

disp('ANALYSE_LSTESTRECORD: loaded data');


params.linescan_period = data.compressed_linescan_period;

%disp(['Compressed linescan period = ' num2str(params.linescan_period) ' s']);

% pixelscale
unitwidth = 5;

% calculated mean across time
mean_line = mean( data.full_image, 1);

% smoothen mean line
mean_line = smooth(mean_line, unitwidth)';

% find cells by doing peak detection
% find centers
[p,center_ind] = findpeaks(mean_line,'minpeakdistance',unitwidth,'minpeakheight',median(mean_line));
while center_ind(1)<unitwidth
    center_ind = center_ind(2:end);
end
while center_ind(end) > size(mean_line,2)-unitwidth
    center_ind = center_ind(1:end-1);
end
n_cells = length(center_ind);

dmean_line = diff(mean_line);

[p,rise_ind] = findpeaks(dmean_line);
[p,fall_ind] = findpeaks(-dmean_line);

left_ind = 0*center_ind;
right_ind = 0*center_ind;

% find maximum slope to the left and right of each peak
% construct cell index list
for i = 1:n_cells
    left = rise_ind(find( rise_ind< center_ind(i)-unitwidth/2,1,'last'));
    if isempty(left)
        left = 1;
    end
    left_ind(i) = left;
    right = fall_ind(find( fall_ind> center_ind(i)+unitwidth/2,1,'first'));
    if isempty(right)
        right = size(mean_line,2);
    end
    right_ind(i) = right;
    cell_ind{i}=(left_ind(i):right_ind(i));
end


if record.process_params.output_show_figures
    figure('Name','Raw image','numbertitle','off');
    hold on
    height = 400;
    mean_line = mean_line/max(mean_line)*height;
    plot(mean_line);
    imagesc(data.full_image(round(linspace(1,end,height)),:))
    plot(mean_line,'k','linewidth',3);
    plot(center_ind,mean_line(center_ind),'or');
    plot(left_ind,mean_line(left_ind),'vr');
    plot(right_ind,mean_line(right_ind),'^r');
    axis image off
    colormap gray
    saveas(gcf,[basename '_linescan_cells.png'],'png');
end


% read track info
trackrecord = record;
trackrecord.epoch = record.trackepoch;
trackname = tpfilename( trackrecord );
if ~exist(trackname,'file')
    error(['ANALYSE_LSTESTRECORD: cannot find track ' trackname ]);
end

trkimg = imread(trackname);
if size(trkimg,3) == 4
    trkimg = trkimg(:,:,1:3);
end

params.lines_per_frame = size(trkimg, 1);
params.pixels_per_line = size(trkimg, 2);
%disp(['Pixels per line = ' num2str(params.pixels_per_line)]);
%disp(['Lines per frame = ' num2str(params.lines_per_frame)]);
if ~isempty(record.track_x)
    x = record.track_x;
    y = record.track_y;
    new_curve = false;
else
    figure('name','Scan track','numbertitle','off');
    imagesc(trkimg);
    axis image
    axis off
    colormap gray
    size(trkimg)
    [x,y]=trace_curve(gcf,1);
    disp(['x = ' mat2str(fix(x))]);
    disp(['y = ' mat2str(fix(y))]);
    new_curve = true;
end
total_distance = compute_distance(x,y);
total_pixel_distance = size(data.full_image,2);

pixel_position = zeros(total_pixel_distance,2);
start_distance(1) = 0;
for i=2:length(x)
    start_distance(i) =start_distance(i-1) + compute_distance( [x(i-1);x(i)],[y(i-1);y(i)]);
end
start_distance(length(x)+1) = total_distance;
for i = 1:(length(x)-1)
    ind = 1+round( start_distance(i)/total_distance * total_pixel_distance):round( start_distance(i+1)/total_distance * total_pixel_distance);
    pixel_position(ind,1) = round(linspace( x(i),x(i+1),length(ind))');
    pixel_position(ind,2) = round(linspace( y(i),y(i+1),length(ind))');
end
pixelind2d =  sub2ind( size( trkimg ), pixel_position(:,2),pixel_position(:,1));

if size(trkimg,3)==3
    trkimg = trkimg(:,:,1);
end
im = trkimg;

imtrack = zeros(size(im,1),size(im,2));
for c = 1:length(cell_ind)
    temp_imtrack = zeros(size(im,1),size(im,2));
    cell_ind2d{c} = pixelind2d( cell_ind{c} );
    temp_imtrack(cell_ind2d{c}) = 1;
    temp_imtrack = conv2(temp_imtrack,ones(4),'same');
    temp_imtrack(temp_imtrack>0.01) = 1;
    cell_ind2d{c} = find(temp_imtrack);
    imtrack(cell_ind2d{c}) = 1;
end

mm = max(double(trkimg(:)));
im(logical(imtrack)) = min(mm,im(logical(imtrack))*5);

if record.process_params.output_show_figures% && new_curve
    figure

    imrgb(:,:,1) = double(trkimg)/mm;
    imrgb(:,:,2) = double(trkimg)/mm;
    imrgb(:,:,3) = double(im)/mm;
    image(imrgb); axis image off; colormap gray
    line(x,y);
    saveas(gcf,[basename '_track_cells.png'],'png');
end


% now calculate cell data in format to fit other twophoton analysis
% routines, i.e. MxN cell list, where M is number of measured intervals
% and
frametimes = params.linescan_period * (0:size(data.full_image,1)-1)';
for i=1:n_cells
    raw_data{1,i} = mean( data.full_image(:,cell_ind{i}),2);
    raw_t{1,i} = frametimes;
end
%disp('TP_ANALYZE_LINESCAN: should take into account finite scanperiod');

listofcells = cell_ind2d;
listofcellnames = {};

disp('ANALYSE_LSTESTRECORD: plotting data');


% plot raw data
if record.process_params.output_show_figures
    record.process_params.method = 'none';
    tpplotdata( raw_data, raw_t, listofcells, listofcellnames, params,record.process_params, record.timeint,'Raw data');
end

% for AMam54 was filter window width was 200 samples, i.e. 200*0.02s = 4s

disp('ANALYSE_LSTESTRECORD: detecting events');

params.micron_per_pixel = record.micron_per_pixel;
record.process_params.method = 'event_detection';

% process data
[processed_data, processed_t] = tpsignalprocess(record.process_params, raw_data, raw_t);
if record.process_params.output_show_figures
    tpplotdata( processed_data, processed_t, listofcells, listofcellnames, params,record.process_params, record.timeint,'Events');
end

if 0 && record.process_params.output_show_figures
    % show cell responses for each event
    plot_params.what = 'amplitude';
    tpshowevents( processed_data, processed_t, listofcells, listofcellnames, params,record.process_params, record.timeint,plot_params);
end

if 0 && record.process_params.output_show_figures
    % show cell times for each event
    plot_params.what = 'time';
    tpshowevents( processed_data, processed_t, listofcells, listofcellnames, params,record.process_params, record.timeint,plot_params);
    saveas(gcf,[basename '_timemap.png'],'png');
end

disp('ANALYSE_LSTESTRECORD: analyze patterns');

% spatial analysis
result = analyze_tppatterns('event_statistics', processed_data, processed_t, listofcells, listofcellnames, params,record.process_params, record.timeint );
save(fullfile(datapath,[basename '_analysis.mat']),'result', 'processed_data', 'processed_t', 'listofcells', 'listofcellnames', 'params','record' );

% correlation analysis
%result = analyze_tppatterns('correlation', processed_data, processed_t, listofcells, listofcellnames, params,record.process_params, record.timeint );

% cluster cells and events
%result = analyze_tppatterns('cluster', processed_data, processed_t, listofcells, listofcellnames, params,record.process_params, record.timeint );

if strcmp(record.experiment(1:4),'AMam') && ...  % i.e. friederike's
        str2double(record.experiment(5:6))<75 % old direction settings
    disp('ANALYSE_LSTESTRECORD: rotating and mirroring direction');

    result.direction = -result.direction+pi/2;
   result.shuffled_direction = -result.shuffled_direction+pi/2;
    
end

record.measures = result;

record.analysed = [user ', ' datestr(now,31) ];

disp('ANALYSE_LSTESTRECORD: finished');

return

function d = compute_distance(x,y)
if length(x)>2
    d = compute_distance( x(1:2),y(1:2)) + compute_distance( x(2:end),y(2:end));
    return
end
d = sqrt( (x(2)-x(1))^2) + sqrt( (y(2)-y(1))^2);
