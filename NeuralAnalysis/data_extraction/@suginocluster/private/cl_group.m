function groups = cl_group(sc,gcsp,nv)
% groups = cl_group(gcsp,nv)
% groups : struct, field:'clsids' = index to clusters
%global gcl;
%global glb;
%dth = gcl.grS;
%cTh = gcl.cTh;
%dth2 = gcl.grS2;
%cTh2 = gcl.cTh2;
dth = sc.SCparams.dth;
cTh = sc.SCparams.cTh;
dth2 = sc.SCparams.dth2;
cTh2 = sc.SCparams.cTh2;

% normalized distance
y = x2_calcDistMat(gcsp,nv);
N = size(gcsp,1);
% th = 1 + sigma*sqrt(2/N);

yc = x2_calcCorMat(gcsp);

% connected components
cm = (y < dth).*(yc > cTh) + (y < dth2) + (yc > cTh2);
cm = cm > 0;
cm1 = cm;
cm2 = (cm1*cm > 0);
count=1;
while (any(any((cm1 ~= cm2))) & count <= N)
	cm1 = cm2;
	cm2 = (cm1*cm > 0);
	count = count + 1;
end

%if glb.display > 1
%	figure;
%	subplot(2,2,1);
%	plotmat(cm2);
%	subplot(2,2,2);
%	cl_plotConnection(cm);
%	subplot(2,2,3);
%	plotmat(y);
%	subplot(2,2,4);
%	plotmat(yc);
%end

% find group
left = 1:size(y,1);
c = 1;
while length(left) > 0
	tmp = find(cm2(left(1),:) == 1);
	groups(c).clsids = tmp;
	c = c+1;
	left = setdiff(left,tmp);
end
