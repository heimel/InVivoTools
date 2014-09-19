function t = duration(css)

CSSparams = css.CSSparams;
dp = getdisplayprefs(css);
if isempty(dp),
        error('Empty displayprefs in centersurroundstim.  Should not happen.');
end;
dp = struct(dp);
StimWindowGlobals;
if ~haspsychtbox|isempty(StimWindowRefresh), % provide best estimate
	t = CSSparams.stimduration + duration(css.stimulus);
else, % provide more exact estimate based on refresh rate & display prefs
        t = length(dp.frames)/StimWindowRefresh + duration(css.stimulus);
end;
