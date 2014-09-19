function newS = strip (S);

%  newS = strip (S)
%
%  Strip removes the displayStruct object and sets the stimulus to 'unloaded'
%  status without releasing the memory held by the displayStruct.  It is useful
%  for saving a loaded object that one wants to keep loaded in memory:
%
%  newS = strip(S);
%  save filename newS
%  (now S is still usable as a loaded stim)
%
%  The alternate way would be:
%  newS = unload(S);
%  save filename newS
%  (now S's structures have been unloaded from memory, so it must be reloaded.)
%
%                                   Questions?  vanhoosr@brandeis.edu

newS = S;
newS.displaystruct = [];

newS.loaded = 0;

