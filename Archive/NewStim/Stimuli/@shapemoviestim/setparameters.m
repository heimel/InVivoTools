function s = setparameters(S,p)

%  SETPARAMETERS - Set the parameters for shapemoviestim
%
%  NEWSMS = SETPARAMETERS(SMS,P)
%
%  Sets the parameters of SMS to P.  The loaded status is preserved.
%  See SHAPEMOVIESTIM for a description of these parameters.
%
%  See also:  SHAPEMOVIESTIM, GETPARAMETERS, STIMULUS/SETPARAMETERS

default_p = struct('rect',[0 0 200 200],'BG',[128 128 128],'scale',1,...
		'fps',10,'N',5,'isi',0.5,'dispprefs',{{}});

if isempty(p),
	par = default_p;
else, 
	[b,ermsg] = verifyshapemoviestim(p);
	if b, error(['Error in shapemovestim parameters: ' ermsg]); end;
	par = p;
end;

sr = 0;
s = [];
oldp = getparameters(S);
if ~isempty(oldp),
	oldp2 = oldp;
	oldp2.rect = par.rect;
    if oldp2==par,  % then the stimuli are identical up to location
	   	S.SMSparams.rect = par.rect;
	   	dp = getdisplayprefs(S);
       	dp = setvalues(dp,{'rect',par.rect});
	   	S = setdisplayprefs(S,dp);
	   	s = S;
    else, sr = 1;
	end;
else, sr = 1;
end;
if sr,  % must set and reload
	l = isloaded(S);
	if l, S = unloadstim(S); end;
	S.SMSparams = par;
	dp = getdisplayprefs(S);
	if isempty(dp),
		    dp=displayprefs({'fps',par.fps,'rect',par.rect,'frames',1:par.N, ...
			par.dispprefs{:}});
	else, dp=setvalues(dp,{'fps',par.fps,'rect',par.rect,'frames',1:par.N,...
			par.dispprefs{:}});
	end;
	S = setdisplayprefs(S,dp);
	if l, S = loadstim(S); end;
	s = S;
end;
