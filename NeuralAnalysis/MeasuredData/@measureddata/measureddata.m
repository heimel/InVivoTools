function A = measureddata(intervals, desc_long, desc_brief)

%  Part of the NeuralAnalysis package
%
%  MD = MEASUREDDATA(INTERVALS, DESC_LONG, DESC_BRIEF)
%
%  Creates a new MEASUREDDATA object, sampled over the intervals described in
%  the Nx2 matrix INTERVALS (i.e., there is assumed to be a clock).

if size(intervals,2)==2||isempty(intervals),
   if nargin>=2, description_long = desc_long;
   else, description_long = ''; end;
   if nargin> 2, description_brief = desc_brief;
   else, description_brief = ''; end;
   associates=struct('type',[],'owner',[],'data',[],'desc',[]);
   associates=associates([]); % make empty
   data = struct('intervals',intervals,'description_long',description_long, ...
              'description_brief',description_brief,'associates',associates);
   A = class(data,'measureddata');

else,
   error(['Could not created mesaureddata: intervals are not Nx2:' mat2str(size(intervals)) '.']);
end;
