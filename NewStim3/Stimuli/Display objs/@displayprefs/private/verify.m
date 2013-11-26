function [good, errormsg] = verify(parameters)
  % verifies a string of parameters to displayprefs
  
  %create a dummy set for comparison
params = struct( ...
                 ...
				 'fps',                  0,                          ...
				 'rect',                 [0 0 0 0],                  ...
				 'roundFrames',          1,                          ...
				 'forceMovie',           0,                          ...
				 'depth',                8,                          ...
				 'absStartTime',         -1,                         ...
				 'BGpretime',            0,                          ...
				 'BGposttime',           0,                          ...
				 'lastframetime',        0,                          ...
				 'defaults',             parameters                  ...
				 );
			%	 'frames',            0                           ... 

  
sz = length(parameters);

good = 1; errormsg = '';

if (mod(sz,2)==0),  % if a multiple of two or empty
	for i=1:2:sz,
		if (isfield(params,parameters{i})),  % if it is a field, add it if it makes sense
			if strcmp('rect', parameters{i}),
				if ~((isnumeric(parameters{i+1})) & prod(double(size(parameters{i+1}) == [ 1 4]))),
					good = 0; errormsg = ['''rect'' must be [x1 y1 x2 y2].']; 
				end;
			else,
				if ~((isnumeric(parameters{i+1})) & prod(double(size(parameters{i+1}) == [1]))),
					good = 0; errormsg = ['' parameters{i} ''' must be 1x1.'];
				end;
			end;
		else,
			if ~strcmp('frames',parameters{i}),
				good = 0; errormsg = ['''' parameters{i} ''' is not a field in displayprefs.'];
			end;
		end;
	end;
else, good = 0; errormsg = ['parameters to displayprefs not of length modulo 2'];
end;
