function [b,vars] = sendremotecommandvar(strs,invarnames,invars)

%  Part of the NewStim package
%  [B,VARS] = SENDREMOTECOMMANDVAR(STRS,INVARNAMES,INVARS)
%
%  Sends a command to a remote machine and returns variables from that
%  machine's reply.  The %  command given in STRS (which should be a cellstr
%  array of strings) is copied to the remote computer.  A "Please Wait" dialog
%  is given while the local computer waits for a response from the remote
%  computer.  The user may cancel this waiting by clicking "Cancel".
%
%   INVARS is a set of variable names to be written to the remote computer.
%   INVARNAMES is the name of each variable.
%
%   VARS is a cell list of variables returned by the remote computer.
%
%   B is 1 if the command was received and processed correctly, and 0 otherwise.
%   Note that the 0 condition can arise if there is an error on the remote
%   machine or if the user pressed cancel.  VARS is empty is B is 0.
%
%
%   See also:  REMOTECOMM, REMOTEDIR, CHECKREMOTEDIR, WRITEREMOTE

NewStimGlobals;
pathstring = NewStimRemoteCommDir;
b = 0;
if checkremotedir(pathstring), % directory exists
   eval('!rm -f fromremote.mat gotit.mat');
   pathn=fixpath(pathstring);
   fname = [pathn 'gotit.mat'];
   fout  = [pathn 'fromremote.mat'];
   fin  =  [pathn 'toremote.mat'];
   savenames(fin,invars,invarnames);
   b = writeremote(pathstring,strs);
   if b,
      if exist(fname), delete(fname); end;
      g = msgbox('Please wait', 'Please wait');
      x = findobj(g,'Style','PushButton');
      set(x,'String','Cancel');
      drawnow;
      dowait(1);
	  cd(pwd); % flush file info
	  while (~exist(fname)&ishandle(g)),dowait(1);drawnow;cd(pwd); end;
      % cd flushes file info
      if ishandle(g), delete(g); end;
      b=(exist(fname)~=0);
	  if b, vars = load(fout,'-mat'); end; 
   end;
end;

if b==0, vars = []; end;

function savenames(fin,invar,invarnames)
evstr = [];
for i_________=1:length(invar),
  evstr = [evstr ' ' invarnames{i_________} ];
  eval([invarnames{i_________} '=invar{i_________};']);
end;
eval(['save ' fin evstr ' -v6']);
