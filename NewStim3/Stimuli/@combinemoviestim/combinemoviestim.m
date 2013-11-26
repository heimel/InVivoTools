function [cms] = combinemoviestim(CM,OLDSTIM)

% COMBINEMOVIESTIM - Combine a script of movie stims into 1 stim
%
%  THECMS = COMBINEMOVIESTIM(PARAMETERS)
%
%  This stimulus type takes a STIMSCRIPT as one of its parameters, and combines
%  any stimuli with a DisplayType of 'Movie' into a single stimulus. All interstimulus
%  time is chopped away.  This stimulus type is particularly useful for running stimuli
%  in quick succession without intervening blank frames that are normally present.
%  
%  PARAMETERS can either be the string 'graphical' (which will prompt the user
%  to enter all of the parameter values), the string 'default' (which will use
%  default parameter values), or a structure.  When using 'graphical', one may
%  also use
%
%  THECMS = COMBINEMOVIESTIM('graphical',OLDCMS)
%
%  where OLDCMS is a previously created COMBINEMOVIESIM object.  This will set the
%  default parameter values to those of OLDCMS.
%
%  If passing a structure, the structure should have the following fields:
%  (dimensions of parameters are given as [M N]; fields are case-sensitive):
%
%  [1x4] script         -  The script containing the stimuli to combine
%  [cell] dispprefs     -  Sets displayprefs fields, or use {} for defaults.
%
%  See also:  STIMSCRIPT

NewStimListAdd('combinemoviestim');

if nargin==0,
	cms = combinemoviestim('default');
	return;
end;

default_p = struct('script',periodicscript('default'));
default_p.dispprefs = {};

cms = [];
finish = 1;

if nargin==1, oldstim=[]; else, oldstim = OLDSTIM; end;

if ischar(CM),
	if strcmp(CM,'graphical'),
		if isempty(oldstim),
			finish = 0;
			[cms,cancelled] = edit_graphical(combinemoviestim('default')); % incomplete
			if cancelled, cms = []; end;
		else,
			[cms,cancelled] = edit_graphical(oldstim); % incomplete
			if cancelled, cms = oldstim; end;
		end;
	elseif strcmp(CM,'default')|strcmp(CM,''),
		CM = [];
	else,
		error('Unknown string input to compose_ca.');
	end;
else,  % they are parameters
end;

if finish,
	s = stimulus(5);
	cms = class(struct('CMp',[]),'combinemoviestim',s);
	cms = setparameters(cms,CM);
end;
