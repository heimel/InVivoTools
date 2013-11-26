function [good, errormsg] = verifyperiodicstim(parameters)

  % note: parameters must be a struct, NOT an object

proceed = 1;
errormsg = '';

if proceed,
	% check that all arguments are present and appropriately sized
	fieldNames = {'imageType','animType','flickerType', ...
				'angle','chromhigh','chromlow','sFrequency', ...
				'sPhaseShift','distance','tFrequency', ...
				'barWidth','rect','nCycles', ...
				'contrast','background','backdrop',...
				'barColor', 'nSmoothPixels', 'fixedDur', ...
				'windowShape','loops'};
        fieldSizes = {[1 1], [1 1], [1 1], ...
				[1 1], [1 3], [1 3], [1 1], ...
				[1 1], [1 1], [1 1], ...
				[1 1], [1 4], [1 1], ...
				[1 1], [1 1], [1 -1], ...
				[1 1], [1 1], [1 1], ...
				[1 1], [1 1]};
	[proceed,errormsg] = hasAllFields(parameters, fieldNames, fieldSizes);
	if proceed, proceed = isfield(parameters,'dispprefs'); end;
end;

if proceed,
	% check to make sure all arguments make sense
	if ~isa(parameters.dispprefs,'cell'), errormsg = 'dispprefs must be a list/cell.'; proceed = 0; end;
end;

if proceed,
	if sum(parameters.imageType*ones(1,9)==(0:8))~=1,
		proceed = 0; errormsg = 'imageType must be 0,1,...,or 8.';
	elseif sum(parameters.animType*ones(1,6)==(0:5))~=1,
		proceed = 0; errormsg = 'animType must be 0,1,..., or 5.';
	elseif sum(parameters.flickerType*ones(1,3)==(0:2))~=1,
		proceed = 0; errormsg = 'flickerType must be 0,1, or 2.';
	elseif parameters.distance<=0, proceed = 0; errormsg = 'distance must be positive.';
	elseif parameters.sFrequency<=0, proceed = 0; errormsg = 'sFrequency must be positive.';
	elseif parameters.tFrequency<=0, proceed = 0; errormsg = 'tFrequency must be positive.';
	elseif parameters.barWidth<=0, proceed = 0; errormsg = 'barWidth must be positive.';
	elseif parameters.nCycles<=0, proceed = 0; errormsg = 'nCycles must be positive.';
	elseif (parameters.contrast<0)|(parameters.contrast>1),
		proceed=0; errormsg = 'contrast must be in [0..1]';
	elseif (parameters.background<0)|(parameters.background>1),
		proceed=0; errormsg = 'background must be in [0..1]';
	elseif size(parameters.backdrop,2)==1,
		if (parameters.backdrop<0)|(parameters.backdrop>1),
			proceed=0; errormsg = 'if backdrop [1x1] then backdrop must be in [0..1]';
		end;
	elseif size(parameters.backdrop,2)==3,
		if ~all(parameters.backdrop>=0&parameters.backdrop<256),
			proceed=0; errormsg = 'If backdrop is [1x3], then entries must be in [0..255].';
		end;
	elseif size(parameters.backdrop,2)~=1&size(parameters.backdrop,2)~=3,
		proceed=0; errormsg = 'backdrop must be [1x1] or [1x3]';
	elseif (parameters.nSmoothPixels<0), proceed=0; errormsg = 'nSmoothPixels must be non-negative.'; 
	elseif (parameters.fixedDur <0), proceed=0; errormsg = 'fixedDur must be non-negative.'; 
	elseif sum(parameters.windowShape*[1 1 1 1]==[0 1 2 3 4 5 6 7])~=1,
		proceed=0; errormsg = 'windowShape must be 0, 1, 2 ... 7.'; 
	elseif ((parameters.rect(3)-parameters.rect(1))*(parameters.rect(4)-parameters.rect(2))<=0)| ...
		(parameters.rect(3)-parameters.rect(1)<0),
		proceed=0; errormsg = 'rect must have positive area.';
	elseif parameters.loops<0, proceed=0; errormsg='loops must be >= 0.';
        % add error checking for chromhigh/low here
	end;
end;

if proceed, % check displayprefs for validity
        try, dummy = displayprefs(parameters.dispprefs);
        catch, proceed = 0; errormsg = ['dispprefs invalid: ' lasterr];
        end;
end;


good = proceed;
