function [MTI,MTI2]=NSCaptureMovie(stimclass)

NewStimGlobals;
StimWindowGlobals;

if NS_PTBv==3,
    currLut = Screen('ReadNormalizedGammaTable', StimWindowMonitor);
    mypriority = MaxPriority(StimWindowMonitor,'WaitBlanking','SetClut','GetSecs'); % PD
end;


if isa(stimclass,'stimscript'),
    myscript = stimclass;
else,
    mystim = NSGetTestStim(stimclass);
    if iscell(mystim)|isa(mystim,'stimulus'),
        myscript = stimscript(0);
        if iscell(mystim),
            for i=1:length(mystim), myscript = append(myscript,mystim{i}); end;
        else, myscript = append(myscript,mystim);
        end;
    else,
        myscript = mystim;
    end;
end;

ShowStimScreen;
myscript = loadStimScript(myscript);
MTI = DisplayTiming(myscript);
[MTI2,start] = DisplayStimScript(myscript,MTI,mypriority,1,true);
myscript = unloadStimScript(myscript);
CloseStimScreen;

if NS_PTBv==3, Screen('LoadNormalizedGammaTable', StimWindowMonitor, currLut); end;

