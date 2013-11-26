function dy=integrated_inhibition_function(t,y,contrast,b,g)

tau=4; %  ms
sigma=1; % ms, delaywidth (turnover for b=1 at sigma=tau/4)
rho=1;

r=y(1);
R=y(2); % is integral over past activity 

input=markinput(t,contrast);
%input=normmodelinput(t,contrast);

dr=(g*input - R)/tau;
dR=(rho^(1-b)*r^b - R)/sigma;

dy(1,1)=dr;
dy(2,1)=dR;