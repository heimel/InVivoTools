function control_db_callback( cbo )
%CONTROL_DB_CALLBACK
%
%  CONTROL_DB_CALLBACK( CBO )
%    handles callbacks for CONTROL_DB
%
% 2005-2014, Alexander Heimel
%

try
    action=get(cbo,'Tag');
catch
    % window must have been closed already
    return
end

h_fig=get(cbo,'Parent');
ud=get(h_fig,'UserData');
windowname=get(h_fig,'Name');

switch windowname
    case 'Record'
        h_dbfig=ud.db_form;
        ud=get(h_dbfig,'UserData');
        ud.db(ud.current_record)=get_record(ud.record_form);
        ud.changed=1;
        set(h_dbfig,'Userdata',ud);
        control_db_callback(ud.h.current_record);
    otherwise %  Database control
        switch action
            case 'current'
                current_record = str2double(get(ud.h.current_record,'String'));
                if isempty(current_record)
                    current_record=0;
                end
                if current_record ~= round(current_record) || current_record<1
                    current_record=1;
                end
                if current_record > length(ud.db)
                    current_record=length(ud.db);
                    if isempty(ud.db)
                        delete(ud.record_form);
                        %close(ud.record_form);
                        ud.record_form=[];
                        set(h_fig,'Userdata',ud);
                        return
                    end
                end
                if current_record==ud.ind(1)
                    set(ud.h.prev,'Enable','off');
                    set(ud.h.first,'Enable','off');
                else
                    set(ud.h.prev,'Enable','on');
                    set(ud.h.first,'Enable','on');
                end
                if current_record==ud.ind(end)
                    set(ud.h.next,'Enable','off');
                    set(ud.h.last,'Enable','off');
                else
                    set(ud.h.next,'Enable','on');
                    set(ud.h.last,'Enable','on');
                end
                ud.current_record=current_record;
                set(ud.h.current_record,'String',num2str(ud.current_record));
                ud.record_form=show_record(ud.db(ud.current_record), ...
                    ud.record_form,h_fig);
                
                % set db form in userdata in record_form userdata
                record_ud=get(ud.record_form,'UserData');
                record_ud.db_form=h_fig;
                set(ud.record_form,'UserData',record_ud);
                set(ud.record_form,'Tag','control_db_callback');
                if ~ud.changed
                    set(ud.h.save,'Enable','off');
                else
                    % disable save button if perm = 'ro'
                    if strcmp(ud.perm,'ro')==0
                        set(ud.h.save,'Enable','on');
                    else
                        set(ud.h.save,'Enable','off');
                    end
                end
                set(h_fig,'Userdata',ud);
            case 'next'
                i=findclosest( ud.ind,ud.current_record);
                if ud.current_record<ud.ind(i)
                    ud.current_record=ud.ind(i);
                elseif i<length(ud.ind)
                    ud.current_record=ud.ind(i+1);
                end
                
                set(ud.h.current_record,'String',num2str(ud.current_record));
                control_db_callback(ud.h.current_record);
            case 'previous'
                i=findclosest( ud.ind,ud.current_record);
                if ud.current_record>ud.ind(i)
                    ud.current_record=ud.ind(i);
                elseif i>1
                    ud.current_record=ud.ind(i-1);
                end
                set(ud.h.current_record,'String',num2str(ud.current_record));
                control_db_callback(ud.h.current_record);
            case 'duplicate'
                record = get_record(ud.record_form);
                if isfield(record,'measures') && isstruct(record.measures) % not copying measures
                    record.measures = [];
                end
                ud.db=insert_record(ud.db,record, ...
                    ud.current_record+1);
                set(ud.h.current_record,'String',num2str(ud.current_record+1));
                ud.ind=(1:length(ud.db));
                ud.changed=1;
                set(h_fig,'Userdata',ud);
                control_db_callback(ud.h.filter);
                control_db_callback(ud.h.current_record);
                
            case 'delete'
                if get(ud.h.filter,'value')
                    answer = questdlg('Delete single record or full selection?',...
                        'Delete','Single','Selection','Cancel','Single');
                else
                    answer = 'Single';
                end
                switch answer
                    case 'Single'
                        ud.db=del_record(ud.db,ud.current_record);
                    case 'Selection'
                        ud.db=del_record(ud.db,ud.ind);
                        set(ud.h.filter,'Value',0)
                    case 'Cancel'
                        return
                end
                ud.changed=1;
                ud.ind=(1:length(ud.db));
                set(h_fig,'Userdata',ud);
                control_db_callback(ud.h.filter);
                control_db_callback(ud.h.current_record);
            case 'first'
                set(ud.h.current_record,'String',num2str( ud.ind(1) ));
                control_db_callback(ud.h.current_record);
                
            case 'last'
                set(ud.h.current_record,'String',num2str( ud.ind(end)  ) );
                control_db_callback(ud.h.current_record);
                
            case 'new'
                new_record=empty_record(ud.db);
                init = get(ud.h.crit,'String');
                if ~isempty(init)
                    if ~any(init=='=')
                        f = fieldnames(ud.db);
                        init = [f{1} '=' init];
                    end
                end
                new_record=set_record(new_record,init);
                ud.db=insert_record(ud.db,new_record, ...
                    ud.current_record+1);
                ud.changed=1;
                ud.ind=(1:length(ud.db));
                set(h_fig,'Userdata',ud);
                control_db_callback(ud.h.filter);
                set(ud.h.current_record,'String',num2str(ud.current_record+1));
                control_db_callback(ud.h.current_record);
            case 'filter'
                val=get(ud.h.filter,'Value');
                if val==0
                    ud.ind=(1:length(ud.db));
                else
                    crit = strtrim(get(ud.h.crit,'String'));
                    if isempty(crit)
                        logmsg('Empty filter criteria');
                        set(ud.h.filter,'Value',0);
                        control_db_callback(ud.h.current_record);
                        return
                    end
                    ind=find_record(ud.db,crit);
                    if ~isempty(ind)
                        ud.ind=ind;
                        i=findclosest( ud.ind,ud.current_record);
                        set(ud.h.current_record,'String',num2str(ud.ind(i)));
                    else
                        errormsg('No records found matching filter');
                        set(ud.h.filter,'Value',0);
                        ud.ind=(1:length(ud.db));
                    end
                end
                
                if length(ud.ind)~=length(ud.db)
                    set(ud.h.count,'String',[ num2str(length(ud.ind)) ...
                        ' (' num2str(length(ud.db)) ')']);
                else
                    set(ud.h.count,'String',num2str(length(ud.db)));
                end
                
                set(h_fig,'UserData',ud);
                control_db_callback(ud.h.current_record);
            case 'crit'
                filtering = get(ud.h.filter,'value');
                if ~filtering
                    set(ud.h.filter,'value',1);
                end
                control_db_callback(ud.h.filter);
                
            case 'dump'
                dump_db(ud.db(ud.ind));
                
            case 'sort'
                btn=questdlg('Do you want to sort the database','Sort database','Ok','Cancel','Ok');
                if strcmp(btn,'Ok')
                    fprintf('Sorting data....');
                    [ud.db,ind_sort]=sort_db(ud.db);
                    if sum( abs( (1:length(ud.db))-ind_sort))>0
                        ud.changed=1;
                    end
                    set(h_fig,'UserData',ud);
                    set(ud.h.current_record,'String',...
                        num2str( find(ind_sort==ud.current_record)));
                    control_db_callback(ud.h.filter);
                    control_db_callback(ud.h.current_record);
                    fprintf('\nDone\n');
                end
            case 'reverse'
                if get(ud.h.filter,'Value')==0
                    errormsg('Turn on a filter to reverse.');
                    return
                end
                btn=questdlg('Do you want to reverse the selection?','Reverse database','Ok','Cancel','Ok');
                if strcmp(btn,'Ok')
                    ud.db(ud.ind)=ud.db(ud.ind(end:-1:1));
                    ud.change = 1;
                    set(h_fig,'UserData',ud);
                    set(ud.h.current_record,'String',...
                        num2str( length(ud.db) - ud.current_record +1));
                    control_db_callback(ud.h.filter);
                    control_db_callback(ud.h.current_record);
                end
            case 'load'
                if ~isempty(ud.db) && ~isempty(ud.filename) && ~isempty(find(ud.perm=='w',1))
                    rmlock(ud.filename);
                end
                [ud.db,ud.filename,ud.perm,ud.lockfile]=open_db( '',fileparts(ud.filename));
                if ~isempty(ud.db) && ~isnumeric(ud.filename)
                    delete(ud.record_form);
                    ud.record_form=[];
                    set(ud.h.current_record,'String','1');
                    ud.changed=0;
                    ud.ind=(1:length(ud.db));
                    set(h_fig,'Userdata',ud);
                    set_control_name(h_fig);
                    control_db_callback(ud.h.filter);
                    control_db_callback(ud.h.current_record);
                end
            case 'import'
                curpath=pwd; % save working directory
                if ~isempty(ud.filename) && exist(fileparts(ud.filename),'dir')
                    cd(fileparts(ud.filename));
                end
                [filename,pathname]=uigetfile({'*.mat','MATLAB Files (*.mat)'},'Load database');
                if isnumeric(filename) % i.e. unsuccessful
                    return
                end
                filename=fullfile(pathname,filename);
                imported = load(filename);
                if ~isempty(ud.db)
                    imported.db = structconvert(imported.db,ud.db);
                end
                try
                    if ud.h.current_record<length(ud.db)
                        ud.db = [ud.db(1:ud.current_record) imported.db ud.db(ud.current_record+1:end)];
                    else
                        ud.db = [ud.db imported.db];
                    end
                catch me
                    switch me.identifier
                        case 'MATLAB:catenate:structFieldBad'
                            errormsg('Unable to import database saved in different formats. Try loading and resaving the to-be-imported database before importing.');
                        otherwise
                            rethrow(me)
                    end
                end
                cd(curpath); % change back to working directory
                ud.changed=1;
                ud.ind=(1:length(ud.db));
                set(h_fig,'Userdata',ud);
                control_db_callback(ud.h.filter);
                control_db_callback(ud.h.current_record);
            case 'save'
                if isempty(ud.filename)
                    control_db_callback(ud.h.save_as);
                    return
                end
                if strcmp(ud.perm,'ro')==1
                    control_db_callback(ud.h.save_as);
                    return
                end
                [ud.filename,ud.lockfile]=save_db(ud.db,ud.filename,'',ud.lockfile);
                ud.changed=0;
                set(h_fig,'Userdata',ud);
                control_db_callback(ud.h.current_record);
            case 'save as' % now export
                if get(ud.h.filter,'value')
                    answer = questdlg('Save all records or the selection only?',...
                        'Save as','All','Selection','Cancel','All');
                else
                    answer = 'All';
                end
                switch answer
                    case 'All'
                        db = ud.db;
                    case 'Selection'
                        db = ud.db(ud.ind);
                    case 'Cancel'
                        return
                end
                filename = save_db(db,'', ud.filename,ud.lockfile );
                
                if ~isnumeric(filename) %i.e. successful
                    rmlock(filename);
                end
            case 'help'
                help_url = 'https://github.com/heimel/InVivoTools/wiki';
                logmsg(['Opening ' help_url ' in default browser.']);
                web(help_url,'-browser');
                
                global global_db global_record
                global_db = ud.db;
                global_record = ud.db(ud.current_record);
                evalin('base','global global_db global_record');
                errormsg('Database and record available as global_db and global_record');
            case 'close'
                if ud.changed==1 % changes to be saved
                    answer=questdlg('Do you want to save changes?',...
                        'Close Database control','Yes');
                    switch answer
                        case 'Yes'
                            control_db_callback(ud.h.save);
                        case 'No'
                            % do nothing
                        case 'Cancel'
                            return
                    end
                end
                if ~isempty(ud.record_form)
                    try
                        delete(ud.record_form);
                        ud.record_form=[];
                        set(h_fig,'Userdata',ud);
                    end
                end
                if ~isempty(find(ud.perm=='w',1))
                    rmlock(ud.filename);
                end
                if ishandle(h_fig)
                    set(h_fig,'CloseRequestFcn','closereq');
                    close(h_fig);
                end
            case 'close figs'
                close_figs;
            case 'table'
                show_table(ud.db(ud.ind));
            otherwise
                if ~isempty(action)
                    ud = feval(action,ud );
                    set(h_fig,'Userdata',ud);
                    control_db_callback(ud.h.current_record);
                end
        end
end





