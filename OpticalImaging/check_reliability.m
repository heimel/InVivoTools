function reliable=check_reliability(record)
%CHECK_RELIABILITY checks if imaged record meets criteria
%
%  RELIABLE=CHECK_RELIABILITY(RECORD)
%
% 2007-2014, Alexander Heimel
%

reliable=[];
response=record.response;

if isempty(response) || isempty(record.timecourse_ratio)
  return
end

baseline_fluc=std(mean(record.timecourse_ratio(1:3,:),1));

rel_baseline_fluc=std(mean(record.timecourse_ratio(1:3,:),1)) /...
    max(abs(record.timecourse_ratio(:)));

logmsg(['baseline fluctuations: ' num2str(baseline_fluc) ...
  ' (abs) ' num2str(rel_baseline_fluc) ...
  ' (rel) ']);
