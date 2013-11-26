% This function does not do much but calling the proper analysis funtion
% I use eval for that, although I tried run before I decided this was nicer
% Because now the functions run in their own 'workspace' and one can esily 
% transmit variables. But most of all, this makes calling the functions
% from other places (ie matlab prompt) much easier.

function [ output_args ] = erg_analysis_block(ergLog, NR)
  global ergConfig;
  
  filename = [ergConfig.datadir ergLog.dataSubDir filesep ergLog.dataFilePrefix num2str(NR,'%03d') ' - DATA.mat'];
  calibfilename = [ergConfig.datadir ergLog.dataSubDir filesep ergLog.dataFilePrefix num2str(NR,'%03d') ' - CALIBRATION.mat'];
  f = [ergConfig.analysisdir filesep 'erg_analysis_block_' ergLog.Entry(NR).analysis '()'];
  eval(['erg_analysis_block_' ergLog.Entry(NR).analysis '(''' filename ''',''' calibfilename ''')']);


  

