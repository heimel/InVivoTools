function sms_script=create_moviescript(chromosomes,param)
%CREATE_MOVIESCRIPT creates moviescript from chromosomes
%
%   SMS_SCRIPT=CREATE_MOVIESCRIPT(CHROMOSOMES,PARAM)
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel (heimel@brandeis.edu)
%


  % get rectangle center from screentool 
  % and calculate screen window size and position accordingly
  [cr,dist,sr]=get_screentoolparams; % local function
  center=round([ (cr(1)+cr(3))/2 (cr(2)+cr(4))/2 ]); %putative center
  ul=max(round(center-param.window*param.scale/2),[1 1]);
  br=ul+param.window*param.scale;
  cr=[ul br];
  set_screentool_cr(cr);
  
  sms=shapemoviestim('default'); 
p=getparameters(sms);
  p.rect=cr;
  p.BG=param.background'; 
  p.scale=param.scale;      
  p.fps= 1/(param.time_per_frame*0.001);  % frames per second
  p.N=param.duration;               % number of frames per movie
  p.isi=param.isi;                   % interstimulus interval
  p.dispprefs={'BGpretime',param.BGpretime}

  sms=setparameters(sms,p);
  sms=addshapemovies(sms,chromosomes);
  sms_script=stimscript(0);
  sms_script=setDisplayMethod(append(stimscript(0),sms),1, ...
 					    param.repeats);
