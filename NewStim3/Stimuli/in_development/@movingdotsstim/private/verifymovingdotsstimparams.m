function [good, errormsg] = verifymovingdotsstimparams(parameters)

  % note: parameters must be a struct, NOT an object

proceed = 1;
errormsg = '';

if proceed,
	% check that all arguments are present and appropriately sized
	fieldNames = {'rect','BG','FG','motiontype','velocity','angvelocity',...
			'direction','coherence','dotsize','numdots','distance',...
			'fps','duration','numpatterns','lifetimes','randState'};
        fieldSizes = {[1 4],[1 3],[1 3],[1 -1],[1 1],[1 1],...
			[1 1],[1 1],[1 1],[1 1],[1 1],...
			[1 1],[1 1],[1 1],[1 1],[35 1]}; 
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
	f = find(parameters.FG<0|parameters.FG>255);
	if f, proceed = 0; errormsg = 'R,G,B in BG must be in [0..255]'; end;
	if parameters.fps<=0,
		proceed=0;errormsg='fps must be >= 0'; end;
	if parameters.duration<=0,
		proceed=0;errormsg='duration must be >= 0'; end;
	if parameters.numdots<=0,
		proceed=0;errormsg='numdots must be >= 0'; end;
	if parameters.dotsize<=0,
		proceed=0;errormsg='dotsize must be >= 0'; end;
	if ~isnumeric(parameters.velocity)
		proceed=0;errormsg='velocity must be a number';end;
	if ~isnumeric(parameters.angvelocity)
		proceed=0;errormsg='angvelocity must be a number';end;
	if parameters.coherence<0|parameters.coherence>1
		proceed=0;errormsg='coherence must be in [0,1]';end;
	if parameters.numpatterns<0
		proceed=0;errormsg='numpatterns must be >=1';end;

end;

if proceed, % check displayprefs for validity
	try, dummy = displayprefs(parameters.dispprefs);
	catch, proceed = 0; errormsg = ['dispprefs invalid: ' lasterr];
	end;
end;

good = ~proceed;
