
prefix = '/home/vanhoosr/nelson/experiment_analysis/acq_ch_01207/';

recname = 'tet1';
recparam = struct ('ref', 2, 'channel', 1);

filter = struct('method','conv','B',[ 1 1 1 1 1 ], 'A', []);
algor = 'threshold';
algor_p=struct ('automatic', 1, 'threshold_value', 3, 'threshold_sign', -1,...
			'num_above', 1, 'filter',filter);

output_type = 'cksmultiunit';
output_p = struct ('filename', 'tet1_c1');


spikedetect(prefix,recname,recparam,algor,algor_p,output_type,output_p);
