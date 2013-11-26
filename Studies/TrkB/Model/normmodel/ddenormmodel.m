function dydt = ddenormmodel(t,y,Z,varargin)
%DDENORMMODEL
%
% 2007, Alexander Heimel
contrast=varargin{1};
n=3;


inh=0.3; % inhibition
n_inh=3;
exc=0.03; % recurrent excitation
k=1;
n_exc=2;
leak=0.01;
dydt = 0.1+ 0.1*normmodelinput(t,contrast) ...
  -leak*(y) ...
  -inh* (max(0,Z(1)))^n_inh  ... 
  + exc*(max(0,y)^n_exc);



%q=0.01;
%k=0.9;
%dydt =  10*q*normmodelinput(t,contrast)-0.01*(1-k)*(y-1)-q*k*(y-1)^3;

