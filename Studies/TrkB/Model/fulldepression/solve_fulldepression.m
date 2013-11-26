function [rm,contrasts]=solve_fulldepression(contrasts,g)

if nargin<1
	contrasts=[];
end
if nargin<2
	g=[];
end
if isempty(g)
	g=1;
end

I0=0;
P0=1;

if isempty(contrasts)
%	contrasts=linspace(0,1,10);
	contrasts=logspace(-2,0,20);
end

time=[];
rm=[];
for contrast=contrasts
	[t,I]=ode23(@fulldepression,[0 200],[I0 P0 P0],[],contrast,P0,g);
	[Im,ind_t]=max(I(:,1));
	rm(end+1)=Im;
	time(end+1)=t(ind_t);
end

figure
if length(contrasts)>1
	subplot(1,3,1)
	plot(contrasts,rm);
	subplot(1,3,2)
	plot(contrasts,rm/max(rm));
	subplot(1,3,3)
	plot(contrasts(2:end),time(2:end));
	axis([0 1 0 150])
else
	plot(t,I); legend('R','Pcortex','Pinput')
end



