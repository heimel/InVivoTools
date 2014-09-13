%STARTUP sets InVivoTools path
%
% 2004-1014, Alexander Heimel
%

% defaults
load_general = 1; % necessary for host function
load_invivotools = 1;
load_mclust = 1;
load_nelsonlabtools=1;
load_newstim=1;
load_neuralanalysis=1;
load_son=1;
load_tdt = 1;
load_twophoton=1;
load_intrinsicsignal=1;
load_erg=1;
load_electrophys = 1;

% set default lab, can be overruled depending on host:
% alternatives 'Fitzpatrick','Levelt','Lohmann'
% is case-sensitive!
lab='Levelt';

majorprefix = fileparts(which('startup.m'));

if load_general, % general
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
    addpath(fullfile(path2general,'CircStat'));
    addpath(fullfile(path2general,'database','matlab_7'));
end

hostname = host;

hosttype = 'omniscient';
switch hosttype
    case 'omniscient'
        load_nelsonlabtools=1;
        load_newstim=1;
        load_neuralanalysis=1;
        load_son=1;
        load_tdt = 1;
        load_twophoton=1;
        load_intrinsicsignal=1;
        load_erg=1;
        load_electrophys = 1;
    otherwise
        disp('STARTUP: Unknown hosttype. Check if host environment variable needs to be set.');
end

if isunix
    updatestr = ['To update from terminal: cd ' fileparts(mfilename('fullpath')) ...
        '; git pull'];
else
    updatestr = 'To update: open github and click on Sync.';
end
disp([ upper(mfilename) ': Adding path to InVivoTools. ' updatestr]);

path2invivotools = majorprefix;

% some calibration files for the packages that depend on each computer
addpath(fullfile(path2invivotools,'Calibration'));
addpath(fullfile(path2invivotools,'Calibration','Monitors'));

% for NewStim3 this folder is configuration
% NewStimConfig file in that folder should be out of version control
% ideally should get different location, but called like this in
% NewStim3/NewStimInit
addpath(fullfile(majorprefix,'Configuration'));

path2expdatatools = fullfile(path2invivotools,'ExpDataTools');
addpath(path2expdatatools);

% add some lab specific tools
labpath = fullfile(path2expdatatools,'Labs',lab);
if exist(labpath,'dir')
    addpath(labpath);
end

% files to use Leveltlab MS Access mouse database
addpath(fullfile(path2invivotools,'ExpDataTools','MdbTools'));

% Twophoton package
if load_twophoton
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
    
    switch lab
        case 'Lohmann'
            twophoton_microscope_type='Lohmann';
        case 'Levelt'
            twophoton_microscope_type='FluoView';
        case 'Fitzpatrick'
            twophoton_microscope_type='PrairieView';
    end
    addpath(fullfile(twophoton_path, 'Synchronization' , lab));
    addpath(fullfile(twophoton_path, 'Laser' , lab));
    addpath(fullfile(twophoton_path, 'Platforms', twophoton_microscope_type));
end

% Electrophysiology analyses
if load_electrophys
    addpath(fullfile(path2invivotools,'Electrophysiology'));
    if load_son % son libraries for importing spike2 data
        sonpath=fullfile(path2invivotools,'Electrophysiology','Son');
        if exist(sonpath,'dir')
            addpath(sonpath);
        end
    end
    
    if load_tdt % function for importing tdt data in linux
        tdtpath=fullfile(path2invivotools,'Electrophysiology','TDT');
        if exist(tdtpath,'dir')
            addpath(tdtpath);
        end
    end
    
    if load_mclust % spike sorter
        mclustpath=fullfile(path2invivotools,'Electrophysiology','MClust-3.5');  % spike sorter
        if exist(mclustpath,'dir')
            addpath(genpath(mclustpath));
        end
    end
end


% NeuralAnalysis package
if load_neuralanalysis
    tmppath=pwd;
    cd(fullfile(path2invivotools,'NeuralAnalysis'));
    NeuralAnalysisObjectInit;
    cd(tmppath);
end


