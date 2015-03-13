function [record,avg] = analyse_oitestrecord( record)
%ANALYSE_OITESTRECORD
%
%   [RECORD,AVG] = ANALYSE_OITESTRECORD( RECORD )
%
% 2005-2014, Alexander Heimel

if isfield(record,'blocks')
    if ischar(record.blocks)
        record.blocks = str2num(record.blocks); %#ok<ST2NM>
    end
end

avg=[];
stddev=[];

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
    errormsg(['Datapath ' datapath ' does not exist.']);
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
        errormsg('Datafile not available');
        return;
    else
        logmsg('Original datafile not available');
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
            logmsg('Image dimensions do not fit data dimensions. Reanalyzing');
            record.imagefile=[];
        end
    else
        n_x=size(data,2);
        n_y=size(data,1);
    end
end

% get already defined ROI
roi=[];
roifile=strtrim(lower(record.roifile));
if isempty(roifile)
    roifile = '';
    record.roifile = '';
end
switch roifile
    case '', % do nothing here
    case 'standard',
        % use circular ROI constructed around point relative to lambda
        
        % position of screen center from all adult mice
        rel_x=2500 + 1000/sqrt(2); % L-M position rel to Lambda in micron
        rel_y=1000 - 1000/sqrt(2);  % A-P position rel to Lambda in micron
        
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
rorfile=strtrim(lower(record.rorfile));
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
        case 'ks'
            if isempty(record.stim_tf)
                logmsg('Error: no frequency given (stim_tf)');
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
        otherwise
            [late_frames,early_frames] = oi_get_framenumbers(record);

            if ~isempty(late_frames)
                if late_frames(end)>fileinfo.n_images
                    logmsg('Number of frames in file fewer than stim_off plus extra time.');
                    late_frames = intersect(late_frames,1:fileinfo.n_images);
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
                record.blocks,early_frames,...
                late_frames,...
                roi,ror,[],compression,response_sign,record);
            
            if h==-1
                logmsg('Could not get image');
            else
                imagefile= [ record.test '_auto_wta_c' ...
                    num2str(compression) '.png'];
                imagepath=fullfile(analysispath,imagefile);
                children=get(h,'Children');
                img=get(children(1),'Children');
                data=get(img,'CData');
                data = uint8(round(255*data));
                imwrite(data,imagepath,'Software', ...
                    'analyse_record');
                data=imread(imagepath);
                record.imagefile=imagefile;
                
                
                %keyboard
                
                close(h);
            end
    end
end

% if no ROI present, let user draw new ROI
if isempty(roifile) ||  ~exist(roifile,'file')
    h_roi=figure;
    image(data); axis image;
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
    logmsg('Please select ROI polygon');
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
    logmsg('Please select ROR polygon');
    ror=select_polygon;
    rorfile= [ record.test '_ror_c' num2str(compression) '.png'];
    rorpath=fullfile(analysispath,rorfile);
    ror=ror & (~roi);
    imwrite(ror,rorpath);
    record.rorfile=rorfile;
    close(h_ror);
    pause(0.01);
end

