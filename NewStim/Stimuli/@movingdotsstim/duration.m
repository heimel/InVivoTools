function t = duration(mds)

MDp = getparameters(mds);

if ~haspsychtbox,
	t = MDp.duration;
else,
	StimWindowGlobals;
	fps_act = StimWindowRefresh/max([1 round(StimWindowRefresh/MDp.fps)]);
	nFrames = round(fps_act*MDp.duration);
    t = nFrames/fps_act;
end;

t = t + duration(mds.stimulus);
