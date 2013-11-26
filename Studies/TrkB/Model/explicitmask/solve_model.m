function [rm,contrasts]=solve_model(contrasts,cm)

if nargin<1
	contrasts=[];
end
if nargin<2
	cm=[];
end
if isempty(cm)
	cm=0;
end

if isempty(contrasts)
%	contrasts=linspace(0,1,10);
	contrasts=logspace(-2,0,20);
end

time=[];
rm=[];
V0=0;

for contrast=contrasts
	[t,I]=ode23(@model,[0 200],[V0 V0],[],contrast,cm);
	[Im,ind_t]=max(I(:,1));
	rm(end+1)=fi(Im);
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
	plot(t,I); legend('Vs','Vm')
end



