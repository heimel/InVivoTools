function reliable=check_reliability(record)
%CHECK_RELIABILITY checks if imaged record meets criteria
%
%  RELIABLE=CHECK_RELIABILITY(RECORD)
%
% 2007, Alexander Heimel
%

reliable=[];
response=record.response;

if isempty(response)
  return;
end

baseline_fluc=std(mean(record.timecourse_ratio(1:3,:),1));

rel_baseline_fluc=std(mean(record.timecourse_ratio(1:3,:),1)) /...
    max(abs(record.timecourse_ratio(:)));

disp(['baseline fluctuations: ' num2str(baseline_fluc) ...
  ' (abs) ' num2str(rel_baseline_fluc) ...
  ' (rel) ']);
