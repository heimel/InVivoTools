function [refrecord, ind_ref] = tp_get_refrecord( record,cycling )
%TP_GET_REFRECORD retrieves reference record for specified record
%
%   [REFRECORD, IND_REF] = TP_GET_REFRECORD( RECORD,CYCLING )
%       if CYCLING (true by default) then it will return the last record
%       in a series as reference for the first
%
%
% 2013, Alexander Heimel
%
refrecord = [];

if nargin<2
    cycling = [];
end
if isempty(cycling)
    cycling = true;
end


% check to see if it is open
 h_db = get_fighandle('TP database*');
if isempty( h_db ) % not open, load from disk
    db = load_testdb(expdatabases( 'tp' ));
        else
    ud = get(h_db,'userdata');
    db=ud.db;
end

if ~isempty(record.ref_epoch)
    if ~isempty(find(record.ref_epoch=='=',1))
        crit = record.ref_epoch;
    else
        crit = ['mouse=' record.mouse ',stack=' record.stack ',epoch=' record.ref_epoch];
    end
    ind_ref = find_record(db,crit);
else
    crit = ['mouse=' record.mouse ',stack=' record.stack ];
    ind_ref = find_record(db,crit);
    crit_current = [crit ',date=' record.date ',slice=' record.slice ];
    ind_cur = find_record(db,crit_current);
    if length(ind_cur)>1
        crit_current = [crit_current ',epoch=' record.epoch];
        ind_cur = find_record(db,crit_current);
    end    
    if length(ind_cur)>1
        crit_current = [crit_current ',comment=' record.comment];
        ind_cur = find_record(db,crit_current);
    end    
    if length(ind_cur)>1
        disp(['TP_GET_REFRECORD. Can not single out current record ' crit_current '. Not returning a reference.']);
        if ~isempty(record.slice)
            errordlg('Can not single out current record. Not returning a reference.','TP_get_refrecord');
            return
        end
    end
    if length(ind_cur)<1
        disp('TP_GET_REFRECORD. Can not find current record. Should not happen. Not returning a reference.');
        if ~isempty(record.slice)
            errordlg('Can not single out current record. Not returning a reference.','TP_get_refrecord');
            return
        end
    end
    ind_prev = sort(ind_ref(ind_ref<min(ind_cur)));
    if ~isempty(ind_prev)
        ind_ref = ind_prev;
    elseif cycling
        disp('TP_GET_REFRECORD. No record before current one. Assuming cycle and taking last record instead.');
        ind_next = sort(ind_ref(ind_ref>max(ind_cur)));
        if ~isempty(ind_next)
            ind_ref = ind_next(end);
%         else
%             disp('TP_GET_REFRECORD. Also no record after current one. Taking current record.');
%             ind_ref = ind_cur;
        end
        else
       ind_ref = [];
    end
end




    
if isempty(ind_ref)
    disp(['TP_GET_REFRECORD: No reference record. ' crit]);
    return
end

if length(ind_ref)>1
    disp('TP_GET_REFRECORD: More than one reference record. Returning last one');
end

% select last record of selection
ind_ref = ind_ref(end);
refrecord = db(ind_ref);

disp(['TP_GET_REFRECORD: returning record associated with ' tpfilename(refrecord)]);