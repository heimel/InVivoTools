function fields=split( s, delimiter, only_outside_accolades )
%SPLIT splits character-delimited line into cell array
%
% fields=split( s, delimiter, only_outside_accolades )
%
% 2005-2013, Alexander Heimel (from Steve Van Hooser)
%

if nargin<3
    only_outside_accolades = [];
end
if isempty(only_outside_accolades)
   only_outside_accolades = false; 
end
if nargin<2
    delimiter=',';
end
fields={};

if isempty(s)
    return
end

if  only_outside_accolades
    fields = split_outside_accolades(s,delimiter);
    return
end

if ~iscell(s)
    s={s};
end

for j=1:length(s)
    ss=s{j};
    ss = [delimiter ss delimiter];
    pos = findstr(ss,delimiter);
    for i=1:length(pos)-1
        fields{j,i} = ss(pos(i)+1:pos(i+1)-1);
    end
end


function fields = split_outside_accolades(s,delimiter)
fields = {};
field = '';
within_accolades = 0;
for i=1:length(s)
    field(end+1) = s(i);
    switch s(i)
        case {'{','(','['}
            within_accolades = within_accolades + 1;
        case {'}',')',']'}
            within_accolades = thresholdlinear(within_accolades - 1);
        case delimiter
            if ~within_accolades
                fields{end+1} = field(1:end-1);
                field = '';
            end
    end            
end
fields{end+1} = field;


