function t = duration(sgs)

sgsparams = sgs.SGSparams;
dp = getdisplayprefs(sgs);
if isempty(dp),
        error('Empty displayprefs in stochasticgridstim.  Should not happen.');
end;
dp = struct(dp);
StimWindowGlobals;
if ~haspsychtbox|isempty(StimWindowRefresh), % provide best estimate
	t = sgsparams.N / dp.fps + duration(sgs.stimulus);
else, % provide more exact estimate based on refresh rate & display prefs
	pauseRefresh = zeros(1,length(dp.frames));
	if dp.roundFrames,
            pauseRefresh(:) = round(StimWindowRefresh / dp.fps);
        else,
            pauseRefresh = diff(fix((1:(length(dp.frames)+1)) * StimWindowRefresh / dp.fps));
        end;
        t = sum(pauseRefresh)/StimWindowRefresh + duration(sgs.stimulus);
end;
