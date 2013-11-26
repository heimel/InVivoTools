function t = duration(cms)

% DURATION - Duration of a COMBINEMOVIESTIM
%
%  T = DURATION(CMS)
%
%  Returns the expected duration of the COMBINEMOVIESTIM stimulus CMS.
%
%  See also:  COMBINEMOVIESTIM, STIMULUS/DURATION

t = 0;

p = getparameters(cms);

do = getDisplayOrder(p.script);

stimdurations = -Inf * ones(1,numStims(p.script));

for i=1:length(do),
	if isinf(stimdurations(do(i))), % we haven't calculated this yet
		s = get(p.script,do(i));
		sstruct = struct(s);
		basestim = sstruct.stimulus;
		% remove pre/post interstimulus time
		stimdurations(do(i)) = duration(s) - duration(basestim);
	end;
	t = t + stimdurations(do(i));
end;

