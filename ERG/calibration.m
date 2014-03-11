function varargout = calibration(varargin)
% CALIBRATION M-file for calibration.fig
%      CALIBRATION, by itself, creates a new CALIBRATION or raises the existing
%      singleton*.
%
%      H = CALIBRATION returns the handle to a new CALIBRATION or the handle to
%      the existing singleton*.
%
%      CALIBRATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALIBRATION.M with the given input arguments.
%
%      CALIBRATION('Property','Value',...) creates a new CALIBRATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before calibration_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to calibration_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help calibration

% Last Modified by GUIDE v2.5 23-Mar-2007 11:08:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @calibration_OpeningFcn, ...
                   'gui_OutputFcn',  @calibration_OutputFcn, ...
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
% --- Executes just before calibration is made visible.
function calibration_OpeningFcn(hObject, eventdata, handles, varargin)
  handles.output = hObject;
  guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = calibration_OutputFcn(hObject, eventdata, handles) 
  varargout{1} = handles.output;
  if (init(gcf) < 0) varargout{1} = -1; else  plot_all_calib(handles); end 

function plot_one_calib(handles,led)
    global calib;

    if (~ismember([led 'Low'],fieldnames(calib)) || ~ismember([led 'High'],fieldnames(calib))) return; end;
    
    axes(handles.axes_calib); hold on; 
    cL = calib.([led 'Low']);
    cH = calib.([led 'High']);
    if (strcmp(led,'green')) color = 'g'; elseif (strcmp(led,'blue')) color = 'b'; elseif (strcmp(led,'UV')) color = 'm'; end
    if (strcmp(led,'green')) offs = 1; elseif (strcmp(led,'blue')) offs = 7; elseif (strcmp(led,'UV')) offs = 11; end

    plot(cL.in,cL.out,[color ':'],cH.in, cH.out/100,[color '-']);

    axes(handles.axes_calib_blocks); hold on;
    plot([cL.out(end)    cL.out(1)   ],[offs   offs  ],color,'LineWidth',5)
    plot([cL.out(end)*5  cL.out(1)*5 ],[offs+1 offs+1],color,'LineWidth',5)
    plot([cL.out(end)*10 cL.out(1)*10],[offs+2 offs+2],color,'LineWidth',5)
    plot([cH.out(end)    cH.out(1)   ],[offs+3 offs+3],color,'LineWidth',5)
    plot([cH.out(end)*5  cH.out(1)*5 ],[offs+4 offs+4],color,'LineWidth',5)
    plot([cH.out(end)*10 cH.out(1)*10],[offs+5 offs+5],color,'LineWidth',5)

function plot_all_calib(handles)
%----------------------------------------------------%
    global calib ergConfig;                          %
%----------------------------------------------------%
    cla(handles.axes_calib);                         % 
    cla(handles.axes_calib_blocks);                  %
    %------------------------------------------------%
    plot_one_calib(handles, 'green');                %
    plot_one_calib(handles, 'blue');                 %
    plot_one_calib(handles, 'UV');                   %
    %------------------------------------------------%
    set(handles.axes_calib, 'Color','k');            %
    set(handles.axes_calib_blocks, 'XScale','log');  %
    set(handles.axes_calib_blocks, 'Color','k');     %
%----------------------------------------------------%
    save([ergConfig.basedir filesep 'latestcalib.mat'], 'calib')
%----------------------------------------------------%

function button_calib_blue_Callback(hObject, eventdata, handles)
    global calib;
    do_calib('blueLow' ,(-4:1:4), 5);  
    do_calib('blueHigh',(-4:0.5:4), 2);  
    calib.fromfile(2) = 0;
    plot_all_calib(handles);

function button_calib_UV_Callback(hObject, eventdata, handles)
    global calib;
    do_calib('UVLow' ,(-4:1:4), 1);  
    do_calib('UVHigh',(-4:1:4), 1);  
    calib.fromfile(3) = 0;
    plot_all_calib(handles);

function button_calib_green_Callback(hObject, eventdata, handles)
    global calib;
    do_calib('greenLow' ,(-4:1:4), 5);  % was 5 instead of 15
%    do_calib('greenLow' ,(-4:1:4), 1);  
    do_calib('greenHigh',(-4:0.5:4), 2); % was 2  
    calib.fromfile(1) = 0;
    plot_all_calib(handles);

