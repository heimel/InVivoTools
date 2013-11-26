% The protocol file opens a window in which protocols can be created
% or changed.
%
% A protocol consists of blocks that can be executed one by one or in a
% sequence automatically. Blocks can be of various types. This system is
% rather flexible: just create a new figure  named 'blockfig_blablabla.fig'
% (try copying one of the others and modify it to your needs). Protocol
% will simply scan the directory for files named like that.
%
% Based on component-tag and filename (blablabla part) a variable-name will 
% be generated in the save file and in the struct that is sent to the run 
% routines. So choose them wisely. Also, you can enter userdata in guide,
% this will be used as default values for that element.
%
% This file also calls erg_protocol_run and erg_block_run. From the latter
% all IO activities are coordinated.
%
% See also: erg_block_run, erg_protocol_run

function varargout = protocol(varargin)
% PROTOCOL M-file for protocol.fig
%      PROTOCOL, by itself, creates a new PROTOCOL or raises the existing
%      singleton*.
%
%      H = PROTOCOL returns the handle to a new PROTOCOL or the handle to
%      the existing singleton*.
%
%      PROTOCOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROTOCOL.M with the given input arguments.
%
%      PROTOCOL('Property','Value',...) creates a new PROTOCOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before protocol_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to protocol_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help protocol

% Last Modified by GUIDE v2.5 09-Oct-2007 15:17:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @protocol_OpeningFcn, ...
                   'gui_OutputFcn',  @protocol_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function loadFigWalkChilds(parent, pretag, ytranspose)
  childs = get(parent,'Children');
  for i = 1:length(childs)
    child = childs(i);
    childType = get(child,'Type');
    if (strcmp(childType,'uicontrol'))
      set(child,'Units','pixels');
      oldpos = get(child,'position');
      oldpos(2) = oldpos(2) + ytranspose;
      set(child,'position',oldpos);
      
      childStyle = get(child,'Style');
      set(child,'Callback',''); 
      set(child,'CreateFcn',@emptyCallback);
      switch childStyle
          case 'radiobutton'
            set(child,'Tag',[pretag get(child,'Tag')]);
          case 'edit'
            set(child,'Tag',[pretag get(child,'Tag')]);
            set(child,'Callback',@changedCallback); 
          case 'popupmenu' %selectbox
            set(child,'Tag',[pretag get(child,'Tag')]);
            set(child,'Callback',@changedCallback); 
        otherwise
         %   disp(['Huh, I did not know that existed as well; childType: ' pretag ':' childType]);
      end
      set(child,'ButtonDownFcn',@emptyCallback);
      set(child,'DeleteFcn',@emptyCallback);
    elseif (strcmp(childType,'uipanel'))
      loadFigWalkChilds(child, pretag, ytranspose);
    else
      disp(['Huh, I did not know that existed as well; childType: ' Type]);
    end
  end
  
function handles = loadPanels(hObject, handles)
  global gui ergConfig;
  %Load all panels from current directory  

  cd(ergConfig.blockdir)
  s = cellstr(ls('blockfig_*.fig'));
  if (length(s)>0) 
    for fnr = 1:length(s)
      fName = s{fnr};
      ImportFig = hgload(fName,struct('visible','off')); % Open fig file and get handle
      ImportPanel = get(ImportFig,'Children');
        
      %The next part is a rather complex calculation to position the panel
      butpos = get(handles.button_new,'position');
      axpos  = get(handles.axesTimeline,'position');
      appos  = get(handles.actionPanel,'position');
      x1 = axpos(1);
      y1 = appos(2) + appos(4) + 2*(butpos(2) - axpos(2) - axpos(4));
      y2 = (axpos(2) - 2*(butpos(2) - axpos(2) - axpos(4)))-y1;
      x2 = axpos(3);

      set(ImportPanel,'Units','pixels');
      mypos  = get(ImportPanel,'position');
      resize = y2 - mypos(4);

      loadFigWalkChilds(ImportPanel, ['protdata_' fName(10:end-4) '_'], resize);

      figNow = hObject;
      NewPanel = copyobj(ImportPanel,figNow); 
      set(NewPanel,'Parent', figNow); 
      set(NewPanel,'position',[x1 y1 x2 y2])
      set(NewPanel,'visible','off');
      delete(ImportFig);                             % Delete imported figure
      handles.(fName(1:end-4)) = NewPanel;
      s{fnr} = fName(10:end-4);
      gui.colors.(s{fnr}) = get(NewPanel,'BackgroundColor');
    end;
  else 
    disp('I could not find any blockfig_*.fig files, maybe you should change your working directory!');
  end;
  set(handles.select_type,'String',[{'Select Type'}; s]);   
  guidata(hObject, handles);

  
