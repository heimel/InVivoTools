function [rm,contrasts]=solve_integrated_inhibition(contrasts,g)

if nargin<1
	contrasts=[];
end
if nargin<2
	g=[];
end

if isempty(g)
	g=1;
end

r0=0;
R0=0;

if isempty(contrasts)
	contrasts=logspace(-3,0,10);
end

b=3; % if b is odd, equations become unstable

time=[];
rm=[];
r60=[];
for contrast=contrasts
	[t,I]=ode23(@integrated_inhibition_function,[0 200],[r0 R0],[],contrast,b,g);
	[Im,ind_t]=max(I(:,1));
	rm(end+1)=Im;
	time(end+1)=t(ind_t);
	r60(end+1)=I(find(t>60,1),1);
end

figure
if length(contrasts)>1
	subplot(1,2,1)
	plot(contrasts,rm,'o');
	hold on
	plot(contrasts,contrasts.^(1/b),'r')
	set(gca,'XScale','log');
	%plot(contrasts,r60,'k')
	subplot(1,2,2)
	plot(contrasts(2:end),time(2:end));
	axis([0.01 1 0 150])
else
	plot(t,I)
	legend('r','R');
	
end



