%INITSTIMS
%
% prior to running, user needs to:
%   turn off screen saver
%   put computer into 256 colors
%   set screen res
%   mount any other necessary computers
%
% 200X, Steve Van Hooser
% 200X-2020, Alexander Heimel

close all
NewStimGlobals
NewStimInit;
remotecommglobals;
ReceptiveFieldGlobals;

theDir = Remote_Comm_dir;
if ~exist(theDir,'dir')
    CloseStimScreen
    msg = {['Remote communication folder ' theDir ' does not exist. ']};
    try
        if ~check_network
            msg{end+1} = '';
            msg{end+1} = 'Network connection is unavailable. Check UTP cables, make sure firewall is turned off, or consult with ICT department.';
        else
            msg{end+1} = '';
            msg{end+1} = 'Ethernet connection is working properly. Check NewStimConfiguration or availability of host computer.';
        end
    catch me
        logmsg(me.message);
    end
    msg{end+1} = '';
    msg{end+1} = 'Consult NewStim manual troubleshooting section.';
    errormsg(msg);
    return
end
cd(theDir);

if ~haspsychtbox
    errormsg('No psychtoolbox present.');
    return
end

if Remote_Comm_isremote
    CloseStimScreen;
    ShowStimScreen;
    warmupps = periodicstim('default');
    wp = getparameters(warmupps);
    wp.imageType = 2;
    wp.dispprefs={'BGpretime',0,'BGposttime',0.05};
    wp.sFrequency = 1.5;% to check linearization
    warmupps = periodicstim(wp);
    warmup = stimscript(0); 
    warmup = append(warmup,warmupps);
    warmup = append(warmup,stochasticgridstim);
    warmup = loadStimScript(warmup);
    MTI=DisplayTiming(warmup);
    DisplayStimScript(warmup,MTI,0,0);
else
    errormsg('Not a remote computer. Change Remote_Comm_isremote in NewStimConfiguration.');
    return
end

if exist('runit.m','file')
    delete('runit.m');
end

switch Remote_Comm_method
    case 'filesystem'
        try
            logmsg('Waiting for remote commands...press Ctrl-C to interrupt.');
            
            while 1  % needs control-C to exit
                pause(0.05);
                if KbCheck && ~StimDisplayOrderRemote && ~gNewStim.StimWindow.debug && ~StimNoBreak
                    CloseStimScreen
                    return
                end
                cd(theDir); % refresh file directory
                
                errorflag = 0;
                txt = checkscript('runit.m');
                if ~isempty(txt)
                    prevtxt =  '';
                    while length(prevtxt)<length(txt)
                        pause(0.2); % to make sure runit is fully written
                        prevtxt = txt;
                        txt = checkscript('runit.m');
                    end
                    
                    try
                        eval(txt)
                        disp(txt);
                    catch me
                        errorflag = 1;
                        errorstr = me.message;
                        inds = find(errorstr==sprintf(Remote_Comm_eol));
                        errorstr(inds) = ':';
                        save('scripterror.mat','errorstr','-mat');
                        CloseStimScreen;
                        logmsg(['Error in script: ' errorstr '.']);
                        keyboard
                    end
                    cd(theDir);
                    logmsg('Ran file, deleting...');
                    delete('runit.m');
                    if exist('toremote','file')
                        delete('toremote');
                    end
                    if exist('toremote.mat','file')
                        delete('toremote.mat');
                    end
                    logmsg('Waiting for remote commands...press Ctrl-C to interrupt.');
                    pause(1);
                end
            end
        catch me
            CloseStimScreen
            rethrow(me)
        end
    case 'sockets' % not kept up to date
        pnet('closeall');
        while 1 % needs control-C to exit
            if exist('fromremote.mat','file')
                delete('fromremote.mat');
            end
            if exist('toremote.mat','file')
                delete('toremote.mat');
            end
            if exist('gotit.mat','file')
                delete('gotit.mat');
            end
            fprintf('Reseting sockets.\n');
            pnet('closeall');
            sockcon = pnet('tcpsocket',Remote_Comm_port);
            if sockcon >= 0
                Remote_Comm_conn = pnet(sockcon,'tcplisten'); % will wait here until connected
            else
                error(['Could not open socket on port ' int2str(Remote_Comm_port) '.']);
            end
            fprintf('Received remote connection, awaiting commands.\n');
            scriptdone = 0; errorflag = 0;
            tic;
            while ~scriptdone
                t = toc;
                pnet(Remote_Comm_conn,'setreadtimeout',10);
                str = pnet(Remote_Comm_conn,'readline');
                if isempty(str) && toc>30
                    scriptdone = 1; % if no response in 30s, assume none coming
                elseif strcmp(str,'PING')
                    fprintf('Writing PONG.\n');
                    pnet(Remote_Comm_conn,'printf',['PONG' Remote_Comm_eol]);
                    scriptdone = 1;
                elseif length(str)>=12 && strcmp(str(1:12),'RECEIVE FILE')
                    fprintf('Preparing to receive file.\n');
                    [B,dum1,dum2,ind]=sscanf(str,'RECEIVE FILE %d',1);
                    recvname = str(ind+1:end);
                    pnet(Remote_Comm_conn,'readtofile',recvname,B);
                    tic;
                elseif length(str)>=11 && strcmp(str(1:11),'RUN SCRIPT ')
                    errorflag = 0;
                    errorstr = '';
                    fprintf('Received RUN SCRIPT command\n');
                    txt = checkscript(str(12:end));
                    if ~isempty(txt)
                        try
                            eval(txt);
                            disp('Eval successful.');
                        catch me
                            disp('Script error!');
                            errorflag = 1;
                            errorstr = me.message;
                        end
                        cd(theDir);
                        disp('Ran file, deleting...');
                        delete('runit.m');
                    end
                    if ~errorflag && ~isempty(txt)
                        pnet(Remote_Comm_conn,'setwritetimeout',5);
                        pnet(Remote_Comm_conn,'printf',['SCRIPT DONE' Remote_Comm_eol]);
                        if exist('gotit.mat','file')
                            d = dir('gotit.mat');
                            pnet(Remote_Comm_conn,'setwritetimeout',5);
                            pnet(Remote_Comm_conn,'printf',...
                                ['RECEIVE FILE %d gotit.mat' Remote_Comm_eol],d.bytes);
                            pnet(Remote_Comm_conn,'writefromfile','gotit');
                            delete('gotit.mat');
                        end
                        if exist('fromremote.mat','file')
                            fprintf('Preparing to write fromremote.\n');
                            d = dir('fromremote.mat');
                            pnet(Remote_Comm_conn,'setwritetimeout',5);
                            pnet(Remote_Comm_conn,'printf',...
                                ['RECEIVE FILE %d fromremote.mat' Remote_Comm_eol],d.bytes);
                            pnet(Remote_Comm_conn,'writefromfile','fromremote.mat');
                        end
                        pnet(Remote_Comm_conn,'setwritetimeout',5);
                        pnet(Remote_Comm_conn,'printf',['TRANSFER DONE' Remote_Comm_eol]);
                        scriptdone = 1;
                    else
                        disp(['Script failed with error ' errorstr]);
                        inds = find(errorstr==sprintf(Remote_Comm_eol)); errorstr(inds) = ':';
                        pnet(Remote_Comm_conn,'setwritetimeout',5);
                        pnet(Remote_Comm_conn,'printf',['SCRIPT ERROR ' errorstr Remote_Comm_eol]);
                        scriptdone = 1;
                    end
                end
            end
        end
end % switch Remote_Comm_method
