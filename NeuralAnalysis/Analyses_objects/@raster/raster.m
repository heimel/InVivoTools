function ra = raster(inputs, parameters, where)

%  Part of the NeuralAnalysis package
%
%  RA = RASTER(INPUTS, PARAMETERS, WHERE)
%
%  Creates a new raster analysis object.  It allows triggered visualization of
%  a spike data object, as well as a means of examining average behavior and
%  variation.  WHERE should be a set of parameters as described in 'help
%  ANALYSIS_GENERIC'.
%
%  INPUTS should contain the following fields:
%      spikes   [1xN] :     spikedata object
%    {triggers} [1xN] :     a cell list of 1-dimensional arrays containing
%                     :       trigger times; each entry is for a different
%                     :       condition
%    condnames  [1xN] :     names for each of the conditions above; should be
%                     :       brief enough to appear as a tick label
%
%  PARAMETERS should contain the following fields:
%      res      [1x1] :     time resolution of the analysis (in seconds)
%    interval   [1x2] :     time around each trigger to show (in seconds),
%                     :       negative means before trigger
%    cinterval  [1x2] :     time around each trigger upon which to base
%                     :       computations ...
% OR cinterval  [Nx2] :     time around each trigger (different for each trigger
%                     :       array) upon which to base computations.
%    showcbars  [1x1] :     0/1 whether or not to show the cinterval on plot
%    fracpsth   [1x1] :     0..1 fraction of space psth should take up
%                     :     1 means no drawing of raster, 0 means no drawing
%                     :     of psth
%    normpsth   [1x1] :     0/1 whether or not to normalize the psth
%                     :        (divides by number of triggers and time
%                               resolution, output is in Hz)
%    showvar    [1x1] :     0/1 whether or not to show variance on psth
%    psthmode   [1x1] :     0/1 bars or lines
%    showfrac   [1x1] :     0..1 fraction of trials to actually display
%                     :        in raster (average is made from all, but
%                     :        for speed std-dev only made from
%                     :        this sublist) (*not implemented yet*)
%
%  PARAMETERS may also be the string 'default' for default parameters
%  (res=0.001,interval=[0.1 1],showrast,showpsth,normpsth,showvar=1,psthmode=0).

if nargin<3
    where = [];
end
if nargin<2
    parameters = [];
end
if nargin==0
    inputs = [];
else
    [good,er]=verifyinputs(inputs);
    if ~good
        error(['INPUT: ' er]);
    end
end

computations = struct('bins',[],'counts',[],'variation',[],'ncounts',[],...
    'ctdev',[],'rast',[]);
internals = struct('cstart',[],'cstop',[],'counts',[],'variation',[],'rast',[]);


nag =analysis_generic([],[],where); delete(nag);
ag = analysis_generic([],[],[]);
ra = class(struct('inputs',inputs,'RAparams',[],'internals',internals,...
    'computations',computations),'raster',ag);
ra = setparameters(ra,parameters); % must be immediately after above
delete(contextmenu(ra)); ra = newcontextmenu(ra);  % install new contextmenu
ra = compute(ra);
ra = setlocation(ra,where);
