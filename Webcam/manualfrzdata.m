function manualfrzdata(subj, exp, expname)

% function takes the mouse number and saves a .mat file with the raw
%duration and angel data
% Azadeh June 2017
% clear all
host('tinyhat')
switch exp
    case 14.13
        
        if ~exist('db_org','var') || isempty(db_org) %#ok<NODEF>
            db_org = load_testdb('wc');
        end
        
        % mice ={'14.13.2.03', '14.13.2.04'};
        % mice ={'14.13.2.04'};
        mice = subj;
        n_mice = length(mice);
        man_frzs = NaN(30,30,2);
        man_frz_dur = NaN(30,30,2);
        % pos_theta = cell(30,30,2);
        % head_theta = cell(30,30,2);
        for m = 1:n_mice
            db = db_org(find_record(db_org,['mouse='  mice{m}...
                ',(stim_type=*hawk*|stim_type=*full*|stim_type=*adv*)']));
            dates = unique({db.date});
            n_dates = length(dates);
            manstimstart = NaN(1,length(db));
            freezing_comment = NaN(length(db),1);
            %     freeze_duration = NaN(length(db),1);
            froze = NaN(length(db),1);
            %     duration = [];
            r = 1;
            max_freezing_starttime = 4; % 4 s
            min_freezing_starttime = -0.5; %-0.5; %s
            min_freezing_duration = 0.6;
            fs = [];
            ft = [];
            if ~isempty(strfind(db(1).stim_type,'hawk'))
                hawkstim = 1;
                discsmal = 2;
            else
                hawkstim = 2;
                discsmal = 1;
            end
            
            for s = 1:2
                switch s
                    case  hawkstim
                        dbs = db(find_record(db,'stim_type=*hawk*'));
                        for d = 1:n_dates
                            d;
                            dbday = dbs(find_record(dbs,['date=' dates{d}]));
                            for i= 1:length(dbday)
                                i;
                                measures = dbday(i).measures;
                                comment = dbday(i).comment;
                                if ~isempty(measures) && isfield(measures,'mousemove')
                                    if ~isempty(measures.mousemove)
                                        mousemove = {measures.mousemove};
                                        %                                 else
                                        %                                     mousemove = [];
                                    end
                                end
                                
                                movement_data(i,d,s) = mousemove;
                                %                         x = {measures.pos_theta};
                                %                         jump = find(~cellfun(@isempty,x))
                                %                         if jump
                                %                         pos_theta(i,d,s) = {[NaN]};
                                %                         else
                                %                            pos_theta(i,d,s) = {measures.pos_theta};
                                %                            head_theta(i,d,s) = {measures.head_theta};
                                %                         end
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
                                            measures.freeze_duration'>=min_freezing_duration, 1);
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
                                            measures.freeze_duration'>=min_freezing_duration, 1);
                                        froze(r) = ~isempty(freeze_index);
                                    end
                                end
                                if isempty(comment)
                                    continue
                                end
                                [~,p] = regexp(comment, 'frz|indetr');
                                freezing_comment(i) = ~isempty(p);
                                if ~isempty(freezing_comment(i)) && freezing_comment(i)~= 0
                                    man_frzs(i,d,s) = 1;
                                    %                                                         pos_theta{i,d,s} = pos_theta;
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
                                %                         day(r) = d;
                                %                         stimtype(r) = s;
                                %                         recs{r} = recordfilter(dbday(i));
                                fs = [fs; cfs]; %#ok<AGROW>
                                ft = [ft; cft]; %#ok<AGROW>
                                r = r+1;
                            end
                        end
                    case discsmal
                        dbs = db(find_record(db, 'stim_type!*hawk*'));
                        for d = 1:n_dates
                            d;
                            dbday = dbs(find_record(dbs,['date=' dates{d}]));
                            for i= 1:length(dbday)
                                i;
                                measures = dbday(i).measures;
                                comment = dbday(i).comment;
                                if ~isempty(measures) && isfield(measures,'mousemove')
                                    if ~isempty(measures.mousemove)
                                        mousemove = {measures.mousemove};
                                        %                                 else
                                        %                                     mousemove = [];
                                    end
                                end
                                movement_data(i,d,s) = mousemove;
                                %                         if exist({measures.pos_theta})
                                %                         pos_theta(i,d,s) = {measures.pos_theta};
                                %                         head_theta(i,d,s) = {measures.head_theta};
                                %                         else
                                %                             continue
                                %                         end
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
                                            measures.freeze_duration'>=min_freezing_duration, 1);
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
                                            measures.freeze_duration'>=min_freezing_duration, 1);
                                        froze(r) = ~isempty(freeze_index);
                                    end
                                end
                                if isempty(comment)
                                    continue
                                    
                                end
                                [~,p] = regexp(comment, 'frz|indetr');
                                freezing_comment(i) = ~isempty(p);
                                if ~isempty(freezing_comment(i)) && freezing_comment(i)~= 0
                                    man_frzs(i,d,s) = 1;
                                    %                             pos_theta(i,d,s) = pos_theta_m;
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
                                %                         day(r) = d;
                                %                         stimtype(r) = s;
                                %                         recs{r} = recordfilter(dbday(i));
                                %
                                fs = [fs; cfs]; %#ok<AGROW>
                                ft = [ft; cft]; %#ok<AGROW>
                                r = r+1;
                            end
                        end
                end
            end
        end
        
        % frzstrname = ['man_frzs_', mice{1}, '.mat'];
        durstrname = ['man_frz_dur_', mice{1}, '.mat'];
        movstrname = ['mouse_move_', mice{1}, '.mat'];
        % angelname = ['pos_theta_', mice{1}, '.mat'];
        % h_angelname = ['head_theta_', mice{1}, '.mat'];
        % save(frzstrname, 'man_frzs');
        save(durstrname, 'man_frz_dur');
        % save(angelname, 'pos_theta');
        % save(h_angelname, 'head_theta');
        save(movstrname, 'movement_data');
   %%    
    case 172002.1
        if ~exist('db_org','var') || isempty(db_org)
            db_org = load_testdb('wc');
        end
        
        mice = subj;
        n_mice = length(mice);
        man_frzs = NaN(30,30,2);
        man_frz_dur = NaN(30,30,2);
        % pos_theta = cell(30,30,2);
        % head_theta = cell(30,30,2);
        for m = 1:n_mice
            m
            db = db_org(find_record(db_org,['mouse='  mice{m}...
                ',(stim_type=*disc*|stim_type=*hawk*|stim_type=*full*|stim_type=*adv*|stim_type=*_ellip*)']));
            if ~isempty(db)
                dates = unique({db.date});
                n_dates = length(dates);
                manstimstart = NaN(1,length(db));
                freezing_comment = NaN(length(db),1);
                %     freeze_duration = NaN(length(db),1);
                froze = NaN(length(db),1);
                %     duration = [];
                r = 1;
                max_freezing_starttime = 4; % 4 s
                min_freezing_starttime = -0.5; %-0.5; %s
                min_freezing_duration = 0.6;
                fs = [];
                ft = [];
             
                    
                    if ~isempty(strfind(db(1).stim_type,'disc_L'))||...
                            ~isempty(strfind(db(1).stim_type,'disc_R'));
                        discori = 1;
                        b_ellip = 2;
                    else
                        discori = 2;
                        b_ellip = 1;
                    end
                    for s = 1:2
                        switch s
                            case  discori
                                dbs = db(find_record(db,...
                                    '(stim_type=*disc_L*|stim_type=*disc_R*|stim_type=*disc-ori*|stim_type=*full*)'));
                                
                                for d = 1:n_dates
                                    d
                                    dbday = dbs(find_record(dbs,['date=' dates{d}]));
                                    for i= 1:length(dbday)
                                        i;
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
                                                    measures.freeze_duration'>=min_freezing_duration, 1);
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
                                                    measures.freeze_duration'>=min_freezing_duration, 1);
                                                froze(r) = ~isempty(freeze_index);
                                            end
                                        end
                                        if isempty(comment)
                                            continue
                                        end
                                        [~,p] = regexp(comment, 'frz|indetr');
                                        freezing_comment(i) = ~isempty(p);
                                        if ~isempty(freezing_comment(i)) && freezing_comment(i)~= 0
                                            man_frzs(i,d,s) = 1;
                                            %                                                         pos_theta{i,d,s} = pos_theta;
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
                                        %                         day(r) = d;
                                        %                         stimtype(r) = s;
                                        %                         recs{r} = recordfilter(dbday(i));
                                        fs = [fs; cfs]; %#ok<AGROW>
                                        ft = [ft; cft]; %#ok<AGROW>
                                        r = r+1;
                                    end
                                end
                            case b_ellip
                                dbs = db(find_record(db,...
                                    '(stim_type=*hawk*|stim_type=*disc_corrS*|stim_type=*disc_s*|stim_type=*_ellip*)'));
                                
                                for d = 1:n_dates
                                    d;
                                    dbday = dbs(find_record(dbs,['date=' dates{d}]));
                                    for i= 1:length(dbday)
                                        i;
                                        measures = dbday(i).measures;
                                        comment = dbday(i).comment;
                                        %                         if exist({measures.pos_theta})
                                        %                         pos_theta(i,d,s) = {measures.pos_theta};
                                        %                         head_theta(i,d,s) = {measures.head_theta};
                                        %                         else
                                        %                             continue
                                        %                         end
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
                                                    measures.freeze_duration'>=min_freezing_duration, 1);
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
                                                    measures.freeze_duration'>=min_freezing_duration, 1);
                                                froze(r) = ~isempty(freeze_index);
                                            end
                                        end
                                        if isempty(comment)
                                            continue
                                        end
                                        [~,p] = regexp(comment, 'frz|indetr');
                                        freezing_comment(i) = ~isempty(p);
                                        if ~isempty(freezing_comment(i)) && freezing_comment(i)~= 0
                                            man_frzs(i,d,s) = 1;
                                            %                             pos_theta(i,d,s) = pos_theta_m;
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
                                        %                         day(r) = d;
                                        %                         stimtype(r) = s;
                                        %                         recs{r} = recordfilter(dbday(i));
                                        %
                                        fs = [fs; cfs]; %#ok<AGROW>
                                        ft = [ft; cft]; %#ok<AGROW>
                                        r = r+1;
                                    end
                                end
                        end
                    end
                else
                    if~isempty(strfind(db(1).stim_type,'disc_L'))||...
                            ~isempty(strfind(db(1).stim_type,'disc_R'))||...
                            ~isempty(strfind(db(1).stim_type,'full'))||...
                            ~isempty(strfind(db(1).stim_type,'b_ellip'));
                        discori = 1;
                        discsmal = 2;
                        b_ellip = 1;
                        hawk = 2;
                    else
                        discori = 2;
                        discsmal = 1;
                        hawk = 1;
                        b_ellip = 2;
                    end
                    for s = 1:2
                        switch s
                            case  discori
                                dbs = db(find_record(db,...
                                    '(stim_type=*disc_L*|stim_type=*disc_R*|stim_type=*disc-ori*|stim_type=*full*|stim_type=*_ellip*)'));
                                
                                for d = 1:n_dates
                                    d
                                    dbday = dbs(find_record(dbs,['date=' dates{d}]));
                                    for i= 1:length(dbday)
                                        i;
                                        measures = dbday(i).measures;
                                        comment = dbday(i).comment;
                                        %                         x = {measures.pos_theta};
                                        %                         jump = find(~cellfun(@isempty,x))
                                        %                         if jump
                                        %                         pos_theta(i,d,s) = {[NaN]};
                                        %                         else
                                        %                            pos_theta(i,d,s) = {measures.pos_theta};
                                        %                            head_theta(i,d,s) = {measures.head_theta};
                                        %                         end
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
                                                    measures.freeze_duration'>=min_freezing_duration, 1);
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
                                                    measures.freeze_duration'>=min_freezing_duration, 1);
                                                froze(r) = ~isempty(freeze_index);
                                            end
                                        end
                                        if isempty(comment)
                                            continue
                                        end
                                        [~,p] = regexp(comment, 'frz|indetr');
                                        freezing_comment(i) = ~isempty(p);
                                        if ~isempty(freezing_comment(i)) && freezing_comment(i)~= 0
                                            man_frzs(i,d,s) = 1;
                                            %                                                         pos_theta{i,d,s} = pos_theta;
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
                                        %                         day(r) = d;
                                        %                         stimtype(r) = s;
                                        %                         recs{r} = recordfilter(dbday(i));
                                        fs = [fs; cfs]; %#ok<AGROW>
                                        ft = [ft; cft]; %#ok<AGROW>
                                        r = r+1;
                                    end
                                end
                            case hawk
                                dbs = db(find_record(db,...
                                    '(stim_type=*hawk*|stim_type=*disc_corrS*|stim_type=*disc_s*)'));
                                
                                for d = 1:n_dates
                                    d;
                                    dbday = dbs(find_record(dbs,['date=' dates{d}]));
                                    for i= 1:length(dbday)
                                        i;
                                        measures = dbday(i).measures;
                                        comment = dbday(i).comment;
                                        %                         if exist({measures.pos_theta})
                                        %                         pos_theta(i,d,s) = {measures.pos_theta};
                                        %                         head_theta(i,d,s) = {measures.head_theta};
                                        %                         else
                                        %                             continue
                                        %                         end
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
                                                    measures.freeze_duration'>=min_freezing_duration, 1);
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
                                                    measures.freeze_duration'>=min_freezing_duration, 1);
                                                froze(r) = ~isempty(freeze_index);
                                            end
                                        end
                                        if isempty(comment)
                                            continue
                                        end
                                        [~,p] = regexp(comment, 'frz|indetr');
                                        freezing_comment(i) = ~isempty(p);
                                        if ~isempty(freezing_comment(i)) && freezing_comment(i)~= 0
                                            man_frzs(i,d,s) = 1;
                                            %                             pos_theta(i,d,s) = pos_theta_m;
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
                                        %                         day(r) = d;
                                        %                         stimtype(r) = s;
                                        %                         recs{r} = recordfilter(dbday(i));
                                        %
                                        fs = [fs; cfs]; %#ok<AGROW>
                                        ft = [ft; cft]; %#ok<AGROW>
                                        r = r+1;
                                    end
                                end
                        end
                    end
               
            end
        end
        %             else errormsg('no record for this mouse')
        %                 continue
        %
        %             end
        
    case 172005.1
        
        if ~exist('db_org','var') || isempty(db_org) %#ok<NODEF>
            db_org = load_testdb('wc');
        end
        
        mice = subj;
        n_mice = length(mice);
        man_frzs = NaN(30,30,2);
        man_frz_dur = NaN(30,30,2);
        % pos_theta = cell(30,30,2);
        % head_theta = cell(30,30,2);
        for m = 1:n_mice
            db = db_org(find_record(db_org,['mouse='  mice{m}...
                ',(stim_type=*hawk*|stim_type=*full*|stim_type=*adv*)|stim_type=*disc*)']));
            dates = unique({db.date});
            n_dates = length(dates);
            manstimstart = NaN(1,length(db));
            freezing_comment = NaN(length(db),1);
            %     freeze_duration = NaN(length(db),1);
            froze = NaN(length(db),1);
            %     duration = [];
            r = 1;
            max_freezing_starttime = 4; % 4 s
            min_freezing_starttime = -0.5; %-0.5; %s
            min_freezing_duration = 0.6;
            fs = [];
            ft = [];
            if ~isempty(strfind(db(1).stim_type,'hawk'))
                hawkstim = 1;
                discsmal = 2;
            else
                hawkstim = 2;
                discsmal = 1;
            end
            
            for s = 1:2
                switch s
                    case  hawkstim
                        dbs = db(find_record(db,'stim_type=*hawk*'));
                        for d = 1:n_dates
                            d;
                            dbday = dbs(find_record(dbs,['date=' dates{d}]));
                            for i= 1:length(dbday)
                                i;
                                measures = dbday(i).measures;
                                comment = dbday(i).comment;
                                if ~isempty(measures) && isfield(measures,'mousemove')
                                    if ~isempty(measures.mousemove)
                                        mousemove = {measures.mousemove};
                                        %                                 else
                                        %                                     mousemove = [];
                                    end
                                end
                                
                                movement_data(i,d,s) = mousemove;
                                %                         x = {measures.pos_theta};
                                %                         jump = find(~cellfun(@isempty,x))
                                %                         if jump
                                %                         pos_theta(i,d,s) = {[NaN]};
                                %                         else
                                %                            pos_theta(i,d,s) = {measures.pos_theta};
                                %                            head_theta(i,d,s) = {measures.head_theta};
                                %                         end
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
                                            measures.freeze_duration'>=min_freezing_duration, 1);
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
                                            measures.freeze_duration'>=min_freezing_duration, 1);
                                        froze(r) = ~isempty(freeze_index);
                                    end
                                end
                                if isempty(comment)
                                    continue
                                end
                                [~,p] = regexp(comment, 'frz|indetr');
                                freezing_comment(i) = ~isempty(p);
                                if ~isempty(freezing_comment(i)) && freezing_comment(i)~= 0
                                    man_frzs(i,d,s) = 1;
                                    %                                                         pos_theta{i,d,s} = pos_theta;
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
                                %                         day(r) = d;
                                %                         stimtype(r) = s;
                                %                         recs{r} = recordfilter(dbday(i));
                                fs = [fs; cfs]; %#ok<AGROW>
                                ft = [ft; cft]; %#ok<AGROW>
                                r = r+1;
                            end
                        end
                    case discsmal
                        dbs = db(find_record(db, 'stim_type!*hawk*'));
                        for d = 1:n_dates
                            d;
                            dbday = dbs(find_record(dbs,['date=' dates{d}]));
                            for i= 1:length(dbday)
                                i;
                                measures = dbday(i).measures;
                                comment = dbday(i).comment;
                                if ~isempty(measures) && isfield(measures,'mousemove')
                                    if ~isempty(measures.mousemove)
                                        mousemove = {measures.mousemove};
                                        %                                 else
                                        %                                     mousemove = [];
                                    end
                                end
                                movement_data(i,d,s) = mousemove;
                                %                         if exist({measures.pos_theta})
                                %                         pos_theta(i,d,s) = {measures.pos_theta};
                                %                         head_theta(i,d,s) = {measures.head_theta};
                                %                         else
                                %                             continue
                                %                         end
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
                                            measures.freeze_duration'>=min_freezing_duration, 1);
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
                                            measures.freeze_duration'>=min_freezing_duration, 1);
                                        froze(r) = ~isempty(freeze_index);
                                    end
                                end
                                if isempty(comment)
                                    continue
                                    
                                end
                                [~,p] = regexp(comment, 'frz|indetr');
                                freezing_comment(i) = ~isempty(p);
                                if ~isempty(freezing_comment(i)) && freezing_comment(i)~= 0
                                    man_frzs(i,d,s) = 1;
                                    %                             pos_theta(i,d,s) = pos_theta_m;
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
                                %                         day(r) = d;
                                %                         stimtype(r) = s;
                                %                         recs{r} = recordfilter(dbday(i));
                                %
                                fs = [fs; cfs]; %#ok<AGROW>
                                ft = [ft; cft]; %#ok<AGROW>
                                r = r+1;
                            end
                        end
                end
            end
        end
        
        % frzstrname = ['man_frzs_', mice{1}, '.mat'];
        durstrname = ['man_frz_dur_', mice{1}, '.mat'];
        movstrname = ['mouse_move_', mice{1}, '.mat'];
        % angelname = ['pos_theta_', mice{1}, '.mat'];
        % h_angelname = ['head_theta_', mice{1}, '.mat'];
        % save(frzstrname, 'man_frzs');
        save(durstrname, 'man_frz_dur');
        % save(angelname, 'pos_theta');
        % save(h_angelname, 'head_theta');
        save(movstrname, 'movement_data');
        
end



% frzstrname = ['man_frzs_', mice{1}, '.mat'];
durstrname = ['man_frz_dur_', mice{1}, '.mat'];
% angelname = ['pos_theta_', mice{1}, '.mat'];
% h_angelname = ['head_theta_', mice{1}, '.mat'];
% save(frzstrname, 'man_frzs');
save(durstrname, 'man_frz_dur');
% save(angelname, 'pos_theta');
% save(h_angelname, 'head_theta');
