function [d,w,m]=age(birthdate,current)
%AGE calculates age in days, weeks or months
%
% [d,w,m]=age(birthdate,current)
%
% 2005-2017, Alexander Heimel
%

val_unknown = -1;NaN;

if nargin<2
  current = [];
end
if isempty(birthdate)
    birthdate = 'unknown';
end

if isempty(current)
  current = floor(now);
else
  current = datenumber(current);
end

if strcmp(birthdate,'unknown') || length(birthdate)<10 || birthdate(5)~='-' 
    d = val_unknown;
else
    d = current-datenumber(birthdate(1:10));
end

w = round(d/7);
m = round(d/365*12);
