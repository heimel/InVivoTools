function record=analyse_testrecord( record)
%ANALYSE_TESTRECORD
%
%   RECORD=ANALYSE_TESTRECORD( RECORD )
%
% 2005-2013, Alexander Heimel

if isfield(record,'blocks')
    if ischar(record.blocks)
        record.blocks = str2num(record.blocks); %#ok<ST2NM>
    end
end

avg=[];stddev=[];

% get compression rate from record.comment
compression_pos=findstr(record.comment,'compression');
if ~isempty(compression_pos)
    comma_pos=find(record.comment(compression_pos:end)==',');
    start_pos=comma_pos(1)+compression_pos;
    if length(comma_pos)>1
        end_pos=comma_pos(2)+compression_pos-1;
    else
        end_pos=length(record.comment);
    end
    compression=eval(record.comment(start_pos:end_pos));
else
    compression=1;
end

datapath=oidatapath( record);
if ~exist(datapath,'dir')
    disp(['WARNING: datapath ' datapath ' does not exist.']);
    return
end

% get analysispath and create if necessary
analysispath=fullfile(datapath,'analysis');
if ~exist(analysispath,'dir')
    ind_filesep=find(analysispath==filesep);
    mkdir( analysispath(1:ind_filesep(end)-1),...
        analysispath(ind_filesep(end)+1:end));
end

% convert comma separated lists into cell list of tests
% e.g. 'mouse_E2,mouse_E3' -> {'mouse_E2','mouse_E3'}
tests=convert_cst2cell(record.test);

% get image info
fileinfo=imagefile_info( fullfile(datapath,...
    [ tests{1} 'B0.BLK']));


if fileinfo.n_images==-1 || fileinfo.n_images==0
    if isempty(record.imagefile)
        disp('Error: datafile not available');
        return;
    else
        disp('Warning: original datafile not available');
    end
    frame_duration=1;
else
    %get frame duration to calculate early and late images for analyse_retinotopy
    frame_duration=fileinfo.frameduration;
    n_x=floor(fileinfo.xsize/compression);
    n_y=floor(fileinfo.ysize/compression);
end

if ~isempty(record.imagefile)
    if record.imagefile(1)=='/' % abs path
        imagepath=record.imagefile;
    else
        imagepath=fullfile(analysispath,record.imagefile);
    end
    if strcmp( imagepath(end-2:end),'mat')
        load(imagepath,'-mat');
    else
        data=imread(imagepath);
    end
    
    %  h_imagefile=figure;imagesc(data);axis image off
    if ~isempty(n_x)
        if size(data,2)~=n_x || size(data,1)~=n_y
            disp('Image dimensions do not fit data dimensions. Reanalyzing');
            record.imagefile=[];
        end
    else
        n_x=size(data,2);
        n_y=size(data,1);
    end
end

% get already defined ROI
roi=[];
roifile=trim(lower(record.roifile));
if isempty(roifile)
    roifile = '';
    record.roifile = '';
