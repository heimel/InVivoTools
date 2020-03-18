function S = onedottwodotsscript(PSparams,OLDSCRIPT)

% NewStim package: onedottwodotscript
%
%  SCRIPT = onedottwodotsscript(PARAMETERS)
%
%  Creates a one dot-two dot object, which is a descendant of the STIMSCRIPT
%  object.  It allows one to easily create a script of one/two dot stimuli
%  which vary along commonly varied dimensions.  The PARAMETERS structure has
%  the same format as onedottwodot except that certain elements can accept
%  vector arguments, which creates an array of stimuli each of which has
%  one of the values of the vector argument.  For example, if one
%  field is set to [0.1 0.5 1] and all other fields are single-valued, then
%  three stimuli will be created, each with one of the contrasts specified.
%
%  PARAMETERS should be a struct with fields described below.  Those fields
%  which are marked with a * are the fields which can accept vector arguments.
%
%

% filename: the image to present
% appear:
% stay:
% stoppoint = how much distance image will cross (Inf for all the way_
% start_position : location to start from (top/left/far)
% velocity_degp:  vx,vy in deg/s, right and up and away are positive
% duration; % duration of movement in s
% extent_deg: size of image in degrees, [horizontal / vertical]
% backdrop: background color
% dot_distances: which distances to add dots for (from center)
% dispprefs:

NewStimScriptListAdd('onedottwodotsscript');
if nargin==0
    S = onedottwodotsscript('default');
    return
end

default_p = default; % private function

finish = 1;

if nargin==1
    oldscript = [];
else
    if ~isa(OLDSCRIPT,'onedottwodotsscript')
        error('OLDSCRIPT must be a onedottwodotsscript.');
    end
    oldscript = OLDSCRIPT;
end

if ischar(PSparams)
    if strcmp(PSparams,'graphical')
        oldstim = onedottwodots('default');
		PSparams = getparameters(oldstim);
        oldstim = onedottwodots(PSparams);
		stim = onedottwodots('graphical', oldstim);
		p = getparameters(stim);
		if isempty(p)
			script = [];
			return
		else
			PSparams = p;
        end
	elseif strcmp(PSparams,'default')
		stim = onedottwodots('default');
		PSparams = getparameters(stim);
	else
		error(['Unknown string input to ' scripttype]);
    end
else
    [good,err] = verifydotscript(PSparams);
    if ~good, error(['Could not create onedottwodotscript: ' err]); end;
end

if finish
    
    s = stimscript(0);
    data = struct('PSparams',PSparams);
    
    S = class(data,'onedottwodotsscript',s);
    %   first make stim with 0-dot
    theParams = PSparams;
    theParams.dot_distance = [0 NaN];
    stim = onedottwodots(theParams); % should never fail
    S = append(S,stim);
    if ~isnan(PSparams.dot_distances)
        for d = 1:length(PSparams.dot_distances)
            %make a stim with only the far dot
            theParams.dot_distance = [NaN PSparams.dot_distances(d)];
            stim = onedottwodots(theParams); % should never fail
            S = append(S,stim);
            %make a stim with both the center and far dot
            theParams.dot_distance = [0 PSparams.dot_distances(d)];
            stim = onedottwodots(theParams); % should never fail
            S = append(S,stim);
            
        end
    end
    % generate all these stims
else
    S = [];
end


