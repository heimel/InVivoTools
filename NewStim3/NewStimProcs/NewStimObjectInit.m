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
	if d1(i).isdir && length(d1(i).name)>=2,
		if strcmp(d1(i).name(1),'@'),
			eval([d1(i).name(2:end) ';']);
		end;
	end;
end;

for i=1:length(d2),
	if d2(i).isdir && length(d2(i).name)>=2,
		if strcmp(d2(i).name(1),'@'),
			eval([d2(i).name(2:end) ';']);
		end;
	end;
end;

