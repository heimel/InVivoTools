function [low,max,high]= compute_halfwidth( x, y )

% COMPUTE_LOWHALFMAX
%     [LOW,MAX,HIGH] = COMPUTE_HALFWIDTH( X, Y )
%
%     interpolates function by linearly (splines goes strange for small points)
%     and returns MAX, where x position where function attains its maximum value
%     LOW < MAX,  where function attains half its maximum
%     HIGH > MAX, where function attains half its maximum
%     returns NAN for LOW or/and HIGH, when function does not come below the point
%     
%     note: ugly,slow and crude routine,    consider taking log x first

if length(x)<500
  step=(x(end)-x(1))/500;  % not that many steps, consider taking log first
  finex=(x(1):step:x(end));
else
  finex=x;
end

intfunction=interp1(x,y,finex,'linear');

[maxvalue,max]=max(intfunction);
halfheight=maxvalue/2;

if( min( intfunction(1:max)-halfheight)>0 );
  % never below halfline
  low =nan;
else
  [low,lowvalue]=findclosest(intfunction(1:max),halfheight);
  low=finex(low);
end

if( min( intfunction(max:end)-halfheight)>0 );
  % never below halfline
  high =nan;
else
  [high,highvalue]=findclosest(intfunction(max:end),halfheight);
  high=finex(high+max-1);
end

max=finex(max);
