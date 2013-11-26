function [s,l]=nomogram(lambda_max)
%NOMOGRAM Lamb's approximation for photoreceptor nomogram 
%
%   S=NOMOGRAM(LAMBDA_MAX)
%      LAMBDA_MAX is peak sensitivity in nm
%    See TD Lamb, Vision Res. 35:3083-3091
%
%  2004, Alexander Heimel


l=linspace(200,800,100);

a=70;
b=28.5;
c=-14.1;
A=0.880;
B=0.924;
C=1.104;
D=0.655;


s=1./(exp(a*(A-lambda_max./l)) + ...
      exp(b*(B-lambda_max./l))+exp(c*(C-lambda_max./l))+D);
