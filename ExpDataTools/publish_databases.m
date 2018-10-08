function publish_databases( figs, publishname, savefigs )
%PUBLISH_DATABASES collects the records used for producing figures
%
%  PUBLISH_DATABASES( FIGS, PUBLISHNAME, SAVEFIGS )
%
%         FIGS = celllist(n,3) with
%            in 1st column the figure name in graph_db and
%            in the 2nd column the experiment (e.g. '13.03')
%            in the 3rd column the host (e.g. 'daneel' or '')
%
% 2017, Alexander Heimel

if nargin<3
    savefigs = false;
end

if nargin<2
    publishname = ['publish_' datestr(now,30)];
end

%extract_databases( figs, publishname, savefigs);
check_figures( publishname);


function extract_databases( figs, publishname, savefigs)
global used_records
used_records = [];

host('');
experiment('');
graphdb = load_graphdb;

for i=1:size(figs,1)
    
    % find graph record
    ind = find_record(graphdb,['name="' figs{i,1} '"']);
    if isempty(ind)
        errormsg(['Cannot find figure ' figs{i,1}]);
    elseif length(ind)>1
        errormsg(['Find too many figures ' figs{i,1}]);
    end
    rec = graphdb(ind);
    
    % select right database
    experiment(figs{i,2});
    host(figs{i,3});
    
    % compute graph
    org_extra_options = rec.extra_options;
    rec.extra_options = [org_extra_options ',collect_records,1'];
    
    [rec,hgraph] = compute_graphrecord(rec);
    rec.extra_options = org_extra_options;
    
    collect_record(rec,'graph')
    
    if savefigs
        saveas(hgraph.fig,['fig1_' num2str(i) '.eps'],'epsc');
    end
    clear functions; %#ok<CLFUNC> % to clear testdb cache
    
    
end

logmsg(['Used ' num2str(length(used_records.test)) ' test records'] );
used_records.test = remove_duplicates(used_records.test);
logmsg(['Used ' num2str(length(used_records.test)) ' unique test records'] );

testdbname = ['testdb_' publishname '.mat'];

answer = 'Yes';
if exist(testdbname,'file')
    answer = questdlg([testdbname ' already exists. Overwrite?'],...
        'Database exists','Yes','Cancel','Cancel');
end
switch answer
    case 'Yes'
        
        flds = fieldnames(used_records);
        for i=1:length(flds)
            recordtype = flds{i};
            db = used_records.(recordtype);
            db = remove_duplicates(db,[],'first');
            filename = fullfile(expdatabasepath,publishname,[ recordtype 'db_' publishname '.mat']);
            save(filename,'db','-v7');
        end
end

% now check if recomputing the figures from the published database
% generates the same results


logmsg('Computed and extracted ');


function check_figures(publishname)

experiment(publishname);
host('');
graphdb = load_graphdb;

for i=1:length(graphdb)
    record = graphdb(i);
    prev_values = record.values;
    record = compute_graphrecord(record,graphdb);
    if ~isempty(prev_values)
        if ~isequaln(record.values.gx,prev_values.gx) || ...
                ~isequaln(record.values.gy,prev_values.gy) || ...
                ~isequaln(record.values.p,prev_values.p)
            errormsg([recordfilter(record,graphdb) ' does not give the same values as previously ']);
            if breakonerror
                keyboard
            end
        else
            logmsg(['Figure ' record.name ' is correct.']); 
        end
    end

end





