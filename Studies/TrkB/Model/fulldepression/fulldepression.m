function dy=fulldepression(t,y,contrast,P0,g)
% based on mark, but added depression in input synapse. 

tau=5; % ms 
tau_depr=500; %ms
f=0.8; % f=0.8 in Marks paper, depression factor

I=y(1);
Pcortex=y(2);
Pinput=y(3);

%r=markfi(I);
r=max(I,0);

input=normmodelinput(t,contrast);
%input=markinput(t,contrast);

dI=(-I+Pinput*input + g*Pcortex *r )/tau;

dPcortex=(P0 - (1+tau_depr*r*(1-f))*Pcortex)/tau_depr;
dPinput =(P0 - (1+tau_depr*input*(1-f))*Pinput)/tau_depr;

dy(1,1)=dI;
dy(2,1)=dPcortex;
dy(3,1)=dPinput;