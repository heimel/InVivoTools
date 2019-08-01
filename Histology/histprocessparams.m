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

if exist('processparams_local.m','file')
    oldparams = params;
    params = processparams_local( params );
    changed_process_parameters(params,oldparams);
end