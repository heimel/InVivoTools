function params = histprocessparams( record ) %#ok<INUSD>
%HISTPROCESSPARAMS parameters for histology and allen brain map analysis
%
%  Local changes to settings should be made in processparams_local.m
%  This should be an edited copy of processparams_local_org.m
%
% 2019, Alexander Heimel
%

if nargin<1
    record = []; %#ok<NASGU>
end

params.hist_allenmaplocation = 'E:\Dropbox (NIN)\Library\Atlas\Allen';
params.hist_sliceslocation = 'E:\Dropbox (NIN)\Projects\Joris_jointfolder\allenatlas\Slices';

params.hist_show_channels = 2; % to show all slice channels, use []

params.hist_phi = -98/180*pi; % angle in AP-LR plane (radii) sagittal =0 ; coronal = pi/2;
params.hist_axis_ap = 315;
params.hist_axis_lr = 112;
params.hist_theta = 0; % angle to DV axis (radii) vertical = 0; horizontal = pi/2
params.hist_xl = [0.5 260.5];
params.hist_yl = [0.4 310.5];

if exist('processparams_local.m','file')
    oldparams = params;
    params = processparams_local( params );
    changed_process_parameters(params,oldparams);
end