function plot_all_test(handles)    
   global test;
   persistent f1;

   if (get(handles.check_float_test,'Value'))
      if (sum(ishandle(f1)) == 0) f1 = figure; end
      figure(f1); 
    else 
      axes(handles.axes_test); 
    end

    gp = 1;
    bp = 10;
    up = 100;
    cla(gca); hold on;
    %ALEXANDER: temporarily disabled green test 
		try
			if (ismember('green',fieldnames(test))) plot(test.green.in,test.green.in*gp,'r'); plot(test.green.in,test.green.in*gp*1.1,'Color',[.5 .5 .5]); plot(test.green.in,test.green.in*gp*0.9,'Color',[.5 .5 .5]); end
			if (ismember('UV',fieldnames(test)))    plot(test.UV.in,test.UV.in*up,'r'); plot(test.UV.in,test.UV.in*up*1.1,'Color',[.5 .5 .5]); plot(test.UV.in, test.UV.in*up*0.9,'Color',[.5 .5 .5]); end
		end
		if (ismember('blue',fieldnames(test))) plot(test.blue.in,test.blue.in*bp,'r'); plot(test.blue.in,test.blue.in*bp*1.1,'Color',[.5 .5 .5]); plot(test.blue.in,test.blue.in*bp*0.9,'Color',[.5 .5 .5]); end
		try
			if (ismember('green',fieldnames(test))) scatter(test.green.in,test.green.out*gp,4,test.green.color,'filled'); end
			if (ismember('UV',fieldnames(test))) scatter(test.UV.in,test.UV.out*up,4,test.UV.color,'filled'); end
		end
		if (ismember('blue',fieldnames(test))) scatter(test.blue.in,test.blue.out*bp,4,test.blue.color,'filled'); end
		set(gca, 'XScale','log','YScale','log','Color','k');  %
    
   
function button_test_green_Callback(hObject, eventdata, handles)  
  doTest('green', handles); 
function button_test_blue_Callback(hObject, eventdata, handles)   
  doTest('blue', handles); 
function button_test_UV_Callback(hObject, eventdata, handles)     
  doTest('UV', handles); 

function doTest(color, handles)
   global test
   test.(color).in  = [logspace(log(4)/log(10),log(40000)/log(10),10)]; 
   %test.(color).in = linspace(5,40,10); 
   [test.(color).out, test.(color).color] = avg_walk_I(color,test.(color).in,10); 
   plot_all_test(handles);
   
            
function do_calib(condition, range, sweeps)
    global calib;
    channel = erg_io_switchCondition(condition);
    calib.(condition).in = range; 
%   calib.(condition).out = avg_walk_v(channel,range,sweeps,400,4000)/4;
    if (~isempty(findstr(condition,'Low'))) 
			% if Low
      calib.(condition).out = avg_walk_v(channel,range,sweeps,10,10)/20;
		else
			% if High
      calib.(condition).out = avg_walk_v(channel,range,sweeps,1,1)/2;
    end
    
function [data,dc] = avg_walk_I(color, range, sweeps)
    global calib;
   
    ds = randomize(repmat(range,[1,sweeps])); %This way data is already the correct size
    dc = zeros(1,length(ds)); 
    data = zeros(1,length(ds)); 

    if (strcmp(color,'green')) colVal = [0 1 0]; elseif (strcmp(color,'blue')) colVal = [0 0 1]; elseif (strcmp(color,'UV')) colVal = [1 0 1]; end

    cL = calib.([color 'Low']);
    cH = calib.([color 'High']);

