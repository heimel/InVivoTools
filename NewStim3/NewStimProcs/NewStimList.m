function g = NewStimList

% Part of the NewStim package
%
%  LIST = NEWSTIMLIST
%
%  Returns a list of strings containing the names of stimulus objects.
%
%  See also:  CELLSTR
%
%  Questions to vanhoosr@brandeis.edu

NewStimGlobals;
g = NewStimStimList;

%g = { 'stimulus', 'stochasticgridstim', 'blinkingstim', ...
%	'periodicstim' 'polygonstim','centersurroundstim','shapemoviestim','wavsound','compose_ca'};
