function filename = hc_filename(record)
%HC_FILENAME generates headcamera filename from record
%
%  FILENAME = HC_FILENAME(RECORD)
%
%  Should be generalized and parameters from processparams_local.m
%
% 2022, Alexander Heimel

if isfield(record,'filename') && ~isempty(record.filename)
    filename = record.filename;
else
    % for Mehran's data
    filename = fullfile(record.mouse,'Recording.mpg');
end

