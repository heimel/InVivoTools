function rl = rec_location(inputs, parameters, where)

%  RL = REC_LOCATION(INPUTS, PARAMETERS, WHERE)
%
%  Creates a new recording location object.  It doesn't perform any computation,
%  but merely holds the data corresponding to the recording location.  It is
%  useful for associating with the data.  It does not draw.
%
%  INPUTS should contain the following fields:
%     depth      [1x1]  :    depth in the brain (in m)
%     loc        [1x3]  :    The M-L,A-P,D-V coordinates (in m)
%                       :       left hemisphere is positive for M-L,
%                       :       posterior is positive for A-P,
%                       :       more ventral is positive for D-V.
%                       :       Use NaN for not specified.
%     wrt        [1x?]  :    Must be string, either:
%                       :    'interaural point'
%                       :    'bregma'
%  PARAMETERS must be either the string 'defaults' or empty.
%
%  See also:  ASSOCIATE

[good,er]=verifyinputs(inputs); if ~good, error(['INPUT: ' er]); end;

nag = analysis_generic([],[],where); delete(nag);
ag = analysis_generic([],[],[]);
rl = class(struct('inputs',inputs),'rec_location',ag);
