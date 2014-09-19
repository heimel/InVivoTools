function [good, errormsg] = verify(parameters),

params = struct( ...
                 ...
				 'displayProc',         '',                  ...
				 'displayType',         '',                  ...
				 'frames',               0,                  ...
				 'offscreen',           [],                          ...
				 'clut',                [],                         ...
				 'clut_usage',          [],                          ...
				 'clut_bg',             [],                          ...
				 'depth',                0,                          ...
				 'makeClip',             0,                          ...
				 'clipRect',         [0 0 0 0],                      ...
				 'userfield', []);
				 

sz = length(parameters);

good = 1; errormsg = '';

if (mod(sz,2)==0),  % if a multiple of two or empty
	for i=1:2:sz,
		if (isfield(params,parameters{i})),  % if it is a field, add it if it makes sense
			if ischar(getfield(params,parameters{i})),
				if ~ischar(parameters{i+1}),
					good = 0;
					errormsg = ['''' parameters{i} ''' should be a string.'];
				end;			
			else,
				if strcmp(parameters{i}, 'clut'),
					if ~(isnumeric(parameters{i+1})|iscell(parameters{i+1})),
						good = 0;
						errormsg = ['''clut'' should be cell or number.'];
					end;
				elseif strcmp(parameters{i},'userfield'),
					if ~(isnumeric(parameters{i+1})|isstruct(parameters{i+1})|iscell(parameters{i+1})),
						good = 0;
						errormsg = ['''userfield'' should be cell, struct, or number.'];
					end;
				elseif ~isnumeric(parameters{i+1}),
					good = 0;
					errormsg = ['''' parameters{i} ''' should be a number.'];
				end;
			end;
		else,
			good = 0; errormsg = ['' parameters{i} ''' is not a field in displaystruct.'];

		end;
	end;
else, good = 0; errormsg = ['parameters to displaystruct not of length modulo 2'];
end;

 % now look at 
