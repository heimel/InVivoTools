% erg_getdata_div retrieves various saved structures. It takes them from
% a cache file or from erg_getdata_raw when no cache is available yet.
%
% This file does not depend on channel-number, all parameters that are 
% returned are saved only once per block.

function [block duration stimuli] = erg_getdata_div(filename)
 global ergConfig;

 cache_filename = [filename(1:end-8) 'CACHE_DIV.mat'];
 if (ergConfig.getdata_cache_load_div && exist(cache_filename,'file'))
   load(cache_filename);
   return;
 else
   data_saved = erg_getdata_raw(filename);
   if isempty(data_saved)
       block = [];
       duration = [];
       stimuli = [];
       return
   end
   block = data_saved.block;
   duration = data_saved.msecs;
   stimuli = data_saved.stimuli;
 end
 
% Actually this is already performed by getdata_raw, no need to do it twice
% if (ergConfig.getdata_cache_save_div)
%     save(cache_filename, 'block','duration','stimuli');
% end;      