% --- Executes just before protocol is made visible.
function protocol_OpeningFcn(hObject, eventdata, handles, varargin)
  global gui;

  % Check if stuff is actually already running...
  if (ismember('output',fieldnames(handles))) return; end

  handles.output = hObject;
  guidata(hObject, handles);
  initVars(handles);

  %initialize the timeLine image based on constants 
  axes(handles.axesTimeline);
  set(handles.axesTimeline,'Units','pixels');
  p = get(handles.axesTimeline, 'position');
  tl_width = gui.constBlockCount*(gui.constBlockSize + gui.constBlockSpacing);
  p(2) = p(2) - ((gui.constBlockSize + gui.constBlockSpacing)-p(4));
  set(handles.axesTimeline, 'position', [p(1) p(2) tl_width (gui.constBlockSize + gui.constBlockSpacing)] );
  i = ones(5,gui.constBlockCount*5,3)*.5;
  for a = (1:5:gui.constBlockCount*5)
      i(3,a+2,1) = 1;
  end
  image(i); axis tight; axis off;
  gui.tlx = p(1) - (gui.constBlockSize + gui.constBlockSpacing);
  gui.tly = p(2) + (gui.constBlockSpacing / 2);

  %Yes, load panels for protocols from protocol_*.fig files 
  handles = loadPanels(hObject, handles);
  
  %Update GUI according to current program state
  updateItemEditor(handles);

function colorTimeline()
  global gui;
  i = ones(5,gui.constBlockCount*5,3)*.5;
  if (gui.dragging == 0 && gui.current>0)
      c5 = 1+5*(gui.current-1);
      i(1:5,c5:c5+4,1) = 1;
      i(1:5,c5:c5+4,2) = 0.4;
      i(1:5,c5:c5+4,3) = 0.4;
  end
  for a = (1:5:gui.constBlockCount*5)
      i(3,a+2,1) = 1;
  end
  image(i); axis tight; axis off;
% --- Outputs from this function are returned to the command line.

function varargout = protocol_OutputFcn(hObject, eventdata, handles) 
  varargout{1} = handles.output;

function res=block2pos(nr)
  global gui;
  res = [gui.tlx+nr*(gui.constBlockSize+gui.constBlockSpacing)+gui.constBlockSpacing*.5 gui.tly gui.constBlockSize gui.constBlockSize];
  
function res=pos2block(x,y)
  global gui;
  x = x - gui.tlx - gui.constBlockSpacing*.5 ;
  res = round(x/(gui.constBlockSize+gui.constBlockSpacing));
  if (res <1) res = 1; end
  if (res > gui.constBlockCount) res = gui.constBlockCount; end
  

function res=createButton(nr, type, handles)
  global gui;
  if (~ismember(type{1},fieldnames(gui.colors))) type{1} = 'none'; end
  
  res = uicontrol('Style', 'pushbutton', 'String','..', 'userdata',nr, 'ButtonDownFcn', @protocolItemClick, ...
      'Position', block2pos(nr), 'enable','inactive', 'backgroundcolor', gui.colors.(type{1}));
%  handles.button_runblock_protocol_item(nr) = res; %not needed? probably even not
%  working
  gui.items(nr).h = res;

% --- Executes on button_runblock press in button_runblock_new.
function button_new_Callback(hObject, eventdata, handles)
  global protocol_data gui;

  if (protocol_data.numItems < gui.constBlockCount)
    gui.hasChanged = 1;
    protocol_data.numItems = protocol_data.numItems + 1;
    protocol_data.items(protocol_data.numItems).data4type(1).dummy = 0;
    protocol_data.items(protocol_data.numItems).type = {'Select Type'};
    protocol_data.items(protocol_data.numItems).tag = '..';
    h = createButton(protocol_data.numItems, protocol_data.items(protocol_data.numItems).type, handles);   
    protocolItemClick(h, eventdata);
    gui.dragging = 0;
    colorTimeline();
  end

function protocolItemClick(hObject, eventdata)
  global gui protocol_data;
  
  handles = guidata(hObject);
  saveProtocolItemTypeData(handles);
  
  gui.current = get(hObject,'userdata');
  gui.dragging = gui.current;
  colorTimeline();
  
  set(handles.figure1,'Units','pixels');
  mouse = get(handles.figure1,'currentpoint');
  thingy = get(gui.items(gui.current).h,'position');
  gui.dragxdif = mouse(1)-thingy(1);
  gui.dragydif = mouse(2)-thingy(2);
  
  updateItemEditor(handles);