end
switch roifile
    case '', % do nothing here
    case 'standard',
        % use circular ROI constructed around point relative to lambda
        %roi=ones(n_y,n_x);
        
        % position of screen center from all adult mice
        % old:
        %rel_x=2314 + 300; % L-M position rel to Lambda in micron
        %rel_y= 605  - 100;  % A-P position rel to Lambda in micron
        
        rel_x=2500 + 1000/sqrt(2); % L-M position rel to Lambda in micron
        rel_y=1000 - 1000/sqrt(2);  % A-P position rel to Lambda in micron
        
        %rel_x=0; % L-M position rel to Lambda in micron
        %rel_y=0;  % A-P position rel to Lambda in micron
        
        rel_x=rel_x / record.scale; % L-M rel to Lambda in pxls
        rel_y=rel_y / record.scale; % A-P rel to Lambda in pxls
        
        [bregma_x,bregma_y]=get_bregma(record.ref_image,datapath,'analysis');
        
        rel_x=rel_x+bregma_x; % L-M rel to top left camera in pxls
        rel_y=rel_y+bregma_y; % A-P rel to top left camera in pxls
        
        rel_x=rel_x-fileinfo.xoffset; % L-M rel to top left ROI in pxls
        rel_y=rel_y-fileinfo.yoffset; % A-P rel to top left ROI in pxls
        
        rel_x=rel_x/fileinfo.xbin; % L-M rel to top left ROI in binned pxls
        rel_y=rel_y/fileinfo.ybin; % A-P rel to top left ROI in binned pxls
        
        
        [dy,dx]=meshgrid(1:n_y,1:n_x);
        dist=sqrt(  (dy-rel_y).^2 + (dx-rel_x).^2 );
        % distance in binned pxls
        
        dist=dist*fileinfo.xbin; % dist in unbinned pxls
        dist=dist*record.scale; % dist in micron
        
        roi=(1+sign( 1000-dist'))/2; % all points within 1000 um of ref. point
        
        roifile= [ record.test '_std_roi.png'];
        roipath=fullfile(analysispath,roifile);
        imwrite(roi,roipath);
        record.roifile=roifile;
    otherwise
        if record.roifile(1)=='/'  % abs. path
            roifile=record.roifile;
        else
            roifile=fullfile(analysispath,record.roifile);
        end
        if exist(roifile,'file')
            roi=double(imread(roifile));
            if ~isempty(n_x)
                if size(roi,2)~=n_x || size(roi,1)~=n_y
                    record.roifile=[];
                end
            end
        end
end

% get already defined ROR
ror=[];
rorfile=trim(lower(record.rorfile));
if isempty(rorfile)
    rorfile = '';
    record.rorfile = '';
end
switch rorfile
    case '', % do nothing here
    case 'empty',
        ror=0*roi;
        rorfile= [ record.test '_empty_ror.png'];
        rorpath=fullfile(analysispath,rorfile);
        imwrite(ror,rorpath);
        record.rorfile=rorfile;
    case 'full',
        filter.width=100; % micron
        filter.width=filter.width/record.scale; % unbinned pixels
        filter.width=filter.width/fileinfo.xbin; % binned pixels
        filter.width=max(1,filter.width);
        filter.unit='pixel';
        aroi=spatialfilter( double(roi>0.99),filter.width,filter.unit);
        ror=1-aroi;
        ror=double(ror>1-exp(-0.5));
        
        rorfile= [ record.test '_full_ror.png'];
        rorpath=fullfile(analysispath,rorfile);
        imwrite(ror,rorpath);
        record.rorfile=rorfile;
    otherwise
        if record.rorfile(1)=='/'  % abs. path
            rorfile=record.rorfile;
        else
            rorfile=fullfile(analysispath,record.rorfile);
        end
        ror=double(imread(rorfile));
        if ~isempty(n_x)
            if size(ror,2)~=n_x || size(ror,1)~=n_y
                record.rorfile=[];
            end
        end
end

% produce image
if isempty(record.imagefile) ...
        || strcmp(record.stim_type,'significance')==1 ...
        || fileinfo.headeronly~=1
    % produce image
    switch record.stim_type
        case {'retinotopy','sf','sf_contrast','contrast_sf','sf_low_tf','tf','od','od_bin','od_mon','contrast','rt_response','ledtest','significance'},
            if strcmp(record.stim_type,'retinotopy')||...
                    strcmp(record.stim_type,'rt_response')||...
                    strcmp(record.stim_type,'significance')
                if isnumeric(record.stim_parameters)
                    dimensions=record.stim_parameters;
                else
                    dimensions=str2num(record.stim_parameters); %#ok<ST2NM>
                end
            else
                dimensions=[];
            end
            early_frames=(1: ceil(record.stim_onset/frame_duration)  );
            late_frames=setdiff( (1:ceil(record.stim_offset/frame_duration)),...
                early_frames);
            
            if ~isempty(late_frames)
                if late_frames(end)>fileinfo.n_images
                    disp(['ANALYSE_TESTRECORD: Number of frames in file not consistent with' ...
                        ' stim_off.']);
                    errordlg(['Number of frames in file not consistent with' ...
                        ' stim_off.'],'Analyse testrecord');
                    return
                end
            end
            if strcmp(record.datatype,'fp')==1
                response_sign=-1;
            else
                response_sign=1;
            end
            if strcmp(record.stim_type,'ledtest')==1
                response_sign=-1;
                early_frames=-1;
            end
            [h,avg,stddev,blocks]=analyse_retinotopy(fullfile(datapath,tests{1}),...
                dimensions,record.blocks,early_frames,...
                late_frames,...
                roi,ror,[],compression,response_sign,record);
            
            if h==-1
                disp('Warning: could not get image');
            else
                imagefile= [ record.test '_auto_wta_c' ...
                    num2str(compression) '.png'];
                imagepath=fullfile(analysispath,imagefile);
                children=get(h,'Children');
                img=get(children(1),'Children');
                data=get(img,'CData');
                imwrite(data,imagepath,'Software', ...
                    'analyse_record');
                data=imread(imagepath);
                record.imagefile=imagefile;
                close(h);
            end
            
        case 'ks',
            if isempty(record.stim_tf)
                disp('Error: no frequency given (stim_tf)');
                return
            end
            [img,ks_data]=ks_analysis(...
                fullfile(datapath,[record.test 'B0.BLK']),...
                record.stim_tf,compression,...
                [],[],[],[],record.stim_onset,record.stim_offset);
            imagefile= [ record.test '_auto_ks_c' ...
                num2str(compression) '.mat'];
            imagepath=fullfile(analysispath,imagefile);
            data=get(img,'CData');
            save(imagepath,'ks_data','data','-mat');
            record.imagefile=imagefile;
        otherwise,
            disp(['Error: Stimulus type ' record.stim_type ...
                ' is not (fully) implemented.']);
            return
    end
end

% if no ROI present, let user draw new ROI
if isempty(roifile) ||  ~exist(roifile,'file')
    h_roi=figure;
    image(data); axis image;
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
    disp('ANALYSE_TESTRECORD: Please select ROI polygon');
    roi=select_polygon;
    
    if ~isfield(fileinfo,'xsize') || size(roi,2)==0
        compression=1;
    else        
        compression=floor(fileinfo.xsize/size(roi,2));
    end
    if isempty(record.roifile)
        roifile= [ record.test '_roi_c' num2str(compression) '.png'];
    end
    if ~isempty(roifile==filesep)
        [roipath,roifile,ext]=fileparts(roifile); %#ok<ASGLU>
        roifile=[roifile  ext];
    end
    roipath=fullfile(analysispath,roifile);
    imwrite(roi,roipath);
    record.roifile=roifile;
    
    close(h_roi);
    pause(0.01);
end

% if no ROR defined, let user draw one
if isempty(record.rorfile)
    %data=imread(imagepath);
    h_ror=figure;
    image(data); axis image;
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
    disp('ANALYSE_TESTRECORD: Please select ROR polygon');
    ror=select_polygon;
    rorfile= [ record.test '_ror_c' num2str(compression) '.png'];
    rorpath=fullfile(analysispath,rorfile);
    ror=ror & (~roi);
    imwrite(ror,rorpath);
    record.rorfile=rorfile;
    close(h_ror);
    pause(0.01);
end

% Do analysis
switch record.stim_type
    case {'od','od_bin','od_mon','sf','tf','contrast',...
            'rt_response','sf_contrast','contrast_sf','sf_low_tf','ledtest'},
        % compute timecourse
        [record.response,record.response_sem,record.response_all,...
            record.timecourse_roi,record.timecourse_ror,...
            record.timecourse_ratio]=...
            average_timecourse(fullfilelist(datapath,tests),...
            [],record.blocks,...
            roi,ror,compression,...
            record,0);
    case 'retinotopy',
        % retinotopy center is asked in results_oitestrecord
    case 'significance'
        % calculate significance with ANOVA using means and stddevs
        
        %   first flatten avg and stddev
        if ~isempty(findstr(record.rorfile,'ror'))
            % add zero response
            disp('adding zero response condition')
            avg(:,:,end+1)=0;
            stddev(:,:,end+1)=mean(stddev,3);
        end
        
        ravg=reshape(avg,size(avg,1)*size(avg,2),size(avg,3));
        rstddev=reshape(stddev,size(stddev,1)*size(stddev,2),size(stddev,3));
        if isempty(roi)
            pvals=significant_pixels_avg_stddev(ravg,rstddev);
        else
            pvals=ones(size(avg,1)*size(avg,2),1);
            roi_ind=find(roi'>0);
            %  pvals(roi_ind)=significant_pixels_avg_stddev(ravg(roi_ind,:),rstddev(roi_ind,:),100);
            pvals(roi_ind)=significant_pixels_avg_stddev(ravg(roi_ind,:),rstddev(roi_ind,:),length(blocks));
        end
        % structure pvals back into frame
        pvals=reshape(pvals,size(avg,1),size(avg,2));
        
        n_roi=length(find(roi>0));
        frac05=length(find(pvals<0.05))/n_roi;
        frac01=length(find(pvals<0.01)) / n_roi;
        frac001=length(find(pvals<0.001))/n_roi;
        record.response=[frac05 frac01 frac001];
        record.response_sem=[];
        record.response_all=[];
        record.timecourse_roi=[];
        record.timecourse_ror=[];
        record.timecourse_ratio=[];
    case 'ks',
        record.timecourse_roi=mean(abs(ks_data(roi'>0)));
        record.timecourse_ror=mean(abs(ks_data(ror'>0)));
        record.timecourse_ratio=record.timecourse_roi/record.timecourse_ror;
    otherwise
        disp([ 'stim_type ' record.stim_type ' is not implemented.']);
end

disp('ANALYSE_TESTRECORD: Finished analysis');
record.analysed=datestr(now);
