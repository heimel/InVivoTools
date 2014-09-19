function newSS = strip(S)
%
%  NEWSTIMSCRIPT = STRIP(STIMSCRIPT)
%
%  This function strips all of the stimuli contained in the stimscript
%  STIMSCRIPT.  See help for the stimulus/strip function for more information,
%  but briefly this allows a copy of a loaded stimscript to be saved without
%  the potentially large displayStruct, while keeping the original stimscript
%  loaded.
%                                 Questions?  vanhoosr@brandeis.edu

for i=1:numStims(S), S.Stims{i} = strip(S.Stims{i}); end;
newSS = S;
