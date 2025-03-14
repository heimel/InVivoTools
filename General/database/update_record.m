function success = update_record(record,h_dbfig,verbose)
%update_record. Updates record in open database
%
% SUCCESS = update_record(RECORD,H_DBFIG,VERBOSE=true)
%
%   finds open database control windows associated with DBNAME
%   finds record and updates the record
%
% 2025, Alexander Heimel

if nargin<3 || isempty(verbose)
    verbose = true;
end

success = false;

db_ud = get(h_dbfig,'userdata');
ind = find_record( db_ud.db, recordfilter(record));
if isempty(ind)
    if verbose
        logmsg(['Unable to update record. Could not find back ' recordfilter(record)])
    end
    return
end
if length(ind)>1
    if verbose
        logmsg(['Unable to update record. Multiple records fitting ' recordfilter(record)])
    end
    return
end

db_ud.db(ind) = record;
db_ud.changed = 1;
set(h_dbfig,'userdata',db_ud);
control_db_callback(db_ud.h.filter);
control_db_callback(db_ud.h.current_record);
if verbose
    logmsg(['Updated record nr ' num2str(ind) ' in open database']);
end
success = true;