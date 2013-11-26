function [a0,f,ftau,d,dtau,err]=depression_model_fit(spiketimes,data,forder,dorder,numatt);

% DEPRESSION_MODEL - Compute parameters of model for synaptic depression
%
% [A0,F,FTAU,D,TAU,ERR]=DEPRESSION_MODEL(SPIKETIMES,SYNAPTIC_CURRENT,...
%            FORDER,DORDER,[NUMATTEMPTS])
%
%  Finds the best fit depression model with FORDER facilitating factors and
%  DORDER depressing factors for the synaptic currents measured in the array
%  SYNAPTIC_CURRENT at presynaptic spike times SPIKETIMES.  This program tries
%  NUMATTEMPTS different random starting positions (default 10) and picks the
%  best solution.
%
%  See Varela, Sen, Gibson, Fost, Abbott, and Nelson, J. Neuroscience 17:7926-40
%  (1997) and 'help depression_model_comp' for details of the model and parameters.
%  ERR is the squared error over the whole data.
%

numattempts = 10; if nargin>4, numattempts = numatt; end;

 % initial conditions
 optims = optimset('MaxFunEvals',100000000000,'TolX',1e-6,'TolFun',1e-6,'MaxIter',100000);
 err=[];xi={};ex={};out={};
 for i=1:numattempts,
   xo=[data(1) rand(1,forder)/10 rand(1,forder) rand(1,dorder) rand(1,dorder)];
   [xi{i},err(i),ex{i},out{i}]=fminsearch('depression_model_err',xo,optims,...
   			spiketimes,data,forder,dorder);
 end;
 [m,i]=min(err); x = xi{i}; err = err(i); % choose x with minumum error
 a0=x(1);
 f=abs(x(2:1+forder));ftau=abs(x(2+forder:1+2*forder));
 d=x(2+2*forder:1+2*forder+dorder); d = abs(d./(d+1));
 dtau=abs(x(2+2*forder+dorder:1+2*(forder+dorder)));

 %this function used to be computed with the following old routines:
 %options=foptions; options(1)=0; options(2)=1e-6;options(14)=10000000;
 %[x,options] = fmins('depression_model_err',xo,options,[],spiketimes,data,forder,dorder);
 %options(10),
 %err = depression_model_err(x,spiketimes,data,forder,dorder);
