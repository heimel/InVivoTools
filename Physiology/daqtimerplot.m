function daqtimerplot(obj, event)
%DAQTIMERPLOT Plots the data acquired.
%
%    DAQTIMERPLOT(OBJ, EVENT) plots the data acquired by the data
%    acquisition engine.  This is an example callback function for the
%    TimerFcn property and is used by the demodaq_callback example.  
%
%    DAQTIMERPLOT can be used with any analog input object.
%
%    Example:
%      ai = analoginput('winsound');
%      addchannel(ai, 1);
%      set(ai, 'SamplesPerTrigger', 40000);
%      set(ai, 'TimerFcn', @daqtimerplot);
%      start(ai);
%
%    See also DEMODAQ_CALLBACK. 
%

%    Copyright 1998-2010 The MathWorks, Inc.

if nargin == 0 
   error(['This function may not be called with 0 inputs.\n',...
         'Type ''daqhelp daqtimerplot'' for an example using DAQTIMERPLOT.']);
elseif nargin == 1
   error('Type ''daqhelp daqtimerplot'' for an example using DAQTIMERPLOT.');
end

% Determine the number of samples to plot.  Make sure that we never try to
% get more samples than are available in the engine.
size = min(floor((obj.SampleRate)*(obj.TimerPeriod)),obj.SamplesAvailable);

% Preview the data in the data acquisition toolbox buffer, and plot it.
data = peekdata(obj, size);
plot(data);
drawnow;