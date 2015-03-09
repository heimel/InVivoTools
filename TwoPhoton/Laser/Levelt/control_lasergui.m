function varargout = control_lasergui(varargin)
% CONTROL_LASERGUI M-file for control_lasergui.fig
%      CONTROL_LASERGUI, by itself, creates a new CONTROL_LASERGUI or raises the existing
%      singleton*.
%
%      H = CONTROL_LASERGUI returns the handle to a new CONTROL_LASERGUI or
%      the handle to
%      the existing singleton*.
%
%      CONTROL_LASERGUI('CALLBACK',hObject,eventData,handles,...) calls the
%      local
%      function named CALLBACK in CONTROL_LASERGUI.M with the given input
%      arguments.
%
%      CONTROL_LASERGUI('Property','Value',...) creates a new CONTROL_LASERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before control_lasergui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property
%      application
%      stop.  All inputs are passed to control_lasergui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% 2012, Alexander Heimel
%

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @control_lasergui_OpeningFcn, ...
    'gui_OutputFcn',  @control_lasergui_OutputFcn, ...
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


% --- Executes just before control_lasergui is made visible.
function control_lasergui_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to control_lasergui (see VARARGIN)

if ~isfield(handles,'output')
    newinstance = true;
else
    newinstance = false;
end

% Choose default command line output for control_lasergui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

if newinstance
    edtPreset_Callback(handles.edtPreset,eventdata,handles)
end

ud.persistent = 1;
set(hObject,'userdata',ud);
checkLaserStatus(handles);

% start status check timer
delete(timerfind('Tag','checklaser'));
logmsg('Starting laser check timer');
%disp(  ['control_lasergui(''checkLaserStatus(' num2str(handles) ')'')'])
% t = timer('Tag','checklaser','TimerFcn', ...
%     ['control_lasergui(''checkLaserStatus(' num2str(handles) ')'')'],...
%     'ExecutionMode','fixedSpacing','Period',5,...
%     'BusyMode','drop',...
%     'StartDelay',2);
% start(t)





% --- Outputs from this function are returned to the command line.
function varargout = control_lasergui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sldPower_Callback(hObject, eventdata, h) %#ok<*DEFNU>
% hObject    handle to sldPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setpower(get(hObject,'Value'),h)


% --- Executes during object creation, after setting all properties.
function sldPower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function edtPreset_Callback(hObject, eventdata, h)
% hObject    handle to edtPreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

presetlevel = str2double(get(hObject,'String'))/100;
if ~isnumeric(presetlevel) || presetlevel < 0 || presetlevel>1 || isnan(presetlevel)
    return
end
psld = get(h.sldPower,'position');
p = get(hObject,'position');

p(2) = psld(2) +p(4)/2 + (psld(4)-1.5*p(4))*presetlevel ;
set(hObject,'position',p);

hbtn = findobj('tag','btnPreset');
pbtn = get(hbtn,'Position');
pbtn(2) = p(2) +p(4)/2 - pbtn(4)/2;
set(hbtn,'Position',pbtn);

setpower(presetlevel,h)


% --- Executes during object creation, after setting all properties.
function edtPreset_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
% hObject    handle to edtPreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edtPower_Callback(hObject, eventdata, h) %#ok<INUSD>
% hObject    handle to edtPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setpower(str2double(get(hObject,'String'))/100,h);



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


function setpower(level,h)
% level should be between 0 and 1

laserglobals;

if isempty(level) || ~isnumeric(level) || level>1 || level<0 || isnan(level)
    return
end

set(h.sldPower,'value',level)
set(h.sldPower,'BackgroundColor',[level^0.5 0 0]);

levelstring = num2str(fix(level*100));
if strcmp(get(h.edtPower,'String'),levelstring)==0
    set(h.edtPower,'string',levelstring)
end

pos = laserpower2nsc200(level);
new_pos = control_nsc200(pos);
if isempty(new_pos) || new_pos~= pos
    errormsg('Failed to set laser power correctly');
else
    GlobalLaserPowerFraction = level; %#ok<NASGU>
end
checkLaserStatus(h);


% --- Executes on button press in btnPreset.
function btnPreset_Callback(hObject, eventdata, h)
% hObject    handle to btnPreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setpower(str2double(get(h.edtPreset,'String'))/100,h)


% --- Executes on button press in btnPower.
function btnPower_Callback(hObject, eventdata, h)
% hObject    handle to btnPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h          structure with handles and user data (see GUIDATA)
if strcmpi(get(hObject,'String'),'on') %i.e. turn on
    turnlaseron(h);
else % i.e. turn off
    turnlaseroff(h);
end

checkLaserStatus(h);

function turnlaseron(h)
checkLaserStatus(h);
set(h.btnPower,'Enable','off');
out = control_maitai('READ:PCTWARMEDUP?');
if isempty(out)
    set(h.btnPower,'Enable','on');
    return;
end
if strcmp(out,'0.00%')
    out = control_maitai('ON');
    pause(2);
end

while ~strcmp(out,'100.00%')
    set(h.txtLaserpower,'String',['Warming up: ' out]);
    set(h.txtIncidentpower,'String','');
    pause(4);
    out = control_maitai('READ:PCTWARMEDUP?');
end
control_maitai('ON');
out = control_maitai('*STB?');
while ~isempty(out) && bitand(out,1)==0 % i.e. not emitting
    pause(2);
    out = control_maitai('*STB?');
end
set(h.btnPower,'String','Off');
set(h.btnPower,'Enable','on');

