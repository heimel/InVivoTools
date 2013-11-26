function [rm,b,n,m,exitflag] = naka_rushton(c,data,xo)
% NAKA_RUSHTON Naka-Rushton fit (for contrast curves)
%
%  [RM,B] = NAKA_RUSHTON(C,DATA)
%
%  Finds the best fit to the Naka-Rushton function
%    R(c) = Rm*c./(b+c)
%  where C is contrast (0-1), Rm is the maximum response, and b is the
%  half-maximum contrast.
%
%  [RM,B,N] = NAKA_RUSHTON(C,DATA)
%
%  Finds the best fit to the Naka-Rushton function
%    R(c) = Rm*c.^n./(b^n+c.^n)
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

if max(c)<=1 && min(c)>0.01
	c=[0.01 c];
	data=[0 data];
    rescale_to_1 = false;
elseif min(c)>1 % will rescale
	c=[1 c];
	data=[0 data];
    rescale_to_1 = true;
    c = c/100;
end



% clip at maximum to remove supersaturation data
 [m,ind] = max(data);
 data(ind:end) = m;


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
		options=foptions; %#ok<FDEPR>
		options(1)=0;
		options(2)=1e-6;
		eval('[x] = fmins(''naka_rushton_err'',xo,options,[],c,data)');
	otherwise
		options=optimset;
%    options.Display = 'final';
        options.MaxFunEvals=10000;
    options.MaxIter=10000;
    options.TolFun = 1e-2;
    options.TolX = 1e-2;
		eval('[x,fval,exitflag] = fminsearch(@(x) naka_rushton_err(x,c,data),xo,options);');
end

rm=x(1);b=x(2);
if nargout>2
	n=x(3);
end
if nargout>3
	m=x(4);
end

if rm<0
  rm=max(abs(data(:)))*10^-8;
  b=10*max(c);
end

if 0
 figure;
 plot(c,data,'+');
 hold on
 cn=(0:0.01:1);
 r=rm* (cn.^n)./ (b^n+cn.^n) ; % without spont
 plot(cn,r);
end


