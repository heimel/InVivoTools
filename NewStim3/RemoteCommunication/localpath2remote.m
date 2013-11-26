function newpath = localpath2remote(pathname)

%  LOCALPATH2REMOTE
%
%   Converts a local pathname to remote

global ghostmachine;

remotecommglobals;

if isempty(ghostmachine) || ~ghostmachine,
	fs = Remote_Comm_localprefix;

	h = findstr(pathname,fs);
	newpath = [ Remote_Comm_remoteprefix pathname(h+length(fs):end)];
    currfilesep = '\';
    h = find(newpath==currfilesep);
	newpath(h) = remotefilesep; % remotefilesep is a function
else, newpath = pathname;
end;

disp(['LOCALPATH2REMOTE: Local path = ' pathname]);
disp(['LOCALPATH2REMOTE: Remote path = ' newpath]);
