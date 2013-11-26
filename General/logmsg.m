function logmsg( msg, caller )
%LOGMSG logs a message to the command line
%
%  LOGMSG( MSG, [CALLER])
%
% 2013, Alexander Heimel
%

if nargin<2
    stack = dbstack(1);
    if ~isempty(stack)
        caller = stack(1).name;
    else
        caller = 'WORKSPACE';
    end
end

disp([upper(caller) ': ' msg ]);
