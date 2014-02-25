function varargout = Hdfsi(varargin)
% HDFSI M-file for Hdfsi.fig
%      HDFSI, by itself, creates a new HDFSI or raises the existing
%      singleton*.
%
%      H = HDFSI returns the handle to a new HDFSI or the handle to
%      the existing singleton*.
%
%      HDFSI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HDFSI.M with the given input arguments.
%
%      HDFSI('Property','Value',...) creates a new HDFSI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Hdfsi_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Hdfsi_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Hdfsi

% Last Modified by GUIDE v2.5 11-Feb-2008 15:01:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Hdfsi_OpeningFcn, ...
                   'gui_OutputFcn',  @Hdfsi_OutputFcn, ...
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


% --- Executes just before Hdfsi is made visible.
function Hdfsi_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Hdfsi (see VARARGIN)

% Choose default command line output for Hdfsi
handles.output = hObject;

handles.continu = true;
if strcmp('Block', varargin{1})
    handles.EVENT = varargin{2};
    filename = varargin{3};
    
    [pathstr, name] = fileparts(filename); 
    [pathstr, Tankname] = fileparts(handles.EVENT.Mytank);
    if strcmp(name, Tankname)  %check whether this is the same tank
        handles.EVENT.filename = filename;
    else
        handles.EVENT.filename = [handles.EVENT.Mytank '.h5'];
    end
    handles.EVENT.Blockname = handles.EVENT.Myblock;
    handles.EVENT.Code = '-'; %default code for this block
    handles.EVENT.Comment = '-'; %default comment for this block

    set(handles.edit_filename, 'String', handles.EVENT.filename)
    set(handles.edit_Blockname, 'String', handles.EVENT.Blockname)
   
    
elseif strcmp('Tank', varargin{1})
    
 
    handles.EVENT = varargin{2};
    set(handles.uipanel2, 'Visible', 'on')
    set(handles.uipanel1, 'Visible', 'off')
    %defaults
    
    handles.EVENT.Tankdoc = '-';
    handles.EVENT.Tankcomment = '-';
    handles.EVENT.Tankcode = '-';
    
    
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Hdfsi wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Hdfsi_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%if isfield(handles, 'EVENT')
    varargout{1} = handles.continu;
    varargout{2} = handles.EVENT;
% else
%     varargout = 0;
% end

% if isempty(handles)
% 
%     close(gcf)
%     
% else
%if ishandle(handles.figure1) && handles.close == 1
     close(handles.figure1)
%end


function edit_filename_Callback(hObject, eventdata, handles)
% hObject    handle to edit_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_filename as text
%        str2double(get(hObject,'String')) returns contents of edit_filename as a double


% --- Executes during object creation, after setting all properties.
function edit_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_edit.
function pb_edit_Callback(hObject, eventdata, handles)
% hObject    handle to pb_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    [pathstr, name, ext] = fileparts(handles.EVENT.filename); 
    dname = uigetdir(pathstr);
    filename = fullfile(dname, [name ext]);
    handles.EVENT.filename = filename;
    set(handles.edit_filename, 'String', filename);
    
% Update handles structure
guidata(hObject, handles);



function edit_Blockname_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Blockname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Blockname as text
%        str2double(get(hObject,'String')) returns contents of edit_Blockname as a double


% --- Executes during object creation, after setting all properties.
function edit_Blockname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Blockname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_code_Callback(hObject, eventdata, handles)
% hObject    handle to edit_code (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_code as text
%        str2double(get(hObject,'String')) returns contents of edit_code as a double
handles.EVENT.Code = get(hObject,'String');
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_code_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_code (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Descr_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Descr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Descr as text
%        str2double(get(hObject,'String')) returns contents of edit_Descr as a double


handles.EVENT.Comment = get(hObject,'String');
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_Descr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Descr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_cancel.
function pb_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pb_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        handles.continu = false;
        uiresume(handles.figure1)
        % Update handles structure
        guidata(hObject, handles);

% --- Executes on button press in pb_Save.
function pb_Save_Callback(hObject, eventdata, handles)
% hObject    handle to pb_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
        handles.continu = true;
        uiresume(handles.figure1)
% Update handles structure
        guidata(hObject, handles);



function e_Tankcode_Callback(hObject, eventdata, handles)
% hObject    handle to e_Tankcode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_Tankcode as text
%        str2double(get(hObject,'String')) returns contents of e_Tankcode as a double
    handles.EVENT.Tankcode = get(hObject,'String');
        % Update handles structure
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function e_Tankcode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_Tankcode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_doc_Callback(hObject, eventdata, handles)
% hObject    handle to e_doc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_doc as text
%        str2double(get(hObject,'String')) returns contents of e_doc as a double
    handles.EVENT.Tankdoc = get(hObject,'String');
    % Update handles structure
    guidata(hObject, handles);
    
% --- Executes during object creation, after setting all properties.
function e_doc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_doc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_TankComment_Callback(hObject, eventdata, handles)
% hObject    handle to e_TankComment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_TankComment as text
%        str2double(get(hObject,'String')) returns contents of e_TankComment as a double
    handles.EVENT.Tankcomment = get(hObject,'String');
        % Update handles structure
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function e_TankComment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_TankComment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_filedoc.
function pb_filedoc_Callback(hObject, eventdata, handles)
% hObject    handle to pb_filedoc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [FileName, PathName] = uigetfile('*.*','Select file');     
    fn = fullfile(PathName, FileName);

    set(handles.e_doc, 'String', fn)
    
    handles.EVENT.Tankdoc = fn;
    % Update handles structure
    guidata(hObject, handles);
    

% --- Executes on button press in pb_OK_tank.
function pb_OK_tank_Callback(hObject, eventdata, handles)
% hObject    handle to pb_OK_tank (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.uipanel2, 'Visible', 'off')
    set(handles.uipanel1, 'Visible', 'on')
    
     uiresume(handles.figure1)
  

