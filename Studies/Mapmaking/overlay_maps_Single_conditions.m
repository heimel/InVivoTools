%function overlay_maps_Single_conditions
%OVERLAY_MAPS loads intrinsic signal winner-take-all maps and overlays them
%
% 2014, Enny van Beest, Alexander Heimel
%

%persistent db mousedb
%% input
exp = 'enny';
host('daneel')

Check_newBin = 0; % DO you want to plot the different colours when binned again?
Check_ProbMap = 1; %Do you want to plot the probability map?

%%
experiment(exp); % to select for which specific experiment to load the data

if ~exist('mousedb','var') || isempty(mousedb)
    mousedb = load_mousedb;
end

if ~exist('db','var') || isempty(db)
    [db,filename2save] = load_testdb;
end

%Where to save?
savepath{1} = 'C:\Software';
savepath{2} = '\\vs01\MVP\Shared\InVivo\Databases\Enny';
% savepath{3} = getdesktopfolder;

%cd(savepath{1})
mousedb = mousedb(find_record(mousedb,'strain!*BXD*,strain!*DBA*'));
%mousedb = mousedb(find_record(mousedb,['mouse=' exp '.*']));


flag = 0;
%Pre-define or load probability_matrix
if exist('ProbMapV1.mat','file')
    load('ProbMapV1.mat')
else
    Sum_Map = nan(500,500,4); %500 x 500 pixels for all images, 4 for 4 colors start with 800 m
    SumSq_Map = nan(500,500,4);
    AllColSum_Map = nan(500,500);
    AllColSumSq_Map = nan(500,500);
    pixel_nr_map = zeros(500,500); %To count how many maps on that pixel
    nr_map = 1;
    %index of which map is used to overlay
    mapIndx = zeros(1,length(db));
    %On which coordinate is lambda alligned?
    lambd_align = [200 200]; %location [x,y] on figure in binned-pixels
    new_bin = 2; %How many pixels do you want to have binned?
    new_scale = 11.04; %How many micron per pixel?
end

