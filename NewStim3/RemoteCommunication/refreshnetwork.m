function refreshnetwork

% REFRESHNETWORK - Refresh this computer's view of the current directory
%
%   Requires write permission to PWD


if isunix,
	fid=fopen('refreshnetworkfile.dummy','w');
	if fid>0, fclose(fid); end;
else,
	switch upper(computer),
		case 'MAC2',
			thedir = pwd; cd(pwd);
	end;
end;
