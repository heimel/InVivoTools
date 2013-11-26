function errormsg( msg )
%ERRORMSG displays error dialog and logs a copy to the command line
%
%  ERRORMSG( MSG )
%
% 2013, Alexander Heimel
%

stack = dbstack(1);
if ~isempty(stack)
    caller = stack(1).name;
else
    caller = 'Error';
end

errordlg(msg,userize(caller));
logmsg(msg,caller);

function str = userize( str )
str(str=='_') = ' ';
str = capitalize(str);