function t = duration(qts)

% DURATION - duration of quicktimemovie stim
%
%  T = DURATION(MYQUICKTIMEMOVIESTIM)
%
%  Returns play duration of MYQUICKTIMEMOVIESTIM
%
%  If the filename cannot be opened then the duration is 0.
%
%  See also:  QUICKTIMESTIM
 

p = getparameters(qts);

if isloaded,
	t = qts.QTSduration;
else,
	try,
		qts = loadstim(qts);
		t = qts.QTSduration;
		qts = unloadstim(qts);
    catch,
        t = 0;
	end;
end;

t = t + duration(qts.stimulus);
