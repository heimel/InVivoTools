function t = duration(S)

%  T = DURATION(S)
%
%  Estimates the amount of time it will take to display the stimulus S.  This
%  result includes the settings given in the displayPrefs.  The error in
%  this estimate should be +/-1 or 2 screen refreshes due to time to load the
%  next stimulus and depending upon whether the rounding option is selected
%  for the displayprefs.
%
%  Note that this function requires the StimWindowRefresh to be available.
%  Thus, it will give 0 if run on a non-Macintosh.
%
%                                Questions?  vanhoosr@brandeis.edu

DF = getdisplayprefs(S);
if ~isempty(DF),
  df = struct(DF);
  StimWindowGlobals;
  if isnan(df.BGpretime)
	  df.BGpretime = 0;
  end
  if isnan(df.BGposttime)
	  df.BGposttime = 0;
  end
  
  if ~haspsychtbox|isempty(StimWindowRefresh),
        t = df.BGpretime+df.BGposttime;
  else,
        preBG = fix(df.BGpretime*StimWindowRefresh)/StimWindowRefresh;
        postBG =fix(df.BGposttime*StimWindowRefresh)/StimWindowRefresh;
        t = preBG + postBG;
  end;
else, t = 0;
end;
