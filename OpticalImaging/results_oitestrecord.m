function newud=results_oitestrecord( ud )
%RESULTS_OITESTRECORD
%
%  RESULTS_OITESTRECORD( UD )
%
%  2005-2014, Alexander Heimel
%

global record

newud=ud;
ud.changed=0;
record=ud.db(ud.current_record);


tit=[record.mouse ' ' record.date ' ' record.test ];
tit(tit=='_')='-';

[imgdata,roi,ror,data]=load_testrecord( record );

compare_to_pos=findstr(record.comment,'compare_to');
if ~isempty(compare_to_pos)
    comma_pos=find(record.comment(compare_to_pos:end)==',');
    start_pos=comma_pos(1)+compare_to_pos;
    if length(comma_pos)>1
        end_pos=comma_pos(2)+compare_to_pos-1;
    else
        end_pos=length(record.comment);
    end
    compare_to=record.comment(start_pos:end_pos);
    ind_compare_to=test2ind(compare_to,record,ud.db);
else
    compare_to='';
    ind_compare_to=[];
end

% get data and analysispath
datapath=oidatapath(record);
analysispath=fullfile(datapath,'analysis');

% convert comma separated lists into cell list of tests
% e.g. 'mouse_E2,mouse_E3' -> {'mouse_E2','mouse_E3'}
tests=convert_cst2cell(record.test);

% get image info
fileinfo=imagefile_info( fullfile(datapath,...
    [ tests{1} 'B0.BLK']));

