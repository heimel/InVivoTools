% NewStimObjectInit - Intializes object types for NewStim package
%
%  NEWSTIMOBJECTINIT
%
%   This function loops through all stimulus types in NEWSTIMDIR/STIMULI
%       and NEWSTIMDIR/SCRIPTS and calls all of the object types with no
%       arguments.  This ensures all types are defined at startup, so they
%       will be recognized by Matlab when reading files from disk, and so
%       they will be registered in the list of stim types and script types.
%       (NEWSTIMLIST and NEWSTIMSCRIPTLIST)
%       

 %  this is a work-around for loading matlab object files...matlab must have
 %  seen the object type before loading.


pwd = which('NewStimInit');
pi = find(pwd==filesep); pwd = [pwd(1:pi(end)-1) filesep];
d1 = dir([pwd 'Stimuli' filesep '*']);
d2 = dir([pwd 'Scripts' filesep '*']);


for i=1:length(d1),
	if d1(i).isdir&length(d1(i).name)>=2,
		if strcmp(d1(i).name(1),'@'),
			eval([d1(i).name(2:end) ';']);
		end;
	end;
end;

for i=1:length(d2),
	if d2(i).isdir&length(d2(i).name)>=2,
		if strcmp(d2(i).name(1),'@'),
			eval([d2(i).name(2:end) ';']);
		end;
	end;
end;

return;

 % in the olden days, we used to make all of these calls manually

if 1,

   eval(['temp_stim = stimulus(5);']);

   clear temp_stim

end;

if 1, % displayPrefs

   temp_dp_p = {'fps',1,'rect',[0 0 1 1],'frames',1};

   eval(['temp_dp = displayprefs(temp_dp_p);']);

   clear temp_dp temp_dp_p
 
end;

if 1, %  displaystruct


  temp_dS_p = {'displayType', 'CLUTanim', 'displayProc', 'standard', ...
              'offscreen', 0, 'frames', 1, 'depth', 8, 'userfield',[],...
                          'clut_usage', [], 'clut_bg', [], 'clut', []};

  eval(['temp_dS = displaystruct(temp_dS_p);']);

  clear temp_dS_p temp_dS

end

if 0,  % periodicstim

   eval(['temp_ps = periodicstim(''default'');']);
   eval(['temp_ps = periodicscript(''default'');']);

   clear temp_ps temp_psps

end;

if 0,  % stochasticgridstim

   temp_SGSparams = struct ( 'BG', [1 1 1], 'dist', [1], 'values', [1 1 1], ...
                    'rect', [0 0 1 1], 'pixSize', [1 1] , 'N', 1, 'fps', 1, ...
                                        'randState', rand('state'));
   temp_SGSparams.dispprefs = {};

   eval(['temp_sgs  = stochasticgridstim(temp_SGSparams);']);

   clear temp_sgs temp_SGSparams

end;

if 0,  % polygonstim

   LBparams = struct('rect',[0 0 50 50],'shape',0,'points',[10 5],...
        'distance',57,'units',0,'orientation',45,...
        'howlong',5,'backdrop',[128 128 128],'background',[0 255 0],...
        'foreground',[255 0 0],'contrast',1,'remove',[0 0],...     
        'offsetxy',[0 0],'offsettheta',0,'smooth',2);
   LBparams.dispprefs = {};
   eval(['temp_pgs = polygonstim(LBparams);']);
   clear LBparams;

   clear temp_pgs;
end;

if 0,  % blinkingstim

   tempBLSp = struct('BG',[ 128 128 128 ],'value',[255 255 255],'random',1, ...
              'repeat',2,'bgpause',0,'fps',3,'rect',[0 0 1000 1000], ...
              'pixSize',[100 100],'randState',rand('state'));
   tempBLSp.dispprefs = {};

   eval(['tempBL = blinkingstim(tempBLSp);']);
   clear tempBL tempBLSp
end;

if 0, % centersurroundstim
   eval(['centersurroundstim(''default'');']);
end;

if 0, % shapemoviestim
	eval(['shapemoviestim(''default'');']);
end;

if 0, % movingdotsstim, still under development
	eval(['movingdotsstim(''default'');']);
end;

if 0, % wavound
	eval(['wavsound(''default'');']);	
end;

if 0, % blank
	eval(['blank(''default'');']);
end;

if 1, % stimscript
   eval(['temp_stimscript = stimscript(0);']);

   clear temp_stimscript;
end;

clear ans;
