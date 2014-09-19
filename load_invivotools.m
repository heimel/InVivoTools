function load_invivotools
%LOAD_INVIVOTOOLS
%
% LOAD_INVIVOTOOLS sets alls paths to InVivoTools and runs some
%    initialization scripts
%
%    check https://github.com/heimel/InVivoTools for most recent version
%    and documentation. In Manual folder
%
% 2014, Alexander Heimel
%

if isunix
    updatestr = ['To update InVivoTools from terminal: cd ' fileparts(mfilename('fullpath')) ...
        '; git pull'];
else
    updatestr = 'To update InVivoTools: open github and click on Sync.';
end
disp([ upper(mfilename) ': ' updatestr]);

majorprefix = fileparts(mfilename('fullpath'));
addpath(fullfile(majorprefix));

if ~exist('processparams_local.m','file')
    success = copyfile(which('processparams_local_org.m'),fullfile(majorprefix,'processparams_local.m'));
    if success
        disp([ upper(mfilename) ': Created ' fullfile(majorprefix,'processparams_local.m')]);
    end
end
disp([ upper(mfilename) ': To override InVivoTools settings: edit processparams_local']);


% defaults, put overrides in processparams_local.m file
params.load_general = 1; % necessary for host function
params.load_nelsonlabtools = 1; % needed for analysis, should be phased out
params.load_newstim = 1; % needed for visual stimulation NewStim package
params.load_neuralanalysis = 1; % needed for electrophysiology analysis
params.load_twophoton = 1; % needed for twophoton analysis
params.load_intrinsicsignal = 1; % needed for optical imaging analysis
params.load_erg =1; % need for ERG stimulation and analysis
params.load_electrophys = 1; % needed for electrophysiology recording and analysis
params.load_expdatatools = 1; % needed for InVivoTools analysis
params.load_studies = {}; % folders of Studies to load

% set default lab, can be overruled depending on host:
% alternatives 'Fitzpatrick','Levelt','Lohmann'
% is case-sensitive!
params.lab='Levelt';

params = processparams_local(params); % load local overrides


if params.load_general, % general
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


path2invivotools = majorprefix;


if params.load_expdatatools
    path2expdatatools = fullfile(path2invivotools,'ExpDataTools');
    addpath(path2expdatatools, ...
        fullfile(path2expdatatools,'MdbTools'),...   % files to use Leveltlab MS Access mouse database
        fullfile(path2expdatatools,'Labs',params.lab));% add some lab specific tools
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
    addpath(fullfile(path2invivotools,'Electrophysiology'),...
        fullfile(path2invivotools,'Electrophysiology','Son'),...    %libraries for importing spike2 data
        fullfile(path2invivotools,'Electrophysiology','TDT'),... % for importing tdt data in linux
        genpath(fullfile(path2invivotools,'Electrophysiology','MClust-3.5')));    % for MClust spike sorter
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
    tmppath=pwd;
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

% ERG software
if params.load_erg
    ergpath = fullfile(path2invivotools,'ERG');
    addpath(ergpath,fullfile(ergpath,'usbActiveWire'));
end

% Temp folder for work in progress
addpath(fullfile(path2invivotools,'Temp'));

% Call Psychtoolbox-3 specific startup function:
if exist('PsychStartup','file')
    PsychStartup;
end

% load Study specific folders
studiespath = cellfun(@(x) fullfile(majorprefix,'Studies',x),params.load_studies,'UniformOutput',false);
addpath(studiespath{:});

clear
