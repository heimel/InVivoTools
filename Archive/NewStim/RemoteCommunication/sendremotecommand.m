function b = sendremotecommand(pathstring,strs)

%  Part of the NewStim package
%  B = SENDREMOTECOMMAND(PATHSTRING,STRS)
%
%  Sends a command to a remote machine.  The directory where the command should
%  be placed is given in PATHSTRING.  The directory is first checked for
%  existance, and, if it doesn't exist, an error is given.  Otherwise, the
%  command given in STRS (which should be a cellstr array of strings) is copied
%  to the remote computer.  A "Please Wait" dialog is given while the local
%  computer waits for a response from the remote computer.  The user may cancel
%  this waiting by clicking "Cancel".
%
%   B is 1 if the command was received and processed correctly, and 0 otherwise.
%   Note that the 0 condition can arise if there is an error on the remote
%   machine or if the user pressed cancel.
%
%   See also:  REMOTECOMM, REMOTEDIR, CHECKREMOTEDIR, WRITEREMOTE

b = 0;
if checkremotedir(pathstring) % directory exists
    if isunix
        eval('!rm -f fromremote.mat gotit.mat ');
    end
    b = writeremote(pathstring,strs);
    if b,
        pathn=fixpath(pathstring);
        fname = [pathn 'gotit.mat'];
        if exist(fname,'file') 
            delete(fname); 
        end;
        g = msgbox('Please wait', 'Please wait');
        x = findobj(g,'Style','PushButton');
        set(x,'String','Cancel');
        drawnow;
        dowait(1);
        cd(pwd); % flush file info
        while (~exist(fname,'file') && ishandle(g)),
            dowait(1);
            drawnow;
            cd(pwd); % flush file info
        end;
        if ishandle(g), delete(g); end;
        b=(exist(fname,'file')~=0);
    end;
end;

