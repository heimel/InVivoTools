function NewStimScriptListAdd(string)

% NewStimScriptListAdd - Add a script type to the list of known script types
%
%  NEWSTIMSCRIPTLISTADD(STRING)
%
%    Adds a script type to the NewStim package's list of known stimscript types.

NewStimGlobals;

NewStimStimScriptList = unique(cat(1,NewStimStimScriptList,{string}));