function initVars(handles)
  global gui protocol_data ergConfig;
  persistent guiColors;
  
  %Set number of channels in select
  for i = 1:ergConfig.maxInputChannels
    s{i} = [num2str(i) ' channel(s)'];
  end
  set(handles.numchannels,'Value',1);
  set(handles.numchannels,'String',s);

  protocol_data = {};
  protocol_data.numItems = 0;
  gui.current = 0;
  
  gui.constBlockCount = 20;
  gui.constBlockSpacing = 10;
  set(handles.axesTimeline,'Units','pixels');
  axPos = get(handles.axesTimeline,'position');
  gui.constBlockSize = (axPos(3)/gui.constBlockCount) - gui.constBlockSpacing;
  
  gui.colors.none = [.8 .8 .8];
  gui.dragging = 0;
  gui.dragydif = 0;
  gui.dragxdif = 0;
  gui.fileLoaded = 0;
  gui.hasChanged = 0;
  gui.path = ergConfig.protocoldir;
  for i=1:gui.constBlockCount gui.items(i).h = 0; end
  
  %Save gui colors in persistent var, later inits will benefit from it
  %since gui will be deleted from time to time
  if (isempty(guiColors)) guiColors = gui.colors; else gui.colors = guiColors; end;
  
% What to draw to the screen, it is decided in this function
function updateItemEditor(handles)
  global gui protocol_data;


  %hide all panels
  content = get(handles.select_type,'String');
  for i = 2:length(content)
     set(handles.(['blockfig_' content{i}]),'visible','off');
  end;
  
  if (gui.current > 0)
    p = protocol_data.items(gui.current);

    %type select box
    set(handles.select_type,'visible','on');
    set(handles.select_type,'value',typeAsNr(handles, p.type));

    loadProtocolItemTypeData(handles);
    if (~strcmp(p.type{1},'Select Type')) 
      set(handles.(['blockfig_' p.type{1}]),'visible','on')
    end

    set(handles.itemTag,'visible','on');
    set(handles.itemTag,'String',p.tag);
  else
    set(handles.select_type,'visible','off');
    set(handles.itemTag,'visible','off');
  end


% Dynamically load data from protocol struct into GUI, fieldnames based on GUI element names
function loadProtocolItemTypeData(handles)
  global gui protocol_data;

  if (gui.current > 0 && ~strcmp(protocol_data.items(gui.current).type{1},'Select Type') )
    try
      hs = guihandles(handles.(['blockfig_' protocol_data.items(gui.current).type{1}]));  
    catch
      return;
    end
    b = fieldnames(hs);
    prefix = ['protdata_' protocol_data.items(gui.current).type{1} '_'];
    for n=b'
      fn = n{1};
      if (length(fn) > length(prefix) && strcmp(prefix,fn(1:length(prefix))))
        name = fn(length(prefix)+1:length(fn));
        type = protocol_data.items(gui.current).type{1};
        d4t = protocol_data.items(gui.current).data4type;
        if (~ismember(type,fieldnames(d4t)) || ~ismember(name,fieldnames(protocol_data.items(gui.current).data4type.(type))))
           protocol_data.items(gui.current).data4type.(type).(name) = get(hs.(fn),'userdata');
        end

        loadedval = protocol_data.items(gui.current).data4type.(protocol_data.items(gui.current).type{1}).(name);
        switch get(hs.(fn),'style')
            case 'radiobutton'
                set(hs.(fn),'value', loadedval);
            case 'edit'
                set(hs.(fn),'String', loadedval);
            case 'popupmenu' %selectbox
                s = get(hs.(fn),'String');
                for i = 1:length(s), if strcmp(s{i},loadedval) break; end; end;
                set(hs.(fn),'value', i);
        end
      end
    end
  end

% Dynamically save data from GUI into protocol struct, fieldnames based on GUI element names
function saveProtocolItemTypeData(handles)
  global gui protocol_data;
  
  gui.hasChanged = 1;
  if (gui.current > 0 && ~strcmp(protocol_data.items(gui.current).type{1},'Select Type'))
    s1 = get(handles.numchannels,'String');
    s2 = s1{get(handles.numchannels,'Value')};
    s3 = [s2(1)];
    protocol_data.items(gui.current).numchannels = str2num(s3);

    try
      hs = guihandles(handles.(['blockfig_' protocol_data.items(gui.current).type{1}]));  
    catch
      return;
    end
    b = fieldnames(hs);
    for n=b'
      fn = n{1};
      s = ['protdata_' protocol_data.items(gui.current).type{1} '_'];
      if (length(fn) > length(s) && strcmp(s,fn(1:length(s))))
        name = fn(length(s)+1:length(fn));
        switch get(hs.(fn),'style')
            case 'radiobutton'
                protocol_data.items(gui.current).data4type.(protocol_data.items(gui.current).type{1}).(name) = get(hs.(fn),'value');
            case 'edit'
                protocol_data.items(gui.current).data4type.(protocol_data.items(gui.current).type{1}).(name) = get(hs.(fn),'String');
            case 'popupmenu' %selectbox
                s = get(hs.(fn),'String');
                protocol_data.items(gui.current).data4type.(protocol_data.items(gui.current).type{1}).(name) = s{get(hs.(fn),'Value')};
            otherwise
                disp(get(hs.(fn),'style'));
        end
      end
    end
  end
  
