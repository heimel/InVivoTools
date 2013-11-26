function b = VerifyNewStimConfiguration

b = 1;

NewStimGlobals;
StimWindowGlobals;

if isempty(StimComputer), b = 0; end;  % we'll keep it simple
