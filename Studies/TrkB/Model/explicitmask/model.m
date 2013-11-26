function dy=model(t,y,cs,cm)

gamma=10;
epsilon=0;
iota=1;
tau=5;

Vs=y(1);
Vm=y(2);

Rs=fi(Vs);
Rm=fi(Vm);

Ls=input_sinus(t,cs);
Lm=input_sinus(t,cm);


 A=1/2*(Rs+Rm); % total activity
%A=1/2*gamma*(Ls+Lm); % total ff drive

dVs=1/tau*( gamma * Ls + epsilon*Rs - iota*fi(A)-Vs);
dVm=1/tau*( gamma * Lm + epsilon*Rm - iota*fi(A)-Vm);

dy(1,1)=dVs;
dy(2,1)=dVm;
