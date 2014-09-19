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
    updatestr = ['To update from terminal: cd ' fileparts(mfilename('fullpath')) ...
        '; git pull'];
else
    updatestr = 'To update: open github and click on Sync.';
end
disp([ upper(mfilename) ': Adding paths for InVivoTools. ' updatestr]);

majorprefix = fileparts(mfilename('fullpath'));
addpath(fullfile(majorprefix));

if ~exist('processparams_local.m','file')
    success = copyfile(which('processparams_local_org.m'),fullfile(majorprefix,'processparams_local.m'));
    if success
        disp([ upper(mfilename) ': Created ' fullfile(majorprefix,'processparams_local.m')]);
    end
end
disp([ upper(mfilename) ': To override InVivoTools processing settings: edit processparams_local']);


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
    addpath(path2general);
    addpath(fullfile(path2general,'structUtility'));
    addpath(fullfile(path2general,'graphs'));
    addpath(fullfile(path2general,'database'));
    addpath(fullfile(path2general,'filelocking'));
    addpath(fullfile(path2general,'stats'));
    addpath(fullfile(path2general,'plot2svg'));
    addpath(fullfile(path2general,'morph'));
    addpath(fullfile(path2general,'model3d'));
    addpath(fullfile(path2general,'filters'));
    addpath(fullfile(path2general,'icons')); % used for tp gui
    addpath(fullfile(path2general,'Wavelet','Wavelet Basics')); % used for erp analysis, Timo
    addpath(fullfile(path2general,'Wavelet','sinefit')); % used for erp analysis, Timo
    addpath(fullfile(path2general,'uitools'));
    addpath(fullfile(path2general,'CircStat')); % circular statistics toolbox
    addpath(fullfile(path2general,'database','matlab_7'));
end


path2invivotools = majorprefix;


if params.load_expdatatools
    path2expdatatools = fullfile(path2invivotools,'ExpDataTools');
    addpath(path2expdatatools);
    
    % add some lab specific tools
    labpath = fullfile(path2expdatatools,'Labs',params.lab);
    if exist(labpath,'dir')
        addpath(labpath);
    end
    
    % files to use Leveltlab MS Access mouse database
    addpath(fullfile(path2invivotools,'ExpDataTools','MdbTools'));
end

% Twophoton package
if params.load_twophoton
    twophoton_path=fullfile(path2invivotools,'TwoPhoton');
    addpath(twophoton_path);
    addpath(fullfile(twophoton_path, 'Reid_cell_finder' ));
    addpath(fullfile(twophoton_path, 'Reid_cell_finder' , 'basic_findcell'));
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
    
    switch params.lab
        case 'Lohmann'
            twophoton_microscope_type='Lohmann';
        case 'Levelt'
            twophoton_microscope_type='FluoView';
        case 'Fitzpatrick'
            twophoton_microscope_type='PrairieView';
    end
    addpath(fullfile(twophoton_path, 'Synchronization' , params.lab));
    addpath(fullfile(twophoton_path, 'Laser' , params.lab));
    addpath(fullfile(twophoton_path, 'Platforms', twophoton_microscope_type));
end

% Electrophysiology analyses
if params.load_electrophys
    addpath(fullfile(path2invivotools,'Electrophysiology'));
    %libraries for importing spike2 data
    addpath(fullfile(path2invivotools,'Electrophysiology','Son'));
    % for importing tdt data in linux
    addpath(fullfile(path2invivotools,'Electrophysiology','TDT'));
    % for MClust spike sorter
    addpath(genpath(fullfile(path2invivotools,'Electrophysiology','MClust-3.5')));
end

% NeuralAnalysis package
if params.load_neuralanalysis
    tmppath=pwd;
    cd(fullfile(path2invivotools,'NeuralAnalysis'));
    NeuralAnalysisObjectInit;
    cd(tmppath);
end

% Check if PTB is in path and collect version number
% (needs to work at MAC OS 9, PTB2)
% if exist('Screen','file')
%     ptbver =  PsychtoolboxVersion;
%     if isnumeric(ptbver) % to use PTB2 format
%         ptbverstring = num2str( ptbver);
%     else
%         if isempty(ptbver)
%             pause(0.05); % delayed needed for PsychtoolboxVersion
%             ptbver =  PsychtoolboxVersion;
%         end
%         ptbver(end+1)=10;
%         p = find(ptbver==10,1); % only interested in first line
%         ptbverstring = ptbver(1:p-1);
%     end
%     disp(['STARTUP: Psychophysics toolbox version ' ptbverstring ' included in path']);
%     if ~isempty(ptbver)
%         ptbver = str2double(trim(ptbverstring(1)));
%     end
% else
%     ptbver = NaN;
% end

% NewStim package to show and analyse visual stimuli
if params.load_newstim
    % for NewStim3 this folder is configuration
    % NewStimConfig file in that folder should be out of version control
    % ideally should get different location, but called like this in
    % NewStim3/NewStimInit, also used for optical imaging
    addpath(fullfile(majorprefix,'Configuration'));
    
    addpath(fullfile(path2invivotools,'NewStim3'));
    NewStimInit;
    % some calibration files for the packages that depend on each computer
    addpath(fullfile(path2invivotools,'Calibration'));
    addpath(fullfile(path2invivotools,'Calibration','Monitors'));
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
    addpath(fullfile(path2invivotools,'OpticalImaging'));
    addpath(fullfile(path2invivotools,'OpticalImaging','Arduino'));
    addpath(fullfile(path2invivotools,'OpticalImaging','IntrinsicSignalStimuli3'));
    addpath(fullfile(path2invivotools,'OpticalImaging','IntrinsicSignalStimuli3','coherence_dots'));
    addpath(fullfile(path2invivotools,'OpticalImaging','IntrinsicSignalStimuli3','opticflow_dots'));
    addpath(fullfile(path2invivotools,'OpticalImaging','IntrinsicSignalStimuli3','rotating_dots'));
    
    % next contains camera framerates
    addpath(fullfile(majorprefix,'Configuration'));
end

% ERG software
ergpath=fullfile(path2invivotools,'ERG');
addpath(ergpath);
addpath(fullfile(ergpath,'usbActiveWire'));

% Temp folder for work in progress
addpath(fullfile(path2invivotools,'Temp'));

% Call Psychtoolbox-3 specific startup function:
if exist('PsychStartup','file')
    PsychStartup;
end

% load Study specific folders
for i=1:length(params.load_studies)
    addpath(genpath(fullfile(majorprefix,'Studies',params.load_studies{i})));
end


clear
