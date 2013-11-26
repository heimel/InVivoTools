function handle=plot_chromosome(chromosome,param,handle)
%PLOT_CHROMOSOME plots chromosome 
%
%   HANDLE=PLOT_CHROMOSOME(CHROMOSOME,PARAM,HANDLE)
%      CHROMOSOME is array of gene struct
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel
%
if nargin<3
  handle=figure;
end
if nargin<2
  param=genetic_defaults;
end

clip = create_pseudoclips( {chromosome}, param );
sclip=smooth_clip(clip{1});
plot_clip(sclip,handle);

