function errormsg( msg, halt )
%ERRORMSG displays error dialog and logs a copy to the command line
%
%  ERRORMSG( MSG, HALT=false )
%     if HALT is true, then also break with real error
%
% 2013-2015, Alexander Heimel
%

if nargin<2
    halt = [];
end
if isempty(halt)
    halt = false;
end

stack = dbstack(1);
if ~isempty(stack)
    caller = stack(1).name;
else
    caller = 'Error';
end

if usejava('awt')
    errordlg(msg,userize(caller));
end
logmsg(msg,caller);

if halt
    stack = dbstack;
    errid = upper(subst_ctlchars([stack(2).name ':' msg(1:min(end,20))]));
    error(errid,msg)
end

function str = userize( str )
str(str=='_') = ' ';
str = capitalize(str);