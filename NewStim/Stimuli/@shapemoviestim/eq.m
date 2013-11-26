function b = eq(x,y)

% STIMULUS/EQ 
%
% Reports two stimuli are the same if their parameters and class types are
% the same.  Note that it is possible for them to have different displayprefs.


%dp1=getdisplayprefs(x);dp2=getdisplayprefs(y);
%b=(dp1==dp2)&(getparameters(x)==getparameters(y))&strcmp(class(x),class(y));
b=(getparameters(x)==getparameters(y))&strcmp(class(x),class(y));

smx=getshapemovies(x);
smy=getshapemovies(y);

b=b&(smx==smy);
