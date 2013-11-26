function [A] = blank(parameters, OLDSTIM)

%  NewStim package:  BLANK
%  
%  THESTIM = BLANK(PARAMETERS)
%
%  Creates a blank stimulus object.  It cannot be used for display, but it
%  exists solely for the purpose of allowing "foreign" stimuli to be analyzed
%  using routines that know how to analyze NewStim stimuli.
%
%  The user can specify any parameters; these parameters are simply held
%  by the stimulus so it can be retreived with getparameters.
%
%  There is only one required parameter field, dispprefs, that describes
%  the display preferences for this stim.
 
NewStimListAdd('blank');
if nargin==0,
	A = blank('default');
	return;
end;

if nargin>1, theoldstim = OLDSTIM; else, theoldstim = []; end;

if ischar(parameters),
	if (strcmp(parameters,'graphical')),
		% does nothing since no real parameters for stimulus
		stimparams.dispprefs = {}; 
	elseif (strcmp(parameters,'default')),
		% does nothing again since no real parameters for stimulus
		stimparams.dispprefs = {}; 
        end;
	if ~isempty(theoldstim), stimparams = getparameters(theoldstim); end;
else,
	% check to make sure there is a dispprefs field
	% pass on anything the user has specified
	if strcmp(class(parameters),'struct'),
		stimparams = parameters;
		if ~isfield(parameters,'dispprefs'),
			error(['Parameter dispprefs is required for stimulus class blank.']);
		end;
	else, stimparams.dispprefs = {};
	end;
end;

data = struct('loaded', 0, 'displaystruct', [], 'displayprefs', [],...
		'params',stimparams);

s = stimulus(5);

NewStimListAdd('blank');

A = class(data,'blank',s);

A = setdisplayprefs(A,displayprefs(stimparams.dispprefs));
