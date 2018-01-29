function [sts,uniq_triggers] = split_stimscript_by_trigger( st )
%SPLIT_STIMSCRIPT_BY_TRIGGER splits recorded stimscript into multiple
%
% [STS,UNIQ_TRIGGERS] = SPLIT_STIMSCRIPT_BY_TRIGGER( ST )
%
%   ST is a struct containing a 'stimscript' and a 'mti' field
%
%   2012-2018, Alexander Heimel
%

if isfield(st,'saveScript')
    stimscriptfield = 'saveScript';
else
    stimscriptfield = 'stimscript';
end
stimscript = st.(stimscriptfield);


if isfield(st,'MTI2')
    mtifield = 'MTI2';
else
    mtifield = 'mti';
end
stimscript = st.(stimscriptfield);


trigger = getTrigger( stimscript );
uniq_triggers = uniq(sort(trigger));

disord = getDisplayOrder(stimscript);
st.trigger = [];
for t = 1:length(uniq_triggers)
   sts(t) = st;
   ind = find(trigger==uniq_triggers(t));
   
   sts(t).(stimscriptfield) = ...
       setDisplayMethod( stimscript, 2, disord(ind), uniq_triggers(t));   
   sts(t).(mtifield) = {st.(mtifield){ind}};
   
   sts(t).trigger = uniq_triggers(t);
end


