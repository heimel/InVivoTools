function varargout = erg_block_run_ui(varargin)
  if (length(varargin) < 1) return; end;
  try
    if (isempty(str2num(varargin{1}))) return; end;
  catch
  end
  
  eval(['persistent whoami' num2str(varargin{1})]);
  
% ERG_BLOCK_RUN_UI M-file for erg_block_run_ui.fig
%      ERG_BLOCK_RUN_UI, by itself, creates a new ERG_BLOCK_RUN_UI or raises the existing
%      singleton*.
%
%      H = ERG_BLOCK_RUN_UI returns the handle to a new ERG_BLOCK_RUN_UI or the handle to
%      the existing singleton*.
%
%      ERG_BLOCK_RUN_UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ERG_BLOCK_RUN_UI.M with the given input arguments.
%
%      ERG_BLOCK_RUN_UI('Property','Value',...) creates a new ERG_BLOCK_RUN_UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before erg_block_run_ui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to erg_block_run_ui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help erg_block_run_ui

% Last Modified by GUIDE v2.5 11-Oct-2007 12:13:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;

if (gui_Singleton == 1) gui_Singleton = 0; end; %GUIDE KEEPS CHANGING IT...

gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @erg_block_run_ui_OpeningFcn, ...
                   'gui_OutputFcn',  @erg_block_run_ui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);

  eval(['isemp = isempty(whoami' num2str(varargin{1}) ');']);
  eval(['ishan = ishandle(whoami' num2str(varargin{1}) ');']);
  
  if (isemp || ~ishan) 
       eval(['whoami' num2str(varargin{1}) '= gui_mainfcn(gui_State, {varargin{2:end}});']);
       eval(['gh = guihandles(whoami' num2str(varargin{1}) ');']);
       set(gh.axesProgress,'NextPlot','replacechildren');
       set(gh.runui_axes1,'NextPlot','replacechildren');
  end

  eval(['gh = guihandles(whoami' num2str(varargin{1}) ');'])
  erg_block_run_ui_args({varargin{2:end}}, gh);    
  
  eval(['if nargout [varargout{1:nargout}] = whoami' num2str(varargin{1}) ';end']);
  eval(['set(whoami' num2str(varargin{1}) ',''name'',''Channel ' num2str(varargin{1}) ' progress'');']);
% End initialization code - DO NOT EDIT


function erg_block_run_ui_OpeningFcn(hObject, eventdata, handles, varargin)
  handles.output = hObject;
  guidata(hObject, handles);

function  erg_block_run_ui_args(varargin, handles)
  persistent f1;
  if (length(varargin)==0) return; end
  
  switch (varargin{1})
      case 'progress'
          if (length(varargin) < 2) disp('Not enough parameters for progress function'); return; end
          do_progress_bar(varargin{2}, handles);
      case 'plot'
          if (length(varargin) < 3) disp('Not enough parameters for plot function'); return; end
          if (get(handles.runui_popup,'Value')) 
            if (isempty(f1) || ~ishandle(f1)) f1 = figure; end
            figure(f1); 
          else
            if (ishandle(f1)) close(f1); end
            axes(handles.runui_axes1);
          end
          plot(varargin{2}, varargin{3});
  end
  
function do_progress_bar(percentage, handles)
  %initialize the timeLine image based on constants 
  if (~get(handles.runui_showprogress,'value')) return; end;
  axe = handles.axesProgress;
  axes(axe);
  set(axe,'Units','pixels');
  p = round(get(axe, 'position'));
  i = ones(p(4),p(3),3)*.5;
  w = round(p(3)/100*percentage);
  if (w >= 0) i(1:p(4),1:w,2) = 1; end
  i([1,2,p(4)-1,p(4)],:,:) = 0;
  i(:,[1,2,p(3)-1,p(3)],:) = 0;
  image(i);   
  axis off;
  axis image;
  
function varargout = erg_block_run_ui_OutputFcn(hObject, eventdata, handles) 
  varargout{1} = handles.output;

function rungui_plotone_Callback(hObject, eventdata, handles)
function rungui_popup_Callback(hObject, eventdata, handles)
function runui_showprogress_Callback(hObject, eventdata, handles)
function runui_plotavg_Callback(hObject, eventdata, handles)
function runui_plotall_Callback(hObject, eventdata, handles)


