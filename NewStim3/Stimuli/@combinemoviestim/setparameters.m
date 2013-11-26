function ncms = setparameters(cms,p)

%  SETPARAMETERS - Set the parameters for COMBINEMOVIESTIM
%
%  NEWCMS = SETPARAMETERS(CMS,P)
%
%  Sets the parameters of CMS to P.  The loaded status is preserved.
%  See COMBINEMOVIESTIM for a description of these parameters.
%
%  See also:  COMBINEMOVIESTIM, GETPARAMETERS, STIMULUS/SETPARAMETERS

default_p = struct('script',periodicscript('default'));
default_p.dispprefs = {};

if isstruct(p),
	myp = default_p;
	fn = fieldnames(p);
	for i=1:length(fn),
		myp = setfield(myp, fn{i}, getfield(p,fn{i}));
	end;
	p = myp;
end;


l = isloaded(cms);

if isempty(p),
	par = default_p;
else,  
	if ~isfield(p,'script'),
		error(['The required field ''script'' is missing from parameters to COMBINEMOVIESTIM.']);
		if ~isa(p.script,'stimscript'),
			error(['The required field ''script'' must be a member of the STIMSCRIPT class.']);
		end;
	end;
	par = p;
end;

ncms = cms;

ncms.CMp = par;

if l,  % if we must reload then reload
	ncms = loadstim(ncms);
end;
