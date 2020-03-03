function [freezetimes,freezetimes_abs] = wc_get_freezetimes(record)
%WC_GET_FREEZETIMES gets freezetimes from freeze in comments field 
%
%  [FREEZETIMES,FREEZETIMES_ABS] = WC_GET_FREEZETIMES(RECORD)
%
%     FREEZETIMES start and stop times of freezing relative to stim start
%     FREEZETIMES start and stop times of freezing relative to movie start
%
% 2020, Alexander Heimel

freezetimes_abs = [];
stimstart = wc_get_stimstart(record);
if ~isfield(record.measures,'freezetimes')
    %logmsg(['Missing freezetimes in ' recordfilter(record)]);
    record.measures.freezetimes = [];
end
freezetimes = record.measures.freezetimes - stimstart; % taking manually detected
freezetimes = select_freezetimes(freezetimes,record,stimstart);

p  = strfind(record.comment,'freezestart');
if ~isempty(p)
    pk = strfind(record.comment(p:end),'=');
    lp = find(record.comment(p+pk:end)>57 |record.comment(p+pk:end)<46,1,'first');
    if isempty(lp)
        lp = length(record.comment) - (p+pk-1);
    end
    freezestart = str2num(record.comment(p+pk:p+pk-1+lp)); %#ok<ST2NM>
    freezetimes(1,:) = freezestart - stimstart +  [0 record.measures.freeze_duration_from_comment];
elseif record.measures.freezing_from_comment==1 && isempty(freezetimes)
    %logmsg(['Freezing scored in comment but not in measures' recordfilter(record)]);
    freezetimes = record.measures.freezetimes_aut - stimstart;
    freezetimes = select_freezetimes(freezetimes,record,stimstart);
    if isempty(freezetimes)
        logmsg(['No freezestart in comment in ' recordfilter(record) '. Stimstart=' num2str(stimstart)]);
        return
    end
end


if (record.measures.freezing_from_comment==0 && ~isempty(freezetimes))
    %logmsg(['Freezing not scored in comment ' recordfilter(record)]);
    freezetimes = [];
end


freezetimes_abs = freezetimes + stimstart;


function freezetimes = select_freezetimes(freezetimes,record,stimstart)
if isempty(freezetimes)
    return
end

% only show freezetimes after stimulus starts
freezetimes = freezetimes(freezetimes(:,1)>0,:);

% 
if all(isnan(record.measures.stim_trajectory(:,1)))
    logmsg(['No stimulus trajectory information in ' recordfilter(record)]);
    freezetimes = [];
    return
end
    
% only show freezes starting before end of stimulus
dur = record.measures.frametimes(find(~isnan(record.measures.stim_trajectory(:,1)),1,'last'))-stimstart;
freezetimes = freezetimes(freezetimes(:,1)<dur,:);

% only show first freezetimes
if ~isempty(freezetimes)
    freezetimes = freezetimes(1,:);
end

