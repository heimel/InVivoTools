function newra = setparameters(ra,parameters)
%  NEWRA = SETPARAMETERS(RA,P)
%
%  Sets the parameters of the RASTER object RA to P.  P must be a valid set of
%  parameters.  The outputs and menus of RA are re-computed and re-displayed.a
%  If P is the string 'default' then the default parameters are chosen.
%
%  See also:  RASTER, GETPARAMETERS

default_p = struct('res',0.001,'interval',[-0.1 1.0],'fracpsth',0.5,...
        'normpsth',1,'showvar',1,'psthmode',0,'showfrac',1,'cinterval',[0 1],...
	'showcbars',1,'axessameheight',1);

if isempty(parameters)||(ischar(parameters)&&strcmp(parameters,'default'))
        parameters = default_p; 
end

%[good,er]=verifyparameters(parameters,getinputs(ra));
%if ~good,error(['PARAMETERS: ' er]);end;

ra.RAparams = parameters;
configuremenu(ra); 
ra = compute(ra); 
draw(ra);

newra = ra;
