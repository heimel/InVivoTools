function [good, errormsg] = verify(parameters)

  % note: parameters must be a struct, NOT an object

proceed = 1;
errormsg = '';

if proceed,
	% check that all arguments are present and appropriately sized
	fieldNames = {'BG','value','rect','pixSize','repeat', ...
                      'bgpause','fps','randState'};
        fieldSizes = {[1 3],[1 3],[1 4],[1 2],[1 1],[1 1],[1 1],[35 1]}; 
	[proceed,errormsg] = hasAllFields(parameters, fieldNames, fieldSizes);
	if proceed,
            proceed = isfield(parameters,'dispprefs');
            if ~proceed, errormsg = 'no dispprefs field.'; end;
        end;
end;

if proceed,
	% check to make sure all arguments make sense
	if ~isa(parameters.dispprefs,'cell'), errormsg = 'dispprefs must be a list/cell.'; proceed = 0;
	else,
		width  = parameters.rect(3) - parameters.rect(1);
		height = parameters.rect(4) - parameters.rect(2);

        x = parameters.pixSize(1); y = parameters.pixSize(2);
        if (x>=1), X = x; else, X = width * x; end;
        if (y>=1), Y = y; else, Y = height * y; end;
        proceed = (fix(width/X)==width/X) & (fix(height/Y)==height/Y);
		if ~proceed, errormsg = 'Grid square size specified does not _exactly_ cover area.'; end;
	end;
end;

if proceed,
        % check colors
        f = find(parameters.BG<0|parameters.BG>255);
        if f, proceed = 0; errormsg = 'R,G,B in BG must be in [0..255]'; end;
        f = find(parameters.value<0|parameters.value>255);
        if f, proceed = 0; errormsg = 'R,G,B in values must be in [0..255]'; end;
end;

if proceed,
        if parameters.fps<=0, proceed = 0; errormsg = 'fps must be positive.';
        elseif parameters.repeat<=0, proceed = 0; errormsg = 'repeat must be positive.';
        elseif parameters.bgpause<0, proceed = 0; errormsg = 'bgpause must be non-negative.';
        elseif ~((parameters.random==0)|(parameters.random==1)), proceed = 0;
		errormsg = 'random must be 0 or 1.';
        end;
end;

if proceed, % check displayprefs for validity
        try, dummy = displayprefs(parameters.dispprefs);
        catch, proceed = 0; errormsg = ['dispprefs invalid: ' lasterr];
        end;
end;

good = proceed;
