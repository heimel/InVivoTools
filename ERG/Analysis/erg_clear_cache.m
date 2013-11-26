%This file removes all cache files present. ergConfig should be global
%To prevent accidents you have to manually change the date in the source to
%the current date in order to be able to execute this function.

function [ output_args ] = erg_clear_cache( input_args )

  global ergConfig;
  
  % Change the date at the end of next statement to current date to run, be
  % cautious...
  if (~strcmp(datestr(now,'dd-mm-yyyy'),'23-10-2007')) 
    disp('This file removes all cache files, should be executed with safety and only after all data is backed up.')
    disp('Change the date in the source file to run, this is a safety measure.');
    return;
  end
  
  s = {'AVG','BSC','DIV','OPS'};
  for i = 1:length(s)
    [d e f] = dirr([ergConfig.datadir filesep '*CACHE_' s{i} '.mat'],'name');
    for j = 1:length(f)
      disp(['DELETING ' f{j}]);
      delete(f{j});
    end
  end