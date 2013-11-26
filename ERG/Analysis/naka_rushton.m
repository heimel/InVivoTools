function [rm,b,n,m,exitflag] = naka_rushton(c,data,xo);
% NAKA_RUSHTON Naka-Rushton fit (for contrast curves)
%
%  [RM,B] = NAKA_RUSHTON(C,DATA)
%
%  Finds the best fit to the Naka-Rushton function
%    R(c) = Rm*c/(b+c)
%  where C is contrast (0-1), Rm is the maximum response, and b is the
%  half-maximum contrast.
%
%  [RM,B,N] = NAKA_RUSHTON(C,DATA)
%
%  Finds the best fit to the Naka-Rushton function
%    R(c) = Rm*c^n/(b^n+c^n)
%  where C is contrast (0-1), Rm is the maximum response, and b is the
%  half-maximum contrast.
%
%  References:
%    Naka_Rushton fit was first described in
%    Naka, Rushton, J.Physiol. London 185: 536-555, 1966
%    and used to fit contrast data of cortical cells in
%    Albrecht and Hamilton, J. Neurophys. 48: 217-237, 1982
%
exitflag=[];

if nargin<3;xo=[];end

if isempty(xo)
  % initial conditions
  xo = [ max(data(:)) 0.4];
  if nargout>2
    xo(3)=2;  % n (exponent)
  end
  if nargout>3
    xo(4)=xo(3);  % m (exponent)
  end
end

matlabversion=version;
switch matlabversion(1:3)
	case '5.3',
		options=foptions;
		options(1)=0;
		options(2)=1e-6;
		eval('[x] = fmins(''naka_rushton_err'',xo,options,[],c,data)');
	otherwise
		options=optimset;
    options.MaxFunEvals=4000;
    options.MaxIter=4000;
		[x,fval,exitflag] = fminsearch(@(x) naka_rushton_err(x,c,data),xo,options);
end

rm=x(1);b=x(2);
if nargout>2
	n=x(3);
end
if nargout>3
	m=x(4);
end