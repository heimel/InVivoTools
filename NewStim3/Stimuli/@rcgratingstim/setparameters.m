function nrcgs = setparameters(rcgs,p)

%  SETPARAMETERS - Set the parameters for RCGRATINGSTIM
%
%  NEWRCGS = SETPARAMETERS(RCGS,P)
%
%  Sets the parameters of RCGS to P.  The loaded status is preserved.
%  See RCGRATINGSTIM for a description of these parameters.
%
%  See also:  RCGRATINGSTIM, GETPARAMETERS, STIMULUS/SETPARAMETERS

default_p.baseps = periodicstim('default');
default_p.reps = 1;
default_p.order = 1;
default_p.pausebetweenreps = 1;
default_p.dur = 0.1;
default_p.orientations = [0:22.5:180-22.5];
default_p.spatialfrequencies = [ 0.025 0.05 0.1 0.2 0.4 0.8];
default_p.spatialphases = [ 0:pi/4:2*pi-pi/4 ];
default_p.randState = rand('state');
default_p.dispprefs = {};

if isstruct(p),
	myp = default_p;
	try, pp = getparameters(rcgs); if ~isempty(pp), myp = pp; end; end;
	fn = fieldnames(p);
	for i=1:length(fn),
		myp = setfield(myp, fn{i}, getfield(p,fn{i}));
	end;
	p = myp;
end;

l = isloaded(rcgs);

if isempty(p),
	par = default_p;
elseif ischar(p),
	par = default_p;
else,  
	par = p;
end;

nrcgs = rcgs;

nrcgs.RCGp = par;

if l,  % if we must reload then reload
	nrcgs = loadstim(nrcgs);
end;
