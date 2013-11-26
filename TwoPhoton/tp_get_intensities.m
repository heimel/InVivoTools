function record = tp_get_intensities(record)
%TP_GET_INTENSITIES
%
%  RECORD = TP_GET_INTENSITIES( RECORD )
%     should be run twice for proper normalizations if some ROIs are new
% 
% 2011, Alexander Heimel
%

disp('TP_GET_INTENSITIES: Should remove intensity info from cellist');

process_parameters = tpprocessparams('',record);
celllist = record.ROIs.celllist;

celllist = structconvert(celllist,tp_emptyroirec);

disp(['TP_GET_INTENSITIES: Processing '  'mouse=' record.mouse ',stack=' record.stack ',date=' record.date ]);

params = tpreadconfig(record);

if isempty(params)
    disp('TP_GET_INTENSITIES: Could not read config file. Returning.');
    return
end

hbar = waitbar(0,'Calculating ROI intensities' );

pvimg = tppreview(record,40,1,1:params.NumberOfChannels,process_parameters);
channel_modes = zeros(1,params.NumberOfChannels);
for ch=1:params.NumberOfChannels
    val = pvimg(:,:,ch);
    channel_modes(ch) = mode(val(:));
end


for i=1:length(celllist)
    intensity_mean = nan(1,params.NumberOfChannels);
    intensity_mean(1:length(celllist(i).intensity_mean)) = celllist(i).intensity_mean;
    celllist(i).intensity_mean = intensity_mean;
end

% get abs values for absent puncta for channel 1
intensities_abs = reshape( [celllist.intensity_mean],params.NumberOfChannels,length(celllist))';
spine = strcmp({celllist.type},'spine');
shaft = strcmp({celllist.type},'shaft');
synapse = spine | shaft;
present = [celllist.present];
absent = ~present;


for ch=1:params.NumberOfChannels
    intensity_no_synapse(ch) = nanmedian( intensities_abs(absent & synapse,ch));
    intensity_synapse(ch) = nanmedian( intensities_abs(present & synapse,ch));
end


% first calculate linear_rois (dendrites), necessary for normalization

ind_dendrite = find(cellfun(@is_linearroi,{celllist.type}));

% ind_dendrite = [strmatch('dendrite',{celllist.type}) strmatch('line',{celllist.type})];

for i = ind_dendrite(:)'
    roi_dendrite = celllist(i);
    roi_dendrite = interpolate_poly(interpolate_poly(roi_dendrite));
    if length(roi_dendrite.zi)<length(roi_dendrite.xi)
        roi_dendrite.zi = roi_dendrite.zi*ones(size(roi_dendrite.xi));
    end
    
    for ch = 1:params.NumberOfChannels
        intensity = [];
        for j = 1:length(roi_dendrite.xi)
            local_intensity = [];
            
            for frame = (max(1,round(roi_dendrite.zi(j))-1):...
                    min(params.NumberOfFrames,round(roi_dendrite.zi(j))+1))
                im = tpreadframe(record,ch,frame,process_parameters);
                im = double(squeeze(im));
                x = round(roi_dendrite.xi(j));
                y = round(roi_dendrite.yi(j));
                
                if y>0 && y<=params.lines_per_frame && x>0 && x<=params.pixels_per_line
                    local_intensity(end+1) = im(y,x); 
                end
                if y>1 && (y-1)<=params.lines_per_frame && x>0 && x<=params.pixels_per_line
                    local_intensity(end+1) = im(y-1,x); 
                end
                if y<params.lines_per_frame && (y+1)>0 && x>0 && x<=params.pixels_per_line
                    local_intensity(end+1) = im(y+1,x);
                end
                if x>1 && (x-1)<=params.pixels_per_line && y>0 && y<=params.lines_per_frame
                    local_intensity(end+1) = im(y,x-1);
                end
                if x<params.pixels_per_line && (x+1)>0 && y>0 && y<=params.lines_per_frame
                    local_intensity(end+1) = im(y,x+1);
                end
            end
            if isempty(local_intensity)
                local_intensity = NaN;
            end
            intensity(end+1) = max(local_intensity);
        end
        roi_dendrite.intensity_mean(ch) = mean(intensity);
        roi_dendrite.intensity_median(ch) = median(intensity);
        roi_dendrite.intensity_max(ch) = max(intensity);
        
        record.measures(i).(['intensity_mean_ch' num2str(ch)]) = mean(intensity);
        record.measures(i).(['intensity_median_ch' num2str(ch)]) = median(intensity);
        record.measures(i).(['intensity_max_ch' num2str(ch)]) = max(intensity);
        
        
        if mean(intensity)<1
            disp(['TP_GET_INTENSITIES: mean intensity of dendrite ' num2str(roi_dendrite.index) ...
                ' channel ' num2str(ch) ' is less than 1.']);
        end
        
    end % ch
    celllist(i).intensity_median = roi_dendrite.intensity_median;
    
    %record.measures(i).intensity_mean = roi_dendrite.intensity_mean;
    %record.measures(i).intensity_max = roi_dendrite.intensity_max;
    
    waitbar(0.5*find(ind_dendrite==i,1)/length(ind_dendrite),hbar);
    
