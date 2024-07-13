function params = db_default_parameters(record)
%db_default_parameters Contains default parameters for control_db
%
%  PARAM = db_default_parameters([RECORD])
%
%  Edit processparams_local for local and temporary edits to these default
%  parameters.
%
% 2024, Alexander Heimel

% General
params = struct;

params.db_backgroundcolor = 0.8*[1 1 1];
params.db_basefontsize = 9; % pt 
params.db_figwidth = 510; % pxl
params.db_buttonpadding = 4; % pxl
params.db_colsep = 3; % pxl, also acting as rowsep

params.db_max_labelwidth = 100; % pxl, for record form
params.db_max_editwidth = 250; % pxl, for record form

% Load processparams_local. Keep at the end
if exist('processparams_local.m','file')
    params = processparams_local( params );
end