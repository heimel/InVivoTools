function [cls,ucls] = cl_recursive2(fea,idx,ns,maxND,thN,sigma)
% [cls,ucls] = cl_recursive2(fea,idx,ns,maxND,thN,sigma)

global gcl;
 % gcl.edS = 1
if sigma < 1 % gcl.edS
	cls.idx = idx;
	ucls = [];
	return;
end

ucls = [];

[cls1,ucls1] = cl_dcluster2(fea(idx,:),idx,ns,maxND,thN,sigma);

if isempty(cls1)
	cls = [];
	ucls = ucls1;
	return;
end

c = 1;
if sigma >= 2
	for i=1:length(cls1)
		[clstmp,uclstmp] = cl_recursive2(fea,cls1(i).idx,ns,maxND,thN,sigma-1);
		if (isempty(clstmp))
			clstmp = cls1(i);
			uclstmp = [];
		end
		n = length(clstmp);
		cls(c:(c+n-1)) = clstmp;
		c = c+n;
		ucls = [ucls uclstmp];
	end
else
	cls = cls1;
	ucls = ucls1;
end
