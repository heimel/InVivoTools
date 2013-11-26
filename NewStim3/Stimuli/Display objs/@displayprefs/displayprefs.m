function df = displayprefs(parameters)

  % parameters is alternating param name and value
% Part of the NewStim package
%
% DP = DISPLAYPREFS(PARAMETERS)
%
%  Creates a displayprefs object.  Each stimulus object has a displayprefs
%  object associated with it.  Most displaypref parameters (exception is noted
%  below) are meant to be adjustable before or after stimulus loading, so it
%  is a quick way to change some aspects of stimuli which take a long time to
%  load.  Note that there are always default values provided, so one only needs
%  to edit the displayprefs parameter if a change from the default behavior
%  is desired.
%
%  One must be careful when editing displayprefs objects.  It is possible to
%  crash the stimulus computer by entering bogus values.  In addition, if one
%  changes the size of the target rectangle to be a different size than
%  expected, the display could be very slow or result in a crash.
%
%  When a displayprefs object is created, the parameters used are stored as
%  defaults.  
%
%  The parameters are below, and should be entered as a cell array
%  (e.g., parameters = {'fps', 4, 'rect', [ 100 100 200 200]} )
%
%    fps  - fames per second to display
%    rect - target on screen (possibly not applicable to all stimuli)
%    roundframes - 0/1 should # refreshes between frames be constant or
%          rounded so that fps is more accurate?
%    depth - image depth (e.g., 8 for 256 colors) {presently must be 8}
%    forceMovie - force use of movie rather than color lookup table animation
%                 (this must be set before loading)
%    BGpretime - amount of time background should be present before playing
%                stim
%    BGposttime - amount of time background should be present after playing stim
%    numFrames  - number of frames to show
%
%   Questions to vanhoosr@brandeis.edu


  % presently unsupported parameters
  %  lastframetime - amount of time last frame should be shown before reverting
  %              to background {presently not supported}
  %  absStartTime - the absolute time when we should start to play the movie
  %              (use <0 for immediately) {not implemented yet}
  %
  % 

if nargin == 0, 
	temp_dp_p = {'fps',1,'rect',[0 0 1 1],'frames',1};
   	df = displayprefs(temp_dp_p);
	return;
end;

params = struct( ...
	'fps',		0,		...
	'rect',		[0 0 0 0],	...
	'roundFrames',	1,		...
	'forceMovie',	0,		...
	'depth',	8,		...
	'absStartTime',	-1,		...
	'BGpretime',	0,		...
	'BGposttime',	0,		...
	'lastframetime',0,		...
	'frames',	0		...
				 );
				 
params.defaults = parameters;
				 
[good,errormsg] = verify(parameters);

if good,
	for i=1:2:length(parameters),
		eval(['params.' parameters{i} ' = parameters{i+1};']);
	end;
else, error(['Could not create displayPrefs: ' errormsg]);
end;
	
df = class(params,'displayprefs');
