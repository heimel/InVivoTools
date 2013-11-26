function varargout = tester(varargin)

% tester M-file for tester.fig
%      tester, by itself, creates a new tester or raises the existing
%      singleton*.
%
%      H = tester returns the handle to a new tester or the handle to
%      the existing singleton*.
%
%      tester('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in tester.M with the given input arguments.
%
%      tester('Property','Value',...) creates a new tester or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tester_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tester_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tester

% Last Modified by GUIDE v2.5 06-Mar-2007 16:18:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tester_OpeningFcn, ...
                   'gui_OutputFcn',  @tester_OutputFcn, ...
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

% --- Executes just before tester is made visible.
function tester_OpeningFcn(hObject, eventdata, handles, varargin)
  global testdata;
  handles.output = hObject;
  guidata(hObject, handles);

  if (~exist('testdata','var')) testdata = []; end
  set(handles.ui_plotcur,'String',num2str(size(testdata,1)));  
  
function varargout = tester_OutputFcn(hObject, eventdata, handles) 
  varargout{1} = handles.output;

function button_go_Callback(hObject, eventdata, handles)
  global testdata;

  isr = str2num(get(handles.ui_sr,'String'));
  erg_io_openclose('resetall');     %we're being kinda rude and just reset the io stuff to our wishes
  erg_io_openclose('openall', isr); %and start it again. We can do that, cause we're just a testing panel :D

  pw = str2num(get(handles.ui_pw,'String'));
  sw = str2num(get(handles.ui_sw,'String'));
  prepulse = str2num(get(handles.ui_prepulse,'String'));
  postpulse = str2num(get(handles.ui_postpulse,'String'));
  
  contents = get(handles.ui_condition,'String');
  condition = contents{get(handles.ui_condition,'Value')};
  
  vs = str2num(get(handles.ui_vs,'String'));
  ve = str2num(get(handles.ui_ve,'String'));
  periods = str2num(get(handles.ui_periods,'String'));
  voltages = linspace(vs,ve,periods);
  
  averages = str2num(get(handles.ui_averages,'String'));
  
  for voltage = (voltages)
    for i = 1:averages
      [times, data] = erg_io_sendpulse_simple(erg_io_switchCondition(condition),prepulse,5,pw,voltage,postpulse,5);
      pause(sw/1000);
    
      testdata(size(testdata,1)+ (1:size(data,1)),(1:length(data))) = data;
      set(handles.ui_plotcur,'String',num2str(size(testdata,1)));
      button_plot_Callback(handles.button_plot, eventdata, handles);
    end      
  end
  
function button_lampoff_Callback(hObject, eventdata, handles)
  erg_io_lampoff('all');

function button_plot_Callback(hObject, eventdata, handles)
  global testdata;
  persistent f1;

  data_plot = [];
  if (size(testdata,1) <= 0); cla; return; end
  if (get(handles.ui_plotone,'Value')) data_plot = testdata(str2num(get(handles.ui_plotcur,'String')),:)'; end
  if (get(handles.ui_plotall,'Value')) data_plot = testdata'; end
  if (get(handles.ui_plotavg,'Value')) 
     nAvgs = str2num(get(handles.ui_averages,'String'));
     periods = str2num(get(handles.ui_periods,'String'));
     if (nAvgs*periods == size(testdata,1) && nAvgs > 1)
        for i = 1:periods
          data_plot2(i,:) = mean(testdata((i-1)*nAvgs+1:i*nAvgs,:),1); 
        end
        size(data_plot,2)+1
        size(data_plot,2)+nAvgs*periods
        size(data_plot2)
        data_plot(:,size(data_plot,2)+1:size(data_plot,2)+periods) = data_plot2';
     else
       data_plot2 = mean(testdata,1)';
       data_plot(:,size(data_plot,2)+1) = data_plot2';
     end
  end
  
  if (length(data_plot) > 0)
    if (get(handles.ui_plotwin,'Value'))
      if (isempty(f1) || ~ishandle(f1)) f1 = figure; end
      figure(f1); 
    else 
      if (ishandle(f1)) close(f1); end
      axes(handles.axes1); 
    end
    plot(data_plot); 
  end;
  
function ui_plotwin_Callback(hObject, eventdata, handles)
  button_plot_Callback(hObject, eventdata, handles);
function ui_plotavg_Callback(hObject, eventdata, handles)
  button_plot_Callback(hObject, eventdata, handles);
function ui_plotone_Callback(hObject, eventdata, handles)
  button_plot_Callback(hObject, eventdata, handles);
function ui_plotall_Callback(hObject, eventdata, handles)
  button_plot_Callback(hObject, eventdata, handles);
  
function ui_plotprev_Callback(hObject, eventdata, handles)
  global testdata;
  v = str2num(get(handles.ui_plotcur,'String'));
  v = v - 1;
  if (v < 1) v = size(testdata,1); end;
  set(handles.ui_plotcur,'String',num2str(v));
  button_plot_Callback(hObject, eventdata, handles);

function ui_plotnxt_Callback(hObject, eventdata, handles)
  global testdata;
  v = str2num(get(handles.ui_plotcur,'String'));
  v = v + 1;
  if (v > size(testdata,1)) v = min(1,size(testdata,1)); end;
  set(handles.ui_plotcur,'String',num2str(v));
  button_plot_Callback(hObject, eventdata, handles);
    
function ui_periods_Callback(hObject, eventdata, handles)

function button_clear_one_sample_Callback(hObject, eventdata, handles)
  global testdata;
  if (size(testdata,1) <= 0) return; end;

  cur = str2num(get(handles.ui_plotcur,'String'));                          % which one to delete?
  testdata(cur:size(testdata,1)-1,:) = testdata(cur+1:size(testdata,1),:);  % 'Opschuiven' 
  testdata = testdata(1:size(testdata,1)-1,:);                              % Actually shrink testdata array

  cur = cur + 1;
  if (cur >= size(testdata,1)) cur = size(testdata,1); set(handles.ui_plotcur,'String',num2str(cur)); end;
  button_plot_Callback(hObject, eventdata, handles);
  
function button_clear_all_samples_Callback(hObject, eventdata, handles)
  global pacq testdata;
  pacq = 0; set(handles.ui_plotcur,'String',num2str(pacq));
  clear global testdata;
  button_plot_Callback(hObject, eventdata, handles);

  
%The crap below is rather pointless GUIDE stuff  
function ui_sw_Callback(hObject, eventdata, handles)
function ui_spp_Callback(hObject, eventdata, handles)
function ui_sr_Callback(hObject, eventdata, handles)
function ui_pw_Callback(hObject, eventdata, handles)
function ui_v_Callback(hObject, eventdata, handles)
function ui_ve_Callback(hObject, eventdata, handles)
function ui_condition_Callback(hObject, eventdata, handles)
function ui_postpulse_Callback(hObject, eventdata, handles)
function ui_prepulse_Callback(hObject, eventdata, handles)
function ui_averages_Callback(hObject, eventdata, handles)

function ui_sr_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor')) set(hObject,'BackgroundColor','white'); end
function ui_pw_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor')) set(hObject,'BackgroundColor','white'); end
function ui_v_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor')) set(hObject,'BackgroundColor','white'); end
function ui_ve_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor')) set(hObject,'BackgroundColor','white'); end
function ui_spp_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor')) set(hObject,'BackgroundColor','white'); end
function ui_sw_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor')) set(hObject,'BackgroundColor','white'); end
function ui_periods_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor')) set(hObject,'BackgroundColor','white'); end
function ui_prepulse_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor')) set(hObject,'BackgroundColor','white'); end
function ui_postpulse_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor')) set(hObject,'BackgroundColor','white'); end
function ui_condition_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor')) set(hObject,'BackgroundColor','white'); end
function ui_averages_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor')) set(hObject,'BackgroundColor','white'); end
