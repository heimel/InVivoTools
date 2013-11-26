function x = clip2unit( x )
%CLIP2UNIT clips value to between 0 and 1

x(x>1) = 1;
x(x<0) = 0;

