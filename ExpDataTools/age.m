function [d,w,m]=age(birthdate,current)
%AGE calculates age in days, weeks or months
%
% [d,w,m]=age(birthdate,current)
%
% 2005, Alexander Heimel
%

if nargin<2
  current=[];
end

if isempty(current)
  current=floor(now);
else
  current=datenumber(current);
end

if ~strcmp(birthdate,'unknown')
  d=current-datenumber(birthdate(1:10));
else
  d=nan;
end

w=round(d/7);
m=round(d/365*12);
