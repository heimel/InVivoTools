function [good, errormsg] = verifyshapemoviestim(parameters)

  % note: parameters must be a struct, NOT an object

proceed = 1;
errormsg = '';

if proceed,
	% check that all arguments are present and appropriately sized
	fieldNames = {'rect','BG','scale','fps','N','isi'};
        fieldSizes = {[1 4],[1 3],[1 1],[1 1],[1 1],[1 1]}; 
	[proceed,errormsg] = hasAllFields(parameters, fieldNames, fieldSizes);
	if proceed,
            proceed = isfield(parameters,'dispprefs');
            if ~proceed, errormsg = 'no displayprefs field.'; end;
        end;
end;

if proceed,
	if ~isa(parameters.dispprefs,'cell'),
		errormsg = 'dispprefs must be a list/cell.'; proceed = 0;
	else,
		width  = parameters.rect(3) - parameters.rect(1);
		height = parameters.rect(4) - parameters.rect(2);
		proceed= (width>0&height>0);
		if ~proceed, errormsg = 'Rect must have positive area.'; end;
	end;
end;

if proceed,
	% check colors
	f = find(parameters.BG<0|parameters.BG>255);
	if f, proceed = 0; errormsg = 'R,G,B in BG must be in [0..255]'; end;
	if parameters.scale~=round(parameters.scale),
		proceed=0;errormsg='Scale must be an integer'; end;
	if parameters.N~=round(parameters.N),
		proceed=0;errormsg='N must be an integer'; end;
	if parameters.fps<=0,
		proceed=0;errormsg='fps must be >= 0'; end;
	if parameters.isi<=0,
		proceed=0;errormsg='isi must be >= 0'; end;
end;

if proceed, % check displayprefs for validity
	try, dummy = displayprefs(parameters.dispprefs);
	catch, proceed = 0; errormsg = ['dispprefs invalid: ' lasterr];
	end;
end;

good = ~proceed;
