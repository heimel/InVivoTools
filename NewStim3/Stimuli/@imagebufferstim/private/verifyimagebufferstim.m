function [good, errormsg] = verifyimagebufferstim(parameters)

  % note: parameters must be a struct, NOT an object

proceed = 1;
errormsg = '';

if proceed,
	% check that all arguments are present and appropriately sized
	fieldNames = {'chromhigh', 'chromlow', 'rect', 'contrast', 'background',...
                  'imgnumber', 'buffer', 'pause', 'blankpause', 'seed'};
        fieldSizes = {[1 3], [1 3], [1 4], [1 1], [1 1], [1 1], [1 1], [1 1], [1 1], [1 1]};
				
	[proceed,errormsg] = hasAllFields(parameters, fieldNames, fieldSizes);
	if proceed, proceed = isfield(parameters,'dispprefs'); end;
end;

if proceed,
	% check to make sure all arguments make sense
	if ~isa(parameters.dispprefs,'cell'), errormsg = 'dispprefs must be a list/cell.'; proceed = 0; end;
end;

if proceed,
	if (parameters.contrast<0)|(parameters.contrast>1),
		proceed=0; errormsg = 'contrast must be in [0..1]';
	elseif (parameters.background<0)|(parameters.background>1),
        proceed=0; errormsg = 'background must be in [0..1]';
    elseif (parameters.buffer<=0),
        proceed=0; errormsg = 'buffer must be larger than 0';
	elseif ((parameters.rect(3)-parameters.rect(1))*(parameters.rect(4)-parameters.rect(2))<=0)| ...
		(parameters.rect(3)-parameters.rect(1)<0),
		proceed=0; errormsg = 'rect must have positive area.';
    elseif parameters.imgnumber<0, proceed=0; errormsg='imgnumber must be >= 1.'
    elseif parameters.pause<0, proceed=0; errormsg='pause must be >= 0.';
    elseif parameters.blankpause<0, proceed=0; errormsg='blankpause must be >= 0.';
        % add error checking for chromhigh/low here
	end;
end;

if proceed, % check displayprefs for validity
        try, dummy = displayprefs(parameters.dispprefs);
        catch, proceed = 0; errormsg = ['dispprefs invalid: ' lasterr];
        end;
end;


good = proceed;
