function pos = peakPos2(x, th, skip, merge)
% x: column vector


% find 1pt peak
dif = diff( (x > th).*x );
p = dif >  0;
n = dif <= 0;
h = p(1:end-1).*n(2:end);

pos = find(h == 1) + 1;

if isempty(pos)
        return;
end

  % removes peaks that aren't the local maximum in a window of +/- skip
% skip pts peak: remove supurious peaks
 % remove for-loop here, use repmat and any
for k=1:length(pos)
        st = max(1,pos(k) - skip);
        ed = min(pos(k) + skip, length(x));

        if ~( all(x(st:pos(k)-1) < x(pos(k)) ) )
                pos(k) = nan;
        elseif  ~( all(x(pos(k)+1:ed) < x(pos(k)) ) )
                pos(k) = nan;
        end
end

postmp = pos(~isnan(pos));
if isempty(postmp)
        pos = [];
        return;
end

% process near true peak
dposi = find(diff(postmp) > merge)+1; % find sample times of peaks farther
                                      % apart than merge samples
if size(dposi,2)>size(dposi,1), dposi = dposi'; end;
dposi = [1;dposi;length(postmp)+1];     % start of groups, last one is a dummy

N = length(dposi)-1;
pos = zeros(N,1);
for k=1:N
        pos(k) = round(mean(postmp(dposi(k):dposi(k+1)-1)));
end
  % puts either single spike or mean time of overlaped spikes ?

