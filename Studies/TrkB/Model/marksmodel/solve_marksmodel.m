function solve_marksmodel(contrasts)

if nargin<1
	contrasts=[];
end

I0=0;
P0=1;

if isempty(contrasts)
	contrasts=linspace(0,1,10);
end

time=[];
rm=[];
for contrast=contrasts
	[t,I]=ode23(@marks_function,[0 200],[I0 P0],[],contrast,P0);
	[Im,ind_t]=max(I(:,1));
	rm(end+1)=markfi(Im);
	time(end+1)=t(ind_t);
end

figure
if length(contrasts)>1
	subplot(1,2,1)
	plot(contrasts,rm);
	subplot(1,2,2)
	plot(contrasts(2:end),time(2:end));
	axis([0 1 0 150])
else
	plot(t,I)
end



