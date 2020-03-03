function stimstart = wc_get_stimstart(record)
%WC_GET_STIMSTART gets best estimate of stimstart from record
%
% 2020, Alexander Heimel

if ~isempty(record.stimstartframe)
    stimstart = record.stimstartframe/30;
elseif isfield(record.measures,'stimstart')
    logmsg(['No stimstartframe in ' recordfilter(record)]);
    stimstart = record.measures.stimstart;
else
    logmsg(['No stimstartframe and no stimstart field in ' recordfilter(record)]);
    stimstart = [];
end