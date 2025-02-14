function [responses,testname]=measure_responses(chromosomes,cksds,cellname, ...
				     param,verbose)
%MEASURE_RESPONSES shows chromosomes movies and calculate responses
%
%  [RESPONSES,TESTNAME]=MEASURE_RESPONSES(CHROMOSOMES,CKSDS,NAMEREF,PARAM)
%
%
%  
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel (heimel@brandeis.edu)
%
 
if nargin<5
  verbose=0;
end




sms_script = create_moviescript(chromosomes,param);
testname = show_moviescript(sms_script,verbose);
wait_to_end_recording(cksds,testname);
fprintf('Waiting for extraction to finish.\n');
responses=calculate_responses(cksds,testname,cellname,param.bins,param.repeats);
sum(responses)