end


%warning('TP_GET_INTENSITIES:MEDIAN','TP_GET_INTENSITIES: taking median instead of mean dendrites');
%warning('OFF','TP_GET_INTENSITIES:MEDIAN');

[blankprev_x,blankprev_y] = meshgrid(1:params.pixels_per_line,1:params.lines_per_frame);

% then all puncta
for j = 1:length(celllist)
    roi = celllist(j);
    if ~isfield(roi,'zi')
        roi.zi = [];
    end
    if is_linearroi(roi.type)
        continue
    end
    
    celllist(j).intensity_mean = NaN(1,params.NumberOfChannels);
    celllist(j).intensity_max = NaN(1,params.NumberOfChannels);
    celllist(j).intensity_rel2dendrite = NaN(1,params.NumberOfChannels);
    celllist(j).intensity_rel2synapse = NaN(1,params.NumberOfChannels);
    celllist(j).zi = round(celllist(j).zi); % make zi integer (2011-11-06, should no longer occur)
    
    if isempty(roi.zi) || isnan(roi.zi(1))
        disp(['TP_GET_INTENSITIES: ROI ' num2str(celllist(j).index) ' has no valid z-coordinate.']);
        continue
    end
    
    
    if any(roi.xi<1) ...
            || any(round(roi.xi)>params.pixels_per_line) ...
            || any(round(roi.yi)<1) ...
            || any(round(roi.yi)>params.lines_per_frame) ...
            || any(round(roi.zi)<1) ...
            || any(round(roi.zi)>params.number_of_frames)
        disp(['TP_GET_INTENSITIES: ROI ' num2str(celllist(j).index) ' is out of image.']);
        continue
    end
    

    bw = inpolygon(blankprev_x,blankprev_y,...
        [roi.xi roi.xi(1)],[roi.yi roi.yi(1)]);

    computed_pixelinds = find(bw);
    
    if length(roi.pixelinds)~=length(computed_pixelinds) || any(roi.pixelinds~=computed_pixelinds)
        disp(['TP_GET_INTENSITIES: discrepancy on pixelinds of ROI ' num2str(roi.index) '. Replacing with recalculated inds.' ]);
        roi.pixelinds = computed_pixelinds;
    end
    
    frame = roi.zi(1);
    if max(roi.zi)~=min(roi.zi)
        disp(['No single plane for ROI: ' record.mouse ' ' record.stack ' ' record.date ' ROI index ' num2str(roi.index)]);
        continue
    end
    if isempty(roi.pixelinds)
        disp(['Empty pixelinds for ROI: ' record.mouse ' ' record.stack ' ' record.date ' ROI index ' num2str(roi.index)]);
        continue
    end
    
    ind_dendrite = find( [celllist.index] == roi.neurite(1),1);
    if isempty(ind_dendrite)
        disp(['TP_GET_INTENSITIES: ROI ' num2str(roi.index) ...
            ' is assigned to non-existing neurite ' num2str(roi.neurite(1))]);
        intensity_dendrite = NaN(size(roi.intensity_mean));
    else
        intensity_dendrite = celllist(ind_dendrite ).intensity_mean;
    end
    
    
    if frame~=round(frame)
        %disp(['TP_GET_INTENSITIES: Frame of ROI ' num2str(roi.index) ' is not integer']);
        frame = round(frame);
    end
    
  
    
    for ch = 1:params.NumberOfChannels
        im = tpreadframe(record,ch,frame,process_parameters);
        im = double(squeeze(im));
        roi.intensity_mean(ch) = nanmean(im(roi.pixelinds));
        roi.intensity_median(ch) = nanmedian(im(roi.pixelinds));
        roi.intensity_max(ch) = max(im(roi.pixelinds));
        roi.intensity_rel2dendrite(ch) = (roi.intensity_mean(ch)-channel_modes(ch)) / (intensity_dendrite(ch)-channel_modes(ch));
        if roi.intensity_rel2dendrite(ch)<0 && roi.present
            disp(['TP_GET_INTENSITIES: ROI ' num2str(roi.index) ' intensity_rel2dendrite below zero for channel ' num2str(ch) '. Setting to zero.']);
            roi.intensity_rel2dendrite(ch) = 0;
        end
            
        roi.intensity_rel2synapse(ch) =  ...
            (roi.intensity_mean(ch)-intensity_no_synapse(ch)) / (intensity_synapse(ch)-intensity_no_synapse(ch));
        %        roi.intensity_median(ch) = median(im(roi.pixelinds));

        record.measures(j).(['intensity_mean_ch' num2str(ch)]) = roi.intensity_mean(ch);
        record.measures(j).(['intensity_median_ch' num2str(ch)]) = roi.intensity_median(ch);
        record.measures(j).(['intensity_max_ch' num2str(ch)]) = roi.intensity_max(ch);
        record.measures(j).(['intensity_rel2dendrite_ch' num2str(ch)]) = roi.intensity_rel2dendrite(ch);
        record.measures(j).(['intensity_rel2synapse_ch' num2str(ch)]) = roi.intensity_rel2synapse(ch);
    end
    
    %celllist(j) = roi;
    
    waitbar(0.5+ 0.5*j/length(celllist),hbar);
