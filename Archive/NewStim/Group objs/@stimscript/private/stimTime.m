function sT = stimTime(Stim);

cpustr = computer;
if strcmp(cpustr,'MAC2'),

StimWindowGlobals;

df = struct(getdisplayprefs(Stim));

sT = fix(df.BGposttime * StimWindowRefresh)/StimWindowRefresh;
sT = fix(df.BGpretime * StimWindowRefresh)/StimWindowRefresh + sT;

if ~isempty(df.frames),
	pauseRefresh = zeros(1,length(df.frames));

	if df.roundFrames,
		pauseRefresh(:) = round(StimWindowRefresh / df.fps);
	else,
		pauseRefresh = diff(fix((1:(ds.frames+1)) * StimWindowRefresh / df.fps));
    end;

	sT = sum(pauseRefresh) / StimWindowRefresh + sT;

end;

else,

sT = 0;
end;
