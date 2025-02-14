function cksds = getcksds()
%GETCKSDS gets cksdirstruct from RunExperiment window
%
%  CKSDS = GETCKSDS ()
%
%  Alexander Heimel (heimel@brandeis.edu)
%
  cksds = [];
  z = geteditor('RunExperiment');
  if ~isempty(z),
    udre = get(z,'userdata');
    cksds = udre.cksds;
  end;
