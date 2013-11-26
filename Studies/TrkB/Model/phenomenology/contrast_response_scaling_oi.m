% first make contrast response graph with graph_db
%
t1_x=[20    40    60    75    90];
t1_y=[ 0.1094    0.3633    0.5252    0.5892    0.7008];
wt_x=[20    40    60    75    90];
wt_y=[  0.3479    0.7239    0.8272    0.8277    1.0000];



c=linspace(0,1,100);
[rm,b,n] = naka_rushton(wt_x/100,wt_y)


wt_fit = rm*c.^n./(b^n+c.^n)
norm=max(wt_fit);
wt_y=wt_y/norm;
t1_y=t1_y/norm;
wt_fit=wt_fit/norm;


figure;
hold on
plot(t1_x,t1_y,'go')
plot(wt_x,wt_y,'ro')
plot(c*100,wt_fit,'r')

% optimal fit contrast scaling
scale=linspace(0.5,3,60);
%scale=1.50
min_error=inf;
for s=scale
	c_scaled=c*100*s;
	ind=findclosest(c_scaled,t1_x);
	error= sum( (t1_y - wt_fit(ind)).^2)
	if error<min_error
		min_error=error;
		proper_scale=s;
	end
end
proper_scale
min_error
plot(c*100*proper_scale,wt_fit,'k')

% optimal fit response scaling
scale=linspace(0.1,2,60);
min_error=inf;
for s=scale
	error= sum( (t1_y - wt_y*s).^2);
	if error<min_error
		min_error=error;
		proper_scale=s;
	end
end
proper_scale
min_error
plot(c*100,wt_fit*proper_scale)

legend('t1','wt','wt','contrast','response')
title('contrast response scaling optical imaging');

