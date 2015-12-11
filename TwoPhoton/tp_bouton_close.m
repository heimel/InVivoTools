function record = tp_bouton_close(record, params,processparams)
%TP_BOUTON_CLOSE computes for ROIs whether there is a bouton type ROI close
%
%  RECORD = TP_BOUTON_CLOSE(RECORD)
% 
% 2014-2015, Alexander Heimel
%

if nargin<2 || isempty(params)
    params = tpreadconfig(record);
end

if isempty(params)
    logmsg('No image information. Cannot link ROIs');
    return
end

if nargin<3 || isempty(processparams)
    processparams = tpprocessparams(record);
end

roilist = record.ROIs.celllist;
n_rois = length(roilist);
ind_bouton = strmatch('bouton',{roilist.type});
ind_no_bouton = setdiff(1:length(roilist),ind_bouton);

r = zeros(n_rois,3);
for i = 1:n_rois
    r(i,1) = sum(roilist(i).xi)/length(roilist(i).xi); % take center
    r(i,2) = sum(roilist(i).yi)/length(roilist(i).yi); % take center
    r(i,3) = sum(roilist(i).zi)/length(roilist(i).zi); % take center
end

r = r.*repmat([params.x_step params.y_step params.z_step],size(r,1),1); 

ind_bouton_present = ind_bouton([roilist(ind_bouton).present]==1);

if isfield(record.measures,'intensity_rel2dendrite')
    ind_bouton_present_and_bright = [];
    for j = ind_bouton_present(:)'
        if all(record.measures(j).intensity_rel2dendrite>processparams.bouton_close_minimum_intensity_rel2dendrite(1:length(record.measures(j).intensity_rel2dendrite)))
            ind_bouton_present_and_bright = [ind_bouton_present_and_bright j];
        end
    end
    ind_bouton_present = ind_bouton_present_and_bright;
end

for i = ind_no_bouton(:)'
    record.measures(i).bouton_close = false;
    record.measures(i).distance2bouton = inf;
    for j = ind_bouton_present(:)'
        if roilist(j).neurite(1)==roilist(i).neurite(1)
            record.measures(i).distance2bouton  = ...
                min(record.measures(i).distance2bouton, norm(r(i,:)-r(j,:)) );
        end
    end
    if record.measures(i).distance2bouton == inf
        record.measures(i).distance2bouton = NaN;
    end
    if record.measures(i).distance2bouton <=processparams.max_bouton_mito_distance_um 
        record.measures(i).bouton_close = true;
    end
end

for i = ind_bouton(:)'
    record.measures(i).bouton_close = true;
    record.measures(i).distance2bouton = 0;
end


