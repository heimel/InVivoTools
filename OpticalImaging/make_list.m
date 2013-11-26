function newud=make_list( ud )
%MAKE_LIST
%
%  NEWUD=MAKE_LIST( UD )
%
% 2005, Alexander Heimel
%

newud=ud;
db=ud.db(ud.ind);

disp('Mouse list');

header=sprintf('#    %-11s %4s %-13s %-20s %s %s perf weight tg_number',...
    'mouse','age','strain','type','cage','usa');
disp(header);

entries={};
for i=1:length(db)
    record=db(i);
    if isempty(record.type)
        type='';
    else
        type=record.type;
    end
    if isempty(record.cage)
        cage='-';
    else
        cage=num2str(record.cage);
    end
    if isempty(record.usable)
        usable=' ';
    else
        usable=num2str(record.usable);
    end
    if ~isempty(findstr(record.actions,'perfusion'))
        perfused='1';
    else
        perfused=' ';
    end
    if record.alive~=0
        if isempty(record.alive)
            disp(['mouse ' record.mouse ' is in a schrodinger cat state']);
        end
            try
            age_d=age(record.birthdate);
            if ~isnan(age_d)
                age_d=['p' num2str(age_d)];
            else
                age_d='?';
            end
        catch
            age_d='?';
        end
    else
        age_d='dead';
    end
    if isempty(record.weight)
        weight='    ';
    else
        weight=num2str(record.weight,'%2.1f');
    end
    if isempty(record.tg_number)
        tg_number=' ';
    else
        tg_number=num2str(record.tg_number);
    end
    if isempty(record.comment)
        comment=' ';
    else
        comment=record.comment;
    end
    
    entries{end+1}=...
        sprintf('%-4d %-11s %-4s %-13s %-20s %3s %s %-2s %-2s %-3s %s %s',...
        ud.ind(i),record.mouse,age_d,...
        record.strain,type(1:min(end,20)),...
        cage,usable,perfused,weight,tg_number,comment);
end

for i=1:length(entries)
    disp(entries{i});
end
