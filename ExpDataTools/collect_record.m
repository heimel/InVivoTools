function collect_record( record, recordtype)
%COLLECT_RECORD in global USED_RECORDS
%
%  COLLECT_RECORD( RECORD, RECORDTYPE )
%     RECORDTYPE = 'test','group','measure','mouse','graph'
%
% 2017, Alexander Heimel

global used_records

if isempty(used_records) || ~isfield(used_records,recordtype)
    used_records.(recordtype) = record;
else
    used_records.(recordtype) = [used_records.(recordtype) record];
end