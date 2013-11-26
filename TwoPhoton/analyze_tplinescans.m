function results = analyze_tplinescans( reanalyze )
%ANALYZE_TPLINESCANS reanalyzes and plots results of whole linescan database
%
%  RESULTS = ANALYZE_TPLINESCANS( REANALYZE )
%
% related function: TPLINESCANDB, SAMPLE_LINESCAN_PARAMETERS
%
% 2010, Alexander Heimel
%

% use new function ttpprocessparams!

if nargin < 1
    reanalyze = false;
end

db = [];

load_testdb(expdatabases('ls'))

if  reanalyze
    db = analyze_all(db);
    clear('datapath','reanalyze');
    save(fullfile(expdatabasepath,expdatabases('ls')),'-mat');
end

db=db(29:end);
results = combine_results(db);
process_params = db(1).process_params;
process_params.output_show_figures = true;

results_tppatternanalysis(results, process_params);

return

function db = analyze_all( db )
for i = 1:length(db)
    disp(['Analyzing record ' num2str(i) ' of ' num2str(length(db))]);

    db(i).process_params.wave_aspect_ratio_correction = true;
    db(i).process_params.findpeaks_fast = false;
    db(i).process_params.wave_criterium = -2;
    db(i).process_params.output_show_figures = false;
    db(i).process_params.retinal_event_threshold = 0.2; 
    db(i).process_params.cortical_event_threshold = 0.9;
    db(i)  = tp_analyze_linescan( db(i) );
    db(i).comment = [db(i).comment ',w=' num2str(sum(db(i).result.waves))];
    results_tppatternanalysis(db(i).result, db(i).process_params);

end
return

function results = combine_results( db )
results = db(1).result;

flds = fields(results);

for i = 2:length(db)
    for j = 1:length(flds)
        field = flds{j};
        try
            if length(results.(field))>1
                if size(results.(field),1)==1
                    results.(field) = [results.(field)  db(i).result.(field) ];
                else
                    results.(field) = [results.(field) ; db(i).result.(field) ];
                end  
                elseif isstruct(results.(field))
                sflds = fields(results.(field));
                for k = 1:length(sflds)
                    subfield = sflds{k};
                    results.(field).(subfield) = [results.(field).(subfield) ; db(i).result.(field).(subfield) ];
                    
                end
            else
                if size(results.(field),2)==1
                results.(field) = [results.(field) ; db(i).result.(field) ];
                else
                results.(field) = [results.(field)  db(i).result.(field) ];
                end
            end
        catch me
            disp(['A problem in concatenating record ' num2str(i) ' with field ' field]);
            rethrow(me)
        end
    end
end




