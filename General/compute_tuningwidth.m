function tuningwidth = compute_tuningwidth( angles, rates )
% COMPUTE_TUNINGWIDTH
%     TUNINGWIDTH = COMPUTE_TUNINGWIDTH( ANGLES, RATES )
%
%     Takes ANGLES in degrees
%
%     linearly interpolates rates
%     and returns the half of the distance
%     between the two points sandwiching the maximum
%     where the response is 1/sqrt(2) of the maximum rate.
%     returns 90, when function does not come below the point
%
% See Rinach et al. J.Neurosci. 2002 22:5639-5651
%
% 2003-2013, Alexander Heimel

tuningwidth = [];

if length(uniq(sort(angles))) ~= length(angles)
    disp('COMPUTE_TUNINGWIDTH: Only works for uniq angles.');
    return
end

if length(angles)<8
    return
end

if all(isnan(angles))
    return
end

angles = mod(angles,360);
angles = [angles 360+angles 720];
rates = [rates rates rates(1)];
fineangles=(0:1:720);

intrates=interp1(angles,rates,fineangles,'linear');

[maxrate,pref]=max(intrates(181:540));
pref=pref+179;
halfheight=maxrate/sqrt(2);

if( min(intrates-halfheight)>0 );
  % never below halfline
  tuningwidth = 90;
else
     [left,leftvalue]=findclosest(intrates(pref-90:pref),halfheight);
     left=left+pref-90-2;
     [right,rightvalue]=findclosest(intrates(pref:pref+90),halfheight);
     right=right+pref-2;
     tuningwidth=(right-left)/2;
     if(tuningwidth>90)
       tuningwidth=90;
     end
end


