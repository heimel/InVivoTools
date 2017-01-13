
% clear all
experiment(14.13)
host('tinyhat')

if ~exist('db_org','var') || isempty(db_org)
    db_org = load_testdb('wc');
end

% mice ={'14.13.2.03', '14.13.2.04'};
mice ={'14.13.2.01'};
n_mice = length(mice);
man_frzs = NaN(30,30,2);
man_frz_dur = NaN(30,30,2);
for m = 1:n_mice
    db = db_org(find_record(db_org,['mouse='  mice{m}...
        ',(stim_type=*hawk*|stim_type=*full*|stim_type=*adv*)']));
    dates = unique({db.date});
    n_dates = length(dates);
    manstimstart = NaN(1,length(db));
    freezing_comment = NaN(length(db),1);
    freeze_duration = NaN(length(db),1);
    froze = NaN(length(db),1);
    duration = [];
    r = 1;
    max_freezing_starttime = 4; % 4 s
    min_freezing_starttime = -0.5; %-0.5; %s
    min_freezing_duration = 0.6;
    fs = [];
    ft = [];
    if ~isempty(strfind(db(1).stim_type,'hawk'))
        hawkstim = 1;
        discstim = 2;
    else
        hawkstim = 2;
        discstim = 1;
    end
    
    for s = 1:2
        switch s
            case  hawkstim
                dbs = db(find_record(db,'stim_type=*hawk*'));
                for d = 1:n_dates
                    dbday = dbs(find_record(dbs,['date=' dates{d}]));
                    for i= 1:length(dbday)
                        
                        measures = dbday(i).measures;
                        comment = dbday(i).comment;
                        stimstartframe = dbday(i).stimstartframe;
                        if isempty(measures) || ~isfield(measures,'freezetimes')...
                                || ~isfield(measures,'stimstart')
                            continue
                        end
                        if ~isempty(stimstartframe)
                            manstimstart(i) = (stimstartframe/30);
                            if isempty(measures.freezetimes)
                                froze(r) = false;
                            else
                                cfs =  measures.freezetimes(:,1) - manstimstart(i);
                                cft = measures.freezetimes(:,2) - measures.freezetimes(:,1);
                                
                                freeze_index = find(cfs>=min_freezing_starttime & ...
                                    cfs<max_freezing_starttime & ...
                                    measures.freeze_duration'>=min_freezing_duration);
                                froze(r) = ~isempty(freeze_index);
                            end
                        else
                            if isempty(measures.freezetimes)
                                froze(r) = false;
                            else
                                cfs =  measures.freezetimes(:,1) - measures.stimstart;
                                cft = measures.freezetimes(:,2) - measures.freezetimes(:,1);
                                
                                freeze_index = find(cfs>=min_freezing_starttime & ...
                                    cfs<max_freezing_starttime & ...
                                    measures.freeze_duration'>=min_freezing_duration);
                                froze(r) = ~isempty(freeze_index);
                            end
                        end
                        if isempty(comment)
                            continue
                        end
                        [q,p] = regexp(comment, 'frz|indetr');
                        freezing_comment(i) = ~isempty(p);
                        if ~isempty(freezing_comment(i)) && freezing_comment(i)~= 0
                            man_frzs(i,d,s) = 1;
                            %                     frz = comment(p-3:p+2);
                            frz = comment(p-5:p);
                            
                            if strcmp(frz,'detfrz')
                                man_frz_dur(i,d,s) = 1;
                            elseif strcmp(frz, 'indetr')
                                man_frzs(i,d,s) = NaN;
                                man_frz_dur(i,d,s) = NaN;
                            else
                                man_frz_dur(i,d,s) = str2num(frz(1:3)); %#ok<ST2NM>
                            end
%                             disp([frz ': ' num2str(freezing_time(r))]);
                        else
%                             disp('no manual measures availale');
                            man_frzs(i,d,s) = 0;
                            man_frz_dur(i,d,s) = 0;
                        end
                        day(r) = d; %#ok<SAGROW>
                        stimtype(r) = s; %#ok<SAGROW>
                        recs{r} = recordfilter(dbday(i)); %#ok<SAGROW>
                        
                        fs = [fs; cfs]; %#ok<AGROW>
                        ft = [ft; cft]; %#ok<AGROW>
                        
                        r = r+1;
                        
                        
                    end
                end
            case discstim
                dbs = db(find_record(db, 'stim_type!*hawk*'));
                for d = 1:n_dates
                    dbday = dbs(find_record(dbs,['date=' dates{d}]));
                    for i= 1:length(dbday)
                        
                        measures = dbday(i).measures;
                        comment = dbday(i).comment;
                        stimstartframe = dbday(i).stimstartframe;
                        if isempty(measures) || ~isfield(measures,'freezetimes')...
                                || ~isfield(measures,'stimstart')
                            continue
                        end
                        if ~isempty(stimstartframe)
                            manstimstart(i) = (stimstartframe/30);
                            if isempty(measures.freezetimes)
                                froze(r) = false;
                            else
                                cfs =  measures.freezetimes(:,1) - manstimstart(i);
                                cft = measures.freezetimes(:,2) - measures.freezetimes(:,1);
                                
                                freeze_index = find(cfs>=min_freezing_starttime & ...
                                    cfs<max_freezing_starttime & ...
                                    measures.freeze_duration'>=min_freezing_duration);
                                froze(r) = ~isempty(freeze_index);
                            end
                        else
                            if isempty(measures.freezetimes)
                                froze(r) = false;
                            else
                                cfs =  measures.freezetimes(:,1) - measures.stimstart;
                                cft = measures.freezetimes(:,2) - measures.freezetimes(:,1);
                                
                                freeze_index = find(cfs>=min_freezing_starttime & ...
                                    cfs<max_freezing_starttime & ...
                                    measures.freeze_duration'>=min_freezing_duration);
                                froze(r) = ~isempty(freeze_index);
                            end
                        end
                        if isempty(comment)
                            continue
                        end
                        [q,p] = regexp(comment, 'frz|indetr');
                        freezing_comment(i) = ~isempty(p);
                        if ~isempty(freezing_comment(i)) && freezing_comment(i)~= 0
                            man_frzs(i,d,s) = 1;
                            %                     frz = comment(p-3:p+2);
                            frz = comment(p-5:p);
                            
                            if strcmp(frz,'detfrz')
                                man_frz_dur(i,d,s) = 1;
                            elseif strcmp(frz, 'indetr')
                                man_frzs(i,d,s) = NaN;
                                man_frz_dur(i,d,s) = NaN;
                            else
                                man_frz_dur(i,d,s) = str2num(frz(1:3)); %#ok<ST2NM>
                            end
%                             disp([frz ': ' num2str(freezing_time(r))]);
                        else
%                             disp('no manual measures availale');
                            man_frzs(i,d,s) = 0;
                            man_frz_dur(i,d,s) = 0;
                        end
                        day(r) = d; %#ok<SAGROW>
                        stimtype(r) = s; %#ok<SAGROW>
                        recs{r} = recordfilter(dbday(i)); %#ok<SAGROW>
                        
                        fs = [fs; cfs]; %#ok<AGROW>
                        ft = [ft; cft]; %#ok<AGROW>
                        
                        r = r+1;
                        
                        
                    end
                end
        end
    end
end

frzstrname = ['man_frzs_', mice{1}, '.mat'];
durstrname = ['man_frz_dur_', mice{1}, '.mat'];
save(frzstrname, 'man_frzs');
save(durstrname, 'man_frz_dur');
