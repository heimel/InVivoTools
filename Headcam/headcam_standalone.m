function headcam_standalone( filename )
%HEADCAM_STANDALONE tool to analyse head camera movie
%
% HEADCAM_STANDALONE( FILENAME )
%
%    FILENAME can be name of movie file, or matlab headcam database
%
% 2022, Alexander Heimel

if nargin<1 || isempty(filename)
    filename = '';
end

if exist(filename,'file') && length(filename)>4 && strcmpi(filename(end-3:end),'.mat')
    % assume matlab database
    load(filename,'db');
else
    record.mouse = '';
    record.date = '';
    record.experiment = '';
    record.setup = '';
    record.datatype = 'hc';
    record.epoch = '';
    record.experimenter = getenv('username');
    record.comment = '';
    record.measures = [];
    record.stim_type = '';
    record.filename = filename;
    db = record;
end
experiment_db(db);

