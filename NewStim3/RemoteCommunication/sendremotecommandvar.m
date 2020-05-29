function [b,vars] = sendremotecommandvar(strs,invarnames,invars)

%  SENDREMOTECOMMANDVAR - Send a remote command with input and/or output variables
%
%  [B,VARS] = SENDREMOTECOMMANDVAR(STRS,INVARNAMES,INVARS)
%
%  This function sends a command and input variables to a remote machine and returns
%  variables from that machine's reply.  The command given in STRS (which should be a
%  cellstr array of strings) is copied to the remote computer.  A "Please Wait" dialog
%  is given while the local computer waits for a response from the remote
%  computer.  The user may cancel this waiting by clicking "Cancel".
%
%   INVARS is a set of variable values to be written to the remote computer.
%   INVARNAMES is the name of each variable.
%
%   VARS is a cell list of variables returned by the remote computer.
%
%   The script that is provided should include the line 'save gotit -mat' or
%   equivilent because SENDREMOTECOMMANDVAR checks for the existence of 'gotit'
%   to indicate the script has finished on the remote machine.

%
%   B is 1 if the command was received and processed correctly, and 0 otherwise.
%   Note that the 0 condition can arise if there is an error on the remote
%   machine or if the user pressed cancel.  VARS is empty if B is 0.
%
%
%   See also:  REMOTECOMM, REMOTEDIR, CHECKREMOTEDIR, WRITEREMOTE

remotecommglobals;
pathstring = Remote_Comm_dir;
b = 0;
errorflag = 0;

[m,ind]=max(size(strs));
strs = cat(ind,{'load(''toremote'',''-mat'');'},strs);

if checkremotedir(pathstring) % directory exists
    pathn=fixpath(pathstring);
    fname = [pathn 'gotit'];
    fnameerror = [pathn 'scripterror.mat'];
    fout  = [pathn 'fromremote.mat'];
    fin  =  [pathn 'toremote.mat'];
    if exist(fname,'file')
        delete(fname);
    end
    if exist(fout)==2
        delete(fout);
    end
    if exist(fnameerror)==2
        delete(fnameerror);
    end
    savenames(fin,invars,invarnames);
    b = writeremote(strs);
    if b
        g = msgbox('Please wait', 'Please wait');
        x = findobj(g,'Style','PushButton');
        set(x,'String','Cancel');
        drawnow;
        dowait(1);
        cd(pwd); % flush file info
        scriptdone = 0;
        while (~scriptdone&&ishandle(g))
            if strcmp(Remote_Comm_method,'filesystem')
                cd(pwd);
                errorflag = exist(fnameerror,'file');
                scriptdone = exist(fname)|errorflag;
                if errorflag
                    load(fnameerror,'-mat');
                    errordlg(['Error: remote script failed with error ' errorstr '.']);
                end
            elseif strcmp(Remote_Comm_method,'sockets')
                pnet(Remote_Comm_conn,'setreadtimeout',0.1);
                str=pnet(Remote_Comm_conn,'readline');
                if length(str)>=11&&strcmp(str(1:11),'SCRIPT DONE')
                    scriptdone = 1;
                    pnet(Remote_Comm_conn,'setreadtimeout',5),
                    str = '';
                    B = 0;
                    while ~B
                        str = pnet(Remote_Comm_conn,'readline'),
                        if length(str>=12) && strcmp(str(1:12),'RECEIVE FILE')
                            [sz,dum1,dum2,ind]=sscanf(str,'RECEIVE FILE %d',1);
                            recvname = str(ind+1:end); % maybe end-1
                            pnet(Remote_Comm_conn,'readtofile',[pathn recvname],sz);
                        end
                        A=length(str)>=13;
                        if A
                            B=strcmp(str(1:13),'TRANSFER DONE'); 
                        else
                            B=0;
                        end
                    end
                    pnet(Remote_Comm_conn,'close');
                elseif length(str)>=12 && strcmp(str(1:12),'SCRIPT ERROR')
                    errordesc = str(14:end);
                    errordlg(['Error: remote script failed with error ' errordesc '.']);
                    scriptdone = 1; errorflag = 1;
                    pnet(Remote_Comm_conn,'close');
                end
            end
        end
        if ishandle(g)
            delete(g); 
        end
        b = scriptdone & ~errorflag;
        if b && exist(fout,'file')
            vars = load(fout,'-mat'); 
        else
            vars = [];
        end
    end
end

if b==0
    vars = []; 
end

if b||errorflag
    try
        delete([fixpath(Remote_Comm_dir) filesep 'runit.m']);
    end
end

function savenames(fin,invar,invarnames)
evstr = [];
for i_________=1:length(invar)
    evstr = [evstr ' ' invarnames{i_________} ]; %#ok<AGROW>
    eval([invarnames{i_________} '=invar{i_________};']);
end
v = str2num(version('-release'));
if v>13
    savestr = ' -V6 -mat '; 
else
    savestr = ' -mat ';
end
eval(['save ' fin evstr savestr]);
