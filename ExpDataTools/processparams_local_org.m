function params = processparams_local(params) %#ok<FNDEF>
%PROCESSPARAMS_LOCAL temporarily and locally override analysis parameters
%
%  Do not edit processparams_local_org.m but make a copy
%  processparams_local.m and edit this instead. 
%
% 2014, Alexander Heimel
%


% Changes here
%
% e.g.
% params.tpdatapath_localroot = ''
% params.tpdatapath_networkroot = ''
% params.ecdatapath_localroot = '';  
%
% params.pre_window = [-Inf 0];
%

% 
% params.load_general = 0; % necessary for host function
% params.load_nelsonlabtools = 0; % needed for analysis, should be phased out
% params.load_newstim = 0; % needed for visual stimulation NewStim package
% params.load_neuralanalysis = 0; % needed for electrophysiology analysis
% params.load_twophoton = 0; % needed for twophoton analysis
% params.load_intrinsicsignal = 0; % needed for optical imaging analysis
% params.load_erg =0; % need for ERG stimulation and analysis
% params.load_electrophys = 0; % needed for electrophysiology recording and analysis
% params.load_expdatatools = 0; % needed for InVivoTools analysis
% params.load_studies = {}; % folders of Studies to load

%