function [rcg] = rcgratingstim(RC,OLDSTIM)

% RCGRATINGSTIM - Combine a script of movie stims into 1 stim
%
%  THERCG = RCGRATINGSTIM(PARAMETERS)
%
%  This stimulus type takes a PERIODICSTIM as one of its parameters, and produces
%  a series of flashed grating stimuli that vary as specified in ORIENTATIONS, 
%  SPATIALFREQUENCIES, and SPATIALPHASES.  They are presented with a duration equal to DUR.
%
%  PARAMETERS should contain (all lower case):
%     BASEPC                :   A PERIODICSTIM upon which gratings are based
%                                (specifys image type, color etc)
%     REPS                  :   The number of times to repeat each grating
%     ORDER                 :   0/1 (sequential or random order)
%     PAUSEBETWEENREPS      :   Number of seconds to pause between trials
%     DUR                   :   The number of seconds to pause between flashed
%                           :          frames
%     ORIENTATIONS          :   Orientations to show
%     SPATIALFREQUENCIES:   :   SFs to show
%     SPATIALPHASES         :   Phases to show
%     RANDSTATE             :   Sets the state of the random number generator
%     DISPPREFS             :   Display preferences
%
%   The user can specify an optional parameter TEST:
%     TEST                  :   0/1 ; if 1, then only the first grating will be
%                               drawn, in order to more easily test display timing
%
%
%  PARAMETERS can either be the string 'graphical' (which will prompt the user
%  to enter all of the parameter values), the string 'default' (which will use
%  default parameter values), or the structure above.  When using 'graphical', one may
%  also use
%
%  THERCS = RCGRATINGSTIM('graphical',OLDRCS)
%
%  where OLDRCS is a previously created RCGRATINGSIM object.  This will set the
%  default parameter values to those of OLDRCS.
%
%  See also:  PERIODICSTIM, STIMSCRIPT

NewStimListAdd('rcgratingstim');

if nargin==0,
	rcg = rcgratingstim('default');
	return;
end;

rcg = [];
finish = 1;

if nargin==1, oldstim=[]; else, oldstim = OLDSTIM; end;

if ischar(RC),
	if strcmp(RC,'graphical'),
		if isempty(oldstim),
			finish = 0;
			[rcg,cancelled] = edit_graphical(rcgratingstim('default')); % incomplete
			if cancelled, rcg = []; end;
		else,
			[rcg,cancelled] = edit_graphical(oldstim); % incomplete
			if cancelled, rcg = oldstim; end;
		end;
	elseif strcmp(RC,'default')|strcmp(RC,''),
		RC = [];
	else,
		error('Unknown string input to compose_ca.');
	end;
else,  % they are parameters
end;

if finish,
	s = stimulus(5);
	rcg = class(struct('RCGp',[]),'rcgratingstim',s);
	rcg = setparameters(rcg,RC);
end;
