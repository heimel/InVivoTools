function d = gephyrin_analyse_all( reanalyze )

% 1: m = md, c = control
% 2: p = spine, h = shaft, s = synapse
% 3: a = all, l = large, s = small
% 4: d = dendrite, p = punctum, m = mouse, s = stack

if nargin<1
    reanalyze = [];
end
if isempty(reanalyze)
    reanalyze = false;
end

spinecount_file = fullfile(tempdir,'puncta_data_all_all_all_stack_rajeev_dendrite_counting.mat');
if  0||reanalyze || ~exist(spinecount_file,'file')
    analyse_puncta_db('all','all','all','stack','','rajeev_dendrite_counting')
end
d.spinecount = load(spinecount_file);

punctacount_file = fullfile(tempdir,'puncta_data_all_synapse_all_stack_rajeev_dendrite_puncta_counting.mat');
if  0|| reanalyze || ~exist(punctacount_file,'file')
    analyse_puncta_db('all','synapse','all','stack','','rajeev_dendrite_puncta_counting')
end
d.punctacount = load(punctacount_file);


spinepunctacount_file = fullfile(tempdir,'puncta_data_all_spine_all_stack_rajeev_dendrite_puncta_counting.mat');
if   0||reanalyze || ~exist(spinepunctacount_file,'file')
    analyse_puncta_db('all','spine','all','stack','','rajeev_dendrite_puncta_counting')
end
d.spinepunctacount = load(spinepunctacount_file);


shaftpunctacount_file = fullfile(tempdir,'puncta_data_all_shaft_all_stack_rajeev_dendrite_puncta_counting.mat');
if  0|| reanalyze || ~exist(shaftpunctacount_file,'file')
    analyse_puncta_db('all','shaft','all','stack','','rajeev_dendrite_puncta_counting')
end
d.shaftpunctacount = load(shaftpunctacount_file);




mpad_file = fullfile(tempdir,'mpad.mat');
if  reanalyze || ~exist(mpad_file,'file')
    analyse_puncta_db('md','spine','all','neurite_hash',mpad_file);
end
d.mpad = load(mpad_file);


msad_file = fullfile(tempdir,'msad.mat');
if reanalyze || ~exist(msad_file,'file')
    analyse_puncta_db('md','synapse','all','neurite_hash',msad_file);
end
d.msad = load(msad_file);

rpad_file = fullfile(tempdir,'rpad.mat');
if  reanalyze || ~exist(rpad_file,'file')
    analyse_puncta_db('repeated','spine','all','neurite_hash',rpad_file);
end
d.rpad = load(rpad_file);

rsad_file = fullfile(tempdir,'rsad.mat');
if reanalyze || ~exist(rsad_file,'file')
    analyse_puncta_db('repeated','synapse','all','neurite_hash',rsad_file);
end
d.rsad = load(rsad_file);

rhad_file = fullfile(tempdir,'rhad.mat');
if reanalyze || ~exist(rhad_file,'file')
    analyse_puncta_db('repeated','shaft','all','neurite_hash',rhad_file);
end
d.rhad = load(rhad_file);


rsap_file = fullfile(tempdir,'rsap.mat');
if reanalyze || ~exist(rsap_file,'file')
    analyse_puncta_db('repeated','synapse','all','punctum',rsap_file);
end
d.rsap = load(rsap_file);



cpad_file = fullfile(tempdir,'cpad.mat');
if reanalyze || ~exist(cpad_file,'file')
    analyse_puncta_db('control','spine','all','neurite_hash',cpad_file);
end
d.cpad = load(cpad_file);

mhad_file = fullfile(tempdir,'mhad.mat');
if reanalyze || ~exist(mhad_file,'file')
    analyse_puncta_db('md','shaft','all','neurite_hash',mhad_file);
end
d.mhad = load(mhad_file);

chad_file = fullfile(tempdir,'chad.mat');
if reanalyze || ~exist(chad_file,'file')
    analyse_puncta_db('control','shaft','all','neurite_hash',chad_file);
end
d.chad = load(chad_file);

csad_file = fullfile(tempdir,'csad.mat');
if reanalyze || ~exist(csad_file,'file')
    analyse_puncta_db('control','synapse','all','neurite_hash',csad_file);
end
d.csad = load(csad_file);

mpld_file = fullfile(tempdir,'mpld.mat');
if reanalyze || ~exist(mpld_file,'file')
    analyse_puncta_db('md','spine','large','neurite_hash',mpld_file);
end
d.mpld = load(mpld_file);


mpsd_file = fullfile(tempdir,'mpsd.mat');
if reanalyze || ~exist(mpsd_file,'file')
    analyse_puncta_db('md','spine','small','neurite_hash',mpsd_file);
