function script = test3dscript(params,OLDSCRIPT)

% NewStim package: TEST3DSCRIPT
%
%
% 2010, Alexander Heimel
%

scripttype = 'test3dscript';

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
		stim = stochasticgridstim3D('graphical');%, oldstim);
		p = getparameters(stim);
		if isempty(p)
			script = [];
			return
		else
			params = p;
		end;
	elseif strcmp(params,'default'),
		stim = stochasticgridstim3D('default');
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
n_rows = 5;
n_cols = 5;
for r = 1:n_rows
    top = (r-1)*210;
    for c = 1:n_cols
        left = (c-1)*336;
        for eyes = 0:2
            params.posR = [left top left+336 top+210];
            params.posL = params.posR;
            params.eyes = eyes;
            stim = stochasticgridstim3D(params);
            script = append(script,stim);
        end
    end
end





