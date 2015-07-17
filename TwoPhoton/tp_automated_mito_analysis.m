function record = tp_automated_mito_analysis(record)
% Created by Rajeev Rajendran 2015-07-17 with CvdT
% Modified from "tp_automated_bouton_analysis"
% see tp_analyse_neurites

switch lower(experiment)
    case '11.12_ls'
        measures = record.measures;
        ROIlist = record.ROIs.celllist;
        indices = [measures.index]; %indices of all rois
        mitos = find ([measures.mito]);

        for i=1:length(mitos)
            mito = mitos(i);
            measures(mito).intensity_mito = ROIlist(mito).intensity_mean(1);
        end
        record.measures = measures;
        
    case '11.12_ls_axons'
        measures = record.measures;
        ROIlist = record.ROIs.celllist;
        indices = [measures.index]; %indices of all rois
        mitos = find ([measures.mito]);

        for i=1:length(mitos)
            mito = mitos(i);
            measures(mito).intensity_mito = ROIlist(mito).intensity_mean(1);
        end
        record.measures = measures;
        
    case '11.12_ls2'
        measures = record.measures;
        ROIlist = record.ROIs.celllist;
        indices = [measures.index]; %indices of all rois
        mitos = find ([measures.mito]);

        for i=1:length(mitos)
            mito = mitos(i);
            measures(mito).intensity_mito = ROIlist(mito).intensity_mean(1);
        end
        record.measures = measures;
end








    

