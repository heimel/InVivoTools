function z = findcovdata(x, th, skip)

% Z = FINDCOVDATA(X, TH, SKIP)
%
%  Identify points in data X above threshold TH, return in Z the index of all
%  points not within SKIP samples.
p=find(x>th);
d=find(diff(p)>1);
d=[1;d;d+1;];
sk=-skip:skip;
s=repmat(sk,length(d),1)+repmat(p(d),1,length(sk));
s=reshape(s,1,prod(size(s)));
s=s(find(s>0&s<=length(x)));
z=x;
z(p)=NaN;
z(s)=NaN;
z=(find(~isnan(z)));
