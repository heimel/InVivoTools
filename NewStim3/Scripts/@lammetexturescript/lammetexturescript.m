function script = lammetexturescript(params,OLDSCRIPT)

% NewStim package: LAMMEMOTIONSCRIPT
%
%  SCRIPT = LAMMETEXTURESCRIPT(PARAMETERS)
%
%  Creates a LAMMETEXTURESCRIPT object, which is a descendant of the STIMSCRIPT
%  object.  It allows one to easily create a script of LAMMESTIM stimuli.
%
%  One may also use the construction SCRIPT=LAMMETEXTURESCRIPT('graphical'), which
%  will prompt the user for all fields.  One may use the construction
%  SCRIPT=LAMMETEXTURESCRIPT('graphical',OLDSCRIPT), which will prompt the
%  user for all fields but provide the parameters of OLDSCRIPT as
%  defaults.  Finally, one may use SCRIPT=LAMMETEXTURESCRIPT('default') to assign
%  default parameter values.
%
% See also: STIMSCRIPT HUPESTIM
%
% 2012, Alexander Heimel
%


scripttype = 'lammetexturescript';
NewStimScriptListAdd(scripttype);

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
        oldstim = lammestim('default');
		params = getparameters(oldstim);
        params.displayprefs = {'BGpretime',2};
        oldstim = lammestim(params);
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

params.figure_onset = 0;
params.figspeed = 0;
params.gndspeed = 0;
%params.gndtextureparams = params.figtextureparams;

s = stimscript(0);
data = struct('params',params);
script = class(data,scripttype,s);
theParams = params;

for sample = 1:params.randsamples
  for typenumber = 1:2 % 12-11-2010, no longer running 7 and 8
	  theParams.typenumber = typenumber;
	  theParams.randState = sample;
      switch typenumber 
          case 1
              theParams.gnddirection = theParams.figdirection + 90;
          case 2
              theParams.gnddirection = theParams.figdirection;
      end
      stim = lammestim(theParams);
	  script = append(script,stim);
  end % typenumber
end % sample