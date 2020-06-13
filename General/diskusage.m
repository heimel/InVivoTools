function df = diskusage( disk )
%DISKUSAGE gives diskusage (only works in unix)
%
% DF = DISKUSAGE( DISK )
%
% 2007-2020, Alexander Heimel
%

df.available = inf;

if nargin < 1 || isempty(disk)
    disk = '.';
end
if ~exist(disk,'dir')
    logmsg(['Folder ' disk ' does not exist']);
    return
end


switch computer
    case {'GLNX86','GLNXA64'}
        [s,w]=system(['df -P ' disk ]);
    otherwise
        logmsg('Full diskusageinfo only works under unix/linux. Here only returning field available.')
        try 
            df.available = java.io.File('.').getFreeSpace();
        catch me
            logmsg(me.message);
        end
        return
end

if s~=0
    logmsg(['Error in performing diskusage of disk ' disk ]);
    return
end

w = split(w,10); % split at returns
header = w{1};
content = w{2};

p = [];
p(end+1) = strfind(header,'Filesystem');
p(end+1) = 20;
p(end+1) = strfind(header,'1024-blocks')+length('1024-blocks');
p(end+1) = strfind(header,'Used')+length('Used');
p(end+1) = strfind(header,'Available')+length('Available');
p(end+1) = strfind(header,' Mounted on');
p(end+1) = 256;

fields = {'filesystem','blocks','used','available','capacity','mounted_on'};

for i=1:length(p)-1
    switch fields{i}
        case 'capacity'
            field = strtrim(content(p(i):min(end,p(i+1)-2))) ;
        otherwise
            field = strtrim(content(p(i):min(end,p(i+1)-1))) ;
    end
    
    if ~isempty(str2double(field))
        field=str2double(field);
    end
    
    df.(fields{i}) = field;
end



