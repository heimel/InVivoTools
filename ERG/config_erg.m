% The file config_erg used the current directory ('cd') to define all
% other folders. This makes it possible to move the whole thing to another
% location
%
% As a convention, all foldernames end WITHOUT final slash
function [ output_args ] = config_erg( input_args )
  global ergConfig;
  
  if (isempty(ergConfig)) 
    curpath = fileparts(which('erg_master_window'));
    
    switch host
        case 'mouse_erg' % mouse erg computer
            ergConfig.datadir = ['F:\Data'];
        case 'eto'  % alexander's laptop
            ergConfig.datadir='/home/data/InVivo/ERG';
        case 'nin278' % lucie's old computer
            ergConfig.datadir='C:\Users\pellissier\Documents\ERG';
        case 'nin381' % lucie's new computer
            ergConfig.datadir='C:\Users\pellissier\My Documents\MATLAB';
        otherwise % assume on network
            ergConfig.datadir = fullfile(networkpathbase,'ERG');
            if ~exist(ergConfig.datadir,'dir')
                ergConfig.datadir = pwd;
            end
    end
    
    params.ergdatapath_localroot = ergConfig.datadir;
    params = processparams_local(params);
    ergConfig.datadir =  params.ergdatapath_localroot;
    
    ergConfig.blockdir = fullfile(curpath,'Blocks');
    ergConfig.protocoldir = fullfile(curpath,'Protocols');
    ergConfig.analysisdir = fullfile(curpath,'Analysis');
    ergConfig.basedir = [curpath];
    ergConfig.analyzeAppendFile = fullfile(ergConfig.datadir,'analyze.m');

 
    addpath (curpath);
    addpath (ergConfig.protocoldir);
    addpath (ergConfig.blockdir);
    addpath(fullfile(curpath,'IO'));
    addpath(fullfile(curpath,'Analysis'));
    addpath(fullfile(curpath,'Includes'));

    addpath (ergConfig.datadir);
    
  end
  
  ergConfig.max_prepulse_samples = 100;
    
  %Calculated in CIE-curves as cval9, used to calculate back and forth between photodiode readouts (based 5ms summations) and candela's
  ergConfig.convert2cd.blue = 0.17941913396/1000;
  disp('CONFIG_ERG: Not measured conversion of green and UV photosensor values to candelas');
  ergConfig.convert2cd.green = 0.17941913396/1000; %we should actually calculate this, current value is copy-pasted from blue led
  ergConfig.convert2cd.UV = 0.17941913396/1000;    %we should actually calculate this, current value is copy-pasted from blue led
  ergConfig.convertToCD = ergConfig.convert2cd.blue; %this one is actually for backwards compatibility
   
  disp('CONFIG_ERG: Set voltage amplification to 10,000');
  ergConfig.voltage_amplification = 10000;
  
  ergConfig.maxInputChannels = 2;

  ergConfig.gaussianfilter_bwave = 8; % in ms. Set to NaN to turn off filter
  disp(['CONFIG_ERG: Filters data for b-wave by gaussian with sigma ' num2str(ergConfig.gaussianfilter_bwave) ' ms']);

  
  %this is used by some analysis functions that want to share a figure with subplots
  ergConfig.subplotfig = -1;

  %Setting one of these to 0 will force getdata functions to ignore
  %existence of cache files, whether it will make/overwrite new ones depends on cache_save.
  %Note: If a lower getdata set is cached, it will be of no use to refress higher ones
  ergConfig.getdata_cache_load_avg = 1; %averages
  ergConfig.getdata_cache_load_div = 1; %various data from raw file, like stims, duration & protocol data
  ergConfig.getdata_cache_load_bsc = 1; %basic data such as a-wave and stuff
  ergConfig.getdata_cache_load_ops = 1; %OPs: filtered signal, FFT data and some parameters
  
  %Setting one of these to 0 will disable all caching saving. Caches will
  %be loaded though if they are already available, unless cache_load is set to 0
  ergConfig.getdata_cache_save_avg = 1;  
  ergConfig.getdata_cache_save_div = 1;
  ergConfig.getdata_cache_save_bsc = 1;
  ergConfig.getdata_cache_save_ops = 1;
  
ergConfig.recompute = true; % can force the program to recompute