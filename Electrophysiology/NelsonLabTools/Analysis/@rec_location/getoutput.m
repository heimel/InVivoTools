function c = getoutput(rl)

%  REC_LOCATION/GETOUTPUT
%
%  C = GETOUTPUT(RL)
%
%  Gets the following fields from the REC_LOCATION object RL:
%
%     depth      [1x1]  :    depth in the brain (in m)
%     loc        [1x3]  :    The M-L,A-P,D-V coordinates (in m)
%                       :       left hemisphere is positive for M-L,
%                       :       posterior is positive for A-P,
%                       :       more ventral is positive for D-V.
%                       :       Use NaN for not specified.
%     wrt        [1x1]  :    With respect to 
%                       :    0 => interaural point
%                       :    1 => bregma
%
%  See also:  REC_LOCATION

c = getinputs(rl);
