function s = setparameters(S,p)

%  SETPARAMETERS - Set the parameters for movingdotsstim
%
%  NEWMDS = SETPARAMETERS(MDS,P)
%
%  Sets the parameters of MDS to P.  The loaded status is preserved.
%  See MOVINGDOTSSTIM for a description of these parameters.
%
%  See also:  MOVINGDOTSSTIM, GETPARAMETERS, STIMULUS/SETPARAMETERS

default_p = struct('rect',[0 0 200 200],'BG',[0 0 0],'FG',[255 255 255],...
		'motiontype','planar','velocity',10,'angvelocity',0,'direction',0,...
		'coherence',1,'dotsize',1.5,'numdots',20,'distance',57,'fps',120,...
		'duration',4,'numpatterns',5,'lifetimes',Inf,'randState',rand('state'),'dispprefs',{{}});

if isempty(p),
	par = default_p;
else, 
	par = default_p;
	pn = fieldnames(p);
	for i=1:length(pn),par=setfield(par,pn{i},getfield(p,pn{i})); end;
	[b,ermsg] = verifymovingdotsstimparams(par);
	if b, error(['Error in movingdotsstim parameters: ' ermsg]); end;
	par = p;
end;

sr = 0; % do we need to set parameters and possibly reload the stimulus?
s = S;
oldp = getparameters(S);
if ~isempty(oldp),
    if oldp~=par, sr = 1;
	end;
else, sr = 1;
end;

if sr,  % must set and reload
	l = isloaded(S);
	if l, S = unloadstim(S); end;
	S.MDSparams = par;
	dp = getdisplayprefs(S);
	nframes = par.fps * par.duration;
	if isempty(dp),
		    dp=displayprefs({'fps',par.fps,'rect',par.rect,...
			'frames',1:nframes,par.dispprefs{:}});
	else, dp=setvalues(dp,{'fps',par.fps,'rect',par.rect,...
			'frames',1:nframes,par.dispprefs{:}});
	end;
	S = setdisplayprefs(S,dp);
	if l, S = loadstim(S); end;
	s = S;
end;