% --- Executes on selection change in select_type.
function select_type_Callback(hObject, eventdata, handles)
  global gui protocol_data;
  
  if(gui.current > 0)
     gui.hasChanged = 1;
     saveProtocolItemTypeData(handles);
     content = get(hObject,'String');
     nr = get(hObject,'Value');
     if (nr > 1) %1 = 'Select Type..'
       protocol_data.items(gui.current).type = {content{nr}};
       set(gui.items(gui.current).h,'backgroundcolor',gui.colors.(content{nr})); 
     end
  end
  updateItemEditor(handles);

function nr = typeAsNr(handles, type)
  content = get(handles.select_type,'String');
  nr = 1;
  for i = 1:length(content)
    if (strcmp(content{i}, type)) nr = i; return; end;
  end;
  
      
% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
  global gui;
  if (gui.dragging > 0)
    set(handles.figure1,'Units','pixels');
    mouse = get(handles.figure1,'currentpoint');
%    set(handles.i1, 'String', [num2str(mouse(1,1)) ',' num2str(mouse(1,2))]);
    set(gui.items(gui.dragging).h,'Position',[mouse(1,1)-gui.dragxdif  mouse(1,2)-gui.dragydif  gui.constBlockSize gui.constBlockSize]);
    drawnow
  end

%Small funx and dums
function editCallback(hObject, eventdata, handles) 
  global gui; 
  gui.hasChanged = 1;
function editCreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor')) set(hObject,'BackgroundColor','white'); end
function figure1_DeleteFcn(hObject, eventdata, handles)
  clear;
function menuFile_Callback(hObject, eventdata, handles)
function emptyCallback(hObject, eventdata)
function changedCallback(hObject, eventdata)
  global gui;
  gui.hasChanged = 1;

% This is called whenever an item should be relocated on the timeLine
function transfer(old, new)
  % assumes new is an empty spot!!
  global gui protocol_data;
  set(gui.items(old).h,'Position',block2pos(new));
  if (old ~= new)
    set(gui.items(old).h,'userdata',new);
    gui.current = new;
    gui.items(new).h = gui.items(old).h;
    gui.items(old).h = 0;
    protocol_data.items(new) = protocol_data.items(old);
  end        

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
  global gui protocol_data;
  if (gui.dragging > 0)
      dragged = gui.dragging;
      gui.dragging = 0;

      set(gui.items(dragged).h,'Units','pixels');
      p = get(gui.items(dragged).h,'Position');
      nr = pos2block(p(1), p(2));
      while (nr > 1 && (gui.items(nr-1).h == 0 || (nr-1==dragged && gui.items(nr).h ==0)))
          nr = nr - 1;
      end
      
      %And now for some shuffle
      if (dragged == nr)
        transfer(dragged, nr);
      elseif (gui.items(nr).h == 0)
        transfer(dragged, nr);
        for i = (dragged:protocol_data.numItems)
          transfer(i+1, i);
        end
      elseif (dragged > nr)                          % -------------------------------------
        transfer(dragged, protocol_data.numItems+1); % save current one after end of line...  
        for i = (dragged:-1:nr+1)                    % make way
          transfer(i-1, i);
        end
        transfer(protocol_data.numItems+1, nr);      % fill up empty spot with dragged one
      elseif (dragged < nr)                          % -------------------------------------
        transfer(dragged, protocol_data.numItems+1); % save current one after end of line...  
        for i = (dragged:nr-1)                       % make way
          transfer(i+1, i);                     
        end
        transfer(protocol_data.numItems+1, nr);      % fill up empty spot with dragged one
      end                                            % -------------------------------------

      %clean up protocol items list  
      protocol_data.items = protocol_data.items(1:protocol_data.numItems); 
      colorTimeline();
  end


