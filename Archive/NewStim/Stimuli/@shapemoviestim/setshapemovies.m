function sms = setshapemovies(thesms, shapemovies)

%  SETSHAPEMOVIES  - Sets shapemovies for a shapemoviestim object
%
%  NEWSMS = SETSHAPEMOVIES(THESMS,SHAPEMOVIES)
%
%  Sets shapemovies for the SHAPEMOVIESTIM object THESMS.  Preserves loaded
%  status.
%
%  See also:  addshapemovies, getshapemovies

l = isloaded(thesms);
if l, thesms = unloadstim(thesms); end;

thesms.nframemovies = [];
thesms = addshapemovies(thesms,shapemovies);

if l, thesms = loadstim(thesms); end;

sms = thesms;
