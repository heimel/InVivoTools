function runexpercallbk(action, fig)
%RUNEXPERCALLBK
%
% 200X-200X Steve Van Hooser
% 2004-2014 Alexander Heimel
%

remotecommglobals

if nargin==1
    fig = gcbf;
end
h = get(fig,'UserData');
switch action
    case 'datapath'
        dp = get(h.datapath,'String'); % in local computer format
        if ~exist(dp,'dir') % if datapath directory does not exist, make it
            try
                [p,f,e]=fileparts(dp);
                mkdir(p,[f e]);
            catch me
                errormsg(me.message);
            end
        end
        try
            h.cksds=cksdirstruct(dp);
            set(fig,'userdata',h);
        catch me
            disp(me.message);
            errordlg(['Datapath ' dp ' is not valid']);
            p = getpathname(h.cksds);
            if p(end)==filesep
                p = p(1:end-1);
            end
            set(h.datapath,'String',p);
        end
    case 'runscript'
        remPath = get(h.remotepath,'String');
        runScrp = get(h.runscript,'String');
        if ~isempty(runScrp)
            copyfile([remPath filesep runScrp], ...
                [remPath filesep 'runit.m']);
            if strcmp(computer,'LNX86') || strcmp(computer,'GLNX86') || strcmp(computer,'GLNXA64')
                eval(['! chmod 770 ' remPath filesep 'runit.m']);
            end
        end
    case 'EnDis'
        strs = lb_getselected(h.rslb);
        if length(strs)==1
            g=char(strs);
            if g(end)=='*'
                set(h.rssb,'enable','on');
            else
                set(h.rssb,'enable','off');
            end
        else
            set(h.rssb,'enable','off');
        end
    case 'showstim'
        saveWaves = get(h.savestims,'value');  % are we acquiring here or just displaying?
        if saveWaves  % make a new test directory if necessary
            runexpercallbk('datapath',fig);
            ntd = newtestdir(h.cksds);
            if ~isempty(ntd)
                set(h.savedir,'String',ntd);
            end
        end
        datapath = get(h.datapath,'String');
        if ~exist(datapath,'dir') % make a new data directory if necessary
            [dPath,dFile]=fileparts(datapath);
            mkdir(dPath,dFile);
            if isunix
                eval(['! chmod 770 ' datapath ';']);
                eval(['! chgrp dataman ' datapath ';']);
            end
        end
        datapath=[get(h.datapath,'String') filesep get(h.savedir,'String')];
        scriptName = char(lb_getselected(h.rslb));
        if scriptName(end)~='*'
            errormsg('Script not loaded');
            return
        end
        scriptName = scriptName(1:end-1);
        if isempty(scriptName)
            errormsg('No script.');
            return
        end
        remPath = get(h.remotepath,'String');
        if saveWaves && exist(datapath,'dir') && isempty(strfind(lower(datapath),'antigua'))
            errormsg('Directory already exists.');
            return
        elseif saveWaves  % otherwise, if we are saving, write the acquisition commands
            [dPath,dFile]=fileparts(datapath);
            mkdir(dPath,dFile);
            if isunix
                eval(['! chmod 770 ' datapath ';']);
                eval(['! chgrp dataman ' datapath ';']);
            end
            aqDat = get(h.list_aq,'UserData');
            if ~isempty(aqDat)
                writeAcqStruct([remPath filesep 'acqParams_in'],aqDat);
            else
                logmsg('Empty acquisition list');
            end
            write_pathfile(fullfile(Remote_Comm_dir,'acqReady'),localpath2remote(datapath));
        end
        bbb=evalin('base',['exist(''' scriptName ''')']);
        if bbb % if script also exists locally, show the duration time in RunExperiment window
            durr=evalin('base',['duration(' scriptName ')']);
            durrh=fix(durr/3600); durr=durr-3600*durrh;
            durrm=fix(durr/60);durr=durr-60*durrm; durrs=fix(durr);
            set(h.ctdwn,'String',['Script duration: ' sprintf('%.2d',durrh) ':' ...
                sprintf('%.2d',durrm) ':' sprintf('%.2d',durrs) '; Started at '  datestr(now,13) '.']);
        end
        % get any extra command strings that are necessary
        cmdstrs = {};
        if get(findobj(fig,'Tag','extdevcb'),'value')  % use cb's
            listofcmds = get(findobj(fig,'Tag','extdevlist'),'string');
            highlightedcmds = get(findobj(fig,'Tag','extdevlist'),'value');
            for i=1:length(highlightedcmds) % only run selected commands
                try
                    cmdstr = listofcmds{highlightedcmds(i)};
                    endp = find(cmdstr==')');
                    if isempty(endp)  % no (), so just add it
                        cmdstr = [cmdstr '(datapath,scriptName,saveWaves,remPath)']; %#ok<AGROW>
                    elseif cmdstr(endp-1)=='(' % we have (), remove and add
                        cmdstr=[cmdstr(1:end-2) '(datapath,scriptName,saveWaves,remPath)'];
                    else % we have (), add the extra arguments
                        cmdstr = [cmdstr(1:endp-1) ',datapath,scriptName,saveWaves,remPath)'];
                    end
                    newcmd = eval(cmdstr);
                catch me
                    errormsg(['Error running extra device/command ' listofcmds{i} ': ' me.message]);
                end
                if ~isempty(newcmd)
                    if size(newcmd,2)>size(newcmd,1)
                        newcmd = newcmd';
                    end
                    cmdstrs = cat(1,cmdstrs,newcmd);
                end
            end
        end
        write_runscript_remote(datapath,scriptName, saveWaves,[remPath filesep 'runit.m'],cmdstrs);
        
        if saveWaves % if acquiring, make new record
            add_record( 'TP', get(h.savedir,'string'), scriptName );
            add_record( 'Wc', get(h.savedir,'string'), scriptName );
            add_record( 'oi', get(h.savedir,'string'), scriptName );
            
            switch lower(host)
                case {'helero2p','g2p'} % scanbox 2photon computer
                    f = findall(0,'Name','scanbox');
                    if isempty(f)
                        logmsg('Cannot find Scanbox window. Not setting Scanbox folder');
                    else
                        % make scanbox window persistent
                        % should be elsewhere
                        ud = get(f,'UserData');
                        if isempty(ud)
                            ud = [];
                            ud.persistent = 1;
                            set(f,'UserData',ud);
                        end
                        
                        f = findall(0,'Tag','dirname');
                        global datadir
                        datadir = datapath;
                        f.String = datadir;
                        mkdir(fullfile(datadir,h.savedir.String)); % make nested folder for scanbox
                    end
                    
                    udport = udp('localhost','RemotePort',7000);
                    fopen(udport);
                    fprintf(udport,['A' get(h.savedir,'string')]);
                    fprintf(udport,'U0'); %
                    fprintf(udport,'E0'); % set experiment nr
                    pause(0.1);
                    fprintf(udport,['MStarting ' scriptName]);
                    fprintf(udport,'G'); % start grabbing
                    % Now scanbox takes over if in same matlab instance
                    logmsg('Back in runexpercallbk');
            end
        end
    case 'add_aq'
        aqdata = get(h.list_aq,'UserData');
        strDat = get(h.list_aq,'String');
        iscell(strDat),
        l = length(strDat);
        if isempty(aqdata)
            clear('aqdata');%otherwise error in aqdata(l+1)=struct
        end
        [strDat{l+1},aqdata(l+1)]=input_aq([],[]);
        if ~isempty(strDat{l+1})
            set(h.list_aq,'UserData',aqdata, ...
                'String',strDat,'value',l+1);
        end
    case 'edit_aq'
        aqdata = get(h.list_aq,'UserData');
        strDat = get(h.list_aq,'String');
        val = get(h.list_aq,'value');
        if val>0
            [strDat{val},aqdata(val)]=input_aq(strDat{val},aqdata(val));
        end
        set(h.list_aq,'UserData',aqdata,'String',strDat);
    case 'delete_aq'
        aqdata = get(h.list_aq,'UserData');
        strDat = get(h.list_aq,'String');
        l = length(strDat);
        val = get(h.list_aq,'value');
        if val>0
            newStrDat={};
            if l~=1
                [newStrDat{1:length(strDat)-1}]= ...
                    deal(strDat{[1:val-1 val+1:l]});
                newAqDat=aqdata([1:val-1 val+1:l]);
                if val~=1
                    val = val-1;
                else
                    val=1;
                end
            else
                val = 0;
            end
            set(h.list_aq,'UserData',newAqDat, ...
                'String',newStrDat,'value',val);
        end
    case 'open_aq'
        [fname, pname] = uigetfile('*','Open file ...');
        if fname(1)~=0  % if user doesn't cancel
            newAqDat = loadStructArray([pname fname]);
            StrDat = cell(length(newAqDat),1);
            for i=1:length(newAqDat)
                StrDat{i} = record2str(newAqDat(i));
            end
            set(h.list_aq,'UserData',newAqDat,'String',StrDat, ...
                'value',1);
        end
    case 'save_aq'
        [fname, pname] = uiputfile('*', 'Save As ...');
        if fname(1)~=0
            aqDat=get(h.list_aq,'UserData');
            writeAcqStruct([pname fname],aqDat);
        end
    case 'extdevaddbt' % add a command
        str = get(findobj(fig,'Tag','extdevlist'),'string');
        prompt={'Enter the new command'};
        def = {''};
        answer = inputdlg(prompt,'Extra stimulus command',1,def);
        if ~isempty(answer)
            str(end+1) = answer;
            set(findobj(fig,'Tag','extdevlist'),'string',str);
            set(findobj(fig,'Tag','extdevlist'),'max',2);
        end
    case 'extdevdelbt' % del a command
        str = get(findobj(fig,'Tag','extdevlist'),'string');
        v = get(findobj(fig,'Tag','extdevlist'),'value');
        if ~isempty(v)
            str=str(setxor(1:length(str),v));
            v = 1:length(str);
            set(findobj(fig,'Tag','extdevlist'),'string',str,'value',v);
        end
    case 'extdevaboutbt'
        str =   {'Extra devices/commands help'
            ''
            'This features allows one to add extra commands to the script that displays'
            'stimscripts.  This can be useful for communicating with other external'
            'devices that need to be coordinated with the visual stimulus.'
            ''
            'To add an extra command, type in a function to be evaluated.  The prototype of'
            'the function should be as follows:'
            ''
            '  MYCELLSTRINGLIST = MYCMDFUNC(MYARG1,MYARG2,...,DATAPATH,SCRIPTNAME,...'
            '                               SAVING,REMOTEPATH)'
            'where MYARG* are your arguments to the function, DATAPATH is the path'
            'of the directory where visual stimulus data will be saved,SCRIPTNAME'
            'is the name of the stimscript to be run,SAVING is 0/1, 1 if stimulus'
            'data will actually be saved (as opposed to just displaying), and '
            'REMOTEPATH is the directory where the script will eventually be written.'
            'MYCELLSTRINGLIST is a cell list of strings containing the script commands'
            'to be run. It will be run a few seconds before visual stimulation.'
            ''
            'To add a command, type in the function to be evaluated.  The last four'
            'arguments will be added for you.  So, you might type:'
            'mycmdfunc(myarg1,myarg2)   or'
            'mycmdfunc() or mycmdfunc if your function has no extra arguments.'
            ''
            'Only commands which are highlighted will be run, and the commands will only'
            'be used in general if Enable EC/Ds is checked.'};
        textbox('Help for extra devices/commands',str);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create window that prompts user for recording parameters
function [str,dat] = input_aq (oldstr,inDat)

if isempty(inDat)
    % specify default parameter values
    inDat = struct('name','','type','','fname','','samp_dt', ...
        3.1807627469e-05,'reps',1,'ref',1,'ECGain',10000);
end

% specify prompts for user
prompt={'Name of record:', 'Type of recording:', 'file name', ...
    'sample interval', 'Number of reps (recalculated)', ...
    'reference', 'ECGain'};
def={inDat.name,inDat.type,inDat.fname,num2str(inDat.samp_dt,15),...
    int2str(inDat.reps),int2str(inDat.ref),int2str(inDat.ECGain)};
dialTitle = 'Record parameters...';

% acquire user-entered recording parameters from promted window
answer = inputdlg(prompt,dialTitle,1,def);
if ~isempty(answer)
    fldn = fieldnames(inDat);
    str = '';
    for i=1:length(fldn)
        if isnumeric(inDat.(fldn{i}))
            inDat.(fldn{i}) = str2num(answer{i}); %#ok<ST2NM>
        else
            inDat.(fldn{i}) = answer{i};
        end
        str = [ str ' : ' answer{i}]; %#ok<AGROW>
    end
    str = str(4:end);
else
    str = oldstr;
end
dat = inDat;


function str = record2str(inDat)
if ~isempty(inDat)
    str=[inDat.name ' : ' inDat.type ' : ' inDat.fname ' : ' ...
        num2str(inDat.samp_dt,15) ' : ' int2str(inDat.reps) ' : ' ...
        int2str(inDat.ref) ' : ' int2str(inDat.ECGain)];
end

function add_record( datatype, epoch, scriptName )
% finds db control window and adds mouse
h_db = get_fighandle([datatype ' database*']);
if ~isempty(h_db)
    if length(h_db)>1
        errormsg(['Multiple ' datatype ' databases open. Cannot determine which one to use.']);
        return
    else
        ud = get(h_db,'Userdata');
        logmsg(['Adding ' datatype ' record ' epoch]);
        control_db_callback(ud.h.last);
        pause(0.1);
        ud = new_testrecord(ud);
        record = ud.db(ud.current_record);
        if isfield(record,'epoch')
            record.epoch = epoch;
        end
        if isfield(record,'stim_type')
            record.stim_type = scriptName;
        end
        ud.db(ud.current_record) = record;
        set(h_db,'Userdata',ud);
        control_db_callback(ud.h.current_record);
    end
end
