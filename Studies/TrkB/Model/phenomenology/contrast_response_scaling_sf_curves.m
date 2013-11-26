% first make contrast response graph with graph_db
%
sf01_x=[20    40    60    75    90];
sf01_y=[  0.29    0.68    0.81   0.92   1.0000];
sf02_x=[    60        90];
sf02_y=[ 0.5005    0.792];



c=linspace(0,1,100);
[rm,b,n] = naka_rushton(sf01_x/100,sf01_y)


sf01_fit = rm*c.^n./(b^n+c.^n)
norm=max(sf01_fit);
sf01_y=sf01_y/norm;
sf02_y=sf02_y/norm;
sf01_fit=sf01_fit/norm;


figure;
hold on
plot(sf02_x,sf02_y,'go')
plot(sf01_x,sf01_y,'ro')
plot(c*100,sf01_fit,'r')

% optimal fit contrast scaling
scale=linspace(0.5,3,300);
%scale=1.50
min_error=inf;
for s=scale
	c_scaled=c*100*s;
	ind=findclosest(c_scaled,sf02_x);
	error= sum( (sf02_y - sf01_fit(ind)).^2)
	if error<min_error
		min_error=error;
		proper_scale=s;
	end
end
disp('contrast scaling');
proper_scale
min_error
plot(c*100*proper_scale,sf01_fit,'k')

% optimal fit response scaling
scale=linspace(0.1,2,60);
min_error=inf;
for s=scale
	ind=findclosest(c,sf02_x);
	error= sum( (sf02_y - s*sf01_fit(ind)).^2);
	if error<min_error
		min_error=error;
		proper_scale=s;
	end
end
disp('response scaling');
proper_scale
min_error
plot(c*100,sf01_fit*proper_scale)

legend('sf02','sf01','sf01','contrast','response')
title('contrast response scaling optical imaging');
set(gca,'Xscale','log')
axis([5 100 0 1.2])
