function newtc = setparameters(tc,parameters,record)

%  NEWRA = SETPARAMETERS(TC,P)
%
%  Sets the parameters of the TUNING_CURVE object TC to P.  P must be a valid set of
%  parameters.  The outputs and menus of TC are re-computed and re-displayed.a
%  If P is the string 'default' then the default parameters are chosen.
%
%  See also:  TUNING_CURVE, GETPARAMETERS

if nargin<3
    record = [];
end

default_p = struct('res',0.010,'showrast',1,'interp',3,'drawspont',1,'int_meth',0,'interval',[0 0]);

if isempty(parameters)||(ischar(parameters)&&strcmp(parameters,'default'))
        parameters = default_p; 
end

%[good,er]=verifyparameters(parameters,getinputs(tc));
%if ~good,error(['PARAMETERS: ' er]);end;

tc.TCparams = parameters;
configuremenu(tc); 
tc = compute(tc,record); 
draw(tc);
newtc = tc;
