function b = runscriptremote(scriptname, acquire)

%  RUNSCRIPTREMOTE - Attemps to run a remote script
%
%  B = RUNSCRIPTREMOTE(SCRIPTNAME, [ACQUIRE])
%
%  Attempts to run a script on the remote machine.  RunExperiment window
%  must be open.  B will return 0 if the script is not a loaded script on
%  the remote machine according to the RunExperiment window.  Optionally,
%  an acquire parameter may be given saying whether or not data should be
%  acquired--the current status of the RunExperiment window will be used if
%  this paramter is not given.

loc = which('RunExperiment');
li = find(loc==filesep); loc = loc(1:li(end)-1);
addpath([loc filesep 'panelcallbacks' filesep]);

b = 1;
z = geteditor('RunExperiment');
if isempty(z), b = 0; return; end;
scriptlist = findobj(z,'Tag','scriptlist');
sn = [scriptname '*'];
[c,ia] = intersect(get(scriptlist,'String'),sn);
if isempty(ia), b = 0; return; end;
set(scriptlist,'value',ia);
if nargin==2,
  set(findobj(z,'Tag','AcquireDataCB'),'value',(acquire>0));
end;
runexpercallbk('showstim',z);
