function newud=analyse_testrecord_callback( ud)
%ANALYSE_TESTRECORD_CALLBACK
%
%   NEWUD=ANALYSE_TESTRECORD_CALLBACK( UD)
%
% 2007-2014, Alexander Heimel

warning('on','all');

newud=ud;

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
    

switch record.datatype
    case {'oi','fp'} % intrinsic signal or flavoprotein
        record=analyse_oitestrecord( record );
    case 'ec'
        record=analyse_ectestrecord( record );
    case 'lfp'
        record=analyse_lfptestrecord( record );
    case {'tp','fret'}
        record=analyse_tptestrecord( record );
    case 'ls' % linescans
        record=analyse_lstestrecord( record );
    otherwise
        errormsg(['Unknown datatype ' record.datatype ]);
        return
end

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

newud=ud;

% call results_XXtestrecord to show results of analysis
switch record.datatype
    case {'oi','fp'}
        ud=results_oitestrecord( ud );
        set(ud.h.fig,'Userdata',ud);
    case 'ec'
        results_ectestrecord( ud.db(ud.current_record));
    case 'lfp'
        if ~isempty(record.measures) && ~strcmp(record.electrode,'wspectrum') % Mehran temporarily
            results_lfptestrecord( ud.db(ud.current_record) );
        end
    case 'tp'
        results_tptestrecord( ud.db(ud.current_record) );
    case 'ls'
        %results_lstestrecord( ud.db(ud.current_record) );
    otherwise
        errormsg(['Unknown datatype ' record.datatype ]);
        return
end

ud.changed=1;
newud=ud;





