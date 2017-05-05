function params = pupilprocessparams(  record )
%PUPILPROCESSPARAMS returns default pupil data processing parameters
%
% PARAMS = PUPILPROCESSPARAMS( RECORD)
%
%  Local changes to settings should be made in processparams_local.m
%  This should be an edited copy of processparams_local_org.m
%
% 2017, Alexander Heimel
%


params.pupil_timeshift = 0.2; % s
params.averaging_window = 0.3; % s
params.separation_from_prev_stim_off = 0.75;  % time (s) to stay clear of prev_stim_off
params.eye_radius_pxl = 110; % default eye radius in pixels
