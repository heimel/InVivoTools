function [good, errormsg] = verifycentersurroundstim(parameters)

  % note: parameters must be a struct, NOT an object
p = parameters;
proceed = 1;
errormsg = '';

if proceed,
	% check that all arguments are present and appropriately sized
	fieldNames = {'center','radius','surrradius','BG','FGc','FGs',...
                      'contrast','lagon','lagoff','surrlagon','surrlagoff',...
                      'stimduration'};
        fieldSizes = {[1 2],[1 1],[1 1],[1 3],[1 3],[1 3],...
                      [1 1],[1 1],[1 1],[1 1],[1 1],...
                      [1 1]}; 
	[proceed,errormsg] = hasAllFields(parameters, fieldNames, fieldSizes);
	if proceed,
            proceed = isfield(parameters,'dispprefs');
            if ~proceed, errormsg = 'no displayprefs field.'; end;
        end;
end;

if proceed,
  try,
   if p.lagon<0,  proceed=0; errormsg='lagon must be >=0.'; end;
   if (p.lagoff>0)&(p.lagon>p.lagoff), proceed=0;
         errormsg='lagoff must be greater than lagon or not used.';end;
   if (p.surrlagon<0)&(p.surrradius>0),
         proceed=0; errormsg='surrlagon must be >=0.'; end;
   if (p.surrlagoff>0)&(p.surrlagon>p.surrlagoff), proceed=0;
         errormsg='surrlagoff must be greater than surrlagon or not used.';end;
   if (p.radius>0)&(p.surrradius>0)&(p.radius>p.surrradius), proceed=0;
         errormsg='surrradius must be greater than radius if used.'; end;
   if (p.stimduration<=0),proceed=0;errormsg='stimudration must be > 0.';end;
  catch, proceed=0; errormsg=['lagon,lagoff,surrlagon,surrlagoff,radius,'...
                              'surrradius, stimduration must be numeric.'];
  end;
end;

if proceed,
	% check colors
	f = find(parameters.BG<0|parameters.BG>255);
	if f, proceed = 0; errormsg = 'R,G,B in BG must be in [0..255]'; end;
	f = find(parameters.FGc<0|parameters.FGc>255);
	if f, proceed = 0; errormsg = 'R,G,B in FGc must be in [0..255]'; end;
	f = find(parameters.FGs<0|parameters.FGs>255);
	if f, proceed = 0; errormsg = 'R,G,B in FGs must be in [0..255]'; end;
end;

if proceed, 
  if p.contrast>1|p.contrast<0,proceed=0;errrmsg='constrast must be in [0..1].'
  end;
end;

if proceed, % check displayprefs for validity
	try, dummy = displayprefs(parameters.dispprefs);
	catch, proceed = 0; errormsg = ['dispprefs invalid: ' lasterr];
	end;
end;

good = proceed;
