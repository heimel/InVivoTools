function ppd=pixels_per_degree
%PIXELS_PER_DEGREE on stimulus monitor
%
%monitor EIZO FlexScan F784-T
%resolution 640x480
%maximum width: 37.5 cm
% computed corresponding height: 28.1 cm
%
%  2005, Alexander Heimel
%  2005-03-02 JFH: changed viewing distance from 30cm to 16cm
%

switch host
    case {'nori999','nin-pc86'}, % stimulus pc of first imaging setup
        ppcm=640/37.5;
    case 'nori002', % new stimulus pc = oude desktop Damian
        ppcm=640/37.5;
    otherwise
        disp('Unknown computer')
        ppcm=640/37.5;
        return
end

viewing_distance=16; % in cm 
cmpd=viewing_distance*tan(2*pi/360);  % cm per degree
ppd=ppcm*cmpd;