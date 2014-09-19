function script = borderscript(params,OLDSCRIPT)

% NewStim package: BORDERSCRIPT
%
%  SCRIPT = BORDERSCRIPT(PARAMETERS)
%
%  Creates a BORDERSCRIPT object, which is a descendant of the STIMSCRIPT
%  object.  It allows one to easily create a script of BORDERSTIM stimuli.
%
%  One may also use the construction SCRIPT=BORDERSCRIPT('graphical'), which
%  will prompt the user for all fields.  One may use the construction
%  SCRIPT=BORDERSCRIPT('graphical',OLDBORDERSCRIPT), which will prompt the
%  user for all fields but provide the parameters of OLDBORDERSCRIPT as
%  defaults.  Finally, one may use SCRIPT=BORDERSCRIPT('default') to assign
%  default parameter values.
%
%
%
% See also: STIMSCRIPT BORDERSTIM


if nargin<2,
	oldscript = [];
else
	if ~isa(OLDSCRIPT,'borderscript'),
		error('OLDSCRIPT must be a borderscript.');
	end;
	oldscript = OLDSCRIPT;
end;

oldstim = oldscript; % not right

if nargin<1
	params='default';
end

if ischar(params),
	if strcmp(params,'graphical'),
		stim = borderstim('graphical', oldstim);
		p = getparameters(stim);
		if isempty(p)
			script = [];
			return
		else
			params = p;
		end;
	elseif strcmp(params,'default'),
		stim = borderstim('default');
		params = getparameters(stim);
	else
		error('Unknown string input to borderscript');
	end;
else
	[good,err] = verifyscript(params);
	if ~good, error(['Could not create borderscript: ' err]); end;
end;


s = stimscript(0);
data = struct('params',params);

script = class(data,'borderscript',s);
% see Zhou et al. J Neurosci 2000, Fig 1 for stimulus sequence

% stim A
theParams = params;
theParams.typenumber = 1;
stimA = borderstim(theParams);
script = append(script,stimA);

% stim D
theParams = params;
theParams.direction = params.direction + 180; 
theParams.typenumber = 4;
stimD = borderstim(theParams);
script = append(script,stimD);

% stim B
theParams = params;
theParams.typenumber = 2;
theParams.direction = params.direction + 180;
theParams.figcolor = params.gndcolor;
theParams.gndcolor = params.figcolor;
stimB = borderstim(theParams);
script = append(script,stimB);


% stim C
theParams = params;
theParams.typenumber = 3;
theParams.figcolor = params.gndcolor;
theParams.gndcolor = params.figcolor;
stimC = borderstim(theParams);
script = append(script,stimC);

% stim C
theParams = params;
theParams.typenumber = 3;
theParams.figcolor = params.gndcolor;
theParams.gndcolor = params.figcolor;
stimC = borderstim(theParams);
script = append(script,stimC);

% stim B
theParams = params;
theParams.typenumber = 2;
theParams.direction = params.direction + 180;
theParams.figcolor = params.gndcolor;
theParams.gndcolor = params.figcolor;
stimB = borderstim(theParams);
script = append(script,stimB);

% stim D
theParams = params;
theParams.typenumber = 4;
theParams.direction = params.direction + 180; 
stimD = borderstim(theParams);
script = append(script,stimD);

% stim A
theParams = params;
theParams.typenumber = 1;
stimA = borderstim(theParams);
script = append(script,stimA);






