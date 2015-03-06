
% StimSerialGlobals - Declares global variables for StimSerial system
%
%  Serial ports are used by the NewStim package to send triggers when
%  a script is about to be displayed and to send triggers before each
%  stimulus is to be presented.  Two named serial devices are used
%  for this purpose, StimSerialScript and StimSerialStimTrigger.
%  These are serial port reference numbers used by the SERIAL command
%  of the Psychophysics toolbox.  These ports may be the same
%  if the user desires.  Triggers are sent by toggling the DTR line
%  of the serial port from 0 to 1; the DTR line is often 1 by default,
%  so devices must specifically look for a transition from 0 to 1, not just
%  the presence of a high signal.  All connections are run at 9600 baud.
%
%  The user may use the serial ports during times other than stimulus
%  presentation.
%
%  StimSerialScriptIn,StimSerialScriptOut,StimSerialStimIn, and
%  StimSerialStimOut need to be initialized in the user's local
%  NewStimCalibrate.m file.
%
%  StimSerialSerialPort - 0/1 Should we enable the StimSerial feature?
%  StimSerialScript - Reference number of serial port that is triggered
%                       at the beginning of stimscript presentation.
%  StimSerialStim   - Reference number of serial port that is triggered
%                       at the beginning of each stimulus presentation.
%  StimSerialScriptIn - Name of serial port to open for input for
%                         StimSerialScript (e.g., '.Bin'). Use serial('Ports')
%                         to get a list of serial ports.
%  StimSerialScriptOut - Name of serial port to open for output for
%                         StimSerialScript (e.g., '.Bout'). 
%  StimSerialStimIn - Name of serial port to open for input for StimSerialStim.
%                         May be the same as StimSerialScriptIn.
%  StimSerialStimOut - Name of serial port to open for input for StimSerialStim.
%                         May be the same as StimSerialScriptOutput.
%
%  Note:  To make a cable that routes the 0/1 signal on the DTR line to 
%  another device using the old Macintosh 8-pin serial cables, one needs
%  to connect to pin 1 in the diagram below; the diagram is of a female
%  connector with the user facing the connector.  A male connector is the
%  mirror image.
%
%        8 7 6   
%        5 4 3   
%         2 1 
%   
% Example use:
% >> StimSerialGlobals
% >> OpenStimSerial
% >> StimSerial(StimSerialScriptOutPin,StimSerialScript,0);
% or
% >> StimSerial('dtr',StimSerialScript,0);
%
% 200X-200X Steve Van Hooser
% 200X-2014 Alexander Heimel

global StimSerialSerialPort;
global StimSerialScriptIn StimSerialScriptOut;
global StimSerialScriptInPin StimSerialScriptOutPin;
global StimSerialStimIn StimSerialStimOut;
global StimSerialStimInPin StimSerialStimOutPin;
global StimSerialScript StimSerialStim;


global gNewStim % to replace other globals in the future
gNewStim.StimSerial.port = StimSerialSerialPort;
gNewStim.StimSerial.scriptin = StimSerialScriptIn;
gNewStim.StimSerial.scriptout = StimSerialScriptOut;
gNewStim.StimSerial.scriptinpin = StimSerialScriptInPin;
gNewStim.StimSerial.scriptoutpin = StimSerialScriptOutPin;
gNewStim.StimSerial.stimin = StimSerialStimIn;
gNewStim.StimSerial.stimout = StimSerialStimOut;
gNewStim.StimSerial.stiminpin = StimSerialStimInPin;
gNewStim.StimSerial.stimoutpin = StimSerialStimOutPin;
gNewStim.StimSerial.script = StimSerialScript;
gNewStim.StimSerial.stim = StimSerialStim;



