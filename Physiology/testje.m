daqreset;    
session = daq.createSession('ni');
optochan = addAnalogOutputChannel(session,'Photometry', 'ao1', 'Voltage'); % optopulse
addAnalogInputChannel(session,'Photometry', 'ai0', 'Voltage'); % optopulse
%ch = addDigitalChannel(s,'Photometry','Port0/Line2:3','OutputOnly');
session.Rate = 1000;
%session.NumberOfScans = length(optopulse); 
optopulse = [zeros(100,1); 3*ones(100,1); zeros(100,1); 3*ones(100,1);zeros(10,1)];
queueOutputData(session,optopulse);
optochan.Range = [-10 10];
session
prepare(session);
startForeground(session);
wait(session);
disp('done');