function [A] = stimulus(parameters, OLDSTIM)

%  NewStim package:  STIMULUS
%
%  THESTIM = STIMULUS(PARAMETERS)
%
%  Creates a new stimulus object.  The stimulus object is not very useful in
%  itself, but it is the parent of all stimulus objects.  PARAMETERS can
%  contain anything because it is a dummy variable as MATLAB does not appear to
%  allow contstructors which take no arguments.  If PARAMETERS is the string
%  'graphical', then the user is asked graphically to input all of the
%  parameters.  Since there are no parameters for STIMULUS, this does nothing,
%  but many children of the STIMULUS object have parameters associated with
%  them.  One may also use 'default' as the argument, in which case the default
%  parameter values are assigned (again, since stimulus has no parameters,
%  this does nothing, but it is useful when creating children of stimulus).
%
%  Stimulus implements a number of useful functions.  See the help for those
%  functions for more information.
%
%  T = DURATION(STIM):
%  DP = GETDISPLAYPREFS(STIM)
%  DS = GETDISPLAYSTRUCT(STIM)
%  L = ISLOADED(STIM)
%  LOADEDSTIM = LOADSTIM(STIM)
%  NEWSTIM = SETDISPLAYPREFS(STIM,DP)
%  NEWSTIM = SETDISPLAYSTRUCT(STIM,DS)
%  NEWSTIM = STRIP(STIM)
%  UNLOADEDSTIM = UNLOADSTIM(STIM)

if nargin==0,
    A = stimulus(5);
    return;
end;

if nargin>1,
    theoldstim = OLDSTIM;
else
    theoldstim = [];
end;

if ischar(parameters),
    if (strcmp(parameters,'graphical')),
        % does nothing since no real parameters for stimulus
    elseif (strcmp(parameters,'default')),
        % does nothing again since no real parameters for stimulus
    end
    if ~isempty(theoldstim)
        stimparams = getparameters(theoldstim);
    end
else
    % we would check parameters here, but there are no parameters to
    % check for stimulus class
    % pass on anything the user has specified
    if isstruct(parameters)
        stimparams = parameters;
    else
        stimparams = [];
    end
end

data = struct('loaded', 0, 'displaystruct', [], 'displayprefs', []);
NewStimListAdd('stimulus');
A = class(data,'stimulus');
