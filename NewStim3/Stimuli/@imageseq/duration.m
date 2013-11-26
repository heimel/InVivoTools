function T = duration(S)

% DURATION- duration of imageseq
%
% T = DURATION(IMAGESEQ)
%
% returns the duration of the image sequence stimulus
% in seconds

p = getparameters(S);

if ~isloaded(S),
	T = p.number_of_images * p.fps+duration(S.stimulus)
else,
	df = struct(getDisplayPrefs(S));
	T = length(df.frames)*df.fps + duration(S.stimulus);
end;