switch record.stim_type
    case {'orientation','direction'}
        
        % WTA map
        figure;
        image(imgdata)
        title(['WTA ' tit]);

        % single conditions
        show_single_condition_maps(record,{fullfile(datapath,tests{1})},[],fileinfo,roi,ror,tit);

        
        file = fullfile(oidatapath(record),[record.test '_B' ...
                mat2str([min(record.blocks) max(record.blocks)]) ...
                '_' record.stim_type '.png']);
        if exist(file, 'file')
            img = imread(file);
            figure('name',file,'NumberTitle','off');
            image(img)
            axis image off;
            label = subst_ctlchars(['Orientation, mouse=' record.mouse ',date=' record.date ',test=' record.test]);
            title(label);
        end
     
        switch record.stim_type
            case 'orientation'
                file = fullfile(oidatapath(record),[record.test '_B' ...
                    mat2str([min(record.blocks) max(record.blocks)]) ...
                    '_hor-ver' '.png']);
                if exist(file, 'file')
                    img = imread(file);
                    figure('name',file,'NumberTitle','off');
                    image(img)
                    axis image off;
                    label = subst_ctlchars(['Horizontal-vertical, mouse=' record.mouse ',date=' record.date ',test=' record.test]);
                    title(label);

                end
        end
        
        if 0 && ~isempty(imgdata)
            fulltitle = [capitalize(record.stim_type) tit]; 
            figure('Name',fulltitle,'NumberTitle','off');
            title(fulltitle)
            imgpic=double(imgdata);
            if ~isempty(roi) % highlight roi outline
                roioutline=1+10*image_outline(roi);
                imgpic(:,:,1)=imgpic(:,:,1).*roioutline;
                imgpic(:,:,2)=imgpic(:,:,2).*roioutline;
                imgpic(:,:,3)=imgpic(:,:,3).*roioutline;
            end
            if 0 && ~isempty(ror) % highlight ror outline
                roroutline=1+10*image_outline(ror);
                imgpic(:,:,1)=imgpic(:,:,1).*roroutline;
                imgpic(:,:,2)=imgpic(:,:,2).*roroutline;
                imgpic(:,:,3)=imgpic(:,:,3).*roroutline;
            end
            imgpic=uint8(imgpic);
            image(imgpic); % show retinotopy with highlights
            axis image off;
        end
        

    case {'retinotopy'}
        figure;
        h_image=subplot(3,4,[1 2 5 6  ]);
        
        if ~isempty(imgdata)
            imgpic=double(imgdata);
            if ~isempty(roi) % highlight roi outline
                roioutline=1+10*image_outline(roi);
                imgpic(:,:,1)=imgpic(:,:,1).*roioutline;
                imgpic(:,:,2)=imgpic(:,:,2).*roioutline;
                imgpic(:,:,3)=imgpic(:,:,3).*roioutline;
            end
            if 0 && ~isempty(ror) % highlight ror outline
                roroutline=1+10*image_outline(ror);
                imgpic(:,:,1)=imgpic(:,:,1).*roroutline;
                imgpic(:,:,2)=imgpic(:,:,2).*roroutline;
                imgpic(:,:,3)=imgpic(:,:,3).*roroutline;
            end
            imgpic=uint8(imgpic);
            image(imgpic); % show retinotopy with highlights
            axis image off;
        end
        title(['Retinotopy ' tit])
        
        % search for reference image
        if isempty(record.ref_image)
            posrefs=dir(fullfile(analysispath,'*.bmp'));
            posrefs=[posrefs dir(fullfile(analysispath,'*.BMP'))];
            if length(posrefs)==1
                answ=questdlg(['Is ' posrefs.name ' the right image?'],...
                    'Reference image','Yes','No');
                switch answ
                    case 'Yes',
                        record.ref_image=posrefs.name;
                        ud.changed=1;
                end
            else
                posrefs=dir(fullfile(analysispath,'refred*.bmp'));
                posrefs=[posrefs dir(fullfile(analysispath,'refred*.BMP'))];
                disp('Possible reference images: ');
                disp( {posrefs(:).name});
            end
        end
        
        % lambda is in unbinned coordinates
        [lambda_x,lambda_y,reffname]=get_bregma(record.ref_image,...
            datapath,'analysis');
        
        
        % ask for monitor center if necessary and store in record.response
        if isempty(record.response)
            record=get_monitorcenter(record,h_image,fileinfo,lambda_x,lambda_y);
            if ~isempty(record.response)
                ud.changed=1;
            end
        end
        
        % show monitor center
        plot_monitorcenter(record,h_image,fileinfo,lambda_x,lambda_y);
        
        % show reference image
        subplot(3,4,[3 4 7 8 ])
        
        %try
        if exist(reffname,'file') && ~exist(reffname,'dir')
            img=imread(reffname,'bmp');
            imgrgb=ind2rgb(img,repmat(linspace(0,1,255)',1,3));
            %img=img+roi_tf_outline;
                       
            if ~isempty(roi) % highlight roi outline
                % scale and move roi to right position on reference image
                roi_outline=(image_outline(roi)>0.01);
               if all(size(roi)==size(img)) 
                   % i.e. saved only imaged region as reference
                   % instead of full image
                   roi_full_outline = roi_outline;
                   disp('RESULTS_OITESTRECORD: Saved imaged region as reference, instead of full camera image.');
               else
                    roi_tf_outline=max(0,imresize(roi_outline,fileinfo.xbin));
                    roi_full_outline=zeros(size(img));
                    roi_full_outline(fileinfo.yoffset+ (1:size(roi_tf_outline,1)), ...
                        fileinfo.xoffset+ (1:size(roi_tf_outline,2)))=roi_tf_outline;
               end
                imgrgb(:,:,1)=imgrgb(:,:,1).*(1-roi_full_outline);
                imgrgb(:,:,2)=imgrgb(:,:,2).*(1-roi_full_outline);
                imgrgb(:,:,3)=imgrgb(:,:,3).*(1-roi_full_outline);
                imgrgb(:,:,1)=imgrgb(:,:,1)+roi_full_outline;
            end
            
            image(imgrgb);
            %Joris save this image to plot it separately in full screen
            %mode to more easily mark V1 and borders
            tmp_imgrgb_fullscreen = imgrgb;
            axis image
            axis off
            hold on
            h=plot(lambda_x,lambda_y,'+r');
            set(h,'MarkerSize',10);
        end
        
        subplot(3,4,9); % retinotopy colors
        cols=retinotopy_colormap(record.stim_parameters(1), ...
            record.stim_parameters(2));
        cols=cols(1:record.stim_parameters(1)*record.stim_parameters(2),:);
        cols=uint8(cols*255);
        image(permute(reshape(cols,record.stim_parameters(1),...
            record.stim_parameters(2),3),[2 1 3]));
        
        axis image;
        xlabel('nasal <-> temporal');
        ylabel('inferior <-> superior');
        set(gca,'Xtick',[]);
        set(gca,'ytick',[]);
        
        
        show_single_condition_maps(record,{fullfile(datapath,tests{1})},[],fileinfo,roi,ror,tit);
        
        %Joris: plot reference image with V1 border separately
        if ~isempty(findstr(record.experimenter,'jv'))
            disp('RESULTS_OITESTRECORD. Showing reference image with border because ''jv'' is experimenter.');
            figure(100);
            try
                imshow(tmp_imgrgb_fullscreen)
            catch me
                logmsg(me.message);
                close(100);
            end
        end
        
    case 'ks'
        if isempty(record.imagefile)
            disp('RESULTS_OITESTRECORD: No data available');
            return
        end
        plot_ks_data(data,tit);
        
        for ind=ind_compare_to
            compare_record=ud.db(ind);
            [compare_imgdata,compare_roi,compare_ror,compare_data]=...
                load_testrecord( compare_record); %#ok<ASGLU>
            if ~isempty(compare_imgdata)
                if prod(size(compare_data)==size(data))==1
                    if compare_record.stim_parameters~=record.stim_parameters
                        % plot absolute map
                        caption=['Absolute map ' tit ' & ' compare_to ];
                        caption((caption=='_'))='-';
                        plot_absolute_map(data,compare_data,caption);
                    end
                    if strcmp(compare_record.eye,record.eye)==0
                        figure;                        % show OD
                        od_ratio=record.timecourse_ratio/ ...
                            compare_record.timecourse_ratio;
                        m=max(abs([data(:); compare_data(:)] ));
                        subplot(1,2,1);
                        colormap hot
                        c=colormap;
                        image(abs(data')/m*length(c));axis off image;
                        caption=[record.eye ' \newline' record.test];
                        caption(caption=='_')='-';
                        title(caption)
                        ax=axis;
                        caption=['Mouse ' record.mouse  ...
                            '       OD ratio: ' num2str(od_ratio,2) ];
                        caption(caption=='_')='-';
                        text(ax(1),ax(3)-0.3*(ax(4)-ax(3)),...
                            caption);
                        subplot(1,2,2);
                        image(abs(compare_data')/m*length(c));axis off image;
                        caption=[compare_record.eye ' \newline' compare_record.test];
                        caption(caption=='_')='-';
                        title(caption)
                        smaller_font(-4);
                    end
                end
            end
        end
    otherwise
        if isempty(record.response)
            logmsg('No responses known');
            return
        end
        
        tests=convert_cst2cell(record.test);
        
        plot_testresults(fullfilelist(datapath,tests),...
            record.response,...
            record.response_sem,...
            record.response_all,...
            record.timecourse_roi,...
            record.timecourse_ror,...
            record.timecourse_ratio,...
            roi,ror,...
            record);
        
        reliable=check_reliability(record);
        if ~isempty(reliable)
            if isempty(record.reliable)
                record.reliable=reliable;
            elseif record.reliable~=reliable
                disp('Warning: Discrepancy with recorded reliability');
            end
        end
end

% wrap-up
if ud.changed
    record.analysed=datestr(now);
    % insert record into database
    ud.db(ud.current_record)=record;
    set(ud.h.fig,'Userdata',ud);
    % show record in recordform
    if ~isfield(ud,'no_callback')
        control_db_callback(ud.h.current_record);
        control_db_callback(ud.h.current_record);
    end
    % get record from recordform
    if isfield(ud,'record_form')
        ud.db(ud.current_record)=get_record(ud.record_form);
    end
end

newud=ud;

evalin('base','global record');

disp('RESULTS_OITESTRECORD: Record available in workspace as ''record''.');
return


%
function record=get_monitorcenter(record,h_image,fileinfo,lambda_x,lambda_y)


% only do analysis if not done before
if ~isempty(record.ref_image)
    disp('Click on pixel representing center of monitor');
    axis on
    subplot(h_image);
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


function plot_monitorcenter(record,h_image,fileinfo,lambda_x,lambda_y)

if isempty(record.response)
    disp('RESULTS_OITESTRECORD: No monitor center position');
    return
end

subplot(h_image);

% convert x y back to image scale
xy=record.response/record.scale;
x=xy(1);y=xy(2);

% shift by lambda
x=x+lambda_x;
y=y+lambda_y;

% shift to absolute unbinned coordinates
if isfield(fileinfo,'xoffset')
    x=x-fileinfo.xoffset;
    y=y-fileinfo.yoffset;
else
    disp('no xoffset in fileinfo. probably missing data file');
    return
end



% transform monitor center to binned coordinates
x=round(x)/fileinfo.xbin;
y=round(y)/fileinfo.ybin;

hold on
plot(x,y,'ow');
h=plot(x,y,'ow');
set(h,'MarkerSize',10);

return
