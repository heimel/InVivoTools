function frames = getshapeframes(sms)

%  GETSHAPEFRAMES - Get first frame indicies from shapemoviestim
%
%  FRAMES = GETSHAPEFRAMES(SMS)
%
%  Returns the indicies of the first frames of shape movies for the
%  SHAPEMOVIESTIM object SMS.
%
%  See also:  SHAPEMOVIESTIM, LOADSTIM

dp = struct(getdisplayprefs(sms));
frames = []; gg=find(dp.frames==1);
if ~isempty(gg), gg_ = find(diff(gg)>1); frames = gg(gg_)+1; end;
