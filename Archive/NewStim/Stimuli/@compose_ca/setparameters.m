function ncca = setparameters(cca,p)

%  SETPARAMETERS - Set the parameters for compose_ca
%
%  NEWCCA = SETPARAMETERS(CCA,P)
%
%  Sets the parameters of CCA to P.  The loaded status is preserved.
%  See COMPOSE_CA for a description of these parameters.
%
%  See also:  COMPOSE_CA, GETPARAMETERS, STIMULUS/SETPARAMETERS

default_p = struct('rect',[0 0 400 400],'dispprefs',{{}});

if isempty(p),
	par = default_p;
else,  % no need for separate verify function because parameters are so simple
	b = 0;
	if isfield(p,'rect'),
		if eqlen(size(p.rect),[1 2]),
			if diff(p.rect([1 3]))>0,
				if diff(p.rect([2 4]))>0,
					b = 1;
				else, ermsg='rect has no height';
				end;
			else, ermsg='rect has no width';
			end;
		else,
			errmsg = 'rect not of correct size';
		end;
	else, ermsg = 'must have ''rect'' field';
	end;
	if b,
		b=isfield(p,'dispprefs');
		if ~b, ermsg = 'no dispprefs field'; end;
	end;
	if b, error(['Error in shapemovestim parameters: ' ermsg]); end;
	par = p;
end;

 % now check to see if parameters that would necessitate a reload changed

sr = 0;
s = [];
oldp = getparameters(cca);
if ~isempty(oldp),
	oldp2 = oldp;
	oldp2.rect = par.rect;
    if oldp2==par,  % then the stimuli are identical up to location
	   	cca.CCp.rect = par.rect;
	   	dp = getdisplayprefs(cca);
	       	dp = setvalues(dp,{'rect',par.rect});
	   	cca = setdisplayprefs(cca,dp);
	   	ncca = cca;
    else, sr = 1;
	end;
else, sr = 1;
end;

if sr,  % if we must reload then set and reload
	l = isloaded(cca);
	if l, cca = unloadstim(cca); end;
	cca.CCp = par;
	dp = getdisplayprefs(cca);
	if isempty(dp),
		    dp=displayprefs({'fps',-1,'rect',par.rect,'frames',1, ...
			par.dispprefs{:}});
	else, dp=setvalues(dp,{'rect',par.rect,par.dispprefs{:}});
	end;
	cca = setdisplayprefs(cca,dp);
	if l, cca = loadstim(cca); end;
	ncca = cca;
end;
