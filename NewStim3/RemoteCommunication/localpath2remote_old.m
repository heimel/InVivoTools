function newpath = localpath2remote(pathname)

%  LOCALPATH2REMOTE
%
%   Converts a local pathname to remote

global ghostmachine;

remotecommglobals;

if ~ghostmachine,
	fs = Remote_Comm_localprefix;

	h = findstr(pathname,fs);
	newpath = [ Remote_Comm_remoteprefix pathname(h+length(fs):end)];
    currfilesep = '\';
	switch (lower(Remote_Comm_remotearchitecture)),
		case 'unix',
			remotefilesep = '/';
		case 'pc',
			remotefilesep = '\';
		case 'mac',
			remotefilesep = ':';
	end;
    h = find(newpath==currfilesep);
	newpath(h) = remotefilesep;
else, newpath = pathname;
end;
