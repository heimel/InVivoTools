function [r,sf]=sf_response(highsf,lowsf,highpass,sf)

if nargin<2
  lowsf=highsf/2;
end

if nargin<3
  highpass=0.5;
end


if nargin<4
  sf=(0:0.01:0.8);
end


r= exp( - sf.^2/ highsf^2 /2) - highpass*exp( - sf.^2/ lowsf^2 /2);
r=r/max(r); % normalize max response

%hold on
%plot(sf,r,'k');
