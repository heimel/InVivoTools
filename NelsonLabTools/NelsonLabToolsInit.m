pwd = which('NelsonLabToolsInit');

pi = find(pwd==filesep); pwd = [pwd(1:pi(end)-1) filesep];

addpath(pwd);
addpath([pwd 'GeneticRFMapper']);
addpath([pwd 'data_extraction']);
addpath([pwd 'ExperimentPanels']);
addpath([pwd 'ExperimentPanels' filesep 'usefulcalls']);
addpath([pwd 'data_extraction' filesep 'tempfuncs']);
addpath([pwd 'data_extraction' filesep 'spike2cell']);
addpath([pwd 'Utility']);
addpath([pwd 'Analysis']);
addpath([pwd 'Analysis' filesep 'lgnanalysis']);
addpath([pwd 'Analysis' filesep 'lgnctxanalysis']);
addpath([pwd 'Analysis' filesep 'lgnctxcsdanalysis']);
addpath([pwd 'Analysis' filesep 'ctxanalysis']);
addpath([pwd 'Analysis' filesep 'mlanalysis']);
addpath([pwd 'Analysis' filesep 'general']);

windowdiscriminator('default');
cksmultipleunit([1 2],'','',1.5,[]);
wdcluster('default');
multiextractor('default');
dotdiscriminator('default');

NelsonLabToolsInitLocal;

clear('pi','pwd');
