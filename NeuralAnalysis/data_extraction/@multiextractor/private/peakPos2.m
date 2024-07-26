function pos = peakPos2(x, th, skip, merge)
% x: column vector

%t0=clock;
% find 1pt peak
y=(x>th).*x;
dif = diff( y );
p = dif >  0; n = dif <= 0;% g = [0;dif < 0]; q = [y==0];
h = p(1:end-1).*n(2:end);
l = (y(1:end-1)>0).*(y(2:end)==0);
%etime(clock,t0),t1=clock;
pos = find(h == 1) + 1;
psn = find(l == 1) + 1;
%etime(clock,t1),t2=clock;
if isempty(pos), return; end;

 % remove spurious points by requiring points fall below threshold

if ~isempty(psn) if psn(1)<pos(1), psn = psn(2:end); end;
                 if psn(end)<pos(1),psn(end+1)=pos(end)+1; end;
end;
l = length(psn);
while (length(pos)~=l),
  [maxmin,iii]=sort([pos;psn]); 
  posi = find(iii<=length(pos));psni=find(iii>length(pos));
  nv = zeros(size(maxmin));
  nv(posi) = x(pos); nv(psni) = 0; nv = [0;nv]; % so first point will be max
  dif = diff( nv );
  p = dif >  0; n = dif <= 0;
  h = p(1:end-1).*n(2:end);
  posii = find(h==1);
  npos = maxmin(posii);
  %length(npos),
  pos = npos;
end;
%etime(clock,t2),

postmp = pos;
if isempty(postmp)
        pos = [];
        return;
end

if merge>0,
  % process near true peak
  dposi = find(diff(postmp) > merge)+1; % find sample times of peaks farther
                                      % apart than merge samples
  if size(dposi,2)>size(dposi,1), dposi = dposi'; end;
  dposi = [1;dposi;length(postmp)+1];     % start of groups, last one is a dummy

  N = length(dposi)-1;
  pos = zeros(N,1);
  for k=1:N
        pos(k)=postmp(dposi(k+1)-1);%round(mean(postmp(dposi(k):dposi(k+1)-1)));
  end
  % puts either single spike or mean time of associated spikes
else, pos = postmp;
end;