% Check if PTB is in path and collect version number
% (needs to work at MAC OS 9, PTB2)
if exist('Screen','file')
    ptbver =  PsychtoolboxVersion;
    if isnumeric(ptbver) % to use PTB2 format
        ptbverstring = num2str( ptbver);
    else
        if isempty(ptbver)
            global Psychtoolbox
            Psychtoolbox=[];
            pause(0.03);
            ptbver =  PsychtoolboxVersion;
        end
        ptbver(end+1)=10;
        p = find(ptbver==10,1); % only interested in first line
        ptbverstring = ptbver(1:p-1);
    end
    disp(['STARTUP: Psychophysics toolbox version ' ptbverstring ' included in path']);
    if ~isempty(ptbver)
        ptbver = str2double(trim(ptbverstring(1)));
    end
else
    ptbver = NaN;
end

% NewStim package to show and analyse visual stimuli
if load_newstim
    addpath(fullfile(path2invivotools,'NewStim3'));
    addpath(fullfile(path2invivotools,'NewStim3','ReceptiveFieldMapper')); % should go to NewStimInit
    NewStimInit;
end

% Nelsonlab tools, must be after NewStim package
if load_nelsonlabtools
    tmppath=pwd;
    cd(fullfile(path2invivotools,'NelsonLabTools'));
    NelsonLabToolsInit; % initializing
    cd(tmppath);
end

% Intrinsic Signal Optical Imaging package
if load_intrinsicsignal
    addpath(fullfile(path2invivotools,'OpticalImaging'));
    addpath(fullfile(path2invivotools,'OpticalImaging','Arduino'));
    addpath(fullfile(path2invivotools,'OpticalImaging','IntrinsicSignalStimuli3'));
    addpath(fullfile(path2invivotools,'OpticalImaging','IntrinsicSignalStimuli3','coherence_dots'));
    addpath(fullfile(path2invivotools,'OpticalImaging','IntrinsicSignalStimuli3','opticflow_dots'));
    addpath(fullfile(path2invivotools,'OpticalImaging','IntrinsicSignalStimuli3','rotating_dots'));
end

% ERG software (Jochem Cornelis)
ergpath=fullfile(path2invivotools,'ERG');
addpath(ergpath);
addpath(fullfile(ergpath,'usbActiveWire'));


% Call Psychtoolbox-3 specific startup function:
if exist('PsychStartup','file')
    PsychStartup;
end


% Studies, specific analyses for studies
if 1 % Ahmadlou & Heimel, in prep
    addpath(fullfile(majorprefix,'Studies','SC'));
end
if 1 % Vangeneugden, Self et al. in prep
    addpath(fullfile(majorprefix,'Studies','Mapmaking'));
    addpath(fullfile(majorprefix,'Studies','Joris'));
    addpath(fullfile(majorprefix,'Studies','Joris','TDT2ML'));
end
if 1 % Saiepour et al. in prep
    addpath(fullfile(majorprefix,'Studies','OD_optogenetics'));
end
if 1 % Saiepour et al. in prep
    addpath(fullfile(majorprefix,'Studies','BCat'));
end
if 1 % Smit-Rigter et al. in prep
    addpath(fullfile(majorprefix,'Studies','Mitochondria'));
end
if 0 % Camillo, Levelt & Heimel, Frontiers in Neuroanatomy 2014
    addpath(fullfile(majorprefix,'Studies','Calretinin'));
end
if 0 % bxd analysis software (Alexander Heimel)
    addpath(fullfile(majorprefix,'Studies','bxd'));
end
if 0 % gephyrin analysis software (2011-2012, Alexander Heimel & Danielle van Versendaal)
    addpath(fullfile(majorprefix,'Studies','Gephyrin'));
end
if 0 % Heimel et al. 2010
    addpath(fullfile(majorprefix,'Studies','TrkB'));
    addpath(fullfile(majorprefix,'Studies','TrkB','Model'));
    addpath(fullfile(majorprefix,'Studies','TrkB','Model','phenomenology'));
end


if ~exist('processparams_local.m','file')
    success = copyfile(which('processparams_local_org.m'),fullfile(majorprefix,'processparams_local.m'));
    if success
        logmsg(['Created ' fullfile(majorprefix,'processparams_local.m')]);
    end
end
logmsg('To override InVivoTools processing settings: edit processparams_local');

clear
