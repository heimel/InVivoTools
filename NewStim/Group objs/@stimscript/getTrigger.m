function trigger = getTrigger(S)

%  TRIGGER = GETTRIGGER(S)
%
%    Returns the trigger settings for the stimScript S.  
%    If no trigger was set, it returns zeros for each of the stimuli.
%
% 2012, Alexander Heimel

try
    trigger = S.trigger;
catch
    trigger = [];
end

if isempty(trigger)
    trigger = zeros(size(getDisplayOrder(S)));
end