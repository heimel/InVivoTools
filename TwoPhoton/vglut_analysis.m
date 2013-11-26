function [results] = vglut_analysis

db_analysis = load_tptestdb_for_analysis;
db_vglut = db_analysis(find_record(db_analysis, ...
    '(mouse=11.21.3.10)'));

db = db_vglut;

results = [];

for i=1:length(db)
    celllist = db(i).ROIs.celllist;
    
    RFP = [];
    
    for j = 1:length(celllist);
        if ismember('RFP',celllist(j).labels);
            RFP(j) = 1;
        else
            RFP(j) = 0;
        end
    end
    
    GFP = [];
    
    for j = 1:length(celllist);
        if ismember('GFP',celllist(j).labels);
            GFP(j) = 1;
        else
            GFP(j) = 0;
        end
    end
    
    VGLUT = [];
    
    for j = 1:length(celllist);
        if ismember('VGLUT2',celllist(j).labels);
            VGLUT(j) = 1;
        else
            VGLUT(j) = 0;
        end
    end
    
    results.spines(i) = sum(RFP);
    results.double(i) = sum(GFP);
    results.thalamic(i) = sum(VGLUT);
    X = GFP&VGLUT;
    results.dbl_thlmc(i) = sum(X);
    results.p_double(i) = sum(GFP)/sum(RFP);
    results.p_thalamic(i) = sum(VGLUT)/sum(RFP);
    results.p_thlmc_gvn_dbl(i) = sum(X)/sum(VGLUT);
    results.p_dbl_gvn_thlmc(i) = sum(X)/sum(GFP);
end


% results(1).val= 11
% results(1).descr ='kflkk'
% results(end+1).val =122
% results(end).descr= 'kjdj'