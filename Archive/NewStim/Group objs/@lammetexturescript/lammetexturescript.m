function script = lammetexturescript(params,OLDSCRIPT)

% NewStim package: LAMMEtextureSCRIPT
%
%  SCRIPT = LAMMEtextureSCRIPT(PARAMETERS)
%
%  Creates a LAMMEtextureSCRIPT object, which is a descendant of the STIMSCRIPT
%  object.  It allows one to easily create a script of LAMMESTIM stimuli.
%
%  One may also use the construction SCRIPT=LAMMEtextureSCRIPT('graphical'), which
%  will prompt the user for all fields.  One may use the construction
%  SCRIPT=LAMMEtextureSCRIPT('graphical',OLDSCRIPT), which will prompt the
%  user for all fields but provide the parameters of OLDSCRIPT as
%  defaults.  Finally, one may use SCRIPT=LAMMEtextureSCRIPT('default') to assign
%  default parameter values.
%
% See also: STIMSCRIPT HUPESTIM
%
% 2010, Alexander Heimel
%

scripttype = 'lammetexturescript';

if nargin<2,
	oldscript = [];
else
	if ~isa(OLDSCRIPT,scripttype),
		error(['OLDSCRIPT must be a ' scripttype]);
	end;
	oldscript = OLDSCRIPT;
end;
if ~isempty(oldscript)
    oldstim = get(oldscript,1); % not correct, should get stim with typenumber 3
else
	oldstim = [];
end
if nargin<1
	params='default';
end

if ischar(params),
	if strcmp(params,'graphical'),
		stim = lammestim('graphical', oldstim);
		p = getparameters(stim);
		if isempty(p)
			script = [];
			return
		else
			params = p;
		end;
	elseif strcmp(params,'default'),
		stim = lammestim('default');
		params = getparameters(stim);
	else
		error(['Unknown string input to ' scripttype]);
	end;
else
	[good,err] = verifyscript(params);
	if ~good, error(['Could not create ' scripttype ': ' err]); end;
end;

% texture script:
params.movement_onset = params.duration + 1; % i.e. never
params.figure_onset = 1;

s = stimscript(0);
data = struct('params',params);
script = class(data,scripttype,s);
% background has different texture 
theParams = params;
params.gndtextureparams = params.figtextureparams;
theParams.gndspeed = 0;
theParams.typenumber = 1;
stim = lammestim(theParams);
script = append(script,stim);
% background has same texture
theParams = params;
params.gndtextureparams = params.figtextureparams;
theParams.figspeed = 0;
theParams.typenumber = 2;
stim = lammestim(theParams);
script = append(script,stim);
