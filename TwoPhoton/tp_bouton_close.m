function record = tp_bouton_close(record)
%TP_BOUTON_CLOSE computes for ROIs whether there is a bouton type ROI close
%
%  RECORD = TP_BOUTON_CLOSE(RECORD)
% 
% 2014, Alexander Heimel
%

params = tpreadconfig(record);

if isempty(params)
    logmsg('No image information. Cannot link ROIs');
    return
end

processparams = tpprocessparams(record);

roilist = record.ROIs.celllist;
n_rois = length(roilist);
ind_bouton = strmatch('bouton',{roilist.type});
ind_no_bouton = setdiff(1:length(roilist),ind_bouton);


r = zeros(n_rois,3);
for i = 1:n_rois
%     r(i,1) = median(roilist(i).xi); % take center
%     r(i,2) = median(roilist(i).yi); % take center
%     r(i,3) = median(roilist(i).zi); % take center
    r(i,1) = mean(roilist(i).xi); % take center
    r(i,2) = mean(roilist(i).yi); % take center
    r(i,3) = mean(roilist(i).zi); % take center
end

r = r.*repmat([params.x_step params.y_step params.z_step],size(r,1),1); 

for i = ind_no_bouton(:)'
    record.measures(i).bouton_close = false;
    record.measures(i).distance2bouton = inf;
    for j = ind_bouton(:)'
       if  roilist(j).present 
           if isfield(record.measures(j),'intensity_rel2dendrite') && ...
                   any(record.measures(j).intensity_rel2dendrite<processparams.bouton_close_minimum_intensity_rel2dendrite(1:length(record.measures(j).intensity_rel2dendrite)))
               continue
           end
           record.measures(i).distance2bouton  = min(record.measures(i).distance2bouton, norm(r(i,:)-r(j,:)) );
       end
    end
    if record.measures(i).distance2bouton <=processparams.max_bouton_mito_distance_um 
        record.measures(i).bouton_close = true;
    end
end

for i = ind_bouton(:)'
    record.measures(i).bouton_close = true;
    record.measures(i).distance2bouton = 0;
end


