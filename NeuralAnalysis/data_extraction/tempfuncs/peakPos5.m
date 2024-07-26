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
pos;
if 1,
tic,
if length(find(pos==4202)),disp('it does.'); end;
% remove peaks that aren't the local maximum in a window of +/- skip; if
% there are peaks too close together, take the maximum one
% one if they are exactly equal
% this is matlab esoterica at its best
l0=length(pos)+1;
while(length(pos)>0)&(length(pos)<l0), % since only adjacent comparisons are
 l0 = length(pos),                     % made, we must iterate, at most skip x's
 % look forward and backward, marking which points are too close together
 rdifA = (-(diff(pos(length(pos):-1:1))))<=skip;
 rdifA = [0;rdifA(length(rdifA):-1:1)];
 difA  = [diff(pos)<=skip;0];
 A = rdifA|difA;A1=rdifA;A2=A1;
 A1(find(rdifA))=1; A1(find(difA))=1; A1i = find(A1);
 A2(find(rdifA))=1; A2(find(difA))=0; A2 = [0;A2(1:end-1)];
 % A1 is 0/1 <=> point i is too close to either i-1 or i+1
 % A2 is 0/1 <=> point i is end of 'run' of points too close together, shifted
 %               by one index
 % now we're going to make a vector with all of the peaks which are too close
 % together, sticking a zero between runs.  We do this by making a big vector
 % of zeros (x2), and sticking in the values
 x2= zeros(sum(A1)+sum(A2),1); % make a vector to store values in runs
 x2i=(cumsum(A1+A2).*A);x2ii=find(x2i);    pos2 = x2;
 x2(x2i(x2ii)) = x(pos(A1i));x2=[0;x2;0]; % pad with zeros for local max op
 pos2(x2i(x2ii)) = pos(A1i);  % for inverse mapping
 difB = diff(x2); % find local max
 p=difB>0; n=difB<=0; h=p(1:end-1).*n(2:end); hi=find(h);
 % replace pos with old pos not too close and the maximum of the ones which are
 pos = sort([pos(find(1-A));pos2(hi)]);
if length(find(pos==4202)),disp('it does2.'); end;
end;
end;

if 0,
tic,
for k=1:length(pos)
        st = max(1,pos(k) - skip);
        ed = min(pos(k) + skip, length(x));

        if ~( all(x(st:pos(k)-1) < x(pos(k)) ) )
                pos(k) = nan;% k,
        elseif  ~( all(x(pos(k)+1:ed) < x(pos(k)) ) )
                pos(k) = nan;% k,
        end
end
end
toc;

postmp = pos(~isnan(pos));
length(pos),
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
