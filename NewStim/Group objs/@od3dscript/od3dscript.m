function script = od3dscript(params,OLDSCRIPT)

% NewStim package: OD3DSCRIPT
%
%
% 2010, Alexander Heimel
%

scripttype = 'od3dscript';

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
		stim = periodicstim3D('graphical');%, oldstim);
		p = getparameters(stim);
		if isempty(p)
			script = [];
			return
		else
			params = p;
		end;
	elseif strcmp(params,'default'),
		stim = periodicstim3D('default');
		params = getparameters(stim);
	else
		error(['Unknown string input to ' scripttype]);
	end;
else
	[good,err] = verifyscript(params);
	if ~good, error(['Could not create ' scripttype ': ' err]); end;
end;

% motion script:

s = stimscript(0);
data = struct('params',params);
script = class(data,scripttype,s);
for direction = (0:45:360-45);
        for eyes = 0:2
            params.eyes = eyes;
            params.angle = direction;
            stim = periodicstim3D(params);
            script = append(script,stim);
    end
end





