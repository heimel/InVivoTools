function pos = peakPos2(x, th, skip, merge)
% x: column vector


% find 1pt peak
y = (x > th).*x;
dif = diff( y );
p = dif >  0; n = dif <= 0; g = [0;dif < 0]; q = [y==0];
h = p(1:end-1).*n(2:end);
l = q.*g;

pos = find(h == 1) + 1;
psn = find(l == 1) ;

if isempty(pos), return; end;

 % remove spurious points by requiring points fall below threshold

if ~isempty(psn) if psn(1)<pos(1), psn = psn(2:end); end; end;
l = length(pos)+1;
while (l-length(pos)>0),
  l = length(pos);
  [maxmin,iii]=sort([pos;psn]); 
  posi = find(iii<=length(pos));psni=find(iii>length(pos));
  nv = zeros(size(maxmin));
  nv(posi) = x(pos); nv(psni) = 0; nv = [0;nv]; % so first point will be max
  dif = diff( nv );
  p = dif >  0; n = dif <= 0;
  h = p(1:end-1).*n(2:end);
  posii = find(h==1);
  npos = maxmin(posii);
  length(npos),
  pos = npos;
end;

%ppos = pos(  find((pos>skip)&(pos<=(length(x)-skip))  ));
%if isempty(ppos)
%        return;
%end

%if size(ppos,2)>size(ppos,1), ppos = ppos'; end;
%if ~(isempty(ppos)&~isempty(pos)),
%if 1,
%tic,
%pts = -skip:skip; pt0=skip+1;
%[M,I] = max( x(repmat(ppos,1,length(pts))+repmat(pts,length(ppos),1))');
%pos = ppos(find(I==pt0));
%end;
%else,
%if 0,
%tic,
%  for k=1:length(pos)
%        st = max(1,pos(k) - skip);
%        ed = min(pos(k) + skip, length(x));
%
%        if ~( all(x(st:pos(k)-1) < x(pos(k)) ) )
%                pos(k) = nan;% k,
%        elseif  ~( all(x(pos(k)+1:ed) < x(pos(k)) ) )
%                pos(k) = nan;% k,
%        end
%  end
%end
%toc;

postmp = pos;
%postmp = pos(~isnan(pos));
%length(postmp);
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
