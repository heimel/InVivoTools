function [fcls,fcsp] = cl_mergeOne(sc,grcls,grcsp,nv)
% [fcls,fcsp] = cl_mergeOne(grcls,grcsp,nv,sigma)
% grcls: group cls'
% grcsp: group csp

%global gcl;
fcls = grcls;
fcsp = grcsp;
mrgTh= sc.SCparams.mrgTh;
cTh  = sc.SCparams.cTh;
mrgTh2=sc.SCparams.mrgTh2;

% threshold
% th = 1+sigma*sqrt(2/size(grcsp,1));
% th = gcl.mrgTh;

% calculate distance mat
y = x2_calcDistMat(grcsp,nv);

% remove self connection
y = y + diag(inf*ones(size(y,1),1));

% find minimum
minv = min(min(y));

if minv >= mrgTh % do nothing
	return;
end

% minv < th -> find pair
mini = find(y==minv);
[i,j] = ind2sub(size(y),mini);
i = i(1);
j = j(1);

% calc similarity
ni = sqrt(grcsp(:,i)'*grcsp(:,i));
nj = sqrt(grcsp(:,j)'*grcsp(:,j));
cor = grcsp(:,i)'*grcsp(:,j)/(ni*nj);

if (cor <= cTh) & (minv > mrgTh2)
	return;
end

% merge grcls(i) & grcls(j)
ni = length(grcls(i).idx);
nj = length(grcls(j).idx);
tmpidx = [grcls(i).idx grcls(j).idx];
tmpcsp = (ni*grcsp(:,i) + nj*grcsp(:,j))/(ni+nj);

fcls(i).idx = tmpidx;
fcls(j) = [];

fcsp(:,i) = tmpcsp;
fcsp(:,j) = [];
