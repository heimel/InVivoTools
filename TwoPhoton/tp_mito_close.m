function record = tp_mito_close(record)
%TP_MITO_CLOSE computes for ROIs whether there is a mito type ROI close
%
%  RECORD = TP_MITO_CLOSE(RECORD)
% 
% 2013, Alexander Heimel
%

params = tpreadconfig(record);

if isempty(params)
    disp('TP_MITO_CLOSE: No image information. Cannot link ROIs');
    return
end

processparams = tpprocessparams([],record);


%disp('TP_MITO_CLOSE: Maximum distance bouton to mitochondrion set in tpprocesparams');



roilist = record.ROIs.celllist;
n_rois = length(roilist);
ind_mito = strmatch('mito',{roilist.type});
ind_no_mito = setdiff(1:length(roilist),ind_mito);


r = zeros(n_rois,3);
for i = 1:n_rois
    r(i,1) = median(roilist(i).xi); % take center
    r(i,2) = median(roilist(i).yi); % take center
    r(i,3) = median(roilist(i).zi); % take center
end


for i = ind_no_mito(:)'
    record.measures(i).mito_close = false;
    record.measures(i).distance2mito = inf;
    for j = ind_mito(:)'
       if  roilist(j).present
           record.measures(i).distance2mito  = min(record.measures(i).distance2mito, norm(r(i,:)-r(j,:))*params.x_step );
       end
    end
    if record.measures(i).distance2mito <=processparams.max_bouton_mito_distance_um
        record.measures(i).mito_close = true;
    end
end

for i = ind_mito(:)'
    record.measures(i).mito_close = true;
    record.measures(i).distance2mito = 0;
end


