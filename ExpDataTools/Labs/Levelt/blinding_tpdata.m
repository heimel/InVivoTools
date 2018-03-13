function [ud,rev_order] =  blinding_tpdata( ud, make_blind )
%
% 2011-2014, Alexander Heimel
%

if nargin<2
    make_blind = get(ud.h.blind,'value');
end

if isfield(ud,'db')
    db = ud.db(ud.ind); % only take selected records
    if length(ud.ind) == length(ud.db)
        logmsg('Blinding entire database. Perhaps you need to make a selection first.');
    end
else
    db = ud;
end

params = tpprocessparams( db(1) );

turn_blinds(ud,params,make_blind);

% get all unique stacks
stacks = cell(length(db),1);
rev_order = false(length(db),1);
for i = 1:length(db)
    stacks{i} = [db(i).mouse ':' db(i).stack];
    rev_order(i) = reverse_order(stacks{i},db(i));
end
stacks = uniq(sort(stacks));

% for all stacks sort slices and reverse if necessary
blind_db = db;

if ~params.blind_shuffle
    for s = 1:length(stacks)
        mouse = stacks{s}(1:find(stacks{s}==':')-1);
        stack = stacks{s}(find(stacks{s}==':')+1 : end);
        ind = find_record(db , ['mouse=' mouse ',stack=' stack]);
        if isfield(db,'slice') && ~isempty(ind)
            slices = {db(ind).slice};
            days = cellfun(@(x) str2double(x(4:end)), slices,'UniformOutput',false);
            days = [days{:}];
            if make_blind && ismember(stacks{s},params.blind_stacks_with_specific_shuffle(1:2:end))
                logmsg(['Using specified sorting for ' stacks{s}]);
                ind_r = strmatch(stacks{s},params.blind_stacks_with_specific_shuffle(1:2:end));
                ind_sort = params.blind_stacks_with_specific_shuffle{ind_r*2};
                if length(days)~=length(ind_sort)
                    errormsg(['Inconsistent number of days specified for blinding ' stacks{s}]);
                end
                days = days(ind_sort);
            elseif make_blind && reverse_order(stacks{s},db(ind(1)))
                %disp('reversing order')
                [days,ind_sort] = sort(days,2,'descend'); %#ok<ASGLU>
            else
                %disp('normal order')
                [days,ind_sort] = sort(days,2,'ascend'); %#ok<ASGLU>
            end
            blind_db(ind) = db(ind(ind_sort));
        end
    end
else
    if make_blind
        hash = zeros(length(db),1);
        for i=1:length(db)
            hash(i) = compute_hash(db(i));
        end
        if length(unique(hash))~=length(hash)
            uh = unique(hash);
            for i=1:length(uh)
                ind = find(hash==uh(i));
                if length(ind)>1
                    errormsg(['Records ' num2str(ind(1)) ' and ' num2str(ind(2)) ' have an identical hash. Change or remove entries.']);
                    turn_blinds(ud,params,false);
                    return
                end
            end
        end
        [~,ind] = sort(hash);
        blind_db = db(ind);
        if reverse_order('',blind_db(1))
            logmsg('Reversing the order');
            blind_db = blind_db(end:-1:1);
        end
    else
        blind_db = sort_db(db);
    end
end

if isfield(ud,'db')
    ud.db(ud.ind) = blind_db;
else
    ud = blind_db;
end

switch db(1).experiment % done for Rajeev by Mehran, sorting by comment
    case {'14.35'}
        logmgsg('Using alternate blinding sequence. Especially written for 14.35.');
        DB = zeros(length(db),1);
        for i=1:length(db)
            if any(isletter(db(i).comment))
                errormsg(['Remove non numerical entries from comment field in record ' num2str(i)])
                turn_blinds(ud,params,false);
                
            end
            DB(i) = str2double(db(i).comment);
        end
        sb=db;
        for i=1:length(db)
            sb(i)=db(DB==i);
        end
        ud.db(ud.ind) = sb;
end

function reverse = reverse_order( stackname, record )

switch record.experiment
    case '10.24'
        reverse = (sin(3*sum(double(stackname)))>0);
        % add exception because of invalid datapoint
        if strcmp(stackname,'10.24.1.27:tuft3')
            % disp('BLINDING_TPDATA: exception');
            reverse = true;
        end
    otherwise
        params = tpprocessparams(record);
        if isfield(params,'blind_reverse')
            reverse = params.blind_reverse;
        else
            reverse = false;
        end
        
        %logmsg(['Blinding reversed = ' num2str(reverse)]);
end

function hash = compute_hash(record)
hash = factorial(11)+helphash(record.mouse) + helphash(record.date) +...
    helphash(record.epoch) + helphash(record.stack) + ...
    helphash(record.slice);
hash = mod(hash^2,factorial(10)+1);

function hh = helphash( str )
if isempty(str)
    hh = 0;
else
    hh = str*2.^(1:length(str))';
end

function turn_blinds(ud,params,make_blind)
if make_blind
    vis = 'off';
else
    vis = 'on';
end

if isfield(ud,'record_form')
    for i = 1:length(params.blind_fields)
        objs = findobj(ud.record_form,'Tag',params.blind_fields{i});
        for obj = objs'
            set(obj,'Visible',vis);
        end
    end
end

