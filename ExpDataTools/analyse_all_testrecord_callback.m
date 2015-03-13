function newud = analyse_all_testrecord_callback( ud)
%ANALYSE_ALL_TESTRECORD
%
%   NEWUD=ANALYSE_ALL_TESTRECORD( UD)
%
% 2007-2015, Alexander Heimel
global stop_analysis
stop_analysis = false;

newud = ud;

logmsg('Started');

tic
h_wait = waitbar(0,['Analysing ' num2str(length(ud.ind)) ' records...'],...
    'CreateCancelBtn','delete(gcbo);global stop_analysis;stop_analysis=true;disp(''ANALYSE_ALL_TESTRECORD_CALLBACK: Stopping analysis...'');');

for count=1:length(ud.ind)
    if count>1
        togo=(length(ud.ind)-count+1)*(elapsed/(count-1)); % s
    else
        togo = 60 *length(ud.ind) ; % s, assume record takes 1 minute
    end
       
    i=ud.ind(count);
    nu = clock;
    nu(end) = nu(end)+togo;
    msg = ['Analyzing record ' num2str(i) ' (' num2str(count) ' of ' ...
        num2str(length(ud.ind)) '). ' ... 
        'Expected finish: ' datestr(datenum(nu),'HH:MM:SS') ];
    drawnow
     try
    if ishandle(h_wait) && ~stop_analysis
        waitbar(count/length(ud.ind),h_wait,msg);
        drawnow;
    else
        stop_analysis = true;
        break
    end
     catch me
         me.message
         stop_analysis = false;
     end
        logmsg( msg);
    switch ud.db(i).datatype
        case {'ec','lfp'}
            ud.db(i)=analyse_testrecord( ud.db(i), false);
            if strcmp(ud.db(i).eye,'ipsi') || strcmp(ud.db(i).eye,'contra')
                ud.db(i) = compute_odi_measures( ud.db(i),ud.db);
            end
        otherwise
            ud.db(i)=analyse_testrecord( ud.db(i), false);
    end
    elapsed=toc;
    ud.changed=1;
    set(ud.h.fig,'Userdata',ud);
 end
if ishandle(h_wait)
    close(h_wait);
end
if stop_analysis
    msg = ['Analyzed record ' num2str(i) ' ( ' num2str(count) ' of ' num2str(length(ud.ind)) ')' ];
    logmsg(msg);
end

% update control_db figure userdate
ud.changed=1;
set(ud.h.fig,'Userdata',ud);

% read analysed record from database into recordform
if ~isfield(ud,'no_callback')
    control_db_callback(ud.h.current_record);
    control_db_callback(ud.h.current_record);
end

newud=ud;

logmsg('Finished');




