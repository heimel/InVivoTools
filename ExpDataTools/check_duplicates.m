function check_duplicates(record,db,curnum)
%CHECK_DUPLICATES check for duplicates of current record
%
%  CHECK_DUPLICATES( RECORD, DB, CURNUM)
%
% 2015, Alexander Heimel

filt = recordfilter(record);
ind = setdiff(find_record(db,filt), curnum);
for i = ind
    [c,flds] = structdiff(record,db(i));
    if c
        errormsg( ['Current record ' num2str(curnum) ' and record ' num2str(i) ' appear identical. ' recordfilter(record)]);
        continue
    end
    logmsg(['Record ' num2str(i) ' only differs in fields ' cell2str(flds)]);
    for f = 1:length(flds)
        field = db(i).(flds{f});
        switch class(field)
            case 'char'
                logmsg(['Record ' num2str(i) ' ' flds{f} ' = ' field]);
        end
    end

    if (length(flds)==1 && flds=={'ROIs'}) || (length(flds)==2 && flds=={'ROIs','measures'})
        warning('CHECK_DUPLICATES:ONLY_ROIS_DIFFER',['Record ' num2str(i) ' only differs in fields ' cell2str(flds)]);
        if isfield(record,'ROIs') && isfield(record.ROIs,'celllist')
            curroinum = length(record.ROIs.celllist);
            logmsg(['Current record has ' num2str(curroinum) ' ROIs']);
            if isfield(db(i),'ROIs') && isfield(db(i).ROIs,'celllist')
                otherroinum =length(db(i).ROIs.celllist);
                logmsg(['Record ' num2str(i) ' has ' num2str(otherroinum) ' ROIs']);
                logmsg(['Different ROI numbers ' num2str(setdiff([db(i).ROIs.celllist.index],[record.ROIs.celllist.index]))]);
            end
        end
    end
end

