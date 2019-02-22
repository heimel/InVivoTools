function sample_linescan_parameters
%SAMPLE_LINESCAN_PARAMETERS
%
% creates new records in linescan database with different parameters
%

db = []; % to mask db function in matlab library
datapath = fileparts(which('tplinescandb'));

load_testdb('ls');
org_db = db;


samplefilename = 'tplinescan_sample_db.mat';
samplefilename = fullfile( datapath, samplefilename );

load(samplefilename,'-mat');


db = db([]);


for r=1:length(org_db)

    record = org_db(r);

    record.precommands = ''; % to remove parameter settings
    record.process_params.output_show_figures = false;
    record.process_params.filter.parameters = 0;
    record.process_params.filter.unit = '#'; % {'#','s'}
    record.process_params.detect_events = 'onset';
    for filter_param = [0 4 8]
        record.process_params.filter.parameters = filter_param;
        for detect_events_threshold = 1.5:0.5:2 % 1.5:0.5:3.5
            record.process_params.detect_events_threshold  = detect_events_threshold;
            for detect_events_group_width = 0.2:0.2:0.8 % 0.2:0.2:1
                record.process_params.detect_events_group_width  = detect_events_group_width;
                fprintf(['filter.parameters = ' num2str(filter_param,'%02.f') ', ']);
                fprintf(['detect_events_threshold = ' num2str(detect_events_threshold,'%.2f') ', ']);
                fprintf(['detect_events_group_width = ' num2str(detect_events_group_width,'%.2f')]);
                record = tp_analyze_linescan( record );
                db(end+1) = record;
                %results_tppatternanalysis(record.result, record.process_params);
                close all
                disp('*****************');
                save(samplefilename,'db','-v7');
            end
        end
    end
end
% optimal for 54a03:
%record.process_params.filter.parameters=5;
%record.process_params.detect_events_group_width=0.6,
%record.process_params.detect_events_threshold=1.5


% optimal for 54a04:
%record.process_params.filter.parameters=5;
%record.process_params.detect_events_group_width=0.6,
%record.process_params.detect_events_threshold=1.5


% optimal for 67a04:
%record.process_params.filter.parameters=5;
%record.process_params.detect_events_group_width=0.2,
%record.process_params.detect_events_threshold=2


