%ANALYSENINAD
%
% 2019, Alexander Heimel

logmsg('Add data folder to processparams_local.m');
logmsg('as e.g. params.oidatapath_localroot = ''E:\Dropbox (NIN)\Desktop\Ninad'';');

record.mouse = '';
record.test = 'led_E0';
record.blocks = 15;
record.datatype = 'oi';
record.setup = 'ninad';
record.date = '';
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

% record = analyse_oitestrecord(record);
% results_oitestrecord(record);

n_blocks = 2;
n_rows = 3;
n_cols = 5;

if ~exist('orgdata','var') || isempty(orgdata)
    orgdata = zeros(408,300,80,n_blocks,n_rows*7);

    b = 1;
    record.blocks = 15;
    orgdata(:,:,:,b,1:7) = oi_read_all_data(record);
    
    record.blocks = 16;
    orgdata(:,:,:,b,8:14) = oi_read_all_data(record);
    
    record.blocks = 17;
    orgdata(:,:,:,b,15:21) = oi_read_all_data(record);
    
    b = 2;
    record.blocks = 15;
    orgdata(:,:,:,b,1:7) = oi_read_all_data(record);
    
    record.blocks = 16;
    orgdata(:,:,:,b,8:14) = oi_read_all_data(record);
    
    record.blocks = 17;
    orgdata(:,:,:,b,15:21) = oi_read_all_data(record);
    
    
    % select stimulus conditions (exclude blanks)
    orgdata = orgdata(:,:,:,:,[2:6 9:13 16:20]);
end

% load ROR
datapath=experimentpath( record);
analysispath=fullfile(datapath,'analysis');
rorfile = fullfile(analysispath,record.rorfile);
ror = double(imread(rorfile));


% load ROI
roifile = fullfile(analysispath,record.roifile);
roi = double(imread(roifile));

rornorm  = true; % normalize by Region of Reference (ROR)
baseline_frames = 1:9;
response_frames = 10:80; % frames to use for response
filterwidth = 4; % pixels

data = orgdata;
if rornorm
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

avgresponse = squeeze(mean(mean(data(:,:,response_frames,1,:),3),4));
if ~rornorm
    baseline_frames = 1:9;
    avgbaseline = squeeze(mean(mean(data(:,:,baseline_frames,1,:),3),4));
    avg = avgresponse - avgbaseline ;
else
    avg = avgresponse;
end

avg = spatialfilter(avg,filterwidth,'pixel' );

% onlinemaps(avg,[],[],[],record);

figure('Name','Colormap');
rc = retinotopy_colormap(n_cols,n_rows);
image( [1:5;6:10;11:15]);
colormap(rc);axis image off

h = plotwta(avg,1:n_rows*n_cols,[],0,find(roi'),5,256,record,rc);
set(h,'Name','Retinotopy');


