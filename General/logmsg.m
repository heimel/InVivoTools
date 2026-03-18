function logmsg( msg, caller, save_to_logfile )
%LOGMSG logs a message to the command line
%
%  LOGMSG( MSG, [CALLER],SAVE_TO_LOGFILE=false)
%
%    If SAVE_TO_LOGFILE is true, it automatically creates a logfile
%    to store the log.
%
% 2013-2026, Alexander Heimel
%
persistent fid

if nargin<3 || isempty(save_to_logfile)
    save_to_logfile = false;
end

if save_to_logfile && isempty(fid)
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    logfile = fullfile(tempdir, ['invivotools_logmsg_' timestamp '.txt']);
    fid = fopen(logfile, 'a');  
    if fid == -1
        disp(['LOGMSG: Could not open log file ' logfile])
    else
        disp(['LOGMSG: Writing log to ' logfile])
    end
end

if nargin<1
    msg = '[Empty message]';
end
if nargin<2 || isempty(caller)
    stack = dbstack(1);
    if ~isempty(stack)
        caller = stack(1).name;
    else
        caller = 'WORKSPACE';
    end
end

if ~iscell(msg)
    msg = {msg};
end
for i=1:length(msg)
    disp([upper(caller) ': ' msg{i} ]);
end
if ~isempty(fid) && fid~=-1
    for i=1:length(msg)
        fprintf(fid,'%s: %s\n',upper(caller),msg{i});
    end
end
