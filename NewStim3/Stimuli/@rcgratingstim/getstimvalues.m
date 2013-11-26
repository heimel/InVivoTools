function v = getstimvalues(RCGstim)
% GETSTIMVALUES - Return the parameters of individual gratings for RCGstim
%
%  V = GETSTIMVALUES(RCGSTIM)
%
%  Returns in V a list of the parameters for individual flashed gratings
% 
%  For each stimulus i:
%
%  V(i,:) = [ SF(i) SP(i) ORI(i)]
%
%  Where ORI(i), SF(i), and SP(i) is the orientation angle, spatial frequency,
%  and spatial phase of stimulus i, respectively.
%
%  Note that this function returns the parameters for each grating number.
%  The order in which the gratings were flashed can be obtained with 
%  GETDISPLAYORDER.
%
%  See also:  GETDISPLAYORDER

p = getparameters(RCGstim);

      % this code must remain similar to that in loadstim.m

v = [];

for sf=1:length(p.spatialfrequencies),
        for sp=1:length(p.spatialphases),
                for o=1:length(p.orientations),
			v(end+1,[1 2 3]) = [p.spatialfrequencies(sf) p.spatialphases(sp) p.orientations(o)];
                end;
        end;
end;

v(end+1,[1 2 3]) = [ NaN NaN NaN]; % the blank
