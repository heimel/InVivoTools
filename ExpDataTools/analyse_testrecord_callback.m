function newud=analyse_testrecord_callback( ud)
%ANALYSE_TESTRECORD_CALLBACK
%
%   NEWUD=ANALYSE_TESTRECORD_CALLBACK( UD)
%
% 2007-2014, Alexander Heimel

%warning('on','all');

record=ud.db(ud.current_record);

if get(ud.h.filter,'value') && length(ud.ind)>1 % i.e. filter on
    answer = questdlg('Analyse entire selection?','Analyse selection','Yes','No','No');
    if strcmp(answer,'Yes')
        newud = analyse_all_testrecord_callback(ud);
        newud.changed = 1;
        return
    end
end

if isfield(record,'experimenter') && isempty(record.experimenter)
    warndlg('Experimenter field is required.','Analyse testrecord callback');
    logmsg('Experimenter field is required.'); 
end


check_duplicates(record,ud.db,ud.current_record);

record = analyse_testrecord( record );

% insert analysed record into database
ud.changed=1;
ud.db(ud.current_record)=record;
set(ud.h.fig,'Userdata',ud);

% compute odi 
if isfield(record,'eye') && ( strcmp(record.eye,'ipsi') || strcmp(record.eye,'contra'))
    record = compute_odi_measures( record,ud.db);
    ud.db(ud.current_record)=record;
    set(ud.h.fig,'Userdata',ud);
end
        
        
% read analysed record from database into recordform
if ~isfield(ud,'no_callback')
    control_db_callback(ud.h.current_record);
    control_db_callback(ud.h.current_record);
end

% get analysed record from recordform and rewrite in database
if isfield(ud,'record_form')
    ud.db(ud.current_record)=get_record(ud.record_form);
end
set(ud.h.fig,'Userdata',ud);

% update recordform one more time with record from database
if ~isfield(ud,'no_callback')
    control_db_callback(ud.h.current_record);
    control_db_callback(ud.h.current_record);
end

results_testrecord( record);

ud.changed=1;
newud=ud;





