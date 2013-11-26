% first make contrast response graph with graph_db
%
t1_x=[30    50    70    90    95];
t1_y=[1.1751    2.1609    3.5027    5.7624    6.0277];
wt_x=[30    50    70    90    95];
wt_y=[ 1.5802    4.6772    7.0951    9.3030    8.9561];



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
scale=linspace(0.5,2,60);
scale=1.50
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
title('contrast response scaling single-unit');