function menuSaveAs_Callback(hObject, eventdata, handles)
  global protocol_data gui;
  saveProtocolItemTypeData(handles);

  [fileName, path, FILTERINDEX] = uiputfile([gui.path '*.epf'], 'Select destination...');
  if (fileName > 0)
    save([path fileName], 'protocol_data','gui', '-MAT');
    gui.fileLoaded = 1;
    gui.path = path;
    gui.fileName = fileName;
    gui.hasChanged = 0;
  end

% --------------------------------------------------------------------
function menuSave_Callback(hObject, eventdata, handles)
  global gui protocol_data;
  if (gui.fileLoaded == 0) 
      menuSaveAs_Callback(0, 0, handles)
  else
    saveProtocolItemTypeData(handles);
    save([gui.path gui.fileName], 'protocol_data','gui', '-MAT');
    gui.hasChanged = 0;
  end

% --------------------------------------------------------------------
function menuNew_Callback(hObject, eventdata, handles)
  if (checkFileSaved==1) 
    startOver(handles);
    colorTimeline();
    updateItemEditor(handles);  
  end
  
function startOver(handles)  
  global protocol_data gui;
  
  if (protocol_data.numItems > 0)
    for i = 1:protocol_data.numItems
      delete(gui.items(i).h);
    end
  end
  clear protocol_data;
  clear gui; 
  initVars(handles);

function res=checkFileSaved()
  global gui;
  res = 1;
  if (gui.hasChanged == 1)
    if (questdlg('Discard current changes??','What to do?','Yeh','Nah', 'Nah')=='Nah')
        res = 0;
    end
  end

  % --------------------------------------------------------------------
function menuLoad_Callback(hObject, eventdata, handles)
  global protocol_data gui;
	
  if (checkFileSaved==1) 
		  pushdir=pwd;
			cd(gui.path);
      [fileName, path, FILTERINDEX] = uigetfile('*.epf', 'Select file...');

      %now update gui and program state according to the new file (and load it first :)
      if (fileName > 0)
          temp_save_colors = gui.colors;
          startOver(handles);
          load([path fileName], 'protocol_data','gui', '-MAT');
          for i = 1:protocol_data.numItems
              createButton(i,protocol_data.items(i).type);
              set(gui.items(i).h, 'String', protocol_data.items(i).tag);
          end
          gui.dragging = 0;
          colorTimeline();
          loadProtocolItemTypeData(handles);
          updateItemEditor(handles);

          gui.fileLoaded = 1;
          gui.hasChanged = 0;
          gui.fileName = fileName;
          gui.path = path;
          gui.colors = temp_save_colors;
			end
			cd(pushdir);
  end
  
function button_delete_Callback(hObject, eventdata, handles)
  global gui protocol_data;
  
  cur = gui.current;
  
  if (cur <= 0) return; end
  delete(gui.items(cur).h);
  for i = (gui.current:protocol_data.numItems-1)                       % make way
    transfer(i+1, i);                     
  end
  if (gui.current >= protocol_data.numItems)
    gui.current = cur - 1;
  else
    gui.current = cur;
  end
  protocol_data.numItems = protocol_data.numItems-1;
  protocol_data.items = protocol_data.items(1:protocol_data.numItems); 
  colorTimeline(); 
  updateItemEditor(handles);

function button_runblock_Callback(hObject, eventdata, handles)
  global gui protocol_data;
  if (gui.current <= 0) 
      if (protocol_data.numItems <=0)
        warndlg('No block was selected. I think you should make one first!','Ooops')
      else
        warndlg('No block was selected. It''s rather easy: just click on one :)','Ooops')
      end
      return;
  end
  saveProtocolItemTypeData(handles);
  erg_block_run(protocol_data.items(gui.current));
  
  
function itemTag_Callback(hObject, eventdata, handles)
  global gui protocol_data;
  if (gui.current <= 0) return; end;
  protocol_data.items(gui.current).tag = get(hObject,'String');
  set(gui.items(gui.current).h,'String',get(hObject,'String'));

function itemTag_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))  set(hObject,'BackgroundColor','white'); end
  
function button_stopreset_Callback(hObject, eventdata, handles)
  erg_block_run('stopandreset');

function button_runall_Callback(hObject, eventdata, handles)
  global protocol_data;
  saveProtocolItemTypeData(handles);
  erg_protocol_run(protocol_data);
  
function button_stopandresetall_Callback(hObject, eventdata, handles)
  erg_protocol_run('stopandreset');
  erg_block_run('stopandreset');

function numchannels_Callback(hObject, eventdata, handles)
function numchannels_CreateFcn(hObject, eventdata, handles) 
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor')) set(hObject,'BackgroundColor','white'); end


