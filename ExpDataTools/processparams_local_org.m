function params = processparams_local(params) %#ok<FNDEF>
%PROCESSPARAMS_LOCAL temporarily and locally override analysis parameters
%
%  Do not edit processparams_local_org.m but make a copy
%  processparams_local.m and edit this instead. 
%
%  Check out specific processparams files for the default settings of 
%  all parameters: 
%     intrinsic signal imaging: oiprocessparams.m 
%     two photon imaging: tpprocessparams.m
%     electrophysiology: ecprocessparams.m
%     behavior imaging: wcprocessparams.m
%     pupil recording: pupilprocessparams.m
%
%  Specific InVivoTools packages can also be deselected for loading in
%  load_invivotools, e.g. to deselect ERG tools for loading add
%       params.load_erg =0; 
%
%
% 2014-2017, Alexander Heimel
%

% UNCOMMENT AND CHANGE AS NECESSARY

% params.databasepath_localroot = 'C:\Users\heimel\Dropbox (NIN)\InVivo';

% params.experimentpath_localroot = 'C:\Users\heimel\Dropbox (NIN)\InVivo';

% params.tpdatapath_localroot = 'E:\Data\InVivo\Microscopy\Helerop2p';

% params.tpdatapath_networkroot= '\\vs01\MVP\Shared\InVivo\Twophoton';

% params.experimentpath_localroot = 'C:\Users\heimel\Dropbox (NIN)';

% params.networkpathbase = 'V:\Shared\InVivo';

% params.ecdatapath_localroot = 'V:\Shared\InVivo\Electrophys\Antigua';

