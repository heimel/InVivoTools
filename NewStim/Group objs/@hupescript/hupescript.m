function script = hupescript(params,OLDSCRIPT)

% NewStim package: HUPESCRIPT
%
%  SCRIPT = HUPESCRIPT(PARAMETERS)
%
%  Creates a HUPESCRIPT object, which is a descendant of the STIMSCRIPT
%  object.  It allows one to easily create a script of HUPESTIM stimuli.
%
%  One may also use the construction SCRIPT=HUPESCRIPT('graphical'), which
%  will prompt the user for all fields.  One may use the construction
%  SCRIPT=HUPESCRIPT('graphical',OLDHUPESCRIPT), which will prompt the
%  user for all fields but provide the parameters of OLDHUPESCRIPT as
%  defaults.  Finally, one may use SCRIPT=HUPESCRIPT('default') to assign
%  default parameter values.
%
%
%
% See also: STIMSCRIPT HUPESTIM


if nargin<2,
	oldscript = [];
else
	if ~isa(OLDSCRIPT,'hupescript'),
		error('OLDSCRIPT must be a hupescript.');
	end;
	oldscript = OLDSCRIPT;
end;

oldstim = oldscript; % not right

if nargin<1
	params='default';
end

if ischar(params),
	if strcmp(params,'graphical'),
		stim = hupestim('graphical', oldstim);
		p = getparameters(stim);
		if isempty(p)
			script = [];
			return
		else
			params = p;
		end;
	elseif strcmp(params,'default'),
		stim = hupestim('default');
		params = getparameters(stim);
	else
		error('Unknown string input to hupescript');
	end;
else
	[good,err] = verifyscript(params);
	if ~good, error(['Could not create hupescript: ' err]); end;
end;


s = stimscript(0);
data = struct('params',params);

script = class(data,'hupescript',s);
% only figure moving
theParams = params;
theParams.gndspeed = 0;
theParams.typenumber = 1;
stim = hupestim(theParams);
script = append(script,stim);
% only background moving
theParams = params;
theParams.figspeed = 0;
theParams.typenumber = 2;
stim = hupestim(theParams);
script = append(script,stim);
% figure and background moving
theParams = params;
theParams.typenumber = 3;
stim = hupestim(theParams);
script = append(script,stim);

