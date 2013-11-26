function NeuralAnalysisObjectInit

pwd = which('NeuralAnalysisObjectInit');

pi = find(pwd==filesep); pwd = [pwd(1:pi(end)-1) filesep];

addpath(pwd);
addpath([pwd 'MeasuredData']);
addpath([pwd 'Analyses_objects']);
addpath([pwd 'Analyses_routines']);
addpath([pwd 'Analyses_routines' filesep 'periodicstim_continuous']);
addpath([pwd 'general']);
addpath([pwd 'UtilityProcs']);
addpath([pwd 'DataManagement']);

g = measureddata([1 2],'','');
g = spikedata([1 2],'','');
