function y = mod180(x)
%MOD180 does modulus 180 and changes all y>90 to y-180
%
% 2013, Alexander Heimel
%

y = mod(x,180);
y(y>90) = y(y>90)-180;