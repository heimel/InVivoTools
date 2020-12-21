function record = wc_add_freezing_approach( record, verbose )
%WC_ADD_FREEZING_APPROACH adds whether stimulus is approaching or receding at freeze start
%
% 2020, Alexander Heimel

if nargin<2 || isempty(verbose)
    verbose = true;
end

record.measures.approaching_at_freeze_start = false;
record.measures.receding_at_freeze_start = false;

m = record.measures;

if m.freezing_from_comment~=1
    return
end


if ~isfield(m,'ind_freeze') || isempty(m.ind_freeze) % no freeze
    if m.session==1 && ~isempty(find_record(record,'mouse=14.13.2*'))
        logmsg(['Not ind_freeze in ' recordfilter(record)])
    end
    return
end

distance = sqrt(m.stim_nose_centered_rotated_cm(m.ind_freeze,1).^2 + ...
    m.stim_nose_centered_rotated_cm(m.ind_freeze,2).^2);

distance = distance(~isnan(distance));
if length(distance)<2
    if m.session==1 && ~isempty(find_record(record,'mouse=14.13.2*'))
        logmsg(['Not distance in ' recordfilter(record)])
    end
    return
end

distance = smooth(distance,5);
ddistance = diff(distance); % derivative

record.measures.approaching_at_freeze_start = (distance(min(5,end))<distance(1));
record.measures.receding_at_freeze_start = (distance(min(5,end))>=distance(1));
if(ddistance(1)==0)
    logmsg(['Something weird in ' recordfilter(record)]);
    keyboard
end