% start status check timer
delete(timerfind('Tag','checklaser'));
disp('CONTROL_LASERGUI: Starting laser check timer');
t = timer('Tag','checklaser','TimerFcn', 'control_lasergui(''checkLaserStatus'')',...
    'ExecutionMode','fixedSpacing','Period',5,...
    'BusyMode','drop',...
    'StartDelay',2);
start(t)
checkLaserStatus(h);




function turnlaseroff(h)
checkLaserStatus(h);
set(h.btnPower,'Enable','off');

delete(timerfind);
control_maitai('OFF');
out = control_maitai('*STB?');
while ~isempty(out) && bitand(out,1)==1 % i.e. emitting
    pause(2);
    out = control_maitai('*STB?');
end
set(h.btnPower,'String','On');
set(h.btnPower,'Enable','on');
checkLaserStatus(h);


function [stb,wavelength,power] = checkLaserStatus(h)
laserglobals;

logmsg('Checking status');

stb = control_maitai('*STB?');
if ~isempty(stb) && bitand(stb,2)==2
    set(h.rbtModelocking,'value',1); % mode locking
else
    set(h.rbtModelocking,'value',0);
end
wavelength = control_maitai('READ:WAVELENGTH?');
if ~isempty(wavelength)
    set(h.sldWavelengthActual,'Value',wavelength);
    set(h.txtWavelengthActual,'String',num2str(wavelength));
    GlobalLaserWavelength = wavelength; %#ok<NASGU>
end
power = control_maitai('READ:POWER?');
if isempty(stb) ||  bitand(stb,1)==0 || isempty(power)
    set(h.txtLaserpower,'String','Laser is off');
    set(h.txtIncidentpower,'String','');
else
    set(h.txtLaserpower,'String',['Laser power: ' num2str(power,4) ' W']);
    GlobalLaserIncidentPower = GlobalLaserPowerFraction * power ;
    set(h.txtIncidentpower,'String',...
        ['Incident power: '   num2str(GlobalLaserIncidentPower,3) ' W']);
end
shutter = control_maitai('SHUTTER?');
if ~isempty(shutter)
    if shutter % i.e. open
        set(h.cbxShutteropen,'Value',1);
    else
        set(h.cbxShutteropen,'Value',0);
    end
end

if ~isempty(stb) && bitand(stb,1)==1 && ~(~isempty(shutter) && ~shutter)
    set(h.rbtEmission,'value',1); % Emission
    set(h.rbtEmission,'ForegroundColor',[1 0 0]);
else
    set(h.rbtEmission,'value',0);
    set(h.rbtEmission,'ForegroundColor',[0 0 0]);
end

if ~isempty(stb) && bitand(stb,1)==1 % i.e. laser on
    set(h.btnPower,'String','Off');
else
    set(h.btnPower,'String','On');
end




function setwavelength( wavelength,h)
control_maitai('WAVELENGTH',round(wavelength));
[~,wavelengthactual] = checkLaserStatus(h);
while wavelengthactual~= wavelength
    pause(2)
    [~,wavelengthactual] = checkLaserStatus(h);
    logmsg(['Requested wavelength = ' num2str(wavelength) ...
        ', actual wavelength = ' num2str(wavelengthactual)]);
end


% --- Executes on slider movement.
function sldWavelength_Callback(hObject, eventdata, h)
% hObject    handle to sldWavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

wavelength = round(get(hObject,'Value'));
set(h.edtWavelength,'String',num2str(wavelength));
setwavelength(wavelength,h);


% --- Executes during object creation, after setting all properties.
function sldWavelength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldWavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




function edtWavelength_Callback(hObject, eventdata, h)
% hObject    handle to edtWavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

wavelength = str2double(get(hObject,'String'));
if isnan(wavelength) || wavelength<780 || wavelength>920
    return
end
set(findobj('Tag','sldWavelength'),'Value',wavelength);
setwavelength(wavelength,h);



% --- Executes during object creation, after setting all properties.
function edtWavelength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtWavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn810.
function btn810_Callback(hObject, eventdata, h)
% hObject    handle to btn810 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

wavelength = 810;
set(h.edtWavelength,'String',num2str(wavelength));
set(h.sldWavelength,'Value',wavelength);
setwavelength(wavelength,h);


% --- Executes on button press in btn920.
function btn920_Callback(hObject, eventdata, h)
% hObject    handle to btn920 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

wavelength = 920;
set(h.edtWavelength,'String',num2str(wavelength));
set(h.sldWavelength,'Value',wavelength);
setwavelength(wavelength,h);

% --- Executes on slider movement.
function sldWavelengthActual_Callback(hObject, eventdata, handles)
% hObject    handle to sldWavelengthActual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sldWavelengthActual_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldWavelengthActual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function txtWavelengthActual_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtWavelengthActual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in tbtShutter.
function tbtShutter_Callback(hObject, eventdata, handles)
% hObject    handle to tbtShutter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbtShutter


% --- Executes on button press in rbtModelocking.
function rbtModelocking_Callback(hObject, eventdata, handles)
% hObject    handle to rbtModelocking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbtModelocking


% --- Executes on button press in cbxShutteropen.
function cbxShutteropen_Callback(hObject, eventdata, h)
% hObject    handle to cbxShutteropen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

control_maitai('SHUTTER',get(hObject,'Value'));
pause(1);
checkLaserStatus(h);
logmsg('SHUTTER STATUS NEEDS TO BE CHECKED AT START!!');


function btn30_Callback(hObject, eventdata, handles)
setpower(0.3,handles)


function btn20_Callback(hObject, eventdata, handles)
setpower(0.2,handles);


function btn10_Callback(hObject, eventdata, handles)
setpower(0.1,handles);
