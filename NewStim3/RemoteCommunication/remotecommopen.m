function b = remotecommopen
% REMOTECOMMOPEN Checks to ensure remote communications are open
%
%  B = REMOTECOMMOPEN
%
%  Returns 1 if remote communications are capable.  The function will try to establish
%  a connection if it is necessary.
%
%  For filesystem communication, the function returns 1 if the directory where remote
%  files are written exists.
%
%  For sockets communication, the function returns 1 if a good socket connection is
%  already established or can be established.

remotecommglobals;

b = 0;

switch(Remote_Comm_method),
	case 'filesystem',
		b = exist(Remote_Comm_dir)==7;
	case 'sockets',
		a = 0;
		if isempty(Remote_Comm_conn), a = -1;
		else, % it's already been open
			% test to make sure it's good
			try,
				a = pnet(Remote_Comm_conn,'status');
				% cannot totally trust status -- remote host
                                % can be disconnected but status still says okay
                                % doesn't fail until a read has failed
			catch,
				a = -1;
			end;
		end;
		if a<=0, % if not presently open, try to open it
			Remote_Comm_conn = pnet('tcp_connect',Remote_Comm_host,...
				Remote_Comm_port);
			if Remote_Comm_conn<0,
				errordlg(['Could not create socket to host ' ...
					Remote_Comm_host ' on port ' ...
					int2str(Remote_Comm_port) '.']);
				Remote_Comm_conn = [];
			else, b = 1;
			end;
		else, b = 1;
		end;
end;
