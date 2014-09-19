function t = duration(sms)

smsparams = sms.SMSparams;
dp = getdisplayprefs(sms);
if isempty(dp),
        error('Empty displayprefs in shapemoviestim.  Should not happen.');
end;
dp = struct(dp);
StimWindowGlobals;
if ~haspsychtbox|isempty(StimWindowRefresh), % provide best estimate
     t=(smsparams.N*length(getshapemovies(sms)))/dp.fps+duration(sms.stimulus);
else, % provide more exact estimate based on refresh rate & display prefs
	pauseRefresh = zeros(1,length(dp.frames));
	if dp.roundFrames,
            pauseRefresh(:) = round(StimWindowRefresh / dp.fps);
        else,
            pauseRefresh = diff(fix((1:(length(dp.frames)+1)) *...
					StimWindowRefresh / dp.fps));
        end;
        t = sum(pauseRefresh)/StimWindowRefresh + duration(sms.stimulus);
end;
