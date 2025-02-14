function mdd = measureddatadisplay(inputs,parameters,where)

%  Part of the NeuralAnalysis package
%
%  MDD = MEASUREDDATADISPLAY(INPUTS, PARAMETERS, WHERE)
%
%  Creates a new object for thumbing through MEASUREDDATA objects' data.
%
%  INPUTS should contain the following field
%   measureddata  {1xN}      :    The measureddata objects to display
%  PARAMETERS should contain the following fields:
%   displayParams [1xN]      :    A structure containing the following fields
%                            :      for each measureddata:
%   displayParams.sepmeth    :    0=>use fraction of data's max/min to determine
%                            :      distance between subsequent channel's data.
%                            :    1=>use fraction of standard deviation
%                            :    2=>use constant offset
%   displayParams.sepdist    :    Distance parameter associated with sepmeth
%                            :       above
%   displayParams.line (0/1) :    Draw lines b/t points (1==yes,default;0==no)
%   displayParams.linesz(0/1):    Size of lines (1 by default)
%   displayParams.sym        :    A character describing which symbol, if any,
%                            :       to use in plotting ('' for none)
%   displayParams.markerSize :    An integer describing the markerSize for the
%                            :       symbol above (must be > 0, default = 1)
%   displayParams.scaling    :    A factor which scales the data
%   displayParams.color [3x1]:    The color to use to plot the data
%   displayParams.draw (0/1) :    If 1, draw, if 0, don't draw (surpress)
%   offset                   :    Offset between measureddata objects' data
%   memwarning               :    Warn if data to be read in exceeds this, in MB
%   xaxis                    :    [xmin xmax] or string 'auto'
%   yaxis                    :    [ymin ymax] or string 'auto'
%   xauto                    :    [xmin xmax] for auto setting, or strings*:
%                            :       'alluptomem' show all data as long as 
%                            :                      memory condition is not met
%                            :       'all'        show all (for big files=bad)
%   removemeans        (0/1) :    If 1, removes means before plotting
%                            :       * strings not implemented yet
%   See also:  MEASUREDDATA

computations = [];
internals    = [];
[good,er] = verifyinputs(inputs); if ~good,error(['INPUT: ' er]);end;

nag = analysis_generic([],[],where); delete(nag);
ag = analysis_generic([],[],[]);
mdd = class(struct('inputs',inputs,'MDDparams',[],'internals',internals,...
            'computations',computations),'measureddatadisplay',ag);
mdd = setparameters(mdd,parameters); % must be immediately after above
delete(contextmenu(mdd)); mdd = newcontextmenu(mdd);
mdd = compute(mdd);
p=getparameters(mdd);
if ischar(p.xaxis)&strcmp(p.xaxis,'auto'),
  mdd=setviewplace(mdd,'beginning');
end;
mdd = setlocation(mdd,where);
