function [good, errormsg] = VerifyStochasticGridStim(parameters)

  % note: parameters must be a struct, NOT an object

proceed = 1;
errormsg = '';

if proceed,
	% check that all arguments are present and appropriately sized
	fieldNames = {'BG','dist','values','rect','pixSize','N','randState'};
        fieldSizes = {[1 3],[-1 1],[-1 3],[1 4],[1 2],[1 1],[35 1]}; 
	[proceed,errormsg] = hasAllFields(parameters, fieldNames, fieldSizes);
	if proceed,
            proceed = isfield(parameters,'dispprefs');
            if ~proceed, errormsg = 'no displayprefs field.'; end;
        end;
end;

if proceed,
	% check rect, pixSize args
	if ~isa(parameters.dispprefs,'cell'),
		errormsg = 'dispprefs must be a list/cell.';
		proceed = 0;
	else,
		width  = parameters.rect(3) - parameters.rect(1);
		height = parameters.rect(4) - parameters.rect(2);

        	x = parameters.pixSize(1); y = parameters.pixSize(2);
        	if (x>=1), X = x; else, X = width * x; end;
        	if (y>=1), Y = y; else, Y = height * y; end;
        	proceed = (fix(width/X)==width/X) & (fix(height/Y)==height/Y);
		if ~proceed,
			errormsg = 'Grid square size specified does not _exactly_ cover area.';
		end;
	end;
end;

if proceed,
	% check colors
	f = find(parameters.BG<0|parameters.BG>255);
	if f, proceed = 0; errormsg = 'R,G,B in BG must be in [0..255]'; end;
	f = find(parameters.values<0|parameters.values>255);
	if f, proceed = 0; errormsg = 'R,G,B in values must be in [0..255]'; end;
end;

if proceed, % check that value and dist have same size
	proceed = (size(parameters.dist,1)==size(parameters.values));
	if ~proceed, errormsg = 'dist and value must have same number of rows.';
	else,
		f = find(parameters.dist<0); proceed = isempty(f);
		if ~proceed, errormsg = 'all entries of dist must be non-negative.'; end;
	end;
end;

if isfield(parameters,'angle'),
	if ~isnumeric(parameters.angle), proceed = 0; errormsg = 'angle must be a number.'; end;
end;

if proceed,
	if parameters.fps<=0, proceed = 0; errormsg = 'fps must be positive.';
	elseif parameters.N<=0, proceed = 0; errormsg = 'N must be positive.';
	end;
end;

if proceed, % check displayprefs for validity
	try, dummy = displayprefs(parameters.dispprefs);
	catch, proceed = 0; errormsg = ['dispprefs invalid: ' lasterr];
	end;
end;

good = proceed;
