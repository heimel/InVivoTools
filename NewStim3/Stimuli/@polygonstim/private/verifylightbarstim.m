function [good,errormsg] = verifylightbarstim(parameters)

proceed = 1;
errormsg = '';

if proceed,
	% check that all arguments are present and appropriately sized
	fieldNames={'rect','shape','units','distance','offsetxy',...
		    'offsettheta','howlong','backdrop','background', ...
		    'foreground','contrast','remove','orientation','points',...
		    'smooth'};
	fieldSizes={[1 4],[1 1],[1 1],[1 1],[1 2],...
		    [1 1],[1 1],[1 3],[1 3],[1 3],[1 1],[-1 2],[1 1],[-1 2],...
		    [1 1]};
	[proceed,errormsg]=hasAllFields(parameters,fieldNames,fieldSizes);
	if proceed,
		proceed = isfield(parameters,'dispprefs');
		if ~proceed,errormsg='no disppprefs field.'; end;
	end;
end;

if proceed,
	% check colors
	f=find(parameters.backdrop<0|parameters.backdrop>255);
	if f,proceed=0; errormsg='R,G,B in backdrop must be in [0..255]';end;
	f=find(parameters.background<0|parameters.background>255);
	if f,proceed=0; errormsg='R,G,B in background must be in [0..255]';end;
	f=find(parameters.foreground<0|parameters.foreground>255);
	if f,proceed=0; errormsg='R,G,B in foreground must be in [0..255]';end;
	if (diff(parameters.rect([1 3])))<0|(diff(parameters.rect([2 4]))<0),
		proceed = 0; errormsg='rect must have positive area.';
	end;
	if parameters.distance<=0,
		proceed=0;errormsg='distance must be positive.';
	end;
	if parameters.howlong<=0,
		proceed=0;errormsg='howlong must be positive.';
	end;
	if parameters.contrast<0|parameters.contrast>1,
		proceed=0; errormsg='contrast must be in [0..1].';
	end;
	if ~(parameters.shape==0|parameters.shape==1),
		proceed=0; errormsg='shape must be 0 or 1.';
	end;
	if parameters.shape==0,
		if size(parameters.points)~=[1 2],
			proceed=0;errormsg='points must be 1x2.';
		else,
			if parameters.points(1)<0|parameters.points(2)<0,
				proceed=0;errormsg='Width,height must be >=0.';
			end;
		end;
		if size(parameters.remove)~=[1 2],
			proceed=0;errormsg='remove must be 1x2.';
		else,
			if parameters.remove(1)<0|parameters.remove(2)<0,
				proceed=0;errormsg='remove must be >=0.';
			end;
		end;
	end;
	if parameters.smooth<1,proceed=0;errormsg='smooth must be >= 1.';end;
end;

if proceed, % check displayprefs for validity
	try, dummy = displayprefs(parameters.dispprefs);
	catch,proceed = 0; errormsg =['dispprefs invalid: ' lasterr];
	end;
end;

good = proceed;

