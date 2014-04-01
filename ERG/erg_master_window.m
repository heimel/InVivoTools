%The file master_window creates a window from which all other components 
%needed for the analysis are launched. It should be run from the "root"
%directory of all matlab files. 
%
%From here it runs config_erg, which sets the global ergConfig
%It also calls ergLogger and points it to a list-view. It really doesn't
%do much more, it's not much more than just an empty shell.
%
%See also: config_erg, calibration, protocol, tester, ergLogger

function varargout = erg_master_window(varargin)
% erg_master_window M-file for erg_master_window.fig
%      erg_master_window, by itself, creates a new erg_master_window or raises the
%      existing singleton*.
%
%      H = erg_master_window returns the handle to a new erg_master_window or the handle to
%      the existing singleton*.
%
%      erg_master_window('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in erg_master_window.M with the given input arguments.
%
%      erg_master_window('Property','Value',...) creates a new erg_master_window or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before erg_master_window_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to erg_master_window_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help erg_master_window

% Last Modified by GUIDE v2.5 22-Oct-2007 14:34:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @erg_master_window_OpeningFcn, ...
                   'gui_OutputFcn',  @erg_master_window_OutputFcn, ...
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

% --- Executes just before erg_master_window is made visible.
function erg_master_window_OpeningFcn(hObject, eventdata, handles, varargin)
  % Check if stuff is actually already running...
  if (ismember('output',fieldnames(handles))) return; end
  ud.persistent = 1;
  set(handles.figure1,'userdata',ud);
  config_erg();
  handles.output = hObject;
  guidata(hObject, handles);
   
% --- Outputs from this function are returned to the command line.
function varargout = erg_master_window_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% Default functions, actually not used or changed
function master_ergLogList_Callback(hObject, eventdata, handles)
function master_ergLogList_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor')) set(hObject,'BackgroundColor','white'); end

% Some functions to call other windows/application modules
function button_calibration_Callback(hObject, eventdata, handles)
  calibration;  
function button_protocol_Callback(hObject, eventdata, handles)
  protocol;
function button_tester_Callback(hObject, eventdata, handles)
  tester;

% Create new experiment: ask for name and mouse number and initialize ergLogger  
function button_newexperiment_Callback(hObject, eventdata, handles)
  global ergConfig;
  options.Resize='on';
  options.WindowStyle='normal';
  options.Interpreter='none';
  mousename = inputdlg('Enter mouse name (DEC.exp_gr.nr)','',1,{''},options);
  
  if (isempty(mousename{1})) return; end
  expname = inputdlg('Enter experiment name');
  if (isempty(expname{1})) return; end
  dirname = [datestr(now,'yyyymmdd - ') mousename{1} ' - ' expname{1}];
  try
    oldcd = cd;
    cd([ergConfig.datadir filesep dirname]);
    disp('Directory already exists, that is not good!');
    cd(oldcd);
    return;
  catch
  end   
  filename = [mousename{1} ' - '];
  ergLogger('close');
  
  % The fancy thing about ergLogger: it gets a handle to a list and a panel 
  % and handles everything else. This keeps things as seperate as possible
  ergLogger('init', {handles.master_ergLogList, handles.master_ergLogPanel, dirname, filename});

% Call the ergLogger to close current experment
function button_closeexp_Callback(hObject, eventdata, handles)
  ergLogger('close');

% Call the ergLogger to load a full experiment  
function button_loadexp_Callback(hObject, eventdata, handles)
  ergLogger('load',  {handles.master_ergLogList, handles.master_ergLogPanel}); 

% This calls for (quick) analysis of the current block (cur). What type of
% analysis is conducted will be determined by erg_analysis_block, based on 
% the ergLog settings (actually the analysis field (dependent on select box).
function button_analyzeblock_Callback(hObject, eventdata, handles)
  global ergLog;
  cur = get(handles.master_ergLogList,'Value');
  if (isempty(cur)) return; end;
  erg_analysis_block(ergLog,cur);
  
% This function writes matlab code (for loading the data file corresponding 
% to the current block to a file (defined in ergConfig.analyzeAppendFile).
function button_addToAnalysis_Callback(hObject, eventdata, handles)
  global ergConfig ergLog;
  cur = get(handles.master_ergLogList,'Value');
  if (isempty(cur)) return; end;
  f = fopen([ergConfig.analyzeAppendFile],'a');
    
  mouseid = ergLog.dataFilePrefix(1:findstr(ergLog.dataFilePrefix,' - '));
  fwrite(f, ['mid = ''' mouseid '''; mouse = cellfind(mid,miceid); if (mouse < 0) mouse = length(miceid)+1; miceid{mouse} = mid; groupsize(mouse) = 0; end; exp = groupsize(mouse)+1; groupsize(mouse) = exp; data_erg(mouse,exp).expgroup=' num2str(ergLog.Entry(cur).groupcode) ';data_erg(mouse,exp).filename = [ergConfig.datadir '''  ergLog.dataSubDir filesep ergLog.dataFilePrefix num2str(cur,'%03d') ' - DATA.mat'']; %' ergLog.Entry(cur).name ' :: ', ergLog.Entry(cur).comment ]);
  fprintf(f,'\n');
  fclose(f);

function button_protocoldump_Callback(hObject, eventdata, handles)
  global ergLog ergConfig;
  cur = get(handles.master_ergLogList,'Value');
  if (isempty(cur)) return; end;
  filename = [ergConfig.datadir ergLog.dataSubDir filesep ergLog.dataFilePrefix num2str(cur,'%03d') ' - DATA.mat'];
  [block duration stimuli] = erg_getdata_div(filename);
  block.data4type.(block.type{1})
   


