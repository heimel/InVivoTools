function err=depression_model_err(x,spiketimes,data,forder,dorder)

%  DEPRESSION_MODEL_ERR - Depression model error function

 % extract parameters
a0=x(1);
f=abs(x(2:1+forder));ftau=abs(x(2+forder:1+2*forder));
d=x(2+2*forder:1+2*forder+dorder); d = abs(d./(d+1));
dtau=abs(x(2+2*forder+dorder:1+2*(forder+dorder)));

 % calculate error
moddat = depression_model_comp(spiketimes,a0,f,ftau,d,dtau);
err = sum(sum((data-moddat).*(data-moddat)));
