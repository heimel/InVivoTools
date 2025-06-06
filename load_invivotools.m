function load_invivotools
%LOAD_INVIVOTOOLS
%
% LOAD_INVIVOTOOLS sets alls paths to InVivoTools and runs some
%    initialization scripts
%
%    check https://github.com/heimel/InVivoTools for most recent version
%    and documentation. In Manual folder
%
% 2014-2023, Alexander Heimel
%

if exist ('OCTAVE_VERSION', 'builtin') 
    isoctave = true;
else
    isoctave = false;
end

if isoctave
    more off
    warning('off','Octave:shadowed-function');
    warning('off', 'Octave:language-extension');
    warning('off', 'Octave:mixed-string-concat');
    try
        pkg load instrument-control
        pkg load statistics % for ivt_graph
    catch me
       disp(me.message);
    end
%   try
%        pkg load image % for imrect in results_wctestrecord
%    catch me
%       disp(me.message);
%    end

    
 end

disp([ mfilename() ': Manual available at https://github.com/heimel/InVivoTools/wiki']);

if isunix
    updatestr = 'To update InVivoTools: update_invivotools';
else
    updatestr = 'To update InVivoTools: open github and click on Fetch origin or Sync.';
end
disp([ mfilename() ': ' updatestr]);

majorprefix = fileparts(mfilename('fullpath'));
addpath(fullfile(majorprefix));

if ~exist('processparams_local.m','file')
    success = copyfile(fullfile(majorprefix,'ExpDataTools','processparams_local_org.m'),fullfile(majorprefix,'processparams_local.m'));
    if success
        disp([ mfilename() ': Created ' fullfile(majorprefix,'processparams_local.m')]);
    end
elseif ~isempty(processparams_local([]))
    disp([ mfilename() ': Local parameter settings in processparams_local:']);
    disp(processparams_local([]));
end
disp([ mfilename() ': To override InVivoTools settings: edit processparams_local']);

% defaults, put overrides in processparams_local.m file
params.load_general = 1; % necessary for host function
params.load_expdatatools = 1; % needed for InVivoTools analysis
params.load_nelsonlabtools = 0; % needed for analysis of Nelson Lab data
% params.load_newstim = 0; % needed for visual stimulation NewStim package
params.load_electrophys = 1; % needed for electrophysiology recording and analysis
params.load_webcam = 1; % needed for InVivoTools analysis
params.load_headcam = 0; % needed for InVivoTools freely moving head cam analysis
params.load_physiology = 1; % needed for EXG recordings
params.load_histology = 0; % needed for matching histology to Allen Mouse Brain Atlas
params.load_dataarchiving = 1; % needed for preparing project for archiving

if params.load_general % general
    % some generally useful tools not associated with any particular package
    path2general=fullfile(majorprefix,'General');
    addpath(path2general, ...
        fullfile(path2general,'structUtility'), ...
        fullfile(path2general,'graphs'), ...
        fullfile(path2general,'database'), ...
        fullfile(path2general,'filelocking'), ...
        fullfile(path2general,'stats'), ...
        fullfile(path2general,'plot2svg'), ...
        fullfile(path2general,'morph'), ...
        fullfile(path2general,'model3d'), ...
        fullfile(path2general,'filters'), ...
        fullfile(path2general,'icons'), ... % used for tp gui
        fullfile(path2general,'Wavelet','Wavelet Basics'), ... % used for erp analysis, Timo
        fullfile(path2general,'Wavelet','sinefit'), ... % used for erp analysis, Timo
        fullfile(path2general,'uitools'), ...
        fullfile(path2general,'CircStat'), ... % circular statistics toolbox
        fullfile(path2general,'matlab-ParforProgress2'));
end

params = processparams_local(params); % load local overrides

path2invivotools = majorprefix;

if params.load_expdatatools
    path2expdatatools = fullfile(path2invivotools,'ExpDataTools');
   % path2expdatatools = [path2expdatatools ';' fullfile(path2expdatatools,'Labs',params.lab)]; % add some lab specific tools
    addpath(path2expdatatools);
end

if params.load_webcam
    addpath(fullfile(path2invivotools,'Webcam'));
end

if params.load_headcam
    addpath(fullfile(path2invivotools,'Headcam'));
end

% Electrophysiology analyses
if params.load_electrophys
    ephys_path = fullfile(path2invivotools,'Electrophysiology');
    % ephys_path = [ephys_path ';' fullfile(path2invivotools,'Electrophysiology','Son')]; % Spike2 files
    ephys_path = [ephys_path ';' fullfile(path2invivotools,'Electrophysiology','TDT')]; % Tucker-Davis Technology files
    % ephys_path = [ephys_path ';' fullfile(path2invivotools,'Electrophysiology','Axon')]; % Axon patch clamp spikes
    % ephys_path = [ephys_path ';' genpath(fullfile(path2invivotools,'Electrophysiology','MClust-3.5'))]; % MClust spike sorter
    ephys_path = [ephys_path ';' fullfile(path2invivotools,'Electrophysiology','Kilosort','inVivoSpecs')]; % for exporting data to kilosort and importing kilosort spikes
    addpath(ephys_path);

    tmppath=pwd;
    cd(fullfile(path2invivotools,'Electrophysiology','NeuralAnalysis'));
    NeuralAnalysisObjectInit;
    cd(tmppath);


end

% Physiology analyses
if params.load_physiology
    addpath(fullfile(path2invivotools,'Physiology'),...
        fullfile(path2invivotools,'Physiology','video'));    % for video 
end


% 
% % NewStim package to show and analyse visual stimuli
% if params.load_newstim
%     % for NewStim3 this folder is configuration
%     % NewStimConfig file in that folder should be out of version control
%     % ideally should get different location, but called like this in
%     % NewStim3/NewStimInit, also used for optical imaging
%     addpath(...
%         fullfile(path2invivotools,'NewStim3'),...
%         fullfile(path2invivotools,'NewStim3','Configuration'),...
%         fullfile(path2invivotools,'NewStim3','Calibration'),...    % some calibration files for the packages that depend on each computer
%         fullfile(path2invivotools,'NewStim3','Calibration','Monitors'));
%     NewStimInit;
% end

% Nelsonlab tools, must be after NewStim package
if params.load_nelsonlabtools
    tmppath = pwd;
    cd(fullfile(path2invivotools,'NelsonLabTools'));
    NelsonLabToolsInit(); % initializing
    cd(tmppath);
end

% Histology and Allen Atlas matching
if params.load_histology
    addpath(fullfile(path2invivotools,'Histology'));
    addpath(fullfile(path2invivotools,'Histology','Allenatlasmatching'));
end
    
if params.load_dataarchiving
    addpath(fullfile(path2invivotools,'DataArchiving'));
end

if isoctave
    warning('on','Octave:shadowed-function');
end

