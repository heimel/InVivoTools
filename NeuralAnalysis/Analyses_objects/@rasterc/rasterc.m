function rac = rasterc(inputs, parameters, where)

%  RASTERC - Continuous raster analysis object, part of the NeuralAnalysis package
%
%  RAC = RASTERC(INPUTS, PARAMETERS, WHERE)
%
%  Creates a new rasterc analysis object.  It allows triggered visualization of 
%  a measureddata object, as well as a means of examining average behavior and
%  variation.  WHERE should be a set of parameters as described in 'help
%  ANALYSIS_GENERIC'.  The measureddata object must have continuously-sampled
%  data.
%
%  INPUTS should contain the following fields:
%      data     [1xN] :     measureddata object
%    {triggers} [1xN] :     a cell list of 1-dimensional arrays containing
%                     :       trigger times; each entry is for a different
%                     :       condition
%    condnames  [1xN] :     names for each of the conditions above; should be
%                     :       brief enough to appear as a tick label
%
%  PARAMETERS should contain the following fields:
%      res      [1x1] :     time resolution of the analysis (in seconds)
%    alignmeth  [1x1] :     method to align data to time resolution above,
%                     :       0 - closest sample
%                     :       1 - fit with cubic spline
%    interval   [1x2] :     time around each trigger to show (in seconds),
%                     :       negative means before trigger
%    cinterval  [1x2] :     time around each trigger upon which to base
%                     :       computations ...
% OR cinterval  [Nx2] :     time around each trigger (different for each trigger
%                     :       array) upon which to base computations.
%    showcbars  [1x1] :     0/1 whether or not to show the cinterval on plot
%    showtbars  [1x1] :     0/1 if featuremeth is 1,2,or 3, shows [t0 t1]
%    showfeature[1x1] :     0/1 plots extracted feature on each waveform
%  rastsepmethod[1x1] :     method by which rasters should be separated
%                     :       0 - fraction of min/max
%                     :       1 - fraction of std
%                     :       2 - constant offset
%    usecolors  [1x1] :     0/1 put each raster in a different color
%  rastsepvalue [1x1] :     value of the separation
%    fracavg    [1x1] :     0..1 fraction of space average should take up
%                     :     1 means no drawing of raster, 0 means no drawing
%                     :     of average
%    showvar    [1x1] :     0/1 whether or not to show variance on average plot
%    showfrac   [1x1] :     0..1 fraction of trials to actually display
%                     :        in raster (average is made from all, but
%                     :        for speed std-dev only made from
%                     :        this sublist) (*not implemented yet*)
%
%  PARAMETERS may also be the string 'default' for default parameters
%  (res=0.001,interval=[0.1 1],showrast,showpsth,normpsth,showvar=1,psthmode=0).

computations = struct('bins',[],'counts',[],'variation',[],'ncounts',[],...
			'ctdev',[],'rast',[]);
internals = struct('cstart',[],'cstop',[],'counts',[],'variation',[],'rast',[]);

[good,er]=verifyinputs(inputs);if ~good,error(['INPUT: ' er]);end;

nag =analysis_generic([],[],where); delete(nag);
ag = analysis_generic([],[],[]);
ra = class(struct('inputs',inputs,'RAparams',[],'internals',internals,...
        'computations',computations),'raster',ag);
ra = setparameters(ra,parameters); % must be immediately after above
delete(contextmenu(ra)); ra = newcontextmenu(ra);  % install new contextmenu
ra = compute(ra);
ra = setlocation(ra,where);
