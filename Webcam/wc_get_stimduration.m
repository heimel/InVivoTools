function stimduration = wc_get_stimduration(record)
%WC_GET_STIMDURATION gets best estimate of stimduration from record
%
% 2020, Alexander Heimel

sf = getstimsfile(record);

stimduration = duration(sf.saveScript);


if isempty(stimduration) || stimduration==0
    logmsg(['Missing stimulus duration for ' recordfilter(record)]);
    warning('STIMDURATION:HARDCODED','Stimulus duration hard coded to 3s');
    warning('off','STIMDURATION:HARDCODED');
    stimduration = 3; % temp
end