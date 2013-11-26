function t = duration(BLstim)

dp = getdisplayprefs(BLstim);
if isempty(dp), error('Empty displayPrefs in blinkingstim.'); end;
dp = struct(dp);
	
if ~strcmp(computer,'MAC2'), t = duration(BLstim.stimulus); end;
width  = BLstim.rect(3) - BLstim.rect(1);
height = BLstim.rect(4) - BLstim.rect(2);

% set up grid
if (BLstim.pixSize(1)>=1),
    X = BLstim.pixSize(1);
else, X = (width*BLstim.pixSize(1));
end;

if (BLstim.pixSize(2)>=1),
    Y = BLstim.pixSize(2);
else, Y = (height*BLstim.pixSize(2));
end;

StimWindowGlobals;

N = BLstim.repeat * (height/Y * width/X);
realframetime = fix(StimWindowRefresh/dp.fps)/StimWindowRefresh;

t = N*realframetime + duration(BLstim.stimulus);
