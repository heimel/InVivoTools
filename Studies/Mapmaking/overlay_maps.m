%function overlay_maps
%OVERLAY_MAPS loads intrinsic signal winner-take-all maps and overlays them
%
% 2014, Enny van Beest, Alexander Heimel
%

%persistent db mousedb
%% input
exp = 'enny';
host('daneel')

%On which coordinate is lambda alligned?
lambd_allign = [20 20]; %location [x,y] on figure in binned-pixels

new_bin = 6; %How many pixels do you want to have binned?
new_scale = 11.04; %How many micron per pixel?
Check_newBin = 1; % DO you want to plot the different colours when binned again?
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
savepath{1} = 'C:\Software\';
savepath{2} = '\\vs01\MVP\Shared\InVivo\Databases\Enny\';

cd(savepath{1})

mousedb = mousedb(find_record(mousedb,'strain!*BXD*,strain!*DBA*'));
%mousedb = mousedb(find_record(mousedb,['mouse=' exp '.*']));

close_figs; % to close non-persistent figures
figure;

%Pre-define or load probability_matrix
if exist('ProbMapV1.mat')
    load('ProbMapV1.mat')
else
    ProbMapV1_Matr = nan(125,125,4,800); %125x125 pixels for all images, 4 for 4 colors start with 800 maps
    nr_map = 1;
    %index of which map is used to overlay
    mapIndx = zeros(1,length(db));
end

for m = 1:length(mousedb) % loop over mice
    ind = find_record(db,['mouse=' mousedb(m).mouse ',stim_type=retinotopy,reliable!0']);
    for i = ind % loop over tests
        
        record = db(i);
        
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
        
        filename = fullfile(oidatapath(record),'analysis',record.imagefile);
        if ~exist(filename,'file') || exist(filename,'dir')
            logmsg(['Image ' filename ' does not exist.']);
            continue
        end
        img = imread(filename);
        if ~isa(img,'uint8')
            logmsg(['Image of ' recordfilter(record) ' is not a uint8.']);
            continue
        end
        impatch = zeros(size(img,1),size(img,2),4,'uint8');
        impatch(:,:,1) = (img(:,:,1)-img(:,:,2)); % red
        impatch(:,:,2) = (img(:,:,2)-img(:,:,1)); % green
        impatch(:,:,3) = img(:,:,3); % blue
        impatch(:,:,4) = img(:,:,1) - impatch(:,:,1); %Yellow
        impatch = double(impatch);
        
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
        image(img)
        axis image off
        
        subplot(3,2,2);
        imagesc(imgref);
        axis image off
        hold on
        plot(lambda_x,lambda_y,'+r','MarkerSize',10); % plot Lambda
        
        % plot Imaged Region
        line([xoffset xoffset+xsize*fileinfo.xbin xoffset+xsize*fileinfo.xbin xoffset xoffset],...
            [yoffset yoffset yoffset+ysize*fileinfo.ybin yoffset+ysize*fileinfo.ybin yoffset]);
        
        hold off
        colmap = colormap('gray');
        for c=1:4
            subplot(3,2,2+c);
            image(impatch(:,:,c)/255*size(colmap,1));
            axis image off
        end
        
        %         logmsg('ENNY WORKING HERE ON IMAGE OVERLAYING');
        %         pause
        logmsg(['Record: ' record.date ' ' record.test])
        
        %Check whether lambda is at proper location
        correct_lambd = input('Lambda at proper location? (y/n)\n','s');
        while strcmp(correct_lambd,'n')
            subplot(3,2,2)
            [lambda_x lambda_y] = ginput(1);
            correct_lambd = input('Lambda at proper location? (y/n)\n','s');
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
        new_xoffset = round(xshift + lambd_allign(1)); %already in new bins
        new_yoffset = round(yshift + lambd_allign(2)); %already in new bins
                
        %Convert to new scale & binsize
        if new_scale~=Cur_scale | Cur_xbin ~= new_bin | Cur_ybin ~= new_bin
            nr_row = ((ysize*Cur_ybin*Cur_scale)/(new_scale))/new_bin; %ysize times bin gives nr pixels. Times scale gives total amount of micron
            nr_col = ((xsize*Cur_xbin*Cur_scale)/(new_scale))/new_bin; %Divided by new scale gives new amount of pixels needed. This is what you bin in the new bin gives needed amount of rows and columns
            GSized_impatch = zeros(nr_row,nr_col,size(impatch,3));
            %nr_row and nr_col should be 68 and 76 respectively, if not
            %it's wrong
            if nr_row ~= nr_row | nr_col ~= nr_col
                error('Nr_rows or nr_cols is not right..!')
            end
            %Calculate the difference in nr_rows and nr_cols with original image
            ydif = size(impatch,1)/nr_row;
            xdif = size(impatch,2)/nr_col;
            
            %Now bin the impatch again
            for ridx = 1:nr_row
                for cidx = 1:nr_col
                    sty_val = ridx*ydif-(ydif-1); %start y value
                    stpy_val = ridx*ydif;
                    stx_val = cidx*xdif-(xdif-1);
                    stpx_val = cidx*xdif;
                    %Check whether the end exceeds size impatch
                    if stpy_val > size(impatch,1)
                        stpy_val = size(impatch,1);
                    end
                    if stpx_val > size(impatch,2)
                        stpx_val = size(impatch,2);
                    end
                    GSized_impatch(ridx,cidx,:) = squeeze(mean(mean(impatch(sty_val:stpy_val,stx_val:stpx_val,:),1),2));
                end
            end
        end
        
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
        Norm_impatch = (GSized_impatch - min(GSized_impatch(:)))/max(GSized_impatch(:)) - min(GSized_impatch(:));
        
        %Now every image has to shift that amount in the ColorMatPerMouse
        ProbMapV1_Matr([new_yoffset:new_yoffset+size(Norm_impatch,1)-1],[new_xoffset:new_xoffset+size(Norm_impatch,2)-1],:,nr_map) = Norm_impatch;
        
        %Check probability map?
        if Check_ProbMap == 1
            figure
            for ccl = 1:size(ProbMapV1_Matr,3)
                subplot(2,2,ccl)
                imagesc(ProbMapV1_Matr(:,:,ccl,nr_map))
                hold on
                plot(LambdaX_bin,LambdaY_bin,'+r','Markersize',10)
            end
            colmap = colormap('gray');
        end

            
        
        nr_map = nr_map+1;
        db(i).overlay_included = 1;
          
        % If checked, put in record
        db(i).lambda.x = lambda_x;
        db(i).lambda.y = lambda_y;
        db(i).new_bin = new_bin;
        db(i).new_scale = new_scale;
          %Save Probability map and mapIndx
        for sp = 1:length(savepath)
            save([savepath{sp} 'ProbMapV1'],'ProbMapV1_Matr','mapIndx','nr_map','lambd_allign','new_bin')
        end
        
        %Save Database
        save_db(db,filename2save)
        
    end % test i
end % mouse m

