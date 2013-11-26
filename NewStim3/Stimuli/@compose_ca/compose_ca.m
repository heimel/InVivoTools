function [cca] = compose_ca(CP,OLDSTIM)

% NewStim package:  COMPOSE_CA  - Compose color table animation based stims
%
%  THECCA = COMPOSE_CA(PARAMETERS)
%
%  A stim that allows compositions of color table animation-based stimuli.
%  One can add stimuli to the COMPOSE_CA object to be composed, and these
%  stimuli are displayed on the rectangle provided as a parameter to
%  the COMPOSE_CA object. 
%  
%  Note that only stimuli that use color table animation and the standard
%  display procedure can be composed.  The color table is created according
%  to the description in the SETCLUTINDEX file.  Not all color table animation
%  stimuli are appropriate to be composed together; only those stimuli whose color
%  tables are a 'continuous' distribution of values will look correct.  [For
%  example, a centersurroundstim, which has 2 colors, and a grating stim, which has
%  1..255 continuous color values might not display appropriately
%  if composed.]  No warning will be issued in the event of an
%  'inappropriate' composition.
%
%  PARAMETERS can either be the string 'graphical' (which will prompt the user
%  to enter all of the parameter values), the string 'default' (which will use
%  default parameter values), or a structure.  When using 'graphical', one may
%  also use
%
%  THECCA = COMPOSE_CA('graphical',OLDCCA)
%
%  where THECCA is a previously created COMPOSE_CA object.  This will set the
%  default parameter values to those of OLDCCA.
%
%  If passing a structure, the structure should have the following fields:
%  (dimensions of parameters are given as [M N]; fields are case-sensitive):
%
%  [1x4] rect           - Location of the stimulus on background window
%                         [top_x top_y bottom_x bottom_y]
%                         (This should be be big enough to cover the
%                          'rect' fields of the stimuli to be composed
%                          or they won't show up)
% [cell] dispprefs      - Sets displayprefs fields, or use {} for defaults.
%
%  See also:  PERIODICSTIM, STIMULUS

NewStimListAdd('compose_ca');

if nargin==0,
	cca = compose_ca('default');
	return;
end;


   default_p = struct('rect',[0 0 500 500]);
   default_p.dispprefs = {};

cca = [];
finish = 1;

if nargin==1, oldstim=[]; else, oldstim = OLDSTIM; end;

if ischar(CP),
	if strcmp(CP,'graphical'),
		if isempty(oldstim),
			finish = 0;
			[cca,cancelled] = edit_graphical(compose_ca('default'));
			if cancelled, cca = []; end;
		else,
			[cca,cancelled] = edit_graphical(oldstim);
			if cancelled, cca = oldstim; end;
		end;
	elseif strcmp(CP,'default')|strcmp(CP,''),
		CP = [];
	else,
		error('Unknown string input to compose_ca.');
	end;
else,  % they are parameters
end;

if finish,
	s = stimulus(5);
	cca = class(struct('CCp',[],'stimlist',[],'clutindex',[]),'compose_ca',s);
	cca = setparameters(cca,CP);
end;
