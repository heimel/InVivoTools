%erg_getdata_raw: gets raw data from savefile, basically its results, stims and some
%protocol data. The latter small thingies will be saved.
%
%This file works on a multi-channel basis: channels are returned as they
%are saved: data_saved.results1, data_saved.results2, etc. In case of older
%file layouts this is adjusted to fit the multi-channel nomenclature 

function [data_saved] = erg_getdata_raw(filename)
  global ergConfig;
  
  if ~exist(filename,'file')
      errormsg(['File ' filename ' does not exist.']);
      data_saved = [];
      return
  end
  
  load(filename,'data_saved');
 
  %Backwards compatibility
  if (~ismember('numchannels',fieldnames(data_saved.block))) 
    data_saved.block.numchannels = 1; 
    data_saved.results1 = data_saved.results;
    data_saved.results =  []; 
  end

  cache_filename = [filename(1:end-8) 'CACHE_DIV.mat'];
  if ((ergConfig.getdata_cache_save_div && ~exist(cache_filename,'file')) || (ergConfig.getdata_cache_save_div && exist(cache_filename,'file') && ~ergConfig.getdata_cache_load_div))
     block = data_saved.block;
     duration = data_saved.msecs;
     stimuli = data_saved.stimuli;
     save(cache_filename, 'block','duration','stimuli');
  end;      