% make bandwith figures
switch record.stim_type
    case {'sf','tf'}
        avg_norm = avg-repmat(min(avg,[],3),[ 1 1 size(avg,3)]);
        roi_edge = edge(roi);
        
        % low
        avg_low = avg_norm(:,:,1)./max(avg_norm,[],3);
        figure;
        im = avg_low;
        im(roi_edge'==1) = 0;
        imagesc(im');
        axis off image
        title(subst_ctlchars(['R_1/R_max: mouse=' record.mouse ',date=' record.date ',test=' record.test]));
        
        % high
        avg_high = avg_norm(:,:,end-1)./max(avg_norm,[],3);
        figure;
        im = avg_high;
        im(roi_edge'==1) = 0;
        imagesc(im');
        axis off image
        title(subst_ctlchars(['R_(end-1)/R_max: mouse=' record.mouse ',date=' record.date ',test=' record.test]));
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
        
        % search for reference image
        if isempty(record.ref_image)
            posrefs=dir(fullfile(analysispath,'*.bmp'));
            posrefs=[posrefs dir(fullfile(analysispath,'*.BMP'))];
            if length(posrefs)==1
                answ=questdlg(['Is ' posrefs.name ' the right image?'],...
                    'Reference image','Yes','No');
                switch answ
                    case 'Yes',
                        record.ref_image = posrefs.name;
                end
            else
                posrefs=dir(fullfile(analysispath,'refred*.bmp'));
                posrefs=[posrefs dir(fullfile(analysispath,'refred*.BMP'))];
                logmsg('Possible reference images: ');
                logmsg( {posrefs(:).name});
            end
        end
        
        if ~isempty(record.imagefile)
            h_image=figure;
            data=imread(imagepath);
            image(data);
            
            
            % lambda is in unbinned coordinates
            [lambda_x,lambda_y,reffname]=get_bregma(record.ref_image,...
                datapath,'analysis');
            
            
            % ask for monitor center if necessary and store in record.response
            if isempty(record.response)
                record=get_monitorcenter(record,h_image,fileinfo,lambda_x,lambda_y);
            end
            
            close(h_image);
        end
        
    case {'orientation','direction'}
        roi_edge = edge(roi);
        cmap = colormap('hsv');
        or_abs = round(rescale(mean(avg,3),[min(avg(:)) max(avg(:))],[1 size(cmap,1)]));       
        multfac = 1+strcmpi(record.stim_type,'orientation');
        
        % polar orientation map
        polavg = zeros(size(avg,1),size(avg,2));
        for c=1:size(avg,3)
            polavg = polavg + avg(:,:,c) * exp(multfac*pi*1i*record.stim_parameters(c)/180);
        end
        
        or_angs = round(rescale(mod(angle(polavg),2*pi),[0 2*pi],[1 size(cmap,1)]));
        
        processparams = oiprocessparams(record);
        if processparams.wta_show_roi
            or_angs(roi_edge'==1) = 0;
        end
        
        or_ang = angle(polavg);
        if processparams.wta_show_roi
            or_ang(roi_edge'==1) = 0;
        end
         
        figure
        image(or_angs');
        axis image off
        colormap hsv
        set(gca,'clim',[0 180])
        
        h = image_intensity(or_angs',or_abs',cmap);
        filename= fullfile(oidatapath(record),[record.test '_B' ...
            mat2str([min(record.blocks) max(record.blocks)]) '_orientation.png']);
        imwrite(get(get(gca,'children'), 'cdata') ,filename, 'png');
        logmsg(['Orientation map saved as: ' filename]);
        close(h);
        
        switch record.stim_type
            case 'orientation'
                logmsg('Selectivity maps are better made with the full data through selecting stim_type = direction');
            case 'direction'
                avg = avg-repmat(min(avg,[],3),[1 1 size(avg,3)]); % subtracting minimal response
                % thus not the real OSI and DSI
                
                osi_map =  zeros(size(polavg));
                dsi_map =  zeros(size(polavg));
                for i=1:size(avg,1)
                    for j=1:size(avg,2)
                        [osi_map(i,j) dsi_map(i,j)]= ...
                            compute_orientation_selectivity_index(record.stim_parameters(1:size(avg,3)), ...
                            avg(i,j,:));
                    end % i
                end %j
                osi_map(osi_map>1) = 1;
                osi_map(osi_map<0) = 0;
                dsi_map(dsi_map>1) = 1;
                dsi_map(dsi_map<0) = 0;
                
                figure('Name','OSI bias map');
                imagesc(osi_map');
                axis image off;

                figure('Name','DSI bias map');
                imagesc(dsi_map');
                axis image off;
        end
    case 'significance'
        record = oi_compute_significance(record);
        record.response=[]; %[frac05 frac01 frac001];
        record.response_sem=[];
        record.response_all=[];
        record.timecourse_roi=[];
        record.timecourse_ror=[];
        record.timecourse_ratio=[];
    case 'ks'
        record.timecourse_roi=mean(abs(ks_data(roi'>0)));
        record.timecourse_ror=mean(abs(ks_data(ror'>0)));
        record.timecourse_ratio=record.timecourse_roi/record.timecourse_ror;
    otherwise
        disp([ 'stim_type ' record.stim_type ' is not implemented.']);
end


reliable=check_reliability(record);
if ~isempty(reliable)
    if isempty(record.reliable)
        record.reliable=reliable;
    elseif record.reliable~=reliable
        logmsg('Discrepancy with recorded reliability');
    end
end

logmsg('Finished analysis');
record.analysed=datestr(now);





function record=get_monitorcenter(record,h_image,fileinfo,lambda_x,lambda_y)


% only do analysis if not done before
if ~isempty(record.ref_image)
    disp('Click on pixel representing center of monitor');
    axis on
    figure(h_image);
    [x,y]=ginput(1);
    % in binned coordinates
    
    % transform monitor center to unbinned coordinates
    x=round(x)*fileinfo.xbin;
    y=round(y)*fileinfo.ybin;
    
    % and shift to absolute unbinned coordinates
    x=x+fileinfo.xoffset;
    y=y+fileinfo.yoffset;
    
    if ~isempty(lambda_x) && ~isempty(lambda_y)
        x=x-lambda_x;
        y=y-lambda_y;
        
        % record.scale should be in unbinned coordinates
        record.response=[x y]*record.scale;
        record.response=round(record.response);
    end
else
    disp('No reference image known.');
end

return
