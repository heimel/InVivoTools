function b = writeremote(strs)

% WRITEREMOTE - Sends a script to the remote machine to be run
%
% B = WRITEREMOTE(STRS) 
%
%  Attempts to write the cellstr STRS to the remote machine as file
%  'runit.m'.  If the file 'toremote' exists in the local 
%  REMOTE_COMM_DIR, this file is sent prior to 'runit.m'.
%
%  Returns 1 if successful, or 0 otherwise.  If the path
%  does not exist, it gives an error dialog.
%
%  The file is written to the directory specified in the directory
%  REMOTE_COMM_DIR as defined in REMOTECOMMGLOBALS and initialized in
%  NewStimCalibrate.
%
%  See also:  REMOTECOMM, REMOTECOMMGLOBALS, SENDCOMMAND, SENDCOMMANDVAR

remotecommglobals;

pathstr = Remote_Comm_dir;

b=1;
pathn=fixpath(pathstr);
fname=[pathn 'runit.m'];
if exist(pathn)~=7,
        b = 0;
        errordlg('Remote directory does not exist.','Error');
elseif exist(fname), % check to see that any previous scripts are finished
        b = 0;
	fprintf(['Checking to see if we can talk to remote machine.\n']);
	if strcmp(Remote_Comm_method,'sockets'),
		if remotecommopen,
			pnet(Remote_Comm_conn,'printf',['PING' Remote_Comm_eol]);
			pnet(Remote_Comm_conn,'setreadtimeout',3);
			str = pnet(Remote_Comm_conn,'readline');
			if isempty(str), b = 0;
			elseif strcmp(str,'PONG'), b = 1;
			else, b = 0;
			end;
			pnet(Remote_Comm_conn,'close');  % flush PING
			pause(1);  % give stim computer time to reset sockets
		end;
	end;
        if b==0,
		errordlg('Remote server not operating or still processing commands.',...
		'Error');
	else, delete(fname);  % runit.m is simply not cleaned up so clean it
	end;
end;

if b==1,
        fid = fopen(fname,'wt');
        if fid<0,
                b = 0;
                errordlg(['Could not create ' fname '.']);
        else,
                bigstr = [];
                for i=1:length(strs),
                        bigstr = [bigstr char(strs(i)) 10];
                end;
                fprintf(fid,'%s',bigstr);
                fclose(fid);
                if isunix_sv, eval(['! chmod 770 ' fname ]); end;
        end;
end;

if b==1&strcmp(Remote_Comm_method,'sockets'),
	% need to transfer runit.m to the remote machine
	% notify computer of incoming file
	if remotecommopen,
		[pathn 'toremote'], exist([pathn 'toremote']),
		if exist([pathn 'toremote'])==2,
			fprintf('Sending file toremote now.\n');
			d=dir([pathn 'toremote']);
			pnet(Remote_Comm_conn,'printf',['RECEIVE FILE %d %s' Remote_Comm_eol],d.bytes,d.name);
			pnet(Remote_Comm_conn,'writefromfile',[pathn 'toremote']);
			delete([pathn 'toremote']);
		end;
		fprintf('Sending file runit.m now.\n');
		d=dir(fname);
		pnet(Remote_Comm_conn,'printf',['RECEIVE FILE %d %s' Remote_Comm_eol],d.bytes,d.name);
		pnet(Remote_Comm_conn,'writefromfile',fname);
		fprintf('Sending run script.\n');
		pnet(Remote_Comm_conn,'printf',['RUN SCRIPT %s' Remote_Comm_eol],'runit.m');
	end;
end;
