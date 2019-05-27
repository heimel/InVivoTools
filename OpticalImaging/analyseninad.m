%ANALYSENINAD
%
% 2019, Alexander Heimel
logmsg('Add data folder to processparams_local.m');
logmsg('as e.g. params.oidatapath_localroot = ''E:\Dropbox (NIN)\Desktop\Ninad'';');


mouse = 'mouse4';
verbose = false;
rornorm  = true; % normalize by Region of Reference (ROR)
filterwidth = 6; % pixels
n_rows = 3;
n_cols = 5;

dbname = fullfile(getdesktopfolder,'testdb_pracownia.mat');
if ~exist(dbname,'file')
    dbname = 'E:\Dropbox (NIN)\Desktop\Ninad\testdb_pracownia.mat';
end

if exist(dbname,'file')
    load(dbname);
else
    db.mouse = '';
    db.test = 'led_E0';
    db.blocks = 15;
    db.datatype = 'oi';
    db.setup = 'ninad';
    db.date = '2018-09-30';
    db.stim_type = 'retinotopy';
    db.comment = '';
    db.imagefile = '';
    db.roifile = 'led_E0_roi_c1.png';
    db.rorfile = 'led_E0_ror_c1.png';
    db.stim_onset = 10;
    db.stim_offset = 80;
    db.stim_parameters = [1 7];
    db.ref_image = '';
    db.response = [];
    db.hemisphere = '';
    db.scale = 8;
    db.experimenter = 'ninad';
end

ind_db = find_record(db,['mouse=' mouse ,'stim_type=retinotopy']);
orgdata = cell(length(ind_db),1);
roi = cell(length(ind_db),1);
avgresponse = cell(length(ind_db),1);

for i = 1:length(ind_db)
    record = db(ind_db(i));
    
    [orgdata{i}, fileinfo, experimentlist] = oi_read_all_data( record,[],[],verbose);
    
    
    firststimframe = ceil(record.stim_onset/fileinfo.frameduration);
    laststimframe = ceil(record.stim_offset/fileinfo.frameduration);
    
    baseline_frames = 1:(firststimframe-1); % frames to use for baseline
    response_frames = firststimframe:laststimframe; % frames to use for response
  
    % select stimulus conditions (exclude blanks)
    orgdata{i} = orgdata{i}(:,:,:,:,2:6);
    
    % load ROR
    datapath = experimentpath( record);
    analysispath = fullfile(datapath,'analysis');
    rorfile = fullfile(analysispath,record.rorfile);
    if ~exist(rorfile,'file') % draw ROR
        logmsg('No ROR. Reanalzying for redrawing ROR')
        record.rorfile = '';
        record = analyse_oitestrecord(record);
    end
    logmsg(['Loading ROR: ' rorfile]);
    ror = double(imread(rorfile));
    rort = ror'/sum(ror(:));
    
    % load ROI
    roifile = fullfile(analysispath,record.roifile);
    logmsg(['Loading ROI: ' roifile]);
    roi{i} = double(imread(roifile));
    
    data = orgdata{i};
    % normalizing
    for b=1:size(data,4)
        for c=1:size(data,5)
            baseimg = mean(orgdata{i}(:,:,baseline_frames,b,c),3);
            if rornorm % subtract baseline 
                for f=1:size(data,3)
                    data(:,:,f,b,c) = orgdata{i}(:,:,f,b,c)./baseimg;
                    data(:,:,f,b,c)=...
                        data(:,:,f,b,c)/sum(sum(rort .* data(:,:,f,b,c))) -1 ;
                end
            else % subtracting baseline
                for f=1:size(data,3) %#ok<UNRCH>
                    data(:,:,f,b,c) = orgdata{i}(:,:,f,b,c)- baseimg;
                end
            end
        end
    end
    
    avgresponse{i} = squeeze(mean(mean(data(:,:,response_frames,:,:),3),4));
    
end %record i

n_conditions =  size(avgresponse{1},3) * length(avgresponse);
avg = zeros( size(avgresponse{1},1),  size(avgresponse{1},2), n_conditions);
for i = 1:length(avgresponse)
    avg(:,:,(i-1)*size(avgresponse{1},3) + (1:size(avgresponse{1},3)) ) = avgresponse{i};
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

% might be better to filter earlier
avg = spatialfilter(avg,filterwidth,'pixel' );

onlinemaps(avg,[],[],[],record);

h = figure('Name','Colormap');
rc = retinotopy_colormap(n_cols,n_rows);
image( [1:5;6:10;11:15]);
colormap(rc);axis image off
saveas(h,fullfile(analysispath,'colormap.png'));


 jointroi = roi{1};
 for i=2:length(roi)
     jointroi = jointroi | roi{i};
 end

% jointroi = ( spatialfilter( max(-avg,[],3),2,'pixel')  >0.0006)';
% jointroi = smoothen(jointroi,5)>0.5;
% figure;imagesc(jointroi);

h = plotwta(avg,1:n_rows*n_cols,[],[],find(jointroi'),5,256,record,rc);

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

jointroipath = fullfile(analysispath,'jointroi.png'); 
imwrite(jointroi,jointroipath);
record.roifile = 'jointroi.png';
record.stim_parameters = [5 3];

results_oitestrecord(record);
