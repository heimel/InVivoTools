function varargout = Tdt2ml(varargin)
% TDT2ML M-file for Tdt2ml.fig
%      TDT2ML, by itself, creates a new TDT2ML or raises the existing
%      singleton*.
%
%      H = TDT2ML returns the handle to a new TDT2ML or the handle to
%      the existing singleton*.
%
%      TDT2ML('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TDT2ML.M with the given input arguments.
%
%      TDT2ML('Property','Value',...) creates a new TDT2ML or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Tdt2ml_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Tdt2ml_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help Tdt2ml

% Last Modified by GUIDE v2.5 24-Jan-2008 10:46:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Tdt2ml_OpeningFcn, ...
                   'gui_OutputFcn',  @Tdt2ml_OutputFcn, ...
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


% --- Executes just before Tdt2ml is made visible.
function Tdt2ml_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Tdt2ml (see VARARGIN)

% Choose default command line output for Tdt2ml
handles.output = [];
handles.OBJ = hObject;

set(0,'Units','characters')
handles.Scrn = get(0,'ScreenSize');
w3 = floor(handles.Scrn(3)/3);
h3 = floor(handles.Scrn(4)/3);
set(handles.figure1, 'Position', [w3 h3 108 27])
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Tdt2ml wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Tdt2ml_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function activex1_TankChanged(hObject, eventdata, handles)
% hObject    handle to activex1 (see GCBO)
% eventdata  structure with parameters passed to COM event listerner
% handles    structure with handles and user data (see GUIDATA)

    
    handles.activex3.UseBlock = '';
    handles.activex2.ActiveBlock = '';
    
    handles.activex2.UseTank = hObject.ActiveTank;
    handles.activex2.Refresh
    handles.activex3.UseTank = hObject.ActiveTank;
    handles.activex3.Refresh
    handles.Mytank = char(hObject.ActiveTank);
    
    %set(handles.ParamPanel, 'Visible', 'off');
    guidata(handles.OBJ, handles);


% --------------------------------------------------------------------
function activex2_BlockChanged(hObject, eventdata, handles)
% hObject    handle to activex2 (see GCBO)
% eventdata  structure with parameters passed to COM event listerner
% handles    structure with handles and user data (see GUIDATA)    set(handles.Data, 'Enable', 'off');
    handles.activex3.UseBlock = '';
    handles.activex3.Refresh
    
  if isfield(handles, 'Reentr') %is this the second or more time
    set(handles.Data, 'Enable', 'off');
    set(handles.Exbase, 'Enable', 'off');
    set(handles.h5sav, 'Enable', 'off');
   else
    handles.Reentr = 0;
   end
    %clear the whole EVENT structure
    handles.EVENT = [];
    
    handles.EVENT.Mytank = handles.Mytank;   
    handles.EVENT.Myblock = hObject.ActiveBlock;
    set(handles.status_txt, 'String','BUSY...retrieving info')  
    handles.EVENT = Exinf4(handles.EVENT);
  
    %copy trial array
    if isfield(handles.EVENT, 'Trials')
        Names = fieldnames(handles.EVENT.Trials);
        for i = 1:length(Names)
            Trials(:,i) = handles.EVENT.Trials.(Names{i});
        end
        handles.Trials = Trials;
        handles.Names = Names;
    else    
       errordlg('No trials in this data, Tdt2ml cannot evaluate this block', 'Error')
    end
    set(handles.status_txt, 'String','READY!!')
    
    handles.activex3.UseBlock = hObject.ActiveBlock;
    handles.activex3.ActiveEvent = '';
    handles.activex3.Refresh
    
   
    %if this is the second time we open a block we can set EVENT parameters
    %neccessary for saving the block data to HDF
     if handles.Reentr > 0
            StrStart = get(handles.labelStart,'String');
            handles.EVENT.Start = str2double(StrStart);

            StrTlngth =  get(handles.labelLen,'String');
            handles.EVENT.Triallngth = str2double(StrTlngth);

            StrChan = get(handles.labelChan, 'String');
            handles.EVENT.CHAN = str2num(StrChan);
            
            set(handles.Exbase, 'Enable', 'on');
            set(handles.h5sav, 'Enable', 'on');
            
     end
     
    guidata(handles.OBJ, handles);
  

% --------------------------------------------------------------------
function activex3_ActEventChanged(hObject, eventdata, handles)
% hObject    handle to activex3 (see GCBO)
% eventdata  structure with parameters passed to COM event listerner
% handles    structure with handles and user data (see GUIDATA)

EvCode = hObject.ActiveEvent;
%Rt = isfield(handles.EVENT.strms.name, EvCode);
try
    Rt = strmatch(EvCode, {handles.EVENT.strms(:).name} );
catch
   errordlg(['Please renew/delete this file: ' handles.EVENT.Mytank handles.EVENT.Myblock '.mat']);
   return
end
if ~isempty(Rt) 
    TYPE = 'strms';
    handles.EVENT.type = TYPE;
    handles.EVENT.Myevent = EvCode;
    %Chans = handles.EVENT.strms.(EvCode).channels;
    Chans = handles.EVENT.strms(Rt).channels;
    set(handles.labelChan, 'String', num2str(1:Chans));
    handles.EVENT.CHAN = (1:Chans);
    handles.Chans = Chans;
    
else
   %Rt = isfield(handles.EVENT.snips, EvCode);
   Rt = strmatch(EvCode, {handles.EVENT.snips(:).name} );
   if ~isempty(Rt)
       TYPE = 'snips';
       handles.EVENT.type = TYPE;
       handles.EVENT.Myevent = EvCode;
       %Chans = handles.EVENT.snips.(EvCode).channels;
       Chans = handles.EVENT.snips(Rt).channels;
       set(handles.labelChan, 'String', num2str(1:Chans));
       handles.EVENT.CHAN = (1:Chans);
       handles.Chans = Chans;
   end
end
    
if ~isempty(Rt)    
    set(handles.Data, 'Enable', 'off'); 
    
    if ~isfield(handles.EVENT, 'Start')
        StrStart = get(handles.labelStart,'String');
        handles.EVENT.Start = str2double(StrStart);
    end
    if ~isfield(handles.EVENT, 'Triallngth')
       StrTlngth =  get(handles.labelLen,'String');
       handles.EVENT.Triallngth = str2double(StrTlngth);
    end
    
    %valid data for all EVENT fields has been entered, rentering we can
    %use these values again
    handles.Reentr = handles.Reentr + 1;
    %the event structure may now be exported or the block may be saved to
    %HDF
    set(handles.Exbase, 'Enable', 'on');
    set(handles.h5sav, 'Enable', 'on');
    
    set(handles.ParamPanel, 'Visible', 'on');

    pos = get(handles.figure1, 'Position');
    if pos(2) + 52 > handles.Scrn(4)
        pos(2) = handles.Scrn(4) - 52;
    end
    pos(4) = 47;
    set(handles.figure1, 'Position', pos)
    set(handles.status_txt, 'Position', [1.8 1.0 104 1.8]);

    guidata(handles.OBJ, handles);
  
  %  beep
else
    hObject.ActiveEvent = '';
    hObject.Refresh
    warndlg('Only stream and snip events can be selected','!! Invalid choice !!')
end

% --------------------------------------------------------------------
function Exbase_Callback(hObject, eventdata, handles)
    if(isfield(handles, 'EVENT'))
        assignin('base','EVENT',handles.EVENT)
    end
    if(isfield(handles, 'sign'))
        assignin('base', 'sign', handles.sign)
    end
    if(isfield(handles, 'snip'))
        assignin('base', 'snip', handles.snip)
    end
    if(isfield(handles, 'Eyesign'))
        assignin('base', 'Eyesign', handles.Eyesign)
    end

    if(isfield(handles, 'Trials'))
        assignin('base', 'Trials', handles.Trials)
    end
    if(isfield(handles, 'Names'))
           assignin('base', 'Names', handles.Names)
    end

    disp('Export done!!!')
    beep
    
% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    delete(hObject);


% --------------------------------------------------------------------
function Help_Callback(hObject, eventdata, handles)
% hObject    handle to Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   Exhelp2



% --------------------------------------------------------------------
function PSTH_Men_Callback(hObject, eventdata, handles)
% hObject    handle to PSTH_Men (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.EVENT.type, 'strms')
     if(isfield(handles, 'sign'))
        Expsth( handles.EVENT, handles.sign)
     end
elseif  strcmp(handles.EVENT.type, 'snips') 
   if(isfield(handles, 'snip'))
       Expsth( handles.EVENT, handles.snip)
   end
end

function labelStart_Callback(hObject, eventdata, handles)
% hObject    handle to labelStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of labelStart as text
%        str2double(get(hObject,'String')) returns contents of labelStart as a double
        StrStart = get(hObject,'String');
        if ~isempty(StrStart) && isempty(regexp(StrStart,'[a-zA-Z\<\>\?\(\)\*\&\^\%\$\#\@\!\{\}]', 'ONCE'))
            handles.EVENT.Start = str2double(StrStart);  
            guidata(handles.OBJ, handles); %update internal store
        else 
              set(hObject, 'String', '0.0');  
              errordlg('Only numbers please!')
        end



function labelLen_Callback(hObject, eventdata, handles)
% hObject    handle to labelLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of labelLen as text
%        str2double(get(hObject,'String')) returns contents of labelLen as a double
        StrTrl = get(hObject,'String');
        if ~isempty(StrTrl) && isempty(regexp(StrTrl,'[a-zA-Z\<\>\?\(\)\*\&\^\%\$\#\@\!\{\}]', 'ONCE'))
            handles.EVENT.Triallngth = str2double(StrTrl);  
           guidata(handles.OBJ, handles); %update internal store
        else 
              set(hObject, 'String', '0.0');  
              errordlg('Only numbers please')
        end




function editCrr_Callback(hObject, eventdata, handles)
% hObject    handle to editCrr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCrr as text
%        str2double(get(hObject,'String')) returns contents of editCrr as a double
    StrSel = get(hObject,'String');
    i = find(strcmp(handles.Names, {'correct'}));
    C = handles.Trials(:,i);  %array with correct or not correct
    try
        Indx = eval(StrSel);
    catch
        err = lasterror;
        errordlg(err.message);
        return
    end
    handles.Trials = handles.Trials(Indx,:);
    set(hObject, 'Enable', 'off');
    % Update handles structure
    guidata(handles.OBJ, handles);

% --- Executes during object creation, after setting all properties.
function editCrr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCrr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editErr_Callback(hObject, eventdata, handles)
% hObject    handle to editErr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editErr as text
%        str2double(get(hObject,'String')) returns contents of editErr as a double
    StrSel = get(hObject,'String');
    i = find(strcmp(handles.Names, {'error'}));
    E = handles.Trials(:,i);  %array with error or not error is 6th element in Trilist
    try
        Indx = eval(StrSel);
    catch
        err = lasterror;
        errordlg(err.message);
        return
    end
    handles.Trials = handles.Trials(Indx,:);
    set(hObject, 'Enable', 'off');
    % Update handles structure
    guidata(handles.OBJ, handles);

% --- Executes during object creation, after setting all properties.
function editErr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editErr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editWrd_Callback(hObject, eventdata, handles)
% hObject    handle to editWrd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWrd as text
%        str2double(get(hObject,'String')) returns contents of editWrd as a double
    StrSel = get(hObject,'String');
    i = find(strcmp(handles.Names, {'word'}));
    W = handles.Trials(:,i);  %array with word is 8th element in Trilist
    try
        Indx = eval(StrSel);
    catch
        err = lasterror;
        errordlg(err.message);
        return
    end
    handles.Trials = handles.Trials(Indx,:);
    set(hObject, 'Enable', 'off');
    % Update handles structure
    guidata(handles.OBJ, handles);

% --- Executes during object creation, after setting all properties.
function editWrd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWrd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BtnCncl.
function BtnCncl_Callback(hObject, eventdata, handles)
    %reset trial array
    
    for i = 1:length(handles.Names)
        Trials(:,i) = handles.EVENT.Trials.(handles.Names{i});
    end
    handles.Trials = Trials;

    set(handles.editCrr, 'String', 'find( C )');
    set(handles.editCrr, 'Enable', 'on');
    
    set(handles.editErr, 'String', 'find( E )');
    set(handles.editErr, 'Enable', 'on');
    
    set(handles.editWrd, 'String', 'find( W )');
    set(handles.editWrd, 'Enable', 'on');
    
    guidata(handles.OBJ, handles);

% --- Executes on button press in BtnRet.
function BtnRet_Callback(hObject, eventdata, handles)
% hObject    handle to BtnRet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   if ~isfield(handles.EVENT, 'Myevent')
       msgbox('Cannot retrieve data, no event selected (Stream or Snip)', '', 'warn')
       return
   end
   if ~isfield(handles.EVENT, 'Triallngth')
        handles.EVENT.Triallngth = str2double(get(handles.labelLen, 'String'));
   end
   if ~isfield(handles.EVENT, 'Start')
       handles.EVENT.Start = str2double(get(handles.labelStart, 'String'));
   end
   
   %only retrieve trials with a stimulus onset (prematurely aborted trials contain a nan)
   ixSO = find(strcmp(handles.Names, {'stim_onset'}));
   %Indx = find(~isnan(handles.Trials(:,ixSO))); 
   handles.Trials = handles.Trials(~isnan(handles.Trials(:,ixSO)),:);
   
   if size(handles.Trials,1) > 1
    set(handles.status_txt, 'String','BUSY...retrieving data');
    set(handles.Data, 'Enable', 'off');
    drawnow  %flushes event queue
    switch handles.EVENT.type
        case 'strms'
            handles.sign = Exd2(handles.EVENT, handles.Trials(:,1));
            
        case 'snips'
            %handles.sign = EXsnip(handles.EVENT, handles.Trials(:,1));
            handles.snip = Exsniptimes(handles.EVENT, handles.Trials(:,1));        
    end
    
    set(handles.status_txt, 'String','READY!!');   
    set(handles.Data, 'Enable', 'on');
    beep
   else
       msgbox('No trials to process, change filter!')
   end
    
    guidata(handles.OBJ, handles);
    

function labelChan_Callback(hObject, eventdata, handles)
% hObject    handle to labelChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of labelChan as text
%        str2double(get(hObject,'String')) returns contents of labelChan as a double

        StrChan = get(hObject,'String');
        if ~isempty(StrChan) && isempty(regexp(StrChan,'[^0-9\s]', 'ONCE'))
            Arr = str2num(StrChan);
            if (min(Arr) > 0 && max(Arr) <= handles.Chans)
                handles.EVENT.CHAN = str2num(StrChan);  
                guidata(handles.OBJ, handles); %update internal store
                return
            end
        end 
              set(hObject, 'String', num2str(handles.EVENT.CHAN));  
              errordlg(['Only integers between 1 and ' num2str(handles.Chans) ' please!'])
        






% --------------------------------------------------------------------
function h5sav_Callback(hObject, eventdata, handles)
% hObject    handle to h5sav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    %only select trals with a stimulus onset time  
    set(handles.status_txt, 'String','BUSY...writing data');
    if isfield(handles, 'filename')
        filename = handles.filename;
    else
        filename = '';
    end
    [OUTP EVENT] = Hdfsi('Block', handles.EVENT, filename);
    if OUTP
        handles.EVENT = H5save(EVENT, handles.Trials);
        set(handles.status_txt, 'String','READY!!');
        
        handles.filename = handles.EVENT.filename;
        
        guidata(handles.OBJ, handles);
    end

% --------------------------------------------------------------------
function T_FILE_Callback(hObject, eventdata, handles)
% hObject    handle to T_FILE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


