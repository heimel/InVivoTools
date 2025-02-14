
ci = get_clock_info(prefix);

ci(2,1) = ci(1,1)+60*30;  % fudge for this data set
ci(4,1) = ci(3,1)+60*30;  % fudge for this data set
ci(2,2) =ci(1,2); ci(4,2) =ci(3,2); % fudge for this data set

prefix = '/home/vanhoosr/nelson/experiment_analysis/acq_ch_01207/';

recname = 'tet1';
recparam = struct ('ref', 2, 'channel', 1);

filter = struct('method','conv','B',[ 1 1 1 1 1 ], 'A', []);
algor = 'threshold';
algor_p=struct ('automatic', 1, 'threshold_value', 4, 'threshold_sign', -1,...
			'num_above', 1, 'filter',filter,'update',0);

output_type = 'cksmultiunit';
output_p = struct ('filename', 'tet1_c1','clock_convers',ci, ...
		'desc_brief','tet1c1pos2','desc_long','this is a test', ...
		'filename_obj','analysis/tet1c1pos2.mu');

outp=spikedetect(prefix,recname,recparam,algor,algor_p,output_type,output_p);