end


% set ranks
intensity_rank = zeros(length(celllist),params.NumberOfChannels);
for ch=1:params.NumberOfChannels
    intensity_rank(present & synapse,ch) = ranks(intensities_abs(present & synapse,ch));
end
for i=1:length(celllist)
    %celllist(i).intensity_rank = intensity_rank(i,:);
    for ch=1:params.NumberOfChannels
         record.measures(i).(['intensity_rank_ch' num2str(ch)]) = intensity_rank(i,ch);
    end
end


close(hbar);



function poly_fine = interpolate_poly( poly )
% doubles number of interpolation points of poly
poly_fine = poly;
poly_fine.xi(1:2:2*length(poly.xi)-1) = poly.xi;
poly_fine.xi(2:2:2*length(poly.xi)-2) = (poly.xi(1:end-1)+poly.xi(2:end))/2;
poly_fine.yi(1:2:2*length(poly.yi)-1) = poly.yi;
poly_fine.yi(2:2:2*length(poly.yi)-2) = (poly.yi(1:end-1)+poly.yi(2:end))/2;
poly_fine.zi(1:2:2*length(poly.zi)-1) = poly.zi;
poly_fine.zi(2:2:2*length(poly.zi)-2) = (poly.zi(1:end-1)+poly.zi(2:end))/2;







