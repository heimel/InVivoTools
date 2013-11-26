function [ud,rev_order] =  blinding_tpdata( ud, make_blind )
%
% 2011, Alexander Heimel
%

if nargin<2
    make_blind = get(ud.h.blind,'value');
end

if isfield(ud,'db')
    db = ud.db;
else 
    db = ud;
end
    
    
if make_blind
    vis = 'off';
else
    vis = 'on';
end

blind_fields = {'date','slice','laser','location','comment'};
if isfield(ud,'record_form')
    for i = 1:length(blind_fields)
        objs = findobj(ud.record_form,'Tag',blind_fields{i});
        for obj = objs'
            set(obj,'Visible',vis);
        end
    end
end

% get all unique stacks
stacks = {};
for i = 1:length(db)
    stacks{i} = [db(i).mouse ':' db(i).stack];
    rev_order(i) = reverse_order(stacks{i});
end
stacks = uniq(sort(stacks));

% for all stacks sort slices and reverse if necessary
blind_db = db;

    for s = 1:length(stacks)
        mouse = stacks{s}(1:find(stacks{s}==':')-1);
        stack = stacks{s}(find(stacks{s}==':')+1 : end);
        ind = find_record(db , ['mouse=' mouse ',stack=' stack]);

        if isfield(db,'slice')
            slices = {db(ind).slice};
            days = cellfun(@(x) str2double(x(4:end)), slices,'UniformOutput',false);
            days = [days{:}];
            
            if make_blind && reverse_order(stacks{s})
                %disp('reversing order')
                [days,ind_sort] = sort(days,2,'descend'); %#ok<ASGLU>
            else
                %disp('normal order')
                [days,ind_sort] = sort(days,2,'ascend'); %#ok<ASGLU>
            end
            blind_db(ind) = db(ind(ind_sort));
        end
        
        
    end

    
if isfield(ud,'db')
    ud.db = blind_db;
else 
    ud = blind_db;
end

function reverse = reverse_order( stackname )
reverse = (sin(3*sum(double(stackname)))>0);

% add exception because of invalid datapoint
if strcmp(stackname,'10.24.1.27:tuft3')
   % disp('BLINDING_TPDATA: exception');
    reverse = true;
end

