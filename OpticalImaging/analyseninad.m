%ANALYSENINAD
%
% 2019, Alexander Heimel
logmsg('Add data folder to processparams_local.m');
logmsg('as e.g. params.oidatapath_localroot = ''E:\Dropbox (NIN)\Desktop\Ninad'';');


mouse = 'mouse2';
verbose = false;
rornorm  = true; % normalize by Region of Reference (ROR)
filterwidth = 6; % pixels
n_rows = 4;
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

ind_db = find_record(db,['mouse=' mouse ,',stim_type=retinotopy']);
roi = cell(length(ind_db),1);
avgresponse = cell(length(ind_db),1);

analyse_first_blocks_only = false; %false

for i = 1:length(ind_db)
    record = db(ind_db(i));
   
    if analyse_first_blocks_only
        record.blocks = record.blocks(1:3);
    end
   % record.blocks = 0:3; %15:29
    %record.blocks = 25:29;
%     switch ind_db(i)
%         case 1
%             record.blocks = [0 1 2];
%         case 2
%             record.blocks = [ 3 4 5];
%         case 3
%             record.blocks = [10 11 12];
%     end
    
    
    [orgdata, fileinfo, experimentlist] = oi_read_all_data( record,[],[],verbose);
    
    firststimframe = ceil(record.stim_onset/fileinfo.frameduration);
    laststimframe = ceil(record.stim_offset/fileinfo.frameduration);
    
    baseline_frames = 1:(firststimframe-1); % frames to use for baseline
    response_frames = firststimframe:laststimframe; % frames to use for response
    
    % select stimulus conditions (exclude blanks)
    orgdata = orgdata(:,:,:,:,2:6);
    
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
    
    data = orgdata;
    % normalizing
    for b=1:size(data,4)
        for c=1:size(data,5)
            baseimg = mean(orgdata(:,:,baseline_frames,b,c),3);
            if rornorm % subtract baseline
                for f=1:size(data,3)
                    data(:,:,f,b,c) = orgdata(:,:,f,b,c)./baseimg;
                    data(:,:,f,b,c)=...
                        data(:,:,f,b,c)/sum(sum(rort .* data(:,:,f,b,c))) -1 ;
                end
            else % subtracting baseline
                for f=1:size(data,3) %#ok<UNRCH>
                    data(:,:,f,b,c) = orgdata(:,:,f,b,c)- baseimg;
                end
            end
        end
    end
    
    avgresponse{i} = squeeze(mean(mean(data(:,:,response_frames,:,:),3),4));
    
end %record i
clear('orgdata');


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
        image( (avg(:,:,cond)-avgmin)'/(avgmax - avgmin) *64);
        axis image off
    end
end

% might be better to filter earlier
avg = spatialfilter(avg,filterwidth,'pixel' );

onlinemaps(avg,[],[],[],record);

h = figure('Name','Colormap');
rc = retinotopy_colormap(n_cols,n_rows);
image( reshape( 1:n_cols*n_rows,n_cols,n_rows)')  %image( [1:5;6:10;11:15]);
colormap(rc);axis image off
saveas(h,fullfile(analysispath,'colormap.png'));

imresp = max(-avg,[],3);
imresp = imresp/max(imresp(:));

join_manual_rois = false;
if join_manual_rois
    jointroi = roi{1};
    for i=2:length(roi)
        jointroi = jointroi | roi{i};
    end
else
    jointroi = ( spatialfilter(imresp,2,'pixel')  >0.38)';
    %jointroi = smoothen(jointroi,5)>0.09;
    %figure;imagesc(jointroi);
end

h = plotwta(avg,1:n_rows*n_cols,[],[],find(jointroi'),5,256,record,rc);

% save WTA
record.imagefile = [record.test '_wta.png'];
filename  = fullfile(datapath,'analysis',record.imagefile);
children = get(h,'Children');
img = get(children(1),'Children');
data = get(img,'CData');
data = uint8(round(255*data));
imwrite(data,filename,'Software','analyse_record');
logmsg(['Winner-take-all map saved as: ' filename]);
% save joint ROI
jointroipath = fullfile(analysispath,'jointroi.png');
imwrite(jointroi,jointroipath);

record.test = '*';
record.roifile = 'jointroi.png';
record.bvimage = 'bvimage.tif';
record.stim_parameters = [n_cols n_rows];
results_oitestrecord(record);

refim=double( imread(fullfile(oidatapath(record),record.bvimage)));
jointroi = double(jointroi);
data = double(data);
 refim(:,:,1)=refim(:,:,1).*(1-0.5*jointroi) ;
 refim(:,:,2)=refim(:,:,2).*(1-0.5*jointroi) ;
 refim(:,:,3)=refim(:,:,3).*(1-0.5*jointroi) ;

refim(:,:,1)=refim(:,:,1) + data(:,:,1).*jointroi.*imresp';
refim(:,:,2)=refim(:,:,2) + data(:,:,2).*jointroi.*imresp';
refim(:,:,3)=refim(:,:,3) + data(:,:,3).*jointroi.*imresp';
figure
image(refim/255);
imresppath = fullfile(analysispath,'Overlay.png');
imwrite(refim/255,imresppath);

% response only, with black background
refim=zeros(size(refim));
jointroi = double(jointroi);
data = double(data);
%  refim(:,:,1)=refim(:,:,1).*(1-0.5*jointroi) ;
%  refim(:,:,2)=refim(:,:,2).*(1-0.5*jointroi) ;
%  refim(:,:,3)=refim(:,:,3).*(1-0.5*jointroi) ;

refim(:,:,1)=refim(:,:,1) + data(:,:,1).*jointroi.*imresp';
refim(:,:,2)=refim(:,:,2) + data(:,:,2).*jointroi.*imresp';
refim(:,:,3)=refim(:,:,3) + data(:,:,3).*jointroi.*imresp';
figure
image(refim/255);
imresppath = fullfile(analysispath,'Retinotopy_black_background.png');
imwrite(refim/255,imresppath);


