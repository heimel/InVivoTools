function output = spikedetect(prefix, recname, recparam, algor, ...
                                  algor_p, output_type, output_p);

curr_dir = pwd;

cd(prefix);

sdpath = which('spikedetect');sdpath = [sdpath(1:end-2) 'ors'];addpath(sdpath);
sd_alg = ['sd_' algor];
dummy = which(sd_alg);

eval(['output=' sd_alg '(recname, recparam, algor_p, output_type, output_p);']);

rmpath(sdpath);
cd(curr_dir);
