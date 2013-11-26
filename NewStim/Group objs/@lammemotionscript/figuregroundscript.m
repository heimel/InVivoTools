function script = figuregroundscript(params,OLDSCRIPT)
scripttype = 'figuregroundscript';
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
		stim = figuregroundstim('graphical', oldstim);
		p = getparameters(stim);
		if isempty(p)
			script = [];
			return
		else
			params = p;
		end;
	elseif strcmp(params,'default'),
		stim = figuregroundstim('default');
		params = getparameters(stim);
	else
		error(['Unknown string input to ' scripttype]);
	end;
else
	[good,err] = verifyscript(params);
	if ~good, error(['Could not create ' scripttype ': ' err]); end;
end;

% motion script:
params.figure_onset = 2;
params.movement_onset = 1;
params.figspeed = 100;
params.figorientation = 45;
params.figdirection = 180;
params.figtextureparams =[20 5 0.5 45];
params.gndtextureparams =[20 5 0.5 135];
%params.gndtextureparams = params.figtextureparams;

s = stimscript(0);
data = struct('params',params);
script = class(data,scripttype,s);
theParams = params;

for sample = 1%:params.randsamples
  for typenumber = 1:7
	  theParams.typenumber = typenumber;
	  theParams.randState = sample;
	  stim = figuregroundstim(theParams);
	  script = append(script,stim);
  end % typenumber
end % sample
