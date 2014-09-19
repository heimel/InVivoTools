function s = setparameters(S,p)

%  SETPARAMETERS - Set the parameters for stochasticgridstim
%
%  NEWSGS = SETPARAMETERS(SGS,P)
%
%  Sets the parameters of SGS to P.  The loaded status is preserved.
%  If possible, loaded data will be reused for speed.
%
%  See also:  GETPARAMETERS, STIMULUS/SETPARAMETERS

oldp = getparameters(S);
oldp2 = oldp;
oldp2.rect = p.rect;
s = [];
if oldp2==p,  % then the stimuli are identical up to location
	if size(p.rect)==[1 4], % quick check for accuracy
		S.SGSparams.rect = p.rect;
		dp = getdisplayprefs(S);
		dp = setvalues(dp,{'rect',p.rect});
        S = setdisplayprefs(S,dp);
		s = S;
	end;
else,  % must make new stim and reload
	l = isloaded(S);
    s = stochasticgridstim(p);
	if l, s = loadstim(s); end;
end;

