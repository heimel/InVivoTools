function rs = rec_structure(inputs, parameters, where)

%  RS = REC_STRUCTURE(INPUTS, PARAMETERS, WHERE)
%
%  Creates a new recording structure object. It doesn't perform any computation,
%  but merely holds the data corresponding to the recording structure.  It is
%  useful for associating with the data.  It does not draw.
%
%  INPUTS should contain the following fields:
%     structure  [1x1]  :    A string, must be one of:
%                       :    'unknown', 'LGN', 'V1','V2','L/ML','Tp',
%                       :    'SC','Pulvinar',...
%                       :    'unspecified visual cortex','unspecified thalamus'
%     layer      [1x1]  :    A string.  'unknown' is always vaild.  For
%                       :    structure='V1','V2','L/ML','Tp',
%                       :    'unspecified visual cortex', then it can be
%                       :    '1','2','3','4','5','6'.
%                       :    For structure='LGN', it can be '1','2','3'.
%                       :    (*not yet defined for other structures*')
%     corrected  [1x1]  :    0/1 if corrected/verified w/ histology
%
%  PARAMETERS must be either the string 'defaults' or empty.
%
%  See also:  ASSOCIATE

[good,er]=verifyinputs(inputs); if ~good, error(['INPUT: ' er]); end;

nag = analysis_generic([],[],where); delete(nag);
ag = analysis_generic([],[],[]);
rl = class(struct('inputs',inputs),'rec_structure',ag);
