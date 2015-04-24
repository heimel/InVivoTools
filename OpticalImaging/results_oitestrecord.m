function results_oitestrecord( record )
%RESULTS_OITESTRECORD
%
%  RESULTS_OITESTRECORD( RECORD )
%
%  2005-2015, Alexander Heimel
%

global global_record

global_record = record;

tit=[record.mouse ' ' record.date ' ' record.test ];
tit(tit=='_')='-';

[imgdata,roi,ror,data]=load_testrecord( record );

compare_to_pos = strfind(record.comment,'compare_to');
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
datapath = experimentpath(record);
analysispath = fullfile(datapath,'analysis');

params = oiprocessparams(record);

% convert comma separated lists into cell list of tests
% e.g. 'mouse_E2,mouse_E3' -> {'mouse_E2','mouse_E3'}
tests=convert_cst2cell(record.test);

% get image info
fileinfo=imagefile_info( fullfile(datapath,...
    [ tests{1} 'B0.BLK']));

switch record.stim_type
    case 'significance'
        fname = fullfile(experimentpath(record),[record.test '_significance.mat']);
        load(fname);
        figure('Name','Significant response');
        imagesc(signif_response')
        axis image off
        colorbar
        
        figure('Name','Significantly different between groups');
        imagesc(signif_between_groups')
        axis image off
        colorbar 

        figure('Name','Significantly different between groups, thresholded');
        imagesc(signif_between_groups'<0.05)
        axis image off
        colorbar 
    case {'orientation','direction'}
        
%         % WTA map
%         figure;
%         image(imgdata)
%         title(['WTA ' tit]);

        % single conditions
        show_single_condition_maps(record,{fullfile(datapath,tests{1})},[],fileinfo,roi,ror,tit);

        
        file = fullfile(experimentpath(record),[record.test '_B' ...
                mat2str([min(record.blocks) max(record.blocks)]) ...
                '_' record.stim_type '.png']);
        if exist(file, 'file')
            imgdata = imread(file);
            figure('name',file,'NumberTitle','off');

            
            imgpic=double(imgdata);
            if ~isempty(roi) && params.wta_show_roi % highlight roi outline
                roioutline=1+10*image_outline(roi);
                imgpic(:,:,1)=imgpic(:,:,1).*roioutline;
                imgpic(:,:,2)=imgpic(:,:,2).*roioutline;
                imgpic(:,:,3)=imgpic(:,:,3).*roioutline;
            end
            if  ~isempty(ror) && params.wta_show_ror  % highlight ror outline
                roroutline=1+10*image_outline(ror);
                imgpic(:,:,1)=imgpic(:,:,1).*roroutline;
                imgpic(:,:,2)=imgpic(:,:,2).*roroutline;
                imgpic(:,:,3)=imgpic(:,:,3).*roroutline;
            end
            imgpic = round(imgpic);
            imgpic(imgpic>255) = 255;
            imgpic=uint8(imgpic);
            image(imgpic); % show retinotopy with highlights

            
            
            
            axis image off;
            label = subst_ctlchars(['Orientation, mouse=' record.mouse ',date=' record.date ',test=' record.test]);
            title(label);
        end
        
        if 0
            switch record.stim_type
                case 'orientation'
                    file = fullfile(experimentpath(record),[record.test '_B' ...
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
            if ~isempty(roi) && params.wta_show_roi % highlight roi outline
                roioutline=1+10*image_outline(roi);
                imgpic(:,:,1)=imgpic(:,:,1).*roioutline;
                imgpic(:,:,2)=imgpic(:,:,2).*roioutline;
                imgpic(:,:,3)=imgpic(:,:,3).*roioutline;
            end
            if  ~isempty(ror) && params.wta_show_ror  % highlight ror outline
                roroutline=1+10*image_outline(ror);
                imgpic(:,:,1)=imgpic(:,:,1).*roroutline;
                imgpic(:,:,2)=imgpic(:,:,2).*roroutline;
                imgpic(:,:,3)=imgpic(:,:,3).*roroutline;
            end
            imgpic = round(imgpic);
            imgpic(imgpic>255) = 255;
            imgpic=uint8(imgpic);
            image(imgpic); % show retinotopy with highlights
            axis image off;
        end
        title(['Retinotopy ' tit])
        
      
        % lambda is in unbinned coordinates
        [lambda_x,lambda_y,reffname]=get_bregma(record.ref_image,...
            datapath,'analysis');
        
        % show monitor center
        if params.wta_show_monitor_center
            oi_plot_monitorcenter(record,h_image,fileinfo,lambda_x,lambda_y);
        end
        
        % show reference image
        subplot(3,4,[3 4 7 8 ])
        
        %try
        if exist(reffname,'file') && ~exist(reffname,'dir')
            img=imread(reffname,'bmp');
            imgrgb=ind2rgb(img,repmat(linspace(0,1,255)',1,3));
            %img=img+roi_tf_outline;
                       
            if ~isempty(roi) && params.reference_show_roi % highlight roi outline
                % scale and move roi to right position on reference image
                roi_outline=(image_outline(roi)>0.01);
               if all(size(roi)==size(img)) 
                   % i.e. saved only imaged region as reference
                   % instead of full image
                   roi_full_outline = roi_outline;
                   logmsg('Saved imaged region as reference, instead of full camera image.');
               else
                    roi_tf_outline=(max(0,imresize(double(roi_outline),fileinfo.xbin))>0.01);
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
            tmp_imgrgb_fullscreen = imgrgb;
            axis image
            axis off
            hold on
            if params.reference_show_lambda
                h=plot(lambda_x,lambda_y,'+r');
                set(h,'MarkerSize',10);
            end
        end
        
        subplot(3,4,9); % retinotopy colors
        show_retinotopy_colors( record);
        
        
        show_single_condition_maps(record,{fullfile(datapath,tests{1})},[],fileinfo,roi,ror,tit);
        
        %Joris: plot reference image with V1 border separately
        if ~isempty(strfind(record.experimenter,'jv'))
            logmsg('Showing reference image with border because ''jv'' is experimenter.');
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
            logmsg('No data available');
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
        

end


evalin('base','global global_record');
logmsg('Record available in workspace as ''global_record''.');
return


