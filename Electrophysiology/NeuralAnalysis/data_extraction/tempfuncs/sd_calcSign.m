function s = sd_calcSign(ex,pp,skip,ns)

% probably can optimize

st = max(1,pp-skip);
ed = min(length(ex),pp+skip);
curv = ex(st,:)+ex(ed,:)-2*ex(pp,:);
[mv,mi] = max(abs(curv));
if mv > 3*ns
	s = sign(ex(pp,mi));
else
	[mv,mi] = max(abs(ex(pp,:)));
	s = sign(ex(pp,mi));
end


% s = sign(mean(ex(pp,:)));
