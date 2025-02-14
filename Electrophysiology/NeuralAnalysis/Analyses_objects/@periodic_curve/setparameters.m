function newpc = setparameters(pc,parameters,record)

%  NEWRA = SETPARAMETERS(PC,P)
%
%  Sets the parameters of the PERIODIC_CURVE object PC to P.
%  P must be a valid set of parameters.  The outputs and
%  menus of PC are re-computed and re-displayed.  If P is
%  the string 'default' then the default parameters are chosen.
%
%  See also:  PERIODIC_CURVE, GETPARAMETERS

if nargin<3
    record = [];
end

gP1 = struct('draw',1,'howdraw',1,'showstderr',1,'showstddev',1,...
                     'showspont',1,'whattoplot',3,'whichdata',[]);
gP2 = struct('draw',1,'howdraw',1,'showstderr',1,'showstddev',1,...
                     'showspont',1,'whattoplot',4,'whichdata',[]);
gP3 = struct('draw',1,'howdraw',1,'showstderr',1,'showstddev',1,...
                     'showspont',1,'whattoplot',5,'whichdata',[]);
gP4 = struct('draw',1,'howdraw',1,'showstderr',1,'showstddev',1,...
                     'showspont',1,'whattoplot',7,'whichdata',[]);
gP = [gP1 gP2 gP3 gP4];

default_p=struct('title','','res',0.010,'lag',0,'paramnames',{{}},...
                 'paramvalues',{{}},'graphParams',gP);

if isempty(parameters)||(ischar(parameters)&&strcmp(parameters,'default'))
        parameters = default_p; 
end

pc.PCparams = parameters;
configuremenu(pc);
pc = compute(pc,record); 
draw(pc);
newpc = pc;
