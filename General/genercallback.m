function genercallback

%  GENERCALLBACK - Generic callback function for user interfaces
%
%  Attempts to call a function with the same name as the 'Tag' field in the
%  figure handle with the callback object as the argument.
%
%  Example:  Suppose there is a button pressed in Figure 1, and the 'Tag'
%  field of Figure 1 is 'myFunnyPanel'.  Then, the generic callback calls
%  the function 'myFunnyPanel(gcbo)';

h1 = gcbf;
t = get(h1,'Tag');
eval([t '(gcbo);']);
