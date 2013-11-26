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
  if ~haspsychtbox|isempty(StimWindowRefresh),
        preBG = df.BGpretime;
        if isnan(preBG)
            preBG = 0;
        end
        postBG = df.BGposttime;
        if isnan(postBG)
            postBG = 0;
        end
        t = preBG + postBG;
  else,
        preBG = fix(df.BGpretime*StimWindowRefresh)/StimWindowRefresh;
        if isnan(preBG)
            preBG = 0;
        end
        postBG =fix(df.BGposttime*StimWindowRefresh)/StimWindowRefresh;
        if isnan(postBG)
            postBG = 0;
        end
        t = preBG + postBG;
  end;
else, t = 0;
end;
