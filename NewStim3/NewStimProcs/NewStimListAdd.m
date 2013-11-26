function NewStimListAdd(string)

% NewStimListAdd - Add a stimulus type to the list of known stimulus types
%
%  NEWSTIMLISTADD(STRING)
%
%    Adds a stimulus type to the NewStim package's list of known stimulus types.

NewStimGlobals;

NewStimStimList = unique(cat(1,NewStimStimList,{string}));
