function script = lammemotionscript(params,OLDSCRIPT)

% NewStim package: LAMMEMOTIONSCRIPT
%
%  SCRIPT = LAMMEMOTIONSCRIPT(PARAMETERS)
%
%  Creates a LAMMEMOTIONSCRIPT object, which is a descendant of the STIMSCRIPT
%  object.  It allows one to easily create a script of LAMMESTIM stimuli.
%
%  One may also use the construction SCRIPT=LAMMEMOTIONSCRIPT('graphical'), which
%  will prompt the user for all fields.  One may use the construction
%  SCRIPT=LAMMEMOTIONSCRIPT('graphical',OLDSCRIPT), which will prompt the
%  user for all fields but provide the parameters of OLDSCRIPT as
%  defaults.  Finally, one may use SCRIPT=LAMMEMOTIONSCRIPT('default') to assign
%  default parameter values.
%
% See also: STIMSCRIPT HUPESTIM
%
% 2010, Alexander Heimel
%


scripttype = 'lammemotionscript';
NewStimScriptListAdd(scripttype);

if nargin<2,
	oldscript = [];
else
	if ~isa(OLDSCRIPT,scripttype),
		error(['OLDSCRIPT must be a ' scripttype]);
	end;
	oldscript = OLDSCRIPT;
end;
% if ~isempty(oldscript)
%     oldstim = get(oldscript,1); % not correct, should get stim with typenumber 3
% else
% 	oldstim = [];
% end
if nargin<1
	params='default';
end

if ischar(params),
	if strcmp(params,'graphical'),
        if isempty(oldscript)
            oldstim = lammestim('default');
            p = getparameters(oldstim);
            p.typenumber = [0 1 2 3 9];
%            oldstim = lammestim(p);
        else
            p = getparameters(oldscript);
        end
        
%		stim = lammestim('graphical', oldstim);
		stim = lammestim('graphical', p);
        if isempty(stim)
            script = [];
        end
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

% motion script:
params.figure_onset = 0;
%params.gndtextureparams = params.figtextureparams;

s = stimscript(0);
data = struct('params',params);
script = class(data,scripttype,s);
theParams = params;

for sample = 1:params.randsamples
    for typenumber = params.typenumber % 12-11-2010, no longer running 7 and 8
        for figdirection = params.figdirection
            
            theParams.typenumber = typenumber;
            theParams.randState = sample;
            theParams.figdirection = figdirection;
            if typenumber == 0
                theParams.gndsize = params.gndsize(1);
                theParams.gndcontrast = params.gndcontrast(1);
                stim = lammestim(theParams);
                script = append(script,stim);
            else
                for gndsize = params.gndsize
                    for gndcontrast = params.gndcontrast
                        for gnddirection = params.gnddirection
                            theParams.gndsize = gndsize;
                            theParams.gnddirection = gnddirection;
                            theParams.gndcontrast = gndcontrast;
                            stim = lammestim(theParams);
                            script = append(script,stim);
                        end
                    end % gndcontrast
                end % gndsize
            end
        end % figdirection
    end % typenumber
end % sample