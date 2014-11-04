function logmsg( msg, caller )
%LOGMSG logs a message to the command line
%
%  LOGMSG( MSG, [CALLER])
%
% 2013-2014, Alexander Heimel
%

if nargin<1
    msg = '[Empty message]';
end
if nargin<2
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