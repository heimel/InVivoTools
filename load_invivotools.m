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

disp([ upper(mfilename) ': Manual available at https://github.com/heimel/InVivoTools/wiki']);

if isunix
    updatestr = 'To update InVivoTools: update_invivotools';
else
    updatestr = 'To update InVivoTools: open github and click on Sync.';
end
disp([ upper(mfilename) ': ' updatestr]);

majorprefix = fileparts(mfilename('fullpath'));
addpath(fullfile(majorprefix));

if ~exist('processparams_local.m','file')
    success = copyfile(fullfile(majorprefix,'ExpDataTools','processparams_local_org.m'),fullfile(majorprefix,'processparams_local.m'));
    if success
        disp([ upper(mfilename) ': Created ' fullfile(majorprefix,'processparams_local.m')]);
    end
elseif ~isempty(processparams_local([]))
    disp([ upper(mfilename) ': Local parameter settings in processparams_local:']);
    disp(processparams_local([]));
end
disp([ upper(mfilename) ': To override InVivoTools settings: edit processparams_local']);

% defaults, put overrides in processparams_local.m file
params.load_general = 1; % necessary for host function
params.load_nelsonlabtools = 0; % needed for analysis of Nelson Lab data
params.load_newstim = 1; % needed for visual stimulation NewStim package
params.load_neuralanalysis = 1; % needed for electrophysiology analysis
params.load_twophoton = 0; % needed for twophoton analysis
params.load_intrinsicsignal = 0; % needed for optical imaging analysis
params.load_electrophys = 1; % needed for electrophysiology recording and analysis
params.load_expdatatools = 1; % needed for InVivoTools analysis
params.load_webcam = 1; % needed for InVivoTools analysis
params.load_headcam = 1; % needed for InVivoTools freely moving head cam analysis
params.load_physiology = 1; % needed for EXG recordings
params.load_histology = 1; % needed for matching histology to Allen Mouse Brain Atlas
params.load_dataarchiving = 1; % needed for preparing project for archiving

% set default lab, can be overruled depending on host:
% alternatives 'Fitzpatrick','Levelt','Lohmann'
% is case-sensitive!
params.lab='Levelt';

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
        fullfile(path2general,'database','matlab_7'));
end

params = processparams_local(params); % load local overrides

path2invivotools = majorprefix;

if params.load_expdatatools
    path2expdatatools = fullfile(path2invivotools,'ExpDataTools');
    % path2expdatatools = [path2expdatatools ';' fullfile(path2expdatatools,'MdbTools')]; % files to use Leveltlab MS Access mouse database
    path2expdatatools = [path2expdatatools ';' fullfile(path2expdatatools,'Labs',params.lab)]; % add some lab specific tools
    addpath(path2expdatatools);
end

if params.load_webcam
    addpath(fullfile(path2invivotools,'Webcam'));
end

if params.load_headcam
    addpath(fullfile(path2invivotools,'Headcam'));
end

% Twophoton package
if params.load_twophoton
    twophoton_path = fullfile(path2invivotools,'TwoPhoton');

    switch params.lab
        case 'Lohmann'
            twophoton_microscope_type='Lohmann';
        case 'Levelt'
            twophoton_microscope_type='FluoView';
        case 'Fitzpatrick'
            twophoton_microscope_type='PrairieView';
    end
    
    addpath(twophoton_path, ...
        fullfile(twophoton_path, 'Reid_cell_finder' ),...
        fullfile(twophoton_path, 'Reid_cell_finder' , 'basic_findcell'),...
        fullfile(twophoton_path, 'Synchronization' , params.lab) ,...
        fullfile(twophoton_path, 'Laser' , params.lab),...
        fullfile(twophoton_path, 'Platforms', twophoton_microscope_type));
    
    addpath(twophoton_path, ...
        genpath([path2invivotools filesep 'Scanbox_Yeti']),...
        genpath([path2invivotools filesep 'NoRMCorre']),...
        genpath([path2invivotools filesep 'matlab-ParforProgress2']));
    
    load_scanbox;
    
    if exist('java','file') && usejava('jvm')
        javaaddpath(fullfile(twophoton_path,'Reid_cell_finder/java'));
        % now check if ij.jar file is already in the javaclasspath
        % ij.jar is the ImageJ javaclass and used in Reid_cell_finder
        jvc=javaclasspath('-all');
        found_ij=strfind(jvc,'ij.jar');
        found_ij= (sum([found_ij{:}])>0);
        if ~found_ij
            javaaddpath(fullfile(twophoton_path,'Reid_cell_finder/ij/ij.jar'));
        end
    end
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
end

% Physiology analyses
if params.load_physiology
    addpath(fullfile(path2invivotools,'Physiology'),...
        fullfile(path2invivotools,'Physiology','video'));    % for video 
end

% NeuralAnalysis package
if params.load_neuralanalysis
    tmppath=pwd;
    cd(fullfile(path2invivotools,'NeuralAnalysis'));
    NeuralAnalysisObjectInit;
    cd(tmppath);
end

% NewStim package to show and analyse visual stimuli
if params.load_newstim
    % for NewStim3 this folder is configuration
    % NewStimConfig file in that folder should be out of version control
    % ideally should get different location, but called like this in
    % NewStim3/NewStimInit, also used for optical imaging
    addpath(fullfile(majorprefix,'Configuration'),...
        fullfile(path2invivotools,'NewStim3'),...
        fullfile(path2invivotools,'Calibration'),...    % some calibration files for the packages that depend on each computer
        fullfile(path2invivotools,'Calibration','Monitors'));
    NewStimInit;
end

% Nelsonlab tools, must be after NewStim package
if params.load_nelsonlabtools
    tmppath = pwd;
    cd(fullfile(path2invivotools,'NelsonLabTools'));
    NelsonLabToolsInit; % initializing
    cd(tmppath);
end

% Intrinsic Signal Optical Imaging package
if params.load_intrinsicsignal
    addpath(fullfile(path2invivotools,'OpticalImaging'),...
        fullfile(path2invivotools,'OpticalImaging','Arduino'),...
        fullfile(path2invivotools,'OpticalImaging','IntrinsicSignalStimuli3'),...
        fullfile(path2invivotools,'OpticalImaging','IntrinsicSignalStimuli3','coherence_dots'),...
        fullfile(path2invivotools,'OpticalImaging','IntrinsicSignalStimuli3','opticflow_dots'),...
        fullfile(path2invivotools,'OpticalImaging','IntrinsicSignalStimuli3','rotating_dots'),...
        fullfile(majorprefix,'Configuration'));    % next contains camera framerates
end

% Histology and Allen Atlas matching
if params.load_histology
    addpath(fullfile(path2invivotools,'Histology'));
    addpath(fullfile(path2invivotools,'Histology','Allenatlasmatching'));
end
    
if params.load_dataarchiving
    addpath(fullfile(path2invivotools,'DataArchiving'));
end

% % Call Psychtoolbox-3 specific startup function:
% if exist('PsychStartup','file')
%     PsychStartup;
% end

% if isunix % bug workaround for Matlab R2012b and more recent
%     % see e.g. http://www.mathworks.com/matlabcentral/answers/114915-why-does-matlab-cause-my-cpu-to-spike-even-when-matlab-is-idle-in-matlab-8-0-r2012b
%     try 
%         com.mathworks.mlwidgets.html.HtmlComponentFactory.setDefaultType('HTMLRENDERER')
%     catch me    
%         disp(['LOAD_INVIVOTOOLS: ' me.message])
%     end
% end

if isoctave
    warning('on','Octave:shadowed-function');
end

