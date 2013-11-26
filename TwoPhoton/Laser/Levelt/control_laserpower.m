function varargout = control_laserpower(varargin)
% CONTROL_LASERPOWER M-file for control_laserpower.fig
%      CONTROL_LASERPOWER, by itself, creates a new CONTROL_LASERPOWER or raises the existing
%      singleton*.
%
%      H = CONTROL_LASERPOWER returns the handle to a new CONTROL_LASERPOWER or the handle to
%      the existing singleton*.
%
%      CONTROL_LASERPOWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONTROL_LASERPOWER.M with the given input arguments.
%
%      CONTROL_LASERPOWER('Property','Value',...) creates a new CONTROL_LASERPOWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before control_laserpower_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to control_laserpower_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help control_laserpower

% Last Modified by GUIDE v2.5 04-Mar-2012 21:04:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @control_laserpower_OpeningFcn, ...
                   'gui_OutputFcn',  @control_laserpower_OutputFcn, ...
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


% --- Executes just before control_laserpower is made visible.
function control_laserpower_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to control_laserpower (see VARARGIN)

if ~isfield(handles,'output')
    newinstance = true;
else
    newinstance = false;
end

% Choose default command line output for control_laserpower
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes control_laserpower wait for user response (see UIRESUME)
% uiwait(handles.figure1);


if newinstance
    edtPreset_Callback(findobj('Tag','edtPreset')) 
end

ud.persistent = 1;
set(hObject,'userdata',ud);


% --- Outputs from this function are returned to the command line.
function varargout = control_laserpower_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sldPower_Callback(hObject, eventdata, handles)
% hObject    handle to sldPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


setpower(get(hObject,'Value'))


% --- Executes during object creation, after setting all properties.
function sldPower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edtPreset_Callback(hObject, eventdata, handles)
% hObject    handle to edtPreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtPreset as text
%        str2double(get(hObject,'String')) returns contents of edtPreset as a double

presetlevel = str2double(get(hObject,'String'))/100;
if ~isnumeric(presetlevel) || presetlevel < 0 || presetlevel>1 || isnan(presetlevel)
    return
end
h = findobj('tag','sldPower');
psld = get(h,'position');
p = get(hObject,'position');

p(2) = psld(2) +p(4)/2 + (psld(4)-1.5*p(4))*presetlevel ;
set(hObject,'position',p);

hbtn = findobj('tag','btnPreset');
pbtn = get(hbtn,'Position');
pbtn(2) = p(2) +p(4)/2 - pbtn(4)/2;
set(hbtn,'Position',pbtn);


setpower(presetlevel)



% --- Executes during object creation, after setting all properties.
function edtPreset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtPreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edtPower_Callback(hObject, eventdata, handles)
% hObject    handle to edtPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtPower as text
%        str2double(get(hObject,'String')) returns contents of edtPower as a double

setpower(str2double(get(hObject,'String'))/100)



% --- Executes during object creation, after setting all properties.
function edtPower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function setpower(level)
% level should be between 0 and 1 

laserglobals;

if isempty(level) || ~isnumeric(level) || level>1 || level<0 || isnan(level)
    return
end

h = findobj('tag','sldPower');
set(h,'value',level)
set(h,'BackgroundColor',[level^0.5 0 0]);

levelstring = num2str(fix(level*100));
h = findobj('tag','edtPower');
if strcmp(get(h,'String'),levelstring)==0
    set(h,'string',levelstring)
end

pos = laserpower2nsc200(level);
new_pos = control_nsc200(pos);
if isempty(new_pos) || new_pos~= pos
    warning('CONTROL_LASERPOWER:FAIL','CONTROL_LASERPOWER: Failed to set laser power correctly');
else
    GlobalLaserPowerFraction = level; 
end


% --- Executes on button press in btnPreset.
function btnPreset_Callback(hObject, eventdata, handles)
% hObject    handle to btnPreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h = findobj('tag','edtPreset');
setpower(str2double(get(h,'String'))/100)
