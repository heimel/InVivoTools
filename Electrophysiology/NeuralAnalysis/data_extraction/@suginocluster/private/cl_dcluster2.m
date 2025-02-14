function [cls,ucls]=cl_dcluster2(fea,idx,nsigma,maxNumDiv,thN,sigma)
% [cls,ucls]=cl_dcluster2(fea,idx,nsigma,maxNumDiv,thN, sigma)
% dcluster: density clustering 
% cls: struct array cls.idx contains index to fea
% ucls: index to unclustered fea
% fea: feature vector (N x 4)
% idx: target index to fea (M x 1), M <= N
% nsigma: noise sigma
% maxnumDiv: 


global f;
global ff;
global K;

% x = fea(idx,:);
make_density2(fea,maxNumDiv,nsigma,sigma);
ff = zeros(size(f));

ci = do_cluster2(size(fea,1));
[ve,ne] = count_class(ci,thN);

% clear global f;
clear global ff;
clear global K;
cls = [];

for i=1:length(ve)
	cls(i).idx = idx(find(ci==ve(i)));
	s = ['cluster' num2str(i) ': #' num2str(length(cls(i).idx))];
	disp(s);
end

if (~isempty(cls))
	ucls = setdiff(idx, [cls.idx]);
else
	ucls = idx;
end

s = ['unclustered:' num2str(length(ucls))];
disp(s);