end
d.mpsd = load(mpsd_file);

cpld_file = fullfile(tempdir,'cpld.mat');
if reanalyze || ~exist(cpld_file,'file')
    analyse_puncta_db('control','spine','large','neurite_hash',cpld_file);
end
d.cpld = load(cpld_file);


cpsd_file = fullfile(tempdir,'cpsd.mat');
if reanalyze || ~exist(cpsd_file,'file')
    analyse_puncta_db('control','spine','small','neurite_hash',cpsd_file);
end
d.cpsd = load(cpsd_file);


chld_file = fullfile(tempdir,'chld.mat');
if reanalyze || ~exist(chld_file,'file')
    analyse_puncta_db('control','shaft','large','neurite_hash',chld_file);
end
d.chld = load(chld_file);


chsd_file = fullfile(tempdir,'chsd.mat');
if reanalyze || ~exist(chsd_file,'file')
    analyse_puncta_db('control','shaft','small','neurite_hash',chsd_file);
end
d.chsd = load(chsd_file);


mhld_file = fullfile(tempdir,'mhld.mat');
if reanalyze || ~exist(mhld_file,'file')
    analyse_puncta_db('md','shaft','large','neurite_hash',mhld_file);
end
d.mhld = load(mhld_file);


mhsd_file = fullfile(tempdir,'mhsd.mat');
if reanalyze || ~exist(mhsd_file,'file')
    analyse_puncta_db('md','shaft','small','neurite_hash',mhsd_file);
end
d.mhsd = load(mhsd_file);



msld_file = fullfile(tempdir,'msld.mat');
if reanalyze || ~exist(msld_file,'file')
    analyse_puncta_db('md','synapse','large','neurite_hash',msld_file);
end
d.msld = load(msld_file);


mssd_file = fullfile(tempdir,'mssd.mat');
if reanalyze || ~exist(mssd_file,'file')
    analyse_puncta_db('md','synapse','small','neurite_hash',mssd_file);
end
d.mssd = load(mssd_file);

msmd_file = fullfile(tempdir,'msmd.mat');
if reanalyze || ~exist(msmd_file,'file')
    analyse_puncta_db('md','synapse','medium','neurite_hash',msmd_file);
end
d.msmd = load(msmd_file);



csld_file = fullfile(tempdir,'csld.mat');
if reanalyze || ~exist(csld_file,'file')
    analyse_puncta_db('control','synapse','large','neurite_hash',csld_file);
end
d.csld = load(csld_file);


cssd_file = fullfile(tempdir,'cssd.mat');
if reanalyze || ~exist(cssd_file,'file')
    analyse_puncta_db('control','synapse','small','neurite_hash',cssd_file);
end
d.cssd = load(cssd_file);

filename = fullfile(tempdir,'osad.mat');
if reanalyze || ~exist(filename,'file')
    analyse_puncta_db('mono','synapse','all','neurite_hash',filename);
end
d.osad = load(filename);
disp('GEPHYRIN_ANALYSE_ALL: Temporary fix for missing timepoint mouse 10.24.2.70, tuft2');
d.osad.relative_lost(end,7) = NaN;
d.osad.relative_lost(12,7) = NaN; % don't know why, should be checked, point was present earlier
%d.osad.relative_lost(7,7) = NaN; % don't know why, should be checked, point was present earlier


filename = fullfile(tempdir,'ohad.mat');
if reanalyze || ~exist(filename,'file')
    analyse_puncta_db('mono','shaft','all','neurite_hash',filename);
end
d.ohad = load(filename);
disp('GEPHYRIN_ANALYSE_ALL: Temporary fix for missing timepoint mouse 10.24.2.70, tuft2');
d.ohad.relative_lost(end,7) = NaN;
d.ohad.relative_lost(10,7) = NaN; % don't know why
%d.ohad.relative_lost(6,7) = NaN; % don't know why


filename = fullfile(tempdir,'opad.mat');
if reanalyze || ~exist(filename,'file')
    analyse_puncta_db('mono','spine','all','neurite_hash',filename);
end
d.opad = load(filename);
disp('GEPHYRIN_ANALYSE_ALL: Temporary fix for missing timepoint mouse 10.24.2.70, tuft2');
%d.opad.relative_lost(end,7) = NaN;
d.opad.relative_lost(9,7) = NaN; % don't know why

filename = fullfile(tempdir,'osam.mat');
if reanalyze || ~exist(filename,'file')
    analyse_puncta_db('mono','synapse','all','mouse',filename);
end
d.osam = load(filename);

filename = fullfile(tempdir,'osas.mat');
if reanalyze || ~exist(filename,'file')
    analyse_puncta_db('mono','synapse','all','stack',filename);
end
d.osas = load(filename);
