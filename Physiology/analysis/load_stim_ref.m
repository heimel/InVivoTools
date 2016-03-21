function [stim_par]=load_stim_ref(file_path_name_stim)
%LOAD_STIM_REF reads stim.mat -> returns struct containing relevant
%stimulus parameters
%   
%   march 2016 S.E. Lansbergen
%

% load stimulus
load(file_path_name_stim);
tmp = get(saveScript);

% size saveScript contains information about the number of stimulus in a
% script.
[~,ind] = size(tmp);

% run loop over all stimuli and retrieve stimulus data
for i = 1:ind
tmp = getparameters(tmp{i});
end

% retrieve baseline time
stim_par.baseline = tmp.dispprefs{2};

% retrieve total stimulus time
stim_par.stim_time = (tmp.expansiontime + tmp.statictime) * tmp.n_repetitions;


logmsg(' *** Stimulus parameters loaded ***')
end
