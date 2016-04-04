function rc = reverse_corr(inputs, parameters, where)

%  Part of the NeuralAnalysis package
%
%  RC = REVERSE_CORR(INPUTS,PARAMETERS,WHERE)
%
%  Creates a new reverse_corr object.  It computes the "average" image which
%  preceded the spiking of a particular neuron.  It also optionally brings up
%  a raster plot which shows the stimulus-response profile of the neuron
%  triggered on the display of any particular portion of the image, and this
%  portion is selectable by the user.  In addition, it optionally brings up a
%  spike-triggered average value of the selected image portion.
%
%  INPUTS should be a struct with the following fields:
%     spikes  {1xN}    :    a cell list of spikedata objects
%   stimtime  [1xM]    :    a vector of stimtime records of stimuli (see
%                      :      'help stimtimestruct')
%   cellnames {1xN}    :    cell list containing names for the spikedata
%                      :      objects above
%
%  PARAMETERS should be a struct with the following fields, or the string
%  'defaults':
%   interval [1x2]     :   interval post-stimulus in which to count spikes
%                      :     (e.g., [0.030 0.120] is 30ms to 120ms)
%   timeres  [1x1]     :   time resolution of reverse-correlation (e.g., 10ms)
%   showrast [1x1] 0/1 :   whether or not to show a raster along with the
%                      :      reverse correlation*
%   show1drev[1x1] 0/1 :   whether or not to show a one-dimentional reverse
%                      :      correlation for the currently selected center
%   feature  [1x1]     :   0=>absolute brightness, 1=>edge contrast difference
%                      :      2=>abs value of 1, 3=>temporal brightness
%                      :      difference b/t prev frame and curr frame,
%                      :      4=>abs value of 3,5=>temporal brightness difference
%                      :      of edges, 6=>abs of 5.
%   showdata [1x1] 0/1 :   whether or not to show a plot with the data values
%                      :      for a grid point and the spikes.
%   normalize[1x1]     :   0=>no normalization, 1=> normalize by difference from
%                             feature mean assuming two stimulus values
%   chanview [1x1]     :   0=>view composite,1=>view red ,2=>view green,3=>view
%                      :      blue; this also determines how the maxmimum
%                      :      location is determined
%   colorbar [1x1] 0/1 :   whether or not to show a colorbar along with the
%                      :      reverse correlation image
%  clickbehav[1x1]     :   0=> zoom, 1=> drag manually select center, 2=>
%                      :      select new grid point for raster, one-dimensional
%                      :      reverse correlation (if possible)
%                      :      image drags a new center rectangle; if possible *,
%                      :      if this is 0 clicking re-directs the raster to
%                      :      that grid point. 
%  datatoview[1x3]     :   [cell timepoint], tells which image to view
%                      :      (should be integers referring to the Nth cell,
%                      :       stimulus, or presentation in input); stim and
%                      :      trial indicate which structures the computations
%                      :      are restricted; if 0 is given for stim, this means
%                      :      an average of all the stims for a given cell, and
%                      :      if 0 is given for trial, then this means average
%                      :      over the trials of that stim.
%show1drevprs[1x5]     :    [mode tres start stop show_std]
%                      :      mode=0=>show value,mode=1=>show abs derivative,
%                      :      tres -> time resolution (e.g., 0.001 = 1ms)
%                      :      start,stop=interval to look in around each frame
%                      :      (e.g., -0.050 0.050 is plus/minus 50ms)
%                      :     show_std=1=>show standard deviation, too
%     bgcolor[1x1]     :   the color to treat as the background color; this is
%                      :     an index in the color list of a stochasticgridstim
%                      :     or blinkingstim (e.g., bgcolor=1=>first one)
%    crcpixel[1x1]     :   Show continuous reverse correlation with this pixel
%                      :     Use -1 for none
%  crctimeres[1x1]     :   Time res (sec) of continuous reverse correlation 
%     crcproj[2x3]     :   Projection from RGB to use for continuous rc
%                      :      cont = (value-crcproj(1,:)) * crcproj(2,:)'
%  crctimeint[1x2]     :   Poststimulus time to examine [start stop], in sec.
%pseudoscreen[1x4]     :   rectangle for a virtual screen to show the stimulus
%                      :      upon.
%
%  Note:  stimuli must be of type stochasticgridstim.
%  
%  See also:  ANALYSIS_GENERIC

%computations = struct('reverse_corr',[],'center',[],'center_rect',[]);
computations = struct('comps',[]);
internal=struct('rasterobj',[],'reverse1d',[],'oldint',[],'selectedbin',0,...
	'oldtimeres',[],'oldfeature',[],'crcpixel',-1,'datatoview',1,...
	'crctimeres',-1,'crctimeint',[-1 1],'crcproj',-1*[1 1 1;1 1 1]);

if ~iscell(inputs.spikes)
	inputs.spikes={inputs.spikes};
end
							
[good,er]=verifyinputs(inputs); 
if ~good,
    msg = ['Input ' er];
    disp(['REVERSE_CORR: ' msg]);
    rc = [];
    return
end

nag = analysis_generic([],[],where); 
delete(nag);
ag = analysis_generic([],[],[]);
rc = class(struct('inputs',inputs,'RCparams',[],'computations',computations,...
	'internal',internal),'reverse_corr',ag);
rc = setparameters(rc,parameters);
delete(contextmenu(rc)); 
rc = newcontextmenu(rc);
rc = compute(rc);
rc = setlocation(rc,where);