%    dummy = robustfit(cH.in,cH.out);
%    cH.out =  cH.in*dummy(2)+dummy(1);
%    dummy = robustfit(cL.in,cL.out);
%    cL.out =  cL.in*dummy(2)+dummy(1);

    erg_io_sendpulse_calib(1,5,5,5); %strangely this is needed cause the 1st sample is screwed up
    for (i=1:length(ds))
        ai = interp1(cL.out    ,cL.in,ds(i));
        bi = interp1(cL.out*5  ,cL.in,ds(i));
        ci = interp1(cL.out*10 ,cL.in,ds(i));
        di = interp1(cH.out    ,cH.in,ds(i));
        ei = interp1(cH.out*5  ,cH.in,ds(i));
        fi = interp1(cH.out*10 ,cH.in,ds(i));
        
        %This is just a trick to try to use the 'low intensity' some more
        xgrens = 3.5;
        if (interp1(cH.out,cH.in,cL.out(1).*10) > xgrens) xgrens = interp1(cH.out,cH.in,cL.out(1).*10); end
            
        if     (~isnan(fi))                 voltage = fi; time =   5; condition = [color 'High'];
        elseif (~isnan(ei))                 voltage = ei; time = 2.5; condition = [color 'High'];
        elseif (~isnan(di) && di < xgrens ) voltage = di; time = 0.5; condition = [color 'High'];
        elseif (~isnan(ci))                 voltage = ci; time =   5; condition = [color 'Low'];
        elseif (~isnan(bi))                 voltage = bi; time = 2.5; condition = [color 'Low'];
        elseif (~isnan(ai))                 voltage = ai; time = 0.5; condition = [color 'Low'];
        else   voltage = -99;   end
        
        if (voltage >= -4 && voltage <= 4)    
          channel = erg_io_switchCondition(condition);
          data(1,i)= erg_io_sendpulse_calib(channel, time, time, voltage) - erg_io_sendpulse_calib(channel, time, time, 5);
          dc(1,i) = time/10+0.5;
        else
          data(1,i) = 0;
          dc(1,i) = 1;
        end
        i %debug output
    end

    A = sortrows([ds; data; dc]')'; 
    X = A(2,:);
    z = A(3,:);
    ds = []; data = []; dc = [];

    for (i = 1:sweeps:length(X)-sweeps+1) 
        data(ceil(i/sweeps)) = mean(X(i:i+sweeps-1)); 
        dc(ceil(i/sweeps),1:3) = colVal.*mean(z(i:i+sweeps-1)); 
    end
%end

function data = avg_walk_v(channel, ds_values, sweeps, time_s, time_r)
    ds = randomize(repmat(ds_values,[1,sweeps]));
    data = zeros(1,length(ds));                   

    erg_io_sendpulse_calib(channel,5,5,5); %strangely this is needed cause the 1st sample is screwed up
    for (i=1:length(ds))
        data(1,i)= max([erg_io_sendpulse_calib(channel, time_s, time_s, ds(i)) ...
					- erg_io_sendpulse_calib(channel, time_s, time_s, 5), 0]);
        i %Debug Output
		end

		%Now let's sort the data again and average over sweeps
    A = sortrows([ds; data]')'; X = A(2,:); data = [];
    for (i = 1:sweeps:length(X)-sweeps+1) 
			data(ceil(i/sweeps)) = mean(X(i:i+sweeps-1)); 
		end
		
		data


function resultCode = init(handles)
    global test calib ergConfig;
    test.dummy = 0;
    calib.dummy = 0;
    resultCode = 0;

    if (erg_io_openclose('openall') < 0) 
      disp('erg_io_openclose, as called from calibration.m::init() returned with an error code, so we quit.')
      close(handles);
      resultCode = -1;
      return;
    end
        
    load([ergConfig.basedir filesep 'latestcalib.mat'],'calib')
    %THIS IS TEMPORARY!!
    calib.UVLow = calib.greenLow;
    calib.UVHigh = calib.greenHigh;
    
    calib.started = now();
    calib.fromfile = [1,1,1];
    
function exit()
    erg_io_openclose('closeall');

function dsout = randomize(dsin)
  dsout = dsin;
  for i = (1:length(dsout))
    a = round(rand*(length(dsout)-1))+1;
    b = round(rand*(length(dsout)-1))+1;
    dummy = dsout(a);
    dsout(a) = dsout(b);
    dsout(b) = dummy;
  end

function figure1_DeleteFcn(hObject, eventdata, handles)
  exit();
function figure1_CreateFcn(hObject, eventdata, handles)

function check_float_test_Callback(hObject, eventdata, handles)
  plot_all_test(handles);    


function axes_test_CreateFcn(hObject, eventdata, handles)

function button_accept_Callback(hObject, eventdata, handles)
  global calib test;
  
  s='';
  if (calib.fromfile(1)) s = [s '(Green from file) ']; end
  if (calib.fromfile(2)) s = [s '(Blue from file) ']; end
  if (calib.fromfile(3)) s = [s '(UV from file) ']; end
  calib.testdata = test;    
  ergLogger('add',{'calib',calib.started, now(), 'Calibration', s, '', [], calib});
  calib.testdata = [];
  calib.started = now(); %'restart' :)
  
  
