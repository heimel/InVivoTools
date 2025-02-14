function [localdir] = getRemoteDir;

%  GETREMOTEDIR - returns the remote directory from RunExperiment panel
%
%  [LOCALDIR] = GETREMOTEDIR
%
%  Returns the local directory remote commucations directory.
%  Requires that RunExperiment be open.

z = geteditor('RunExperiment');
if ~isempty(z), z=z(1); 
   ud = get(z,'userdata');
   localdir = get(ud.remotepath);
else, localdir = [];
end;
