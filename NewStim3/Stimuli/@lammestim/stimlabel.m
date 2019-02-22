function label = stimlabel( stim )
par = getparameters( stim );

% typenumber| fig motion  | gnd motion   | fixed aper | figure percept 
% ----------|-------------|--------------|------------------
%   1       | figdir      | no           | yes        | yes
%   2       | no          | gnddir       | yes        | yes
%   3       | figdir      | gnddir       | yes        | no
%   4       | figdir      | gnddir + 180 | yes        | yes
%   5       | figdir + 180| gnddir       | yes        | yes
%   6       | figdir + 180| gnddir + 180 | yes        | no
%   7       | figdir      | no           | no         | yes
%   8       | figdir      | gnddir       | no         | no
%   9       | figdir      | figdir + 90  | yes        | yes
%  10       | no fig pres.| gnddir       | yes        | no
%  11       | figdir,phase| gnddir       | yes        | yes

switch par.typenumber
    case 0 
        label = 'C'; % center-only
    case {1,2,3,6,8}
        label = 'I'; % iso
    case {4,5,7,11} % out of phase
        label = 'O';
    case {9} 
        label = 'X'; % cross
    case {10} 
        label = 'A'; % annulus
    otherwise 
        label = 'U'; % unknown
end