function ag = analysis_generic(inputs, parameters, where)

%  Part of the NeuralAnalysis package
%
%  AG = ANALYSIS_GENERIC(INPUTS, PARAMETERS, WHERE)
%
%  A base class for analysis methods.  INPUTS are the inputs to the analysis
%  function, which for ANALYSIS_GENERIC objects is always ignored.  
%  PARAMETERS are the parameters, which are also always ignored.  WHERE is a
%  structure describing where the analysis should be plotted.  It should either
%  be empty ([]) if no drawing is to take place, or a structure with the
%  following entries:
%
%  where.figure   #         |     figure number to draw in
%  where.rect    [1x4]      |     rectangle where the drawing should take place
%  where.units              |     either 'normalized' or 'pixel' (see docs
%                           |      for axes properties)
%  Right-clicking the graphical output of an analysis_generic object will give
%  a menu of options.  This menu is accessible by calling CONTEXTMENU.

if nargin<3
    where = [];
end

cb = 'agcontextmenucallback(analysis_generic([],[],[]))';
if ~isempty(where),
	[good,err] = verifywhere(where);
	if ~good, error(err);
	else, figure(where.figure); end;
else,
end;

ag = class(struct('contextmenu',[],'where',[]),'analysis_generic');
ag = newcontextmenu(ag);
ag = setlocation(ag,where);
