function dy=marks_function(t,y,contrast,P0)
tau=5; % ms 
tau_depr=500; %ms
f=0.8; % f=0.8 in Marks paper, depression factor

I=y(1);
g=1;  % g=1
P=y(2);

%r=markfi(I);
r=max(I,0);

%input=normmodelinput(t,contrast);
input=markinput(t,contrast);

dI=(-I+input + g*P *r)/tau;

dP=(P0 - (1+tau_depr*r*(1-f))*P)/tau_depr;
dy(1,1)=dI;
dy(2,1)=dP;