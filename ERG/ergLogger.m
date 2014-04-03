function [ output_args ] = ergLogger(what, args)
  global ergLog;
  
  switch what
      case 'init'
        ergLogger_init(args); 
      case 'update'
        ergLogger_update(); 
      case 'add'
        ergLogger_add(args);  
      case 'close'
        ergLogger_close();  
      case 'load'
        ergLogger_load(args);  
  end
  
function ergLogger_load(args)
  global ergLog ergConfig;
  currdir=pwd;
  cd(ergConfig.datadir);
  [fileName, path, FILTERINDEX] = uigetfile(['*LOGFILE.mat'], 'Select file...');
  cd(currdir);
  %now update gui and program state according to the new file (and load it first :)
   if (fileName > 0)
      ergLogger('close');
      load([path fileName], 'ergLog', '-MAT');
      ergLogg_fixfilesep;
      ergLogger_fixGui(args{1},args{2})
   end

function ergLogg_fixfilesep
  global ergLog 
  ergLog.dataSubDir(ergLog.dataSubDir=='\')=filesep;
    

   
function ergLogger_close(args)
  global ergLog;
  if (isempty(ergLog)) return; end;
  ergLogger_update();
 
  try
    for i = fieldnames(ergLog.listPanelItem)'
      delete(ergLog.listPanelItem.(i{1}));
    end
  catch
  end
  try
    set(ergLog.listBox,'String', {});
    set(ergLog.listBox,'Value', 1);
  catch
  end
  clear global ergLog

function ergLogger_add(args)  
  global ergLog ergConfig;
  
  if (isempty(ergLog)) 
    disp('No log to add to, sorry!');
    return;
  end      
      
  ergLog.nEntries = ergLog.nEntries + 1;
  n = ergLog.nEntries;
  ergLog.Entry(n).type = args{1};
  ergLog.Entry(n).start = args{2};
  ergLog.Entry(n).end = args{3};
  ergLog.Entry(n).name = args{4};
  ergLog.Entry(n).description = args{5};
  ergLog.Entry(n).comment = args{6};
  
  oldpath = cd;
  cd([ergConfig.datadir ergLog.dataSubDir]);
  if (~isempty(args{7})) 
    data_saved = args{7}; 
    save([ergLog.dataFilePrefix num2str(ergLog.nEntries,'%03d') ' - DATA.mat'], 'data_saved'); 
  end;
  
  if (~isempty(args{8})) calib_saved = args{8}; save([ergLog.dataFilePrefix num2str(ergLog.nEntries,'%03d') ' - CALIBRATION.mat'], 'calib_saved'); end;
  cd(oldpath);
  
  ergLogger_update();

function ergLogger_fixGui(listBox, listPanel)
  global ergLog;
  
    ergLog.listBox = listBox;
    ergLog.listPanel = listPanel;
    set(ergLog.listBox,'Callback',@ergLogger_listCallback)
  
    set(ergLog.listPanel,'Units','Pixels');
    h = 18; m = 5; w = 60;
    p1 = get(ergLog.listPanel,'Position');
    p2 = [m p1(4) - m w h];
    p2 = p2 - [0 h+m 0 0]; newText(ergLog.listPanel, p2, 'typeTxt', 'Type:');
    p2 = p2 - [0 h+m 0 0]; newText(ergLog.listPanel, p2, 'nameTxt', 'Name:');
    p2 = p2 - [0 h+m 0 0]; newText(ergLog.listPanel, p2, 'startTxt', 'Started:');
    p2 = p2 - [0 h+m 0 0]; newText(ergLog.listPanel, p2, 'endTxt','Finished:');
    p2 = p2 - [0 h+m 0 0]; newText(ergLog.listPanel, p2, 'descriptionTxt', 'Description:');
    p2 = p2 - [0 h+m 0 0]; newText(ergLog.listPanel, p2, 'pathTxt','Path:');
    p2 = p2 - [0 h+m 0 0]; newText(ergLog.listPanel, p2, 'commentGroupcode','Group:');
    p2 = p2 - [0 h+m 0 0]; newText(ergLog.listPanel, p2, 'commentTxt','Comment:');
    p2 = p2 - [0 h+m 0 0]; newText(ergLog.listPanel, p2, 'commentAnalysis','Analysis:');

    p2 = [2*m+w p1(4) - m p1(3)-w-4*m h];
    p2 = p2 - [0 h+m 0 0]; newEdit(ergLog.listPanel, p2, 'type', 0);
    p2 = p2 - [0 h+m 0 0]; newEdit(ergLog.listPanel, p2, 'name', 1);
    p2 = p2 - [0 h+m 0 0]; newEdit(ergLog.listPanel, p2, 'start', 0);
    p2 = p2 - [0 h+m 0 0]; newEdit(ergLog.listPanel, p2, 'end', 0);
    p2 = p2 - [0 h+m 0 0]; newEdit(ergLog.listPanel, p2, 'description',0);
    p2 = p2 - [0 h+m 0 0]; newEdit(ergLog.listPanel, p2, 'path', 0);
    p2 = p2 - [0 h+m 0 0]; newEdit(ergLog.listPanel, p2, 'groupcode', 1);
  %  p2(4) = p2(2)-3*m; p2(2) = 2*m;
    p2 = p2 - [0 h+m 0 0]; newEdit(ergLog.listPanel, p2, 'comment', 1);
    
    global ergConfig;
    cd(ergConfig.analysisdir);
    s = cellstr(ls('erg_analysis_block_*.m'));
    if (length(s)>0) 
      for fnr = 1:length(s)
        fName = s{fnr};
        s{fnr} = fName(20:end-2);
      end
    end
    p2 = p2 - [0 h+m 0 0]; newPulldown(ergLog.listPanel, p2, 'analysis', s, 1);
    
  % p2 = p2 - [0 0 w 0]; res = res = newText(ergLog.listPanel, p2, [ergConfig.datadir ergLog.dataSubDir '\' ergLog.dataFilePrefix );
    ergLogger_update();

    if (ishandle(ergLog.listBox) && ~isempty(s));
			set(ergLog.listBox,'Value', 1); 
			ergLogger_listCallback; 
		end;

function ergLogger_init(args)
  global ergLog ergConfig;

  if (isempty(ergLog))
    ergLog.nEntries = 0;
    ergLog.Entry = [];
    
    ergLog.dataSubDir = [filesep num2str(args{3})]; %'\20070405 - LogTest';
    ergLog.dataFilePrefix = num2str(args{4}); %'20070405 - ';

    mkdir(fullfile(ergConfig.datadir,ergLog.dataSubDir));
    ergLogger_fixGui(args{1},args{2});
  end

function newText(parent, pos, name, txt)
  global ergLog;
  ergLog.listPanelItem.(name) = uicontrol('HorizontalAlignment','left','Style','text','String',txt,'parent',parent,'Units','Pixels','Position',pos);  

function nr=analysis2nr(txt, list)
  nr = 1;
  for i = 1:length(list)
    if (strcmp(txt, list{i}))
      nr = i; return;
    end
  end
  
function newPulldown(parent, pos, name, txt, changable)
  global ergLog;
  if (changable) cb = @ergLogger_listPanelCallback; else cb = @ergLogger_listCallback; end;
  if (changable) col = [0 0 0]; else col=[0.5 0.5 0.5]; end;
  ergLog.listPanelItem.(name) = uicontrol('ForegroundColor',col,'UserData',{name},'Callback',cb,'HorizontalAlignment','left','Style','popupmenu','String',txt,'parent',parent,'Units','Pixels','Position',pos);  
  
function newEdit(parent, pos, name, changable)
  global ergLog;
  if (changable) cb = @ergLogger_listPanelCallback; else cb = @ergLogger_listCallback; end;
  if (changable) col = [0 0 0]; else col=[0.5 0.5 0.5]; end;
  ergLog.listPanelItem.(name) = uicontrol('ForegroundColor',col,'Callback',cb,'UserData',{name},'HorizontalAlignment','left','Style','edit','String','','parent',parent,'Units','Pixels','Position',pos);  
  
  
function ergLogger_update()
  global ergLog ergConfig;
  if (isempty(ergLog) || ergLog.listBox <= 0 || size(ergLog.Entry,2) ~= ergLog.nEntries) return; end;
  
  s = {};
  for (i = 1:ergLog.nEntries)
    s{i} = ergLog.Entry(i).name;
  end
  if (ishandle(ergLog.listBox)) 
      set(ergLog.listBox,'String', s); 
  end;
  
  try
    save([ergConfig.datadir ergLog.dataSubDir filesep ergLog.dataFilePrefix  '000 - LOGFILE.mat'], 'ergLog'); 
  catch
    disp(['ERGLOGGER: Problem saving logfile in ergLogger_update() - FilePath = [' ergConfig.datadir ergLog.dataSubDir filesep ergLog.dataFilePrefix  '000 - LOGFILE.mat' ']'])
  end
  
  
function ergLogger_listCallback(hObject, eventdata)
  global ergLog ergConfig;
  if (isempty(ergLog)) return; end;
  
  cur = get(ergLog.listBox,'Value');
  if (isempty(cur)) return; end;
  if (isempty(ergLog.Entry)) return; end;

  set(ergLog.listPanelItem.type,'String',ergLog.Entry(cur).type);
  set(ergLog.listPanelItem.name,'String',ergLog.Entry(cur).name);
  set(ergLog.listPanelItem.start,'String',datestr(ergLog.Entry(cur).start));
  set(ergLog.listPanelItem.end,'String',datestr(ergLog.Entry(cur).end));
  set(ergLog.listPanelItem.comment,'String',ergLog.Entry(cur).comment);
  set(ergLog.listPanelItem.description,'String',ergLog.Entry(cur).description);
  set(ergLog.listPanelItem.path,'String',[ergConfig.datadir ergLog.dataSubDir filesep ergLog.dataFilePrefix num2str(cur,'%03d')]);

  modded = false;
  if (~ismember('groupcode',fieldnames(ergLog.Entry(cur))) || isempty(ergLog.Entry(cur).groupcode)) 
    ergLog.Entry(cur).groupcode = -1;
    modded = true;
  end
  set(ergLog.listPanelItem.groupcode,'String',ergLog.Entry(cur).groupcode);
  
  if (~ismember('analysis',fieldnames(ergLog.Entry(cur))) || isempty(ergLog.Entry(cur).analysis)) 
    ergLog.Entry(cur).analysis = 'pulsetrain';
    modded = true;
  end
  set(ergLog.listPanelItem.analysis,'Value',analysis2nr(ergLog.Entry(cur).analysis, get(ergLog.listPanelItem.analysis,'String')));
  
if  ergLog.Entry(cur).start > datenum('2014-03-17')
    logmsg('Experiment done after 2014-03-17. ');
      ergConfig.voltage_amplification = 1000;
else
      ergConfig.voltage_amplification = 10000;
end  
logmsg(['Amplification = ' num2str( ergConfig.voltage_amplification )]);
  %if (modded) ergLogger('update'); end
  
function ergLogger_listPanelCallback(hObject, eventdata)
  global ergLog;
  name = get(hObject,'UserData');
  name = name{1};
  cur = get(ergLog.listBox,'Value');
  if (strcmp(get(hObject,'style'),'edit'))
    ergLog.Entry(cur).(name) = get(hObject,'String');
  else
    s = get(hObject,'String');
    ergLog.Entry(cur).(name) = s{get(hObject,'Value')};
  end
  ergLogger('update');

  
