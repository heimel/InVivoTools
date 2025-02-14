function [cls2,gcsp2,ovl] = cl_findOverlapped(sc,cls1,gcsp1,nv,th,maxN)
% [cls2,gcsp2,ovl] = cl_findOverlapped(cls1,gcsp1,nv,sigma,maxN)

L = size(gcsp1,1);
noise = reshape(ones(L/4,1)*nv,L,1);
% th = 1+sigma*sqrt(2/L);

ovl = [];

N = size(gcsp1,2);
n = zeros(N,1);
for i=1:N
	n(i) = length(cls1(i).idx);
end

target = find(n <= maxN);
I = setdiff(1:N, target);

c = 1;
for it = 1:length(target)
	t = target(it);
	x2 = nan*ones(N,N);
	for ii = 1:length(I)
		i = I(ii);
		J = I(find(I>i));
		for ij=1:length(J)
			j = J(ij);
			x2tmp = mean( (gcsp1(:,t)-gcsp1(:,i)-gcsp1(:,j)).^2./noise );
% 			x2(i,j) = x2tmp/(1/n(t)+1/n(i)+1/n(j));
			x2(i,j) = x2tmp;
		end
	end
	x2min = min(min(x2));
	if x2min < th
		mini = find(x2 == x2min);
		[i,j] = ind2sub(size(x2),mini);
		ovl(c).t = t;
		ovl(c).i = i(1);
		ovl(c).j = j(1);
		ovl(c).x2 = x2min;
		ovl(c)
		c = c+1;
	end
end

% remove overlapped
I = 1:N;
if ~isempty(ovl)
	I = setdiff(I,[ovl.t]);
end

cls2 = cls1(I);
gcsp2 = gcsp1(:,I);

% for i = 1:length(ovl)
% 	ovl(i).i = find(I == ovl(i).i);
% 	ovl(i).j = find(I == ovl(i).j);
% end