% for m = 1:length(mousedb) % loop over mice - not necessary
ind = find_record(db,['stim_type=retinotopy,reliable!0,hemisphere=left']);
for i = ind(end:-1:1) % loop over tests
    close_figs; % to close non-persistent figures
    h = figure('units','normalized');
    record = db(i);
    
    %If necessary; reset one
    %         if i == 2806
    %             mapIndx(i) = 0;
    %         end
    %
    %Check whether this map is already considered
    if mapIndx(i) == 1
        continue
    else
        mapIndx(i) = 1;
    end
    
    if isempty(record.ref_image) || isempty(record.imagefile)
        continue
    end
    if length(record.stim_parameters)~=2 || ~all(record.stim_parameters==[2 2]) % only do 2x2 maps
        continue
    end
    
    if 1
        if ~strcmpi(record.hemisphere,'left')
            continue
        end
    else
        logmsg('TEMPORARILY NOT SELECTING FOR HEMISPHERE'); %#ok<UNRCH>
    end
    
    if isfield(db(i),'overlay_included') & ~strcmpi(db(i).overlay_included,'yes')
        continue
    end
    
    %     filename = fullfile(oidatapath(record),'analysis',record.imagefile);
    remind = strfind(record.imagefile,'_auto');
    % filename = fullfile(oidatapath(record),'analysis',[record.imagefile]);
    %List all files in folder
    sublist = dir(fullfile(oidatapath(record),[record.imagefile(1:remind-1) 'single*.png']))
    no_pic = 0; %To count nr of pictures missing
    
    for subname = 1:length(sublist)
        filename = fullfile(oidatapath(record),sublist(subname).name);
        clear sort_vec_scale
        if ~exist(filename,'file') || exist(filename,'dir')
            logmsg(['Image ' filename ' does not exist.']);
            no_pic = no_pic+1;
            continue
        end
        
        img = imread(filename);
        if ~isa(img,'uint8')
            logmsg(['Image of ' recordfilter(record) ' is not a uint8.']);
            no_pic = no_pic+1;
            continue
        end
        if subname == 1
            impatch = zeros(size(img,1),size(img,2),4,'uint8'); %Save colours out in one matrix
        end
        
        %Change scale of image - dark values are higher intensity.
        sort_vec_scale(1,:) = unique(sort(img(:),'ascend'));
        sort_vec_scale(2,:) = fliplr(sort_vec_scale(1,:));
        img = changem(img,sort_vec_scale(2,:),sort_vec_scale(1,:));
        
        impatch(:,:,subname) = img;

        %         impatch(:,:,1) = (img(:,:,1)-img(:,:,2)); % red
        %         impatch(:,:,2) = (img(:,:,2)-img(:,:,1)); % green
        %         impatch(:,:,3) = img(:,:,3); % blue
        %         impatch(:,:,4) = img(:,:,1) - impatch(:,:,1); %Yellow
        %         impatch = double(impatch);
        
    end
    
    %if one of the conditions is missing
    if no_pic > 0
        continue
    end
    
    impatch = double(impatch);
   
    win_img =  imread(fullfile(oidatapath(record),'analysis',[record.imagefile]));
    if ~isa(win_img,'uint8')
        logmsg(['Image of ' recordfilter(record) ' is not a uint8.']);
        continue
    end
    
    % lambda is in unbinned pixel coordinates
    % reference image is unbinned (and I assume same scale?)
    [lambda_x,lambda_y,refname] = get_bregma(record);
    if isempty(lambda_x) || isempty(lambda_y)
        continue
    end
    imgref = imread(refname,'bmp'); % unbinned
    
    % convert comma separated lists into cell list of tests
    % e.g. 'mouse_E2,mouse_E3' -> {'mouse_E2','mouse_E3'}
    tests=convert_cst2cell(record.test);
    
    % get image info
    fileinfo=imagefile_info( fullfile(oidatapath(record),...
        [ tests{1} 'B0.BLK']));
    if ~isfield(fileinfo,'xoffset')
        continue
    end
    
    %Coordinates
    xoffset = fileinfo.xoffset; % in unbinned pixels
    yoffset = fileinfo.yoffset; % in unbinned pixels
    xsize = fileinfo.xsize; % in binned pixels
    ysize = fileinfo.ysize; % in binned pixels
    
    % show data
    subplot(3,2,1);
    image(win_img)
    axis image off
    
    subplot(3,2,2);
    imagesc(imgref);
    axis image off
    hold on
    h_lambda = plot(lambda_x,lambda_y,'+r','MarkerSize',10); % plot Lambda
    
    % plot Imaged Region
    line([xoffset xoffset+xsize*fileinfo.xbin xoffset+xsize*fileinfo.xbin xoffset xoffset],...
        [yoffset yoffset yoffset+ysize*fileinfo.ybin yoffset+ysize*fileinfo.ybin yoffset]);
    
    col_names = {'red','green','blue','yellow'};
    colmap = colormap('gray');
    for c=1:4
        subplot(3,2,2+c);
        image(impatch(:,:,c)/255*size(colmap,1));
        axis image off
        title(col_names(c))
    end
    
    %         logmsg('ENNY WORKING HERE ON IMAGE OVERLAYING');
    %         pause
    logmsg(['Record: ' record.date ' ' record.test])
    
    %Check whether lambda is at proper location
    db(i).experimenter
    if isempty(db(i).lambda)
        LF = figure;
        
        imagesc(imgref);
        axis image off
        hold on
        h_lambda = plot(lambda_x,lambda_y,'+r','MarkerSize',10); % plot Lambda
        
        % plot Imaged Region
        line([xoffset xoffset+xsize*fileinfo.xbin xoffset+xsize*fileinfo.xbin xoffset xoffset],...
            [yoffset yoffset yoffset+ysize*fileinfo.ybin yoffset+ysize*fileinfo.ybin yoffset]);
        
        colmap = colormap('gray');
        
        disp('Lambda at proper location? (y/n)');
        %             set(h,'outerposition',[0 0 1 1])
        
        k = waitforbuttonpress;
        correct_lambd = get(gcf,'currentcharacter');
        while ~strcmpi(correct_lambd,'y')
            [lambda_x lambda_y] = ginput(1);
            delete(h_lambda);
            h_lambda = plot(lambda_x,lambda_y,'+r','MarkerSize',10); % plot Lambda
            disp('Lambda at proper location? (y/n)');
            k = waitforbuttonpress;
            correct_lambd = get(gcf,'currentcharacter');
        end
        close(LF)
        disp('Are you sure about this position? (y/n)')
        k = waitforbuttonpress;
        certainty = get(gcf,'currentcharacter');
    else
        lambda_x = db(i).lambda.x;
        lambda_y = db(i).lambda.y;
        display('Lambda already confirmed')
    end
    
    set(h,'OuterPosition',[0.25 0.25 0.6 0.6])
    
    %Whether to include this map into the average?
    if isempty(db(i).overlay_included)
        button_correctlypressed = 0;
        while button_correctlypressed ~= 1
            disp('Include this map in average map? (y/n/m) for yes/no/maybe')
            k = waitforbuttonpress;
            incl = get(gcf,'currentcharacter');
            if strcmpi(incl,'y')
                button_correctlypressed = 1;
                db(i).overlay_included = 'yes';
            elseif strcmpi(incl,'n')
                button_correctlypressed = 1;
                db(i).overlay_included = 'no';
            elseif strcmpi(incl,'m')
                button_correctlypressed = 1;
                db(i).overlay_included = 'maybe'
            else
                disp('Wrong button')
            end
        end
    end
    
    
    %If you do not want to include this map, continue to the next
    if ~strcmpi(db(i).overlay_included,'yes');
        continue
    end
    
    %Current Bin Size & Scale
    Cur_scale = record.scale;
    Cur_xbin = fileinfo.xbin;
    Cur_ybin = fileinfo.ybin;
    
    %Now lambda is checked, determine position of lambda to left corner
    %of imaged region
    yshift = (((yoffset - lambda_y)*Cur_scale)/new_scale)/new_bin; %in
    xshift = (((xoffset - lambda_x)*Cur_scale)/new_scale)/new_bin;
    
    % xshift + new lambda location is new offset for imaged region
    new_xoffset = round(xshift + lambd_align(1)); %already in new bins
    new_yoffset = round(yshift + lambd_align(2)); %already in new bins
    
    %Convert to new scale & binsize
    if exist('ProbMapV1.mat','file') %if Already a current map exists,
        % nr_rows  and nr_cols should be the same
        fprintf('Number or rows %.0f and columns %.0f\n',nr_row,nr_col)
    else
        %Or calculate nr_rows & cols needed
        nr_row = round(((ysize*Cur_ybin*Cur_scale)/(new_scale))/new_bin); %ysize times bin gives nr pixels. Times scale gives total amount of micron
        nr_col = round(((xsize*Cur_xbin*Cur_scale)/(new_scale))/new_bin); %Divided by new scale gives new amount of pixels needed. This is what you bin in the new bin gives needed amount of rows and columns
    end
    % Alexander: nice routine below, but did you consider IMRESIZE?
    GSized_impatch = imresize(impatch,[nr_row nr_col]);
    
    %Check:
    if Check_newBin == 1
        figure
        for c=1:4
            subplot(2,2,c);
            image(GSized_impatch(:,:,c)/255*size(colmap,1));
            axis image off
        end
        colmap = colormap('gray');
    end
    
    %Normalize GSized_impatch colours from 0 to 1
    Norm_impatch = (GSized_impatch - min(GSized_impatch(:)))/(max(GSized_impatch(:)) - min(GSized_impatch(:)));
    
    %Now every image has to shift that amount in the ColorMatPerMouse
    new_Fig = nan(size(Sum_Map,1),size(Sum_Map,2),size(Sum_Map,3));
    new_Fig([new_yoffset:new_yoffset+size(Norm_impatch,1)-1],[new_xoffset:new_xoffset+size(Norm_impatch,2)-1],:) = Norm_impatch;
    pixel_nr_map([new_yoffset:new_yoffset+size(Norm_impatch,1)-1],[new_xoffset:new_xoffset+size(Norm_impatch,2)-1]) = pixel_nr_map([new_yoffset:new_yoffset+size(Norm_impatch,1)-1],[new_xoffset:new_xoffset+size(Norm_impatch,2)-1])+1;
    
    %nansum makes 0 of sum of 2 nans. You don't want that
    NanMat = isnan(new_Fig) + isnan(Sum_Map);
    
    %Maps to save
    Sum_Map = nansum(cat(4,Sum_Map,new_Fig),4); %nansum up every map
    Sum_Map(NanMat>1) = NaN;
    
    NanMat = isnan(new_Fig) + isnan(SumSq_Map);
    SumSq_Map = nansum(cat(4,SumSq_Map,new_Fig.^2),4); %To calculate the std later
    SumSq_Map(NanMat>1) = NaN; %Bring back the Nans
    
    Mean_Map = Sum_Map./repmat(pixel_nr_map,[1 1 4]); %Mean map
    std_Map = (SumSq_Map)./repmat(pixel_nr_map,[1 1 4]) - (Mean_Map.^2); %std map
    %Nan should only be removed when in both cases no nan...
    
    NanMat = isnan(AllColSum_Map) + isnan(new_Fig(:,:,1))+isnan(new_Fig(:,:,2))+isnan(new_Fig(:,:,3))+isnan(new_Fig(:,:,4));
    
    % Same for All colors together
    AllColSum_Map = nansum(cat(3,AllColSum_Map,nansum(Sum_Map,3)),3);
    AllColSum_Map(NanMat>4) = NaN;
    
    NanMat = isnan(AllColSumSq_Map) +  isnan(new_Fig(:,:,1))+isnan(new_Fig(:,:,2))+isnan(new_Fig(:,:,3))+isnan(new_Fig(:,:,4));
    AllColSumSq_Map = nansum(cat(3,AllColSumSq_Map,new_Fig.^2),3);
    AllColSumSq_Map(NanMat>4) = NaN;
    
    All_Col_meanMap = AllColSum_Map./pixel_nr_map;
    All_Col_stdMap = AllColSumSq_Map./pixel_nr_map - (All_Col_meanMap.^2);
    
    Mapnames = {'Sum_Map','Mean_Map','AllColSum_Map','All_Col_meanMap'};
    
    nr_map
    nr_map = nr_map+1;
    
    % If checked, put in record
    db(i).lambda.x = lambda_x;
    db(i).lambda.y = lambda_y;
    db(i).new_bin = new_bin;
    db(i).new_scale = new_scale;
    if isempty(db(i).Lambda_certainty)
        db(i).Lambda_certainty = certainty;
    end
    
    
    % saving is slow, probably better to move save_db to after the for
    % loops and make it possible to break out.
    flag = flag + 1;
    %Save Database every 15
    if flag == 5
        rmlock(filename2save); % a little unsafe
        disp('Saving...')
        save_db(db,filename2save)
        
        flag = 0;
        
        %Check probability maps?
        if Check_ProbMap == 1
            for mp = [2,4] %only sum and mean_map
                figure
                map2plot = eval(Mapnames{mp});
                least_maps = floor(nr_map*0.2); %nr of maps at least needed for pixel to be shown in map (10%)
                NaNMat = repmat((pixel_nr_map<least_maps),[1 1 size(map2plot,3)]);
                map2plot(NaNMat) = NaN;
                
                for ccl = 1:size(map2plot,3)
                    subplot(ceil(size(map2plot,3)/2),ceil(size(map2plot,3)/2),ccl)
                    imagescnan(map2plot(:,:,ccl))
                    hold on
                    plot(lambd_align(1),lambd_align(2),'+r','Markersize',10)
                    if mp == 3 || mp == 4
                        colorbar
                    end
                end
                %                 colmap = colormap('gray');
                
                suplabel(Mapnames{mp},'t');
                
            end
        end
        
        %             disp('Press button to continue')
        %             pause
    end
    %Save Probability map and mapIndx
    for sp = 1:length(savepath)
        if exist(savepath{sp},'dir')
            save(fullfile(savepath{sp},'ProbMapV1'),'All_Col_meanMap','All_Col_stdMap','AllColSum_Map','AllColSumSq_Map','Sum_Map','SumSq_Map','Mean_Map','std_Map','mapIndx','nr_map','new_bin','nr_row','nr_col','lambd_align','new_scale','pixel_nr_map')
        end
    end
    
end % test i



