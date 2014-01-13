function t = duration(stim)

params = getparameters(stim);

dp = getdisplayprefs(stim);
if isempty(dp),
    error('Empty displayprefs in stimulus.  Should not happen.');
end;
dp = struct(dp);
StimWindowGlobals;
if ~haspsychtbox | isempty(StimWindowRefresh) | ~isloaded(stim), %#ok<OR2> % provide best estimate
    t = params.duration + duration(stim.stimulus); 
else % provide more exact estimate based on refresh rate & display prefs
    pauseRefresh = zeros(1,length(dp.frames));
    if dp.roundFrames,
        pauseRefresh(:) = round(StimWindowRefresh / dp.fps);
    else
        pauseRefresh = diff(fix((1:(length(dp.frames)+1)) * StimWindowRefresh / dp.fps));
    end;
    t = sum(pauseRefresh)/StimWindowRefresh + duration(stim.stimulus);
end;
