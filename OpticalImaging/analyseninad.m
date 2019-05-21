%ANALYSENINAD
%
% 2019, Alexander Heimel

logmsg('Add data folder to processparams_local.m');
logmsg('as e.g. params.oidatapath_localroot = ''E:\Dropbox (NIN)\Desktop\Ninad'';');

dbname = fullfile(getdesktopfolder,'testdb_pracownia.mat');
if ~exist(dbname,'file')
    dbname = 'E:\Dropbox (NIN)\Desktop\Ninad\testdb_pracownia.mat';
end
load(dbname);
if exist('db','var')
    record = db(1);
else
record.mouse = '';
record.test = 'led_E0';
record.blocks = 15;
record.datatype = 'oi';
record.setup = 'ninad';
record.date = '2018-09-30';
record.stim_type = 'retinotopy';
record.comment = '';
record.imagefile = '';
record.roifile = 'led_E0_roi_c1.png';
record.rorfile = 'led_E0_ror_c1.png';
record.stim_onset = 10;
record.stim_offset = 80;
record.stim_parameters = [1 7];
record.ref_image = '';
record.response = [];
record.hemisphere = '';
record.scale = 8;
record.experimenter = 'ninad';
end


record.test = 'mouse5_r1';
record.blocks = 13;


datapath=experimentpath( record);
analysispath=fullfile(datapath,'analysis');
rorfile = fullfile(analysispath,record.rorfile);
if ~exist(rorfile,'file') % draw ROR
    logmsg('Analzying for redrawing ROR')
    record.roifile = '';
    record.rorfile = '';
    record = analyse_oitestrecord(record);
    results_oitestrecord(record);
end

n_rows = 3;
n_cols = 5;
rornorm  = false; % normalize by Region of Reference (ROR)
baseline_frames = 1:9; % frames to use for baseline
response_frames = 10:80; % frames to use for response
filterwidth = 4; % pixels

orgdata = [];
n_blocks = 2;

verbose = false;
if ~exist('orgdata','var') || isempty(orgdata)
    logmsg('Loading data');
    orgdata = zeros(408,300,80,n_blocks,n_rows*7);
    
    % row 1
    record.test = 'mouse5_r1';
    record.blocks = 13;
    orgdata(:,:,:,1,1:7) = oi_read_all_data(record,[],[],verbose);

    record.test = 'mouse5_r1';
    record.blocks = 14;
    orgdata(:,:,:,2,1:7) = oi_read_all_data(record,[],[],verbose);
    
    % row 2
    record.test = 'mouse5_r2';
    record.blocks = 17;
    orgdata(:,:,:,1,8:14) = oi_read_all_data(record,[],[],verbose);

    record.test = 'mouse5_r2';
    record.blocks = 18;
    orgdata(:,:,:,2,8:14) = oi_read_all_data(record,[],[],verbose);
        
    % row 3
    record.test = 'mouse5_r3';
    record.blocks = 15;
    orgdata(:,:,:,1,15:21) = oi_read_all_data(record,[],[],verbose);

    record.test = 'mouse5_r3';
    record.blocks = 19;
    orgdata(:,:,:,2,15:21) = oi_read_all_data(record,[],[],verbose);
        
    
    % select stimulus conditions (exclude blanks)
    orgdata = orgdata(:,:,:,:,[2:6 9:13 16:20]);
end

% selecting first block only
%orgdata = orgdata(:,:,:,2,:);

% load ROR
datapath=experimentpath( record);
analysispath=fullfile(datapath,'analysis');
rorfile = fullfile(analysispath,record.rorfile);
logmsg(['Loading ROR: ' rorfile]);
ror = double(imread(rorfile));

% load ROI
roifile = fullfile(analysispath,record.roifile);
logmsg(['Loading ROI: ' roifile]);
roi = double(imread(roifile));


data = orgdata;
if rornorm
    logmsg('Normalizing by region of reference'); %#ok<*UNRCH>
    rort = ror'/sum(ror(:));
    for b=1:size(data,4)
        for c=1:size(data,5)
            baseimg = mean(orgdata(:,:,baseline_frames,b,c),3);
            for f=1:size(data,3)
                %  data(:,:,f,1,c) = orgdata(:,:,f,1,c) - orgdata(:,:,9,1,c);
                data(:,:,f,b,c) = orgdata(:,:,f,b,c)./baseimg;
                data(:,:,f,b,c)=...
                    data(:,:,f,b,c)/sum(sum(rort .* data(:,:,f,b,c))) -1 ;
            end
        end
    end
end

avgresponse = squeeze(mean(mean(data(:,:,response_frames,:,:),3),4));

if 0 % show raw average data
    figure;
    for y=1:n_rows
        for x=1:n_cols
            cond = (y-1)*n_cols+x;
            subplot(n_rows,n_cols,cond);
            imagesc( avgresponse(:,:,cond) );
            colorbar
            axis image off
        end
    end
end


% show raw data normalized to same factors
avgmax = max(avgresponse(:));
avgmin = min(avgresponse(:));
figure;
for y=1:n_rows
    for x=1:n_cols
        cond = (y-1)*n_cols+x;
        subplot(n_rows,n_cols,cond);
        image( (avgresponse(:,:,cond)-avgmin)/(avgmax - avgmin) *64);
    end
end

if ~rornorm
    baseline_frames = 1:9;
    avgbaseline = squeeze(mean(mean(data(:,:,baseline_frames,:,:),3),4));
    avg = avgresponse - avgbaseline ;
else
    avg = avgresponse;
end


% show normalized data normalized to same factors
avgmax = max(avg(:));
avgmin = min(avg(:));
figure;
for y=1:n_rows
    for x=1:n_cols
        cond = (y-1)*n_cols+x;
        subplot(n_rows,n_cols,cond);
        image( (avg(:,:,cond)-avgmin)/(avgmax - avgmin) *64);
        axis image off
    end
end



avg = spatialfilter(avg,filterwidth,'pixel' );

onlinemaps(avg,[],[],[],record);

figure('Name','Colormap');
rc = retinotopy_colormap(n_cols,n_rows);
image( [1:5;6:10;11:15]);
colormap(rc);axis image off

h = plotwta(avg,1:n_rows*n_cols,[],0,find(roi'),5,256,record,rc);

% save WTA
record.imagefile = [record.test '_wta.png'];
filename  = fullfile(datapath,'analysis',record.imagefile);
    children = get(h,'Children');
                img = get(children(1),'Children');
                data = get(img,'CData');
                data = uint8(round(255*data));
                imwrite(data,filename,'Software', ...
                    'analyse_record');
logmsg(['Winner-take-all map saved as: ' filename]);

record.test = 'mouse5_r1';
record.blocks = 13;
record.stim_parameters = [5 3];
%record.roifile = '';

results_oitestrecord(record);
