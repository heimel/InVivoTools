% prior to running, user needs to:
%   turn off screen saver
%   put computer into 256 colors
%   set screen res
%   mount any other necessary computers


if 0,
	addpath([pwd 'commands']);
	applescript('helloIgor.applescript');
end;

close all; 
NewStimGlobals
NewStimInit;
remotecommglobals;
ReceptiveFieldGlobals;

theDir=Remote_Comm_dir;
if exist(theDir)~=7 % i.e. no directory (using old format for Matlab 5 compatibility)
    CloseStimScreen
    
    msg={['Remote communication folder ' theDir ' does not exist. ']};
    try
        [s,status] = urlread('http://www.google.com');
        if ~status
            msg{end+1} = '';
            msg{end+1} = 'Network connection is unavailable. Check UTP cables, make sure firewall is turned off, or consult with ICT department.'; 
        else
            msg{end+1} = '';
            msg{end+1} = 'Ethernet connection is working properly. Check NewStimConfiguration or availability of host computer.';
        end
    end
    msg{end+1} = '';
    msg{end+1} = 'Consult NewStim manual troubleshooting section.';
    disp(['INITSTIMS: ' msg{1}]);
    errordlg(msg,'Initstims');
    return
end
cd(theDir);


if ~haspsychtbox
    errordlg('No psychtoolbox present.');
    disp('INITSTIMS: No psychtoolbox present');
    return
end

if Remote_Comm_isremote
	CloseStimScreen;
   	ShowStimScreen;

	%quickRFmap; % commented by Alexander
    
	warmupps=periodicstim('default');
    % alexander
    disp('INITSTIMS: working on pre and post time gamma correction and debug');
    wp = getparameters(warmupps)
    wp.imageType = 2;
    wp.dispprefs={'BGpretime',1,'BGposttime',1};
    warmupps = periodicstim(wp);
    %
    
	warmup = stimscript(0); warmup=append(warmup,warmupps);warmup=loadStimScript(warmup);
	MTI=DisplayTiming(warmup);
	DisplayStimScript(warmup,MTI,0,0);
else
    errordlg('Not a remote computer. Change Remote_Comm_isremote in NewStimConfiguration.');
    disp('INITSTIMS: Not a remote computer. Change Remote_Comm_isremote in NewStimConfiguration.');
    return
end


if exist('runit.m')==2, delete runit.m, end;

switch Remote_Comm_method,

case 'filesystem',
    try % alexander
    while 1,  % needs control-C to exit
		pause(2);
        if KbCheck && ~StimDisplayOrderRemote
            CloseStimScreen
            return
        end
		cd(theDir); % refresh file directory
		disp('Waiting for remote commands...press COMMAND-PERIOD (APPLE-.) or Ctrl-C to interrupt.');
            	
		errorflag = 0;
		txt = checkscript('runit.m');
		if ~isempty(txt),
			try,
				eval(txt)
                disp(txt);
			catch,
				errorflag = 1;
				errorstr = lasterr;
				inds = find(errorstr==sprintf(Remote_Comm_eol)); errorstr(inds) = ':';
				save scripterror errorstr -mat
                CloseStimScreen; % 2012-02-23 Alexander
				disp(['Error in script: ' errorstr '.']);
                keyboard  % 2012-02-23 Alexander
			end;
			cd(theDir);
			disp('Ran file, deleting...');
			delete runit.m;
			if exist('toremote')==2, delete('toremote'); end;
		end;
	end;
    catch me
        CloseStimScreen
        rethrow(me)
    end
case 'sockets',
	pnet('closeall');
	while 1, % needs control-C to exit
		if exist('fromremote')==2, delete('fromremote'); end;
		if exist('toremote')==2, delete('toremote'); end;
		if exist('gotit')==2, delete('gotit'); end;
		fprintf('Reseting sockets.\n');
		pnet('closeall');
		sockcon = pnet('tcpsocket',Remote_Comm_port);
		if sockcon >= 0,
			Remote_Comm_conn = pnet(sockcon,'tcplisten'); % will wait here until connected
		else,
			error(['Could not open socket on port ' int2str(Remote_Comm_port) '.']);
		end;
		fprintf('Received remote connection, awaiting commands.\n');
		scriptdone = 0; errorflag = 0;
		tic;
		while ~scriptdone,
			t = toc;
			pnet(Remote_Comm_conn,'setreadtimeout',10);
			str = pnet(Remote_Comm_conn,'readline');
			if length(str)>1, str, end;
			if length(str) == 0 & toc>30, scriptdone = 1; % if no response in 30s, assume none coming
			elseif strcmp(str,'PING'),
				fprintf(['Writing PONG.\n']);
				pnet(Remote_Comm_conn,'printf',['PONG' Remote_Comm_eol]);
				scriptdone = 1;
			elseif length(str)>=12&strcmp(str(1:12),'RECEIVE FILE'),
				fprintf('Preparing to receive file.\n');
				[B,dum1,dum2,ind]=sscanf(str,'RECEIVE FILE %d',1);
				recvname = str(ind+1:end),
				pnet(Remote_Comm_conn,'readtofile',recvname,B);
				tic;
			elseif length(str)>=11&strcmp(str(1:11),'RUN SCRIPT '),
				errorflag = 0;
				errorstr = '';
				fprintf('Received RUN SCRIPT command\n');
				txt = checkscript(str(12:end));
				if ~isempty(txt),
					try,
						eval(txt);
						disp(['Eval successful.']);
					catch,  
						disp(['Script error!']);
						errorflag = 1;
						errorstr = lasterr;
					end;
					cd(theDir);
					disp('Ran file, deleting...');
					delete runit.m;
				end;
				if ~errorflag&~isempty(txt),
					pnet(Remote_Comm_conn,'setwritetimeout',5);
					pnet(Remote_Comm_conn,'printf',['SCRIPT DONE' Remote_Comm_eol]);
					if exist('gotit')==2,
						d = dir('gotit');
						pnet(Remote_Comm_conn,'setwritetimeout',5);
						pnet(Remote_Comm_conn,'printf',...
						['RECEIVE FILE %d gotit' Remote_Comm_eol],d.bytes);
						pnet(Remote_Comm_conn,'writefromfile','gotit');
						delete('gotit');
					end;
					if exist('fromremote')==2,
						fprintf('Preparing to write fromremote.\n');
						d = dir('fromremote');
						pnet(Remote_Comm_conn,'setwritetimeout',5);
						pnet(Remote_Comm_conn,'printf',...
							['RECEIVE FILE %d fromremote' Remote_Comm_eol],d.bytes);
						pnet(Remote_Comm_conn,'writefromfile','fromremote');
					end;
					pnet(Remote_Comm_conn,'setwritetimeout',5);
					pnet(Remote_Comm_conn,'printf',['TRANSFER DONE' Remote_Comm_eol]);
					scriptdone = 1;
				else,
					disp(['Script failed with error ' errorstr]);
					inds = find(errorstr==sprintf(Remote_Comm_eol)); errorstr(inds) = ':';
					pnet(Remote_Comm_conn,'setwritetimeout',5);
					pnet(Remote_Comm_conn,'printf',['SCRIPT ERROR ' errorstr Remote_Comm_eol]);
					scriptdone = 1;
				end;
			end;
		end;
	end;
end;
