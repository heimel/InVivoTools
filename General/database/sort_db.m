function [db,ind,changed]=sort_db(db,alt_order,show_waitbar)
%SORT_DB sorts the records of a structarray by field order
%
%  [NEWDB,IND,CHANGED] = SORT_DB(DB,ALT_OLDER=[],VERBOSE=true)
%    uses quicksort only to sort first fields,
%    and bubblesort for all other fields, i.e. it is extremely slow
%     ALT_ORDER is an optional alternative ordering of the fields to use,
%     can be a subset of fields
%
%  2005-2019, Alexander Heimel
%

changed = false;

if isempty(db)
    ind = [];
    return
end

if nargin<3 || isempty(show_waitbar)
    show_waitbar = true;
end

if nargin<2 || isempty(alt_order)
    order=fieldnames(db(1));
else
    order=alt_order;
end

if ~iscell(order)
    order = {order};
end

n=length(db);
ind=(1:n);
list_is_sorted=0;

waiting = 0;
wait_interval = 1/n;
if show_waitbar
    hbar = waitbar(waiting,'Sorting');
end

% if first field is numeric, then we just borrow the matlab quicksort
% routine

if isnumeric(db(1).(order{1}))
    vals = [db.(order{1})];
    if length(vals)>length(db) %i.e. multiple columns
        vals = reshape(vals,numel(vals)/length(db),length(db))';
        vals = vals(:,1); % take first column
    end
    [~,ind] = sort(vals);
    db = db(ind);
elseif ischar(db(1).(order{1}))
    vals = {db.(order{1})};
    [~,ind] = sort(vals);
    db = db(ind);
end

pass=0;
while ~list_is_sorted
    %  swaps = 0;
    list_is_sorted=1;
    for i=1:n-1
        if later_record(db(i),db(i+1),order)
            rectemp=db(i);
            db(i)=db(i+1);
            db(i+1)=rectemp;
            
            indtemp=ind(i);
            ind(i)=ind(i+1);
            ind(i+1)=indtemp;
            
            list_is_sorted=0;
        elseif ~later_record(db(i+1),db(i),order)
           logmsg([ 'More than one record like ' recordfilter(db(i)) ]);
        end
    end
    pass=pass+1;
    
    waiting = pass * wait_interval;
    if show_waitbar
        waitbar(waiting,hbar);
    end
end
if show_waitbar
    close(hbar);
end
if pass>1
    changed = true;
end

return


function val=later_record(rec1,rec2,fields)
% returns 1 if rec1 is after rec2, when the first fields are higher

val=0;
for i=1:length(fields)
    f1 = rec1.(fields{i});
    f2 = rec2.(fields{i});
    
    if ~isnumeric(f1)  % for Levelt Lab only
        if strcmp(f1(1:min(5,end)),'mouse')==1 && strcmp(f2(1:min(5,end)),'mouse')==1
            % This is to sort mouse_E13 before mouse_E3
            % if a string contains digits, then ignore text and convert
            % to number.
            digits_ind1=find(f1<58 & f1>47);
            digits_ind2=find(f2<58 & f2>47);
            if ~isempty(digits_ind1) && ~isempty(digits_ind2)
                f1 = str2num( f1(digits_ind1) ); %#ok<ST2NM>
                f2 = str2num( f2(digits_ind2) ); %#ok<ST2NM>
            end
        end
        
    end
    
    if isempty(f1) && isempty(f2)
        % continue to next field
    elseif isnumeric(f1)
        if isempty(f1)
            val = 0;
            return
        end
        if isempty(f2)
            val = 1;
            return
        end
        if isnan(f1(1)) && ~isnan(f2(1))
            val = 1; % sort nans to end
            return
        end
        if f1(1)>f2(1)
            val=1;
            return
        elseif f1(1)<f2(1)
            val = 0;
            return
        end
        % else continue with comparison of next field
    elseif ischar(f1) && ischar(f2) && strcmp(f1,f2)==0
        sc=sort({f1,f2});
        if strcmp(sc{1},f1)==1
            val=0;
            return;
        else
            val=1;
            return;
        end
    end
end


