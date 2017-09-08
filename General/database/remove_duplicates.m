function db = remove_duplicates(db,flds,keep,keep_criterium)
%REMOVE_DUPLICATES removes duplicates from db
%
% DB = REMOVE_DUPLICATES(DB,FLDS,KEEP,KEEP_CRITERIUM)
%     FLDS is cell list of field names to use. Empty uses all
%     KEEP is 'first','last' (default),'keep_criterium'
%       for KEEP is 'all', no duplicates are removed only shown
%     KEEP_CRITERIUM is selectium criterium used if KEEP is
%     'keep_criterium'. If none fits the keep criterium, it will keep the
%     last
%
% 2013-2017, Alexander Heimel, Daan van Versendaal
%

if nargin<2 || isempty(flds)
    flds = fields(db);
end
if nargin<3 || isempty(keep)
    keep = 'all';
end

remove = false(length(db),1);
for i=1:length(db)
    crit  = '';
    for f = 1:length(flds)
        val = db(i).(flds{f});
        if iscell(val) || isstruct(val) || isnumeric(val)
            continue
        end
        if ~isempty(crit)
            crit = [crit ','];
        end
        crit = [crit flds{f} '="' val '"'];
    end
    ind = find_record(db,crit);
    if isempty(ind)
        errordlg('Could not find original record.' ,'Remove duplicates');
        return
    end
    if length(ind)>1
        switch lower(keep)
            case 'all'
                % do nothing
                logmsg(['Duplicate record fitting ' crit]);
            case 'first' 
                remove(ind) = 1;
                remove(ind(1)) = 0;
            case 'last'
                remove(ind) = 1;
                remove(ind(end)) = 0;
            case 'keep_criterium'
                remove(ind) = 1;
                keepind = find_record(db(ind),keep_criterium);
                if ~isempty(keepind)
                    remove(ind(keepind)) = 0;
                else
                    remove(ind(end)) = 0;
                end
        end
    end
end
db(remove) = [];



