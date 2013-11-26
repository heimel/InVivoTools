function g = NewStimScriptList

% Part of the NewStim package
%
%  LIST = NEWSTIMSCRIPTLIST
%
%  Returns a list of strings containing the names of stimscript objects.
%
%  See also:  CELLSTR
%
%  Questions to vanhoosr@brandeis.edu

NewStimGlobals;
g = NewStimStimScriptList;
%g = { 'stimscript', 'periodicscript' };